// pages/index/index.js
var common = require('../../utils/common.js');

Page({
  data: {
    categories: [],
    currentCategory: '综合新闻',
    swiperImg: [
      { src: 'https://news.ouc.edu.cn/_upload/tpl/00/73/115/template115/images/default_img.jpg' },
      { src: 'https://news.ouc.edu.cn/_upload/article/images/b2/2a/87bd3a7449dc9526d47b577fa2b8/c2645e85-9148-4e68-8047-c19ffa5b517b.png' },
      { src: 'https://news.ouc.edu.cn/_upload/article/images/63/6c/49238d3d4e91a77a92fc2af1e836/0fe3cfad-ae2c-4264-9b0f-33f5dc429a51.jpg' },
      { src: 'https://news.ouc.edu.cn/_upload/article/images/0f/d0/8a2b106241a4950bab7b10c8b053/b768ebf2-9cfb-4111-8f02-f5e34303b565.png' }
    ],
    newsList: []
  },

  onLoad: function() {
    var categories = common.getCategories();
    this.setData({
      categories: categories
    });
    this.loadNews('综合新闻');
  },

  // 切换分类
  switchCategory: function(e) {
    var category = e.currentTarget.dataset.category;
    console.log('点击切换分类:', category);
    
    // 如果点击的是当前分类，不做处理
    if (category === this.data.currentCategory) {
      return;
    }
    
    this.setData({
      currentCategory: category
    });
    
    this.loadNews(category);
  },

  loadNews: function(category) {
    wx.showLoading({
      title: '加载中...',
    });
    
    try {
      var list = common.getNewsByCategory(category);
      console.log('分类 ' + category + ' 的新闻数量:', list.length);
      
      this.setData({
        newsList: list || []
      });
    } catch (e) {
      console.error('加载新闻失败:', e);
      this.setData({
        newsList: []
      });
    } finally {
      wx.hideLoading();
    }
  },

  goToDetail: function(e) {
    var id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: '../detail/detail?id=' + id,
    });
  }
});