App({
  onLaunch: function() {
    if (!wx.cloud) {
      console.error('请使用2.2.3或以上的基础库以使用云能力')
    } else {
      wx.cloud.init({
        traceUser: true,
      })
    }

    const isLogin = wx.getStorageSync('isLogin') || false
    const userInfo = wx.getStorageSync('userInfo') || null

    this.globalData = {
      userInfo: userInfo,
      openid: userInfo ? userInfo.openid : null,
      isLogin: isLogin
    }
  },

  globalData: {
    userInfo: null,
    openid: null,
    isLogin: false
  }
})