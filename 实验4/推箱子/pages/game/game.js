// pages/game/game.js
var data = require('../../utils/data.js')

// 全局变量
var map = []
var box = []
var w = 40
var row = 0
var col = 0
var steps = 0
var history = []

// 星级标准
var starConfigs = [
  { star3: 55, star2: 70 },
  { star3: 15, star2: 25 },
  { star3: 25, star2: 40 },
  { star3: 30, star2: 45 }
]

Page({
  data: {
    level: 0,
    levelIndex: 0,
    steps: 0,
    stars: 0,
    isGameOver: false,
    maxLevel: 1,
    showWinModal: false,
    winStars: 0,
    winSteps: 0,
    winComment: '',
    levelScores: {},
    levelSteps: {}
  },

  onLoad: function(options) {
    let levelIndex = parseInt(options.level)
    let levelNum = levelIndex + 1
    
    let maxLevel = wx.getStorageSync('maxLevel') || 1
    
    if (levelNum > maxLevel) {
      wx.showToast({
        title: '请先通关前面的关卡！',
        icon: 'none'
      })
      setTimeout(() => {
        wx.navigateBack()
      }, 1500)
      return
    }
    
    let levelScores = {}
    let levelSteps = {}
    for (let i = 0; i < 4; i++) {
      levelScores[i] = wx.getStorageSync('score_' + i) || 0
      levelSteps[i] = wx.getStorageSync('steps_' + i) || 0
    }
    
    this.setData({
      level: levelNum,
      levelIndex: levelIndex,
      steps: 0,
      maxLevel: maxLevel,
      isGameOver: false,
      showWinModal: false,
      levelScores: levelScores,
      levelSteps: levelSteps
    })
    steps = 0
    history = []
    
    // 初始化画布上下文（旧版 API）
    this.ctx = wx.createCanvasContext('myCanvas')
    
    this.initMap(levelIndex)
    this.drawCanvas()
    
    // 显示加载提示
    wx.showLoading({
      title: '加载中...',
      mask: true
    })
    
    // 延迟隐藏加载提示，确保图片加载完成
    setTimeout(() => {
      wx.hideLoading()
    }, 500)
  },

  initMap: function(levelIndex) {
    let mapData = data.maps[levelIndex]
    for (var i = 0; i < 8; i++) {
      map[i] = []
      box[i] = []
      for (var j = 0; j < 8; j++) {
        box[i][j] = 0
        map[i][j] = mapData[i][j]
        if (mapData[i][j] == 4) {
          box[i][j] = 4
          map[i][j] = 2
        } else if (mapData[i][j] == 5) {
          map[i][j] = 2
          row = i
          col = j
        }
      }
    }
    this.saveHistory()
  },

  saveHistory: function() {
    let mapCopy = map.map(arr => [...arr])
    let boxCopy = box.map(arr => [...arr])
    history.push({
      map: mapCopy,
      box: boxCopy,
      row: row,
      col: col,
      steps: steps
    })
    if (history.length > 100) {
      history.shift()
    }
  },

  // 绘制地图（旧版 API）
  drawCanvas: function() {
    if (this.data.showWinModal) {
      return
    }
    
    let ctx = this.ctx
    if (!ctx) {
      this.ctx = wx.createCanvasContext('myCanvas')
      ctx = this.ctx
    }
    
    ctx.clearRect(0, 0, 320, 320)
    
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        let img = 'ice'
        if (map[i][j] == 1) {
          img = 'stone'
        } else if (map[i][j] == 3) {
          img = 'pig'
        }
        ctx.drawImage('/images/icons/' + img + '.png', j * w, i * w, w, w)
        if (box[i][j] == 4) {
          ctx.drawImage('/images/icons/box.png', j * w, i * w, w, w)
        }
      }
    }
    ctx.drawImage('/images/icons/bird.png', col * w, row * w, w, w)
    ctx.draw()
  },

  addStep: function() {
    steps++
    this.setData({
      steps: steps
    })
    this.saveHistory()
  },

  tryMove: function(dRow, dCol) {
    if (this.data.isGameOver || this.data.showWinModal) return
    
    let newRow = row + dRow
    let newCol = col + dCol
    
    if (newRow < 0 || newRow > 7 || newCol < 0 || newCol > 7) return
    if (map[newRow][newCol] == 1) return
    
    if (box[newRow][newCol] == 4) {
      let boxRow = newRow + dRow
      let boxCol = newCol + dCol
      if (boxRow < 0 || boxRow > 7 || boxCol < 0 || boxCol > 7) return
      if (map[boxRow][boxCol] == 1) return
      if (box[boxRow][boxCol] == 4) return
      
      box[boxRow][boxCol] = 4
      box[newRow][newCol] = 0
      row = newRow
      col = newCol
      this.addStep()
      this.drawCanvas()
      this.checkWin()
      return
    }
    
    row = newRow
    col = newCol
    this.addStep()
    this.drawCanvas()
  },

  up: function() { this.tryMove(-1, 0) },
  down: function() { this.tryMove(1, 0) },
  left: function() { this.tryMove(0, -1) },
  right: function() { this.tryMove(0, 1) },

  undo: function() {
    if (this.data.showWinModal) return
    if (history.length <= 1) {
      wx.showToast({ title: '没有上一步了', icon: 'none' })
      return
    }
    history.pop()
    let prev = history[history.length - 1]
    map = prev.map.map(arr => [...arr])
    box = prev.box.map(arr => [...arr])
    row = prev.row
    col = prev.col
    steps = prev.steps
    this.setData({
      steps: steps,
      isGameOver: false
    })
    this.drawCanvas()
  },

  isWin: function() {
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        if (box[i][j] == 4 && map[i][j] != 3) {
          return false
        }
      }
    }
    return true
  },

  getStars: function(levelIndex) {
    var config = starConfigs[levelIndex] || { star3: 15, star2: 25 }
    if (steps <= config.star3) return 3
    if (steps <= config.star2) return 2
    return 1
  },

  getComment: function(stars) {
    if (stars === 3) return '🌟 完美通关！太厉害了！'
    if (stars === 2) return '👍 表现不错！再接再厉！'
    return '💪 继续加油！争取更高分！'
  },

  checkWin: function() {
    if (this.isWin()) {
      let levelIndex = this.data.levelIndex
      let stars = this.getStars(levelIndex)
      let comment = this.getComment(stars)
      
      let scoreKey = 'score_' + levelIndex
      let oldScore = wx.getStorageSync(scoreKey) || 0
      if (stars > oldScore) {
        wx.setStorageSync(scoreKey, stars)
      }
      
      let stepsKey = 'steps_' + levelIndex
      let oldSteps = wx.getStorageSync(stepsKey) || 9999
      if (steps < oldSteps) {
        wx.setStorageSync(stepsKey, steps)
      }
      
      let levelScores = this.data.levelScores
      let levelSteps = this.data.levelSteps
      levelScores[levelIndex] = Math.max(levelScores[levelIndex] || 0, stars)
      levelSteps[levelIndex] = Math.min(levelSteps[levelIndex] || 9999, steps)
      
      let maxLevel = wx.getStorageSync('maxLevel') || 1
      if (this.data.level + 1 > maxLevel) {
        wx.setStorageSync('maxLevel', this.data.level + 1)
        this.setData({ maxLevel: this.data.level + 1 })
      }
      
      this.setData({
        isGameOver: true,
        showWinModal: true,
        winStars: stars,
        winSteps: steps,
        winComment: comment,
        levelScores: levelScores,
        levelSteps: levelSteps
      })
      
      // 清空画布
      this.ctx.clearRect(0, 0, 320, 320)
      this.ctx.draw()
    }
  },

  onRestart: function() {
    this.setData({ showWinModal: false })
    this.restartGame()
  },

  onNextLevel: function() {
    this.setData({ showWinModal: false })
    let nextLevel = this.data.levelIndex + 1
    let maxLevel = wx.getStorageSync('maxLevel') || 1
    
    if (nextLevel + 1 > maxLevel) {
      wx.showToast({
        title: '🎉 所有关卡已通关！',
        icon: 'none'
      })
      setTimeout(() => {
        wx.navigateBack()
      }, 1000)
      return
    }
    
    wx.redirectTo({
      url: '/pages/game/game?level=' + nextLevel
    })
  },

  onHome: function() {
    this.setData({ showWinModal: false })
    wx.navigateBack()
  },

  restartGame: function() {
    let levelIndex = this.data.levelIndex
    steps = 0
    history = []
    this.setData({
      steps: 0,
      isGameOver: false,
      showWinModal: false,
      stars: 0
    })
    this.initMap(levelIndex)
    this.drawCanvas()
    wx.showToast({ title: '已重新开始', icon: 'none' })
  },

  goHome: function() {
    wx.navigateBack()
  }
})