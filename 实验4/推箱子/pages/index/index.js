// pages/index/index.js
Page({
  data: {
    levels: ['level01.png', 'level02.png', 'level03.png', 'level04.png'],
    maxLevel: 1,
    scores: {},      // { 0: 3, 1: 2, 2: 0, 3: 0 }
    steps: {},       // { 0: 8, 1: 12, 2: 0, 3: 0 }
    // 弹窗数据
    showModal: false,
    modalLevel: 0,
    modalStars: 0,
    modalSteps: 0
  },

  onLoad: function() {
    this.refreshData()
  },

  onShow: function() {
    this.refreshData()
  },

  refreshData: function() {
    let maxLevel = wx.getStorageSync('maxLevel') || 1
    let scores = {}
    let steps = {}
    for (let i = 0; i < 4; i++) {
      scores[i] = wx.getStorageSync('score_' + i) || 0
      steps[i] = wx.getStorageSync('steps_' + i) || 0
    }
    this.setData({
      maxLevel: maxLevel,
      scores: scores,
      steps: steps
    })
  },

  // 显示关卡详情弹窗
  showLevelDetail: function(e) {
    let level = e.currentTarget.dataset.level
    let levelNum = level + 1
    
    // 未解锁的关卡不能点击
    if (levelNum > this.data.maxLevel) {
      wx.showToast({
        title: '🔒 请先通关前面的关卡！',
        icon: 'none'
      })
      return
    }
    
    let stars = this.data.scores[level] || 0
    let stepCount = this.data.steps[level] || 0
    
    this.setData({
      showModal: true,
      modalLevel: level,
      modalStars: stars,
      modalSteps: stepCount
    })
  },

  // 关闭弹窗
  closeModal: function() {
    this.setData({ showModal: false })
  },

  // 开始游戏
  startGame: function() {
    let level = this.data.modalLevel
    this.setData({ showModal: false })
    wx.navigateTo({
      url: '/pages/game/game?level=' + level
    })
  },

  // 阻止弹窗背景滚动
  preventMove: function() {
    return false
  },

  // 重置所有进度（调试用）
  resetProgress: function() {
    wx.removeStorageSync('maxLevel')
    for (let i = 0; i < 4; i++) {
      wx.removeStorageSync('score_' + i)
      wx.removeStorageSync('steps_' + i)
    }
    this.refreshData()
    wx.showToast({ title: '已重置进度', icon: 'none' })
  }
})