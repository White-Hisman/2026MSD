// utils/common.js

// 模拟新闻数据 - 添加分类字段
const news = [
  // ===== 综合新闻 =====
  {
    id: '264698',
    title: '学校2026年度国家自然科学基金再创佳绩',
    poster: 'https://news.ouc.edu.cn/_upload/tpl/00/73/115/template115/images/default_img.jpg',
    content: '2026年国家自然科学基金集中接收期项目评审结果日前公布。本年度集中接收期，学校共申报各类项目1110项，全部通过形式审查，连续多年实现“零初筛”。截至目前，共获批各类项目281项，同比增长33.2%，获批直接经费1.75亿元（总经费约2.2亿元），同比增长48.3%，各项指标大幅提升，再创历史新高，为学校“十五五”高质量发展提供有力支撑。',
    add_date: '2026-08-27',
    category: '综合新闻'
  },
  {
    id: '264699',
    title: '中国海洋大学参加2026山东省教育博览会',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/4c/43/16200dfc4105a419b576e303927a/1cdc48e7-7106-4cdb-be6b-2920ce34387e.jpg',
    content: ' 8月21日至23日，2026山东省教育博览会在山东国际会展中心举办，省委常委、统战部部长邓云锋，省人大常委会副主任王随莲，省政协副主席、党组成员宋永祥参观展区。省委教育工委常务副书记，省教育厅党组书记、厅长陈必昌，济南市副市长、市政府党组成员任广锋陪同有关活动。中国海洋大学参加教育高质量发展成果展，学校党委常委、副校长李岩作为嘉宾出席展会相关活动。',
    add_date: '2026-08-26',
    category: '综合新闻'
  },
  {
    id: '264700',
    title: '2026海峡两岸大学生海洋文化交流活动在中国海洋大学开营',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/50/25/b4f8203141ba8644e5ff29cb8033/3e378710-ecc1-4c77-8d12-092f8d8085ec.jpg',
    content: ' 8月22日上午，由中国海洋大学主办的“2026海峡两岸大学生海洋文化交流活动”开营仪式在鱼山校区举行。来自台湾海洋大学、台湾政治大学等高校机构、协会的30名师生和来自学校的19名师生参加。台湾事务办公室副主任刘泰对台湾师生的到来表示欢迎。他表示，学校自2005年首次举办海峡两岸大学生海洋文化交流活动以来，今年已举办至第十七届，为促进两岸青年师生交流合作发挥了积极作用。希望本届海峡两岸海洋文化交流活动的师生能领略青岛滨海城市的独特魅力、感悟齐鲁文化的深厚底蕴、体悟两岸同根同源的文化底色，期待交流互鉴取得良好成效。',
    add_date: '2026-08-24',
    category: '综合新闻'
  },

  // ===== 学术海大 =====
  {
    id: '304083',
    title: '中国海洋大学在俯冲带火山活动的深部驱动机制研究方面取得新进展',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/74/d6/b14f185544daadfce33d3cee6d26/62d99082-7905-433d-ac56-852d8d4e3e31.jpg',
    content: '近日，中国海洋大学海洋地球科学学院在国际权威学术期刊Nature Communications（《自然-通讯》）在线发表了题为“Slab thermal transitions in the Aeolian arc driven by sub-slab mantle upwelling in the early Pleistocene”（早更新世板下地幔上涌驱动的伊奥利亚俯冲板块热状态转变）的研究论文。该研究首次揭示了地中海伊奥利亚岛弧火山活动记录的一次俯冲板块热状态快速转变，建立了板块撕裂诱发的热地幔上涌与弧岩浆成分演化之间的关联。',
    add_date: '2026-08-28',
    category: '学术海大'
  },
  {
    id: '304084',
    title: '中国海洋大学马克思主义学院教授洪晓楠在《马克思主义研究》刊发封面文章',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/cc/41/8997400748c6b8b3b43006c91176/2d7b17f4-e8b3-4346-8177-b4ab08ef61f9.jpg',
    content: '近日，中国海洋大学马克思主义学院教授洪晓楠撰写的理论文章《论习近平党建思想的核心要义与理论品格》在《马克思主义研究》2026年第8期刊发，并作为封面文章推出。',
    add_date: '2026-08-28',
    category: '学术海大'
  },
  {
    id: '304085',
    title: '中国海洋大学在海洋生态修复综合成效评估领域取得新进展',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/7b/00/0be69d454261a65d0507c1ff72ee/486fb8f0-c341-4607-bbaf-29862ac171a5.jpg',
    content: '近日，中国海洋大学海洋与大气学院鲍献文教授团队王楠课题组联合自然资源部海洋减灾中心等国内外团队，在Nature旗下期刊Communications Earth & Environment（通讯-地球与环境）发表题为“National restoration initiatives promote China’s marine ecosystem recovery”（国家修复行动促进中国海洋生态系统重焕生机）的最新研究成果。研究创新性构建了区域性海洋生态修复成效指数（MERE Index），首次从国家尺度评估了覆盖多区域、多生态类型的海洋生态修复工程的综合成效，证实了中国政府主导的系统化海洋生态修复模式成效显著，同步实现了生境恢复、碳汇提升和经济价值增长，为全球海洋生态修复提供了可借鉴的科学方法和中国经验。',
    add_date: '2026-08-26',
    category: '学术海大'
  },

  // ===== 校园纵横 =====
  {
    id: '305670',
    title: '学校原创歌曲《一树繁花》在山东省第26个民族团结进步宣传月启动仪式上唱响',
    poster: 'https://news.ouc.edu.cn/_upload/tpl/00/73/115/template115/images/default_img.jpg',
    content: '8月25日，山东省第26个民族团结进步宣传月启动仪式在临沂市郯城县举行。省委常委、统战部部长邓云锋出席并宣布宣传月启动。启动仪式上，各族干部群众共同观看铸牢中华民族共同体意识主题文艺演出。在山东省教育厅指导下，由学校党委统战部创作的铸牢中华民族共同体意识主题歌曲《一树繁花》作为启动仪式第一个文艺节目，精彩亮相，以优美的旋律和深情的歌词唱响民族团结主旋律，获得与会领导嘉宾一致好评。',
    add_date: '2026-08-27',
    category: '校园纵横'
  },
  {
    id: '305671',
    title: '中国海洋大学学子在第二十届中国大学生跆拳道锦标赛（总决赛）中再创佳绩',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/19/01/bd4d7c0e4aa98535ce6d50b1a85b/b7c4ca4a-8ccb-4d7a-ac5b-dd44c8d80a6f.jpg',
    content: '近日，第二十届中国大学生跆拳道锦标赛（总决赛）在南京圆满落幕。经过5天激烈角逐，中国海洋大学代表队奋勇拼搏，最终斩获2枚银牌、1枚铜牌，以扎实的专业素养和昂扬的竞技风采，为学校赢得荣誉。',
    add_date: '2026-08-26',
    category: '校园纵横'
  },
  {
    id: '305672',
    title: '2026海峡两岸大学生海洋文化交流活动在中国海洋大学开营',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/50/25/b4f8203141ba8644e5ff29cb8033/3e378710-ecc1-4c77-8d12-092f8d8085ec.jpg',
    content: '8月22日上午，由中国海洋大学主办的“2026海峡两岸大学生海洋文化交流活动”开营仪式在鱼山校区举行。来自台湾海洋大学、台湾政治大学等高校机构、协会的30名师生和来自学校的19名师生参加。',
    add_date: '2026-08-24',
    category: '校园纵横'
  },

  // ===== 院系聚焦 =====
  {
    id: '305673',
    title: '中国科学院新疆理化所_所长潘世烈一行到院交流',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/05/01/73f02b4541d1889260ab64faa695/0a37c8b9-b226-4da9-a0d6-4aec22712cfc.jpg',
    content: ' 8月26日，中国科学院新疆理化所（以下简称“新疆理化所”）‌所长潘世烈一行到材料科学与工程学院交流，学院党委书记杜军华、院长崔洪芝参加交流。潘世烈介绍了新疆理化所基本情况，并作题为《真空紫外光电功能晶体创制》的报告。非线性光学晶体作为激光技术的重要物质基础，是前沿科学研究等领域重要战略支撑，他围绕真空紫外光电功能晶体材料的创制与应用，分享了其团队在非线性光学晶体研制领域取得的最新成果。',
    add_date: '2026-08-27',
    category: '院系聚焦'
  },
  {
    id: '305674',
    title: '中国海洋大学未来科学家全国研究生“未来能源与双碳材料及器件”学术论坛举办',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/a2/85/7e9cd10d4b07900be3b2e11caaee/01b7fb45-feeb-4788-bd65-6634958d1fb5.jpg',
    content: '8月22日至23日，中国海洋大学未来科学家全国研究生“未来能源与双碳材料及器件”学术论坛在西海岸校区材料科学与工程学院举办。本次论坛由中国海洋大学研究生院主办，材料科学与工程学院承办，山东大学化学与化工学院、山东硅酸盐学会、山东省储能学会协办。来自瑞典皇家理工学院、西北工业大学、南开大学、山东大学、哈尔滨工业大学（威海）、北京林业大学、安徽工业大学、青岛大学、青岛科技大学、中国科学院过程工程研究所等10余所高校和科研院所的专家学者，以及全国相关领域优秀硕士、博士研究生参加论坛。论坛由中国海洋大学材料科学与工程学院副院长王焕磊主持。',
    add_date: '2026-08-25',
    category: '院系聚焦'
  },
  {
    id: '305675',
    title: '化学化工学院学子获第二届“中控杯”智能制造挑战赛全国总决赛获佳绩',
    poster: 'https://news.ouc.edu.cn/_upload/article/images/16/68/295a5b2044e09f2cb04ed509fb53/6c8a3409-10e9-4b7b-9e7c-1d1081295d0a.jpg',
    content: '8月18日至20日，2026年第二届“中控杯”智能制造挑战赛全国总决赛在杭州白马湖国际会展中心举行。本届大赛共吸引来自浙江大学、华中科技大学、大连理工大学、中国海洋大学等全国103所高校的近400支队伍报名参赛。在化学化工学院副教授周鑫、副教授林子昕老师的指导下，2025级硕士研究生唐敬、2024级本科生郝杰、2025级本科生唐启成和刘紫钰组成中国海洋大学“溯川求理”团队，凭借“丙烯两步氧化制丙烯酸全流程智能优化设计”项目以总分第二的成绩荣获全国总决赛一等奖。',
    add_date: '2026-08-25',
    category: '院系聚焦'
  }
];

// 获取所有新闻列表
function getNewsList() {
  return news.map(function(item) {
    return {
      id: item.id,
      poster: item.poster,
      add_date: item.add_date,
      title: item.title,
      category: item.category
    };
  });
}

// 获取新闻内容
function getNewsDetail(newsID) {
  let msg = {
    code: '404',
    news: {}
  };
  for (var i = 0; i < news.length; i++) {
    if (newsID == news[i].id) {
      msg.code = '200';
      msg.news = news[i];
      break;
    }
  }
  return msg;
}

// 获取分类列表（四个主题）
function getCategories() {
  return ['综合新闻', '学术海大', '校园纵横', '院系聚焦'];
}

// 根据分类获取新闻
function getNewsByCategory(category) {
  return getNewsList().filter(function(item) {
    return item.category === category;
  });
}

// 对外暴露接口
module.exports = {
  getNewsList: getNewsList,
  getNewsDetail: getNewsDetail,
  getNewList: getNewsList,
  getCategories: getCategories,
  getNewsByCategory: getNewsByCategory
};