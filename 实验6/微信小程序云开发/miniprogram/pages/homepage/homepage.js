const db = wx.cloud.database()
const photos = db.collection('photos')
var app = getApp()

Page({
  data: {
    photoList: [],
    userInfo: null,
    stats: {
      total: 0,
      hasDesc: 0,
      latestDate: '-'
    }
  },

  onShow: function() {
    if (!app.globalData.isLogin) {
      wx.reLaunch({ url: '/pages/login/login' })
      return
    }
    this.setData({ userInfo: app.globalData.userInfo })
    this.loadMyPhotos()
  },

  loadMyPhotos: function() {
    const openid = app.globalData.openid
    if (!openid) return

    wx.showLoading({ title: '加载中...' })
    photos.where({ _openid: openid })
      .orderBy('timestamp', 'desc')
      .get({
        success: res => {
          const list = res.data
          // 计算统计数据
          const stats = {
            total: list.length,
            hasDesc: list.filter(item => item.desc && item.desc.length > 0).length,
            latestDate: list.length > 0 ? list[0].addDate : '-'
          }
          this.setData({
            photoList: list,
            stats: stats
          })
          wx.hideLoading()
        },
        fail: () => {
          wx.hideLoading()
          wx.showToast({ title: '加载失败', icon: 'none' })
        }
      })
  },

  goToDetail: function(e) {
    const id = e.currentTarget.dataset.id
    wx.navigateTo({
      url: `/pages/detail/detail?id=${id}`
    })
  },

  deletePhoto: function(e) {
    const id = e.currentTarget.dataset.id
    const url = e.currentTarget.dataset.url

    wx.showModal({
      title: '确认删除',
      content: '确定要删除这张图片吗？',
      confirmColor: '#e74c3c',
      confirmText: '删除',
      success: res => {
        if (res.confirm) {
          this.doDelete(id, url)
        }
      }
    })
  },

  doDelete: function(id, url) {
    wx.showLoading({ title: '删除中...' })

    photos.doc(id).remove({
      success: () => {
        if (url && url.startsWith('cloud://')) {
          wx.cloud.deleteFile({
            fileList: [url],
            complete: () => {
              wx.hideLoading()
              this.afterDelete()
            }
          })
        } else {
          wx.hideLoading()
          this.afterDelete()
        }
      },
      fail: () => {
        wx.hideLoading()
        wx.showToast({ title: '删除失败', icon: 'none' })
      }
    })
  },

  afterDelete: function() {
    wx.showToast({ title: '已删除 ✅', icon: 'success' })
    this.loadMyPhotos()
    const pages = getCurrentPages()
    const idx = pages.find(p => p.route === 'pages/index/index')
    if (idx && idx.loadPhotoList) {
      idx.loadPhotoList()
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
  }
})