const db = wx.cloud.database()
const photos = db.collection('photos')
var app = getApp()

Page({
  data: {
    photoList: [],
    isLogin: false,
    userInfo: null
  },

  onShow: function() {
    const isLogin = app.globalData.isLogin
    const userInfo = app.globalData.userInfo

    if (!isLogin) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }

    this.setData({ isLogin, userInfo })
    this.loadPhotoList()
  },

  // 按时间戳倒序：最新的在最上面（4321的顺序）
  loadPhotoList: function() {
    wx.showLoading({ title: '加载中...' })
    photos.orderBy('timestamp', 'desc').get({
      success: res => {
        this.setData({ photoList: res.data })
        wx.hideLoading()
      },
      fail: () => {
        wx.hideLoading()
        wx.showToast({ title: '加载失败', icon: 'none' })
      }
    })
  },

  goToAdd: function() {
    wx.navigateTo({ url: '/pages/add/add' })
  },

  goToProfile: function() {
    wx.switchTab({ url: '/pages/homepage/homepage' })
  },

  goToDetail: function(e) {
    const id = e.currentTarget.dataset.id
    if (id) {
      wx.navigateTo({
        url: `/pages/detail/detail?id=${id}`
      })
    }
  },

  handleLogout: function() {
    wx.showModal({
      title: '确认退出',
      content: '确定要退出登录吗？',
      confirmColor: '#e74c3c',
      confirmText: '退出',
      success: (res) => {
        if (res.confirm) {
          app.globalData.isLogin = false
          app.globalData.userInfo = null
          app.globalData.openid = null
          wx.removeStorageSync('userInfo')
          wx.removeStorageSync('isLogin')
          wx.removeStorageSync('loginFormData')

          wx.showToast({
            title: '已退出',
            icon: 'success'
          })

          setTimeout(() => {
            wx.reLaunch({
              url: '/pages/login/login'
            })
          }, 500)
        }
      }
    })
  },

  onPullDownRefresh: function() {
    this.loadPhotoList()
    wx.stopPullDownRefresh()
  }
})