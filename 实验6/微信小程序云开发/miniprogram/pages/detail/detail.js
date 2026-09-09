const db = wx.cloud.database()
const photos = db.collection('photos')

Page({
  data: {
    photo: null
  },

  onLoad: function(options) {
    console.log('详情页接收参数:', options)

    if (!options || !options.id) {
      wx.showToast({
        title: '参数错误',
        icon: 'none'
      })
      return
    }

    wx.showLoading({
      title: '加载中...'
    })

    photos.doc(options.id).get({
      success: res => {
        console.log('获取图片成功:', res.data)
        this.setData({ photo: res.data })
        wx.hideLoading()
      },
      fail: err => {
        console.error('获取图片失败:', err)
        wx.hideLoading()
        wx.showToast({
          title: '加载失败',
          icon: 'none'
        })
      }
    })
  },

  // 下载图片
  downloadPhoto: function() {
    if (!this.data.photo) {
      wx.showToast({ title: '图片信息错误', icon: 'none' })
      return
    }

    wx.showLoading({
      title: '下载中...'
    })

    wx.cloud.downloadFile({
      fileID: this.data.photo.photoUrl,
      success: res => {
        wx.saveImageToPhotosAlbum({
          filePath: res.tempFilePath,
          success: () => {
            wx.hideLoading()
            wx.showToast({
              title: '保存成功',
              icon: 'success'
            })
          },
          fail: () => {
            wx.hideLoading()
            wx.showToast({
              title: '请授权保存相册',
              icon: 'none'
            })
          }
        })
      },
      fail: err => {
        console.error('下载失败:', err)
        wx.hideLoading()
        wx.showToast({
          title: '下载失败',
          icon: 'none'
        })
      }
    })
  },

  // 全屏预览
  previewPhoto: function() {
    if (!this.data.photo) {
      wx.showToast({ title: '图片信息错误', icon: 'none' })
      return
    }
    wx.previewImage({
      urls: [this.data.photo.photoUrl],
      current: this.data.photo.photoUrl
    })
  },

  // 分享
  onShareAppMessage: function() {
    if (!this.data.photo) {
      return {
        title: '分享一张图片',
        path: 'pages/index/index'
      }
    }
    return {
      title: `${this.data.photo.nickName} 分享了一张图片`,
      path: `pages/detail/detail?id=${this.data.photo._id}`,
      imageUrl: this.data.photo.photoUrl
    }
  }
})