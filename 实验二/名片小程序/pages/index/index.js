// index.js
Page({
  data: {
    show1: false,
    show2: false,
    show3: false,
    show4: false
  },

  tap(e) {
    const id = e.currentTarget.dataset.id;
    const map = {
      'a1': 'show1',
      'a2': 'show2',
      'a3': 'show3',
      'a4': 'show4'
    };
    const key = map[id];
    if (!key) return;

    const now = this.data[key];
    this.setData({
      [key]: !now
    });
  }
});