// index.js
const app = getApp()
Page({
  data: {
    wording: 'girl'
  },
  onClick: function() {
    const newWording = this.data.wording === 'girl' ? 'boy' : 'girl';
    this.setData({
      wording: newWording
    });
  }
})