// pages/my/my.js
var common = require('../../utils/common.js');

// 默认头像
const defaultAvatarUrl = 'https://mmbiz.qpic.cn/mmbiz/icTdbqWNwNRna42FI242Lcia07jQodd2FJGIYQF6OLAJGFxM4FbnQP6yfMxBgjE/0';

Page({
  data: {
    isLogin: false,
    src: '',
    nickName: '',
    avatarUrl: defaultAvatarUrl,
    tempAvatar: '',
    tempNickName: '',
    newsList: [],
    number: 0
  },

  onChooseAvatar: function(e) {
    console.log('========== 选择头像 ==========');
    const { avatarUrl } = e.detail;
    console.log('✅ 选择的头像:', avatarUrl);
    
    this.setData({
      avatarUrl: avatarUrl,
      tempAvatar: avatarUrl
    });
    
    wx.vibrateShort({ type: 'light' });
  },

  onNicknameChange: function(e) {
    console.log('========== 昵称输入 ==========');
    this.setData({
      tempNickName: e.detail.value
    });
  },

  submitLogin: function() {
    var that = this;
    
    var avatar = this.data.tempAvatar;
    var nickName = this.data.tempNickName.trim();
    
    if (!avatar || avatar === defaultAvatarUrl) {
      wx.showToast({
        title: '请选择头像 🖼️',
        icon: 'none',
        duration: 1500
      });
      return;
    }
    
    if (!nickName) {
      wx.showToast({
        title: '请输入昵称 ✏️',
        icon: 'none',
        duration: 1500
      });
      return;
    }
    
    wx.showLoading({
      title: '登录中...',
      mask: true
    });
    
    wx.login({
      success: function(loginRes) {
        wx.hideLoading();
        console.log('✅ wx.login 成功:', loginRes);
        
        var userInfo = {
          nickName: nickName,
          avatarUrl: avatar,
          loginTime: new Date().toLocaleString()
        };
        
        wx.setStorageSync('userInfo', userInfo);
        
        that.setData({
          isLogin: true,
          src: avatar,
          nickName: nickName
        });
        
        wx.showToast({
          title: '🎉 登录成功',
          icon: 'success',
          duration: 2000
        });
        
        that.getMyFavorites();
      },
      fail: function(err) {
        wx.hideLoading();
        console.error('❌ wx.login 失败:', err);
        wx.showToast({
          title: '登录失败，请重试',
          icon: 'none'
        });
      }
    });
  },

  logout: function() {
    var that = this;
    
    wx.showModal({
      title: '提示',
      content: '确定要退出登录吗？',
      confirmColor: '#328EEB',
      confirmText: '确定退出',
      cancelText: '取消',
      success: function(res) {
        if (res.confirm) {
          wx.removeStorageSync('userInfo');
          
          that.setData({
            isLogin: false,
            src: '',
            nickName: '',
            avatarUrl: defaultAvatarUrl,
            tempAvatar: '',
            tempNickName: '',
            newsList: [],
            number: 0
          });
          
          wx.showToast({
            title: '已退出',
            icon: 'success'
          });
        }
      }
    });
  },

  getMyFavorites: function() {
    try {
      var allNews = common.getNewsList();
      var info = wx.getStorageInfoSync();
      var keys = info.keys;
      
      var myList = [];
      var collectCount = 0;
      
      for (var i = 0; i < allNews.length; i++) {
        var newsId = allNews[i].id;
        if (keys.indexOf(newsId) !== -1) {
          var newsData = wx.getStorageSync(newsId);
          if (newsData && newsData.id && newsData.title) {
            myList.push(newsData);
            collectCount++;
          }
        }
      }
      
      this.setData({
        newsList: myList,
        number: collectCount
      });
      
    } catch (e) {
      console.error('❌ 获取收藏列表失败:', e);
      this.setData({
        newsList: [],
        number: 0
      });
    }
  },

  onShow: function() {
    console.log('📱 my页面显示');
    
    try {
      var userInfo = wx.getStorageSync('userInfo');
      if (userInfo && userInfo.nickName) {
        this.setData({
          isLogin: true,
          src: userInfo.avatarUrl || '',
          nickName: userInfo.nickName || ''
        });
        this.getMyFavorites();
      } else {
        this.setData({
          isLogin: false,
          newsList: [],
          number: 0
        });
      }
    } catch (e) {
      console.error('❌ 读取用户信息失败:', e);
    }
  },

  goToDetail: function(e) {
    var id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({
      url: '../detail/detail?id=' + id,
    });
  },

  goToIndex: function() {
    wx.switchTab({
      url: '/pages/index/index'
    });
  }
});