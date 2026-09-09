var app = getApp()

Page({
  data: {
    userAvatar: '',
    nickname: '',
    location: '',
    gender: '保密',
    isFormValid: false,
    isLogging: false
  },

  onLoad: function(options) {
    // 检查是否已登录
    if (app.globalData.isLogin) {
      wx.switchTab({
        url: '/pages/index/index'
      })
    }

    // 检查云开发
    if (!wx.cloud) {
      wx.showModal({
        title: '错误',
        content: '云开发未初始化，请检查网络',
        showCancel: false
      })
    }

    // 检查是否有缓存的表单数据
    const cachedUser = wx.getStorageSync('loginFormData')
    if (cachedUser) {
      this.setData({
        userAvatar: cachedUser.avatar || '',
        nickname: cachedUser.nickname || '',
        location: cachedUser.location || '',
        gender: cachedUser.gender || '保密'
      })
      this.checkFormValid()
    }
  },

  // 选择头像
  chooseAvatar: function() {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: (res) => {
        const tempFilePath = res.tempFilePaths[0]
        this.setData({
          userAvatar: tempFilePath
        })
        this.saveFormData()
        this.checkFormValid()
      },
      fail: (err) => {
        console.error('选择图片失败:', err)
        wx.showToast({
          title: '选择图片失败',
          icon: 'none'
        })
      }
    })
  },

  // 输入昵称
  onNicknameInput: function(e) {
    this.setData({
      nickname: e.detail.value
    })
    this.saveFormData()
    this.checkFormValid()
  },

  // 选择位置
  chooseLocation: function() {
    wx.chooseLocation({
      success: (res) => {
        let location = res.address || res.name || ''
        if (!location) {
          location = `${res.latitude},${res.longitude}`
        }
        this.setData({
          location: location
        })
        this.saveFormData()
        this.checkFormValid()
      },
      fail: (err) => {
        console.error('选择位置失败:', err)
        wx.showToast({
          title: '请允许获取位置权限',
          icon: 'none',
          duration: 2000
        })
      }
    })
  },

  // 选择性别
  selectGender: function(e) {
    this.setData({
      gender: e.currentTarget.dataset.gender
    })
    this.saveFormData()
    this.checkFormValid()
  },

  // 验证表单是否完整
  checkFormValid: function() {
    const { userAvatar, nickname, location } = this.data
    this.setData({
      isFormValid: !!(userAvatar && nickname && nickname.trim() && location)
    })
  },

  // 保存表单数据到缓存
  saveFormData: function() {
    try {
      wx.setStorageSync('loginFormData', {
        avatar: this.data.userAvatar,
        nickname: this.data.nickname,
        location: this.data.location,
        gender: this.data.gender
      })
    } catch (e) {
      console.error('保存缓存失败:', e)
    }
  },

  // 登录处理
  handleLogin: function() {
    if (this.data.isLogging) return

    if (!this.data.isFormValid) {
      wx.showToast({
        title: '请完善所有信息',
        icon: 'none'
      })
      return
    }

    this.setData({ isLogging: true })
    wx.showLoading({
      title: '登录中...',
      mask: true
    })

    console.log('开始调用云函数 getOpenid')

    wx.cloud.callFunction({
      name: 'getOpenid',
      success: (res) => {
        console.log('云函数调用成功:', res)
        const openid = res.result.openid

        if (!openid) {
          wx.hideLoading()
          this.setData({ isLogging: false })
          wx.showToast({
            title: '获取用户ID失败，请重试',
            icon: 'none'
          })
          return
        }

        console.log('获取到openid:', openid)

        // 判断头像类型
        if (this.data.userAvatar && this.data.userAvatar.startsWith('http')) {
          this.doLogin(openid, this.data.userAvatar)
        } else if (this.data.userAvatar) {
          this.uploadAvatarAndLogin(openid)
        } else {
          this.doLogin(openid, 'https://thirdwx.qlogo.cn/mmopen/vi_32/POgEwh4mIHO4nibH0KlMECNjjGxQUq24ZEaGT4poC6icRiccVGKSyXwibcPq4BWmiaIGuG1icwxaQX6grC9VemZoJ8rg/132')
        }
      },
      fail: (err) => {
        console.error('云函数调用失败:', err)
        wx.hideLoading()
        this.setData({ isLogging: false })

        let errorMsg = '获取用户信息失败'
        if (err.errMsg) {
          errorMsg = err.errMsg
        }

        wx.showModal({
          title: '登录失败',
          content: `错误信息：${errorMsg}\n\n请检查：\n1. 网络是否正常\n2. 云函数是否已部署\n3. 云开发环境ID是否正确`,
          showCancel: false,
          confirmText: '我知道了'
        })
      }
    })
  },

  // 上传头像到云存储
  uploadAvatarAndLogin: function(openid) {
    const timestamp = Date.now()
    const cloudPath = `avatars/${openid}_${timestamp}.jpg`

    console.log('开始上传头像:', cloudPath)

    wx.cloud.uploadFile({
      cloudPath: cloudPath,
      filePath: this.data.userAvatar,
      success: (res) => {
        console.log('头像上传成功:', res)
        this.doLogin(openid, res.fileID)
      },
      fail: (err) => {
        console.error('头像上传失败:', err)
        wx.hideLoading()
        this.setData({ isLogging: false })
        wx.showToast({
          title: '头像上传失败，请重试',
          icon: 'none'
        })
      }
    })
  },

  // 执行登录
  doLogin: function(openid, avatarUrl) {
    console.log('执行登录, openid:', openid)

    const userInfo = {
      openid: openid,
      avatarUrl: avatarUrl || 'https://thirdwx.qlogo.cn/mmopen/vi_32/POgEwh4mIHO4nibH0KlMECNjjGxQUq24ZEaGT4poC6icRiccVGKSyXwibcPq4BWmiaIGuG1icwxaQX6grC9VemZoJ8rg/132',
      nickName: this.data.nickname.trim(),
      province: this.data.location || '未知',
      country: this.data.gender || '保密',
      gender: this.data.gender || '保密',
      loginTime: new Date().toLocaleString()
    }

    // 保存到全局
    app.globalData.openid = openid
    app.globalData.userInfo = userInfo
    app.globalData.isLogin = true

    // 保存到本地缓存
    try {
      wx.setStorageSync('userInfo', userInfo)
      wx.setStorageSync('isLogin', true)
      // 登录成功后清除表单缓存
      wx.removeStorageSync('loginFormData')
    } catch (e) {
      console.error('保存缓存失败:', e)
    }

    wx.hideLoading()
    this.setData({ isLogging: false })

    wx.showToast({
      title: '登录成功！🎉',
      icon: 'success',
      duration: 1500
    })

    // 跳转到首页
    setTimeout(() => {
      wx.switchTab({
        url: '/pages/index/index',
        fail: (err) => {
          console.error('跳转失败:', err)
          wx.reLaunch({
            url: '/pages/index/index'
          })
        }
      })
    }, 1500)
  }
})