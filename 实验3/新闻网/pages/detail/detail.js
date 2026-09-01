// pages/detail/detail.js
var common = require('../../utils/common.js');

Page({
  data: {
    isLogin: false,
    article: {
      id: '',
      title: '',
      poster: '',
      content: '',
      add_date: '',
      category: ''
    },
    isAdd: false
  },

  onLoad: function(options) {
    console.log('详情页参数:', options);
    
    this.checkLoginStatus();
    
    let id = options.id;
    if (!id) {
      wx.showToast({
        title: '参数错误',
        icon: 'none'
      });
      return;
    }

    var newarticle = wx.getStorageSync(id);
    
    if (newarticle != '') {
      console.log('从收藏夹读取新闻:', newarticle);
      this.setData({
        isAdd: true,
        article: newarticle
      });
    } else {
      let result = common.getNewsDetail(id);
      console.log('从数据源获取新闻:', result);
      
      if (result.code == '200') {
        this.setData({
          article: result.news,
          isAdd: false
        });
      } else {
        wx.showToast({
          title: '新闻不存在',
          icon: 'none'
        });
      }
    }
  },

  // ============================================================
  // 检查登录状态
  // ============================================================
  checkLoginStatus: function() {
    try {
      var userInfo = wx.getStorageSync('userInfo');
      if (userInfo && userInfo.nickName) {
        this.setData({
          isLogin: true
        });
      } else {
        this.setData({
          isLogin: false
        });
      }
    } catch (e) {
      this.setData({
        isLogin: false
      });
    }
  },

  // ============================================================
  // 跳转到登录页
  // ============================================================
  goToLogin: function() {
    wx.showModal({
      title: '提示',
      content: '收藏需要先登录，是否前往登录？',
      confirmText: '去登录',
      confirmColor: '#328EEB',
      cancelText: '取消',
      success: function(res) {
        if (res.confirm) {
          wx.switchTab({
            url: '/pages/my/my'
          });
        }
      }
    });
  },

  // ============================================================
  // 添加收藏
  // ============================================================
  addFavorites: function() {
    if (!this.data.isLogin) {
      this.goToLogin();
      return;
    }
    
    let article = this.data.article;
    wx.setStorageSync(article.id, article);
    this.setData({
      isAdd: true
    });
    
    wx.showToast({
      title: '收藏成功',
      icon: 'success',
      duration: 1500
    });
    
    wx.vibrateShort({
      type: 'light'
    });
  },

  // ============================================================
  // 取消收藏
  // ============================================================
  cancelFavorites: function() {
    let article = this.data.article;
    wx.removeStorageSync(article.id);
    this.setData({
      isAdd: false
    });
    
    wx.showToast({
      title: '已取消收藏',
      icon: 'success',
      duration: 1500
    });
    
    wx.vibrateShort({
      type: 'light'
    });
  },

  // ============================================================
  // 返回上一页
  // ============================================================
  goBack: function() {
    wx.navigateBack({
      delta: 1,
      fail: function() {
        wx.switchTab({
          url: '/pages/index/index'
        });
      }
    });
  },

  // ============================================================
  // 分享文章
  // ============================================================
  onShareAppMessage: function() {
    let article = this.data.article;
    return {
      title: article.title || '海大新闻',
      path: '/pages/detail/detail?id=' + article.id,
      imageUrl: article.poster || ''
    };
  },

  onShareTimeline: function() {
    let article = this.data.article;
    return {
      title: article.title || '海大新闻',
      query: 'id=' + article.id,
      imageUrl: article.poster || ''
    };
  }
});