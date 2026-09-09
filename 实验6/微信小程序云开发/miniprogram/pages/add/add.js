const db = wx.cloud.database()
const photos = db.collection('photos')
var app = getApp()

// 格式化日期显示（仅用于展示）
function formatDateDisplay() {
  const d = new Date()
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return y + '-' + m + '-' + day
}

Page({
  data: {
    tempImage: '',
    desc: '',
    location: '',
    isUploading: false
  },

  onLoad: function() {
    if (!app.globalData.isLogin) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    if (app.globalData.userInfo && app.globalData.userInfo.province) {
      this.setData({ location: app.globalData.userInfo.province })
    }
  },

  chooseImage: function() {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['album', 'camera'],
      success: (res) => {
        this.setData({ tempImage: res.tempFilePaths[0] })
      }
    })
  },

  removeImage: function() {
    this.setData({ tempImage: '' })
  },

  onDescInput: function(e) {
    this.setData({ desc: e.detail.value })
  },

  chooseLocation: function() {
    wx.chooseLocation({
      success: (res) => {
        let location = res.address || res.name || ''
        if (!location) {
          location = `${res.latitude},${res.longitude}`
        }
        this.setData({ location: location })
      }
    })
  },

  submitUpload: function() {
    if (this.data.isUploading) return
    if (!this.data.tempImage) {
      wx.showToast({ title: '请先选择图片', icon: 'none' })
      return
    }

    const userInfo = app.globalData.userInfo
    this.setData({ isUploading: true })
    wx.showLoading({ title: '发布中...', mask: true })

    const cloudPath = `photos/${Date.now()}_${Math.floor(Math.random() * 10000)}.jpg`

    wx.cloud.uploadFile({
      cloudPath: cloudPath,
      filePath: this.data.tempImage,
      success: (uploadRes) => {
        const now = Date.now()  // 时间戳，用于排序
        const dateStr = formatDateDisplay()  // 仅用于显示

        photos.add({
          data: {
            photoUrl: uploadRes.fileID,
            avatarUrl: userInfo.avatarUrl || '',
            nickName: userInfo.nickName || '用户',
            province: userInfo.province || '未知',
            country: userInfo.country || '保密',
            addDate: dateStr,        // 显示用：2026-09-08
            timestamp: now,          // 排序用：数字时间戳
            desc: this.data.desc || '',
            location: this.data.location || ''
          },
          success: () => {
            wx.hideLoading()
            this.setData({ isUploading: false, tempImage: '', desc: '' })
            wx.showToast({ title: '发布成功 🎉', icon: 'success' })
            
            const pages = getCurrentPages()
            const idx = pages.find(p => p.route === 'pages/index/index')
            if (idx && idx.loadPhotoList) {
              idx.loadPhotoList()
            }
            setTimeout(() => wx.switchTab({ url: '/pages/index/index' }), 800)
          },
          fail: () => {
            wx.hideLoading()
            this.setData({ isUploading: false })
            wx.showToast({ title: '发布失败', icon: 'none' })
          }
        })
      },
      fail: () => {
        wx.hideLoading()
        this.setData({ isUploading: false })
        wx.showToast({ title: '上传失败', icon: 'none' })
      }
    })
  }
})