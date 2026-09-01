// app.js
App({
  globalData: {
    userInfo: null,
    isLogin: false
  },

  onLaunch: function() {
    // 检查本地是否有用户信息
    try {
      var userInfo = wx.getStorageSync('userInfo');
      if (userInfo && userInfo.nickName) {
        this.globalData.userInfo = userInfo;
        this.globalData.isLogin = true;
      }
    } catch (e) {
      console.error('读取用户信息失败:', e);
    }
  },

  // 设置用户信息
  setUserInfo: function(userInfo) {
    this.globalData.userInfo = userInfo;
    this.globalData.isLogin = true;
    wx.setStorageSync('userInfo', userInfo);
  },

  // 清除用户信息
  clearUserInfo: function() {
    this.globalData.userInfo = null;
    this.globalData.isLogin = false;
    wx.removeStorageSync('userInfo');
  }
});