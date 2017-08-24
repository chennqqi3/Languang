//
//  faceDefine.h
//  eCloud
//
//  Created by yanlei on 15/8/24.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#ifndef eCloud_faceDefine_h
#define eCloud_faceDefine_h

#if defined(_HUAXIA_FLAG_) || defined(_BGY_FLAG_)

/** 表情图标的名字 */
#define faceIconNameDef [NSMutableArray arrayWithObjects:@"face_01weixiao",@"face_02piezui",@"face_03se",@"face_04fadai",@"face_05deyi",@"face_06liulei",@"face_07haixiu",@"face_08bizui",@"face_09shui",@"face_10daku",@"face_11ganga",@"face_12fanu",@"face_13tiaopi",@"face_14ciya",@"face_15jingya",@"face_16nanguo",@"face_17ku",@"face_18jiong",@"face_19zhuakuang",@"face_20tu",@"face_21touxiao",@"face_22yukuai",@"face_23baiyan",@"face_24aoman",@"face_25jie",@"face_26kun",@"face_27jingkong",@"face_28liuhan",@"face_29hanxiao",@"face_30youxian",@"face_31fendou",@"face_32zhouma",@"face_33yiwen",@"face_34xu",@"face_35yun",@"face_36fengle",@"face_37shuai",@"face_38kulou",@"face_39qiaoda",@"face_40zaijian",@"face_41cahan",@"face_42koubi",@"face_43guzhang",@"face_44qiudale",@"face_45huaixiao",@"face_46zuohengheng",@"face_47youhengheng",@"face_48haqian",@"face_49bishi",@"face_50weiqu",@"face_51kuaiku",@"face_52yinxian",@"face_53qinqin",@"face_54he",@"face_55kelian",@"face_56caidao",@"face_57xigua",@"face_58pijiu",@"face_59lanqiu",@"face_60pingpang",@"face_61kafei",@"face_62fan",@"face_63zhutou",@"face_64meigui",@"face_65diaoxie",@"face_66zuichun",@"face_67aixin",@"face_68xinsui",@"face_69dangao",@"face_70shandian",@"face_71zhadan",@"face_72dao",@"face_73zuqiu",@"face_74piaochong",@"face_75bianbian",@"face_76yueliang",@"face_77taiyang",@"face_78liwu",@"face_79yongbao",@"face_80qiang",@"face_81ruo",@"face_82woshou",@"face_83shengli",@"face_84baoquan",@"face_85gouyin",@"face_86quantou",@"face_87chajin",@"face_88aini",@"face_89no",@"face_90ok",@"face_106jianxiao",@"face_107heiha",@"face_108wulian",@"face_109jizhi",@"face_110cha",@"face_111hongbao",@"face_112lazhu",@"face_113ye",@"face_114zhoumei",nil]

/** 表情的名字 */
#define faceValueDef [NSMutableArray arrayWithObjects:@"wx",@"pz",@"se",@"fd",@"dy",@"ll",@"hx",@"bz",@"shui",@"dk",@"gg",@"fn",@"tp",@"cy",@"jy",@"ng",@"ku",@"jiong",@"zk",@"tu",@"tx",@"yk",@"by",@"am",@"je",@"kun",@"jk",@"lh",@"hxiao",@"yx",@"fdou",@"zm",@"yw",@"xu",@"yun",@"fl",@"shuai",@"kl",@"qd",@"zj",@"ch",@"kb",@"gz",@"qdl",@"hx",@"zhh",@"yhh",@"hq",@"bs",@"wq",@"kk",@"yxian",@"qq",@"he",@"klian",@"cd",@"xg",@"pj",@"lq",@"pp",@"kf",@"fan",@"zt",@"mg",@"dx",@"zc",@"ax",@"xs",@"dg",@"sd",@"zd",@"dao",@"zq",@"pc",@"bb",@"yl",@"ty",@"lw",@"yb",@"qiang",@"ruo",@"ws",@"sl",@"bq",@"gy",@"qt",@"cj",@"an",@"no",@"ok",@"jx",@"hh",@"wl",@"jz",@"cha",@"hb",@"lz",@"ye",@"zmei",nil]

#elif defined (_LANGUANG_FLAG_)

/** 表情图标的名字 */
#define faceIconNameDef [NSMutableArray arrayWithObjects:@"笑哭",@"我最美",@"饥饿",@"困",@"抠鼻",@"鼓掌",@"亲亲",@"委屈",@"呲牙",@"流汗",@"调皮",@"呕吐",@"得意",@"嘘",@"酷",@"偷笑",@"敲打",@"抓狂",@"擦汗",@"大哭",@"害羞",@"再见",@"可爱",@"流泪",@"便便",@"无奈",@"泪奔",@"托腮",@"疑问",@"卖萌",@"小纠结",@"吐血",@"斜眼笑",@"doge",@"睡",@"骚扰",@"惊喜",@"坏笑",@"右哼哼",@"白眼",@"傲慢",@"微笑",@"尴尬",@"惊讶",@"恐惧",@"示爱",@"发呆",@"发怒",@"憋嘴",@"冷汗",@"憨笑",@"鄙视",@"晕",@"装逼",@"可怜",@"咒骂",@"拥抱",@"猪头",@"闭嘴",@"难过",@"衰",@"眨眼睛",@"折磨",@"左哼哼",@"色",@"哈欠",@"吓",@"骷髅",@"糗大了",@"快哭了",@"赞",@"踩",@"握手",@"胜利",@"抱拳",@"勾引",@"爱你",@"差劲",@"拳头",@"NO",@"爱心",@"凋谢",@"饭",@"西瓜",@"OK",@"月亮",@"太阳",@"礼物",@"帅",@"玫瑰",@"蛋糕",@"刀",@"心碎",@"拜托",@"点赞",@"无聊",@"托脸",@"吃",@"送花",@"害怕",@"花痴",@"小样儿",@"瞅一眼",@"飙泪",@"我不看",@"河蟹",@"羊驼",@"包子",@"幽灵",@"蛋",@"九宫格",@"菊花",@"香皂",@"红包",@"啵啵",@"糊脸",@"拍头",@"扯一扯",@"舔一舔",@"蹭一蹭",@"拽炸天",@"顶呱呱",@"啤酒",@"瓢虫",@"咖啡",@"足球",@"篮球",@"乒乓",@"闪电",@"茶",@"双喜",@"鞭炮",@"灯笼",@"麻将",@"K歌",@"购物",@"邮件",@"喝彩",@"祈祷",@"爆筋",@"棒棒糖",@"喝奶",@"面条",@"香蕉",@"飞机",@"汽车",@"向后开",@"车厢",@"向前开",@"钞票",@"熊猫",@"电灯泡",@"风车",@"闹钟",@"雨伞",@"气球",@"戒指",@"沙发",@"卫生纸",@"药",@"青蛙",nil]

/** 表情的名字 */
#define faceValueDef [NSMutableArray arrayWithObjects:@"笑哭",@"我最美",@"饥饿",@"困",@"抠鼻",@"鼓掌",@"亲亲",@"委屈",@"呲牙",@"流汗",@"调皮",@"呕吐",@"得意",@"嘘",@"酷",@"偷笑",@"敲打",@"抓狂",@"擦汗",@"大哭",@"害羞",@"再见",@"可爱",@"流泪",@"便便",@"无奈",@"泪奔",@"托腮",@"疑问",@"卖萌",@"小纠结",@"吐血",@"斜眼笑",@"doge",@"睡",@"骚扰",@"惊喜",@"坏笑",@"右哼哼",@"白眼",@"傲慢",@"微笑",@"尴尬",@"惊讶",@"恐惧",@"示爱",@"发呆",@"发怒",@"憋嘴",@"冷汗",@"憨笑",@"鄙视",@"晕",@"装逼",@"可怜",@"咒骂",@"拥抱",@"猪头",@"闭嘴",@"难过",@"衰",@"眨眼睛",@"折磨",@"左哼哼",@"色",@"哈欠",@"吓",@"骷髅",@"糗大了",@"快哭了",@"赞",@"踩",@"握手",@"胜利",@"抱拳",@"勾引",@"爱你",@"差劲",@"拳头",@"NO",@"爱心",@"凋谢",@"饭",@"西瓜",@"OK",@"月亮",@"太阳",@"礼物",@"帅",@"玫瑰",@"蛋糕",@"刀",@"心碎",@"拜托",@"点赞",@"无聊",@"托脸",@"吃",@"送花",@"害怕",@"花痴",@"小样儿",@"瞅一眼",@"飙泪",@"我不看",@"河蟹",@"羊驼",@"包子",@"幽灵",@"蛋",@"九宫格",@"菊花",@"香皂",@"红包",@"啵啵",@"糊脸",@"拍头",@"扯一扯",@"舔一舔",@"蹭一蹭",@"拽炸天",@"顶呱呱",@"啤酒",@"瓢虫",@"咖啡",@"足球",@"篮球",@"乒乓",@"闪电",@"茶",@"双喜",@"鞭炮",@"灯笼",@"麻将",@"K歌",@"购物",@"邮件",@"喝彩",@"祈祷",@"爆筋",@"棒棒糖",@"喝奶",@"面条",@"香蕉",@"飞机",@"汽车",@"向后开",@"车厢",@"向前开",@"钞票",@"熊猫",@"电灯泡",@"风车",@"闹钟",@"雨伞",@"气球",@"戒指",@"沙发",@"卫生纸",@"药",@"青蛙",nil]

#define faceAfterName [NSMutableArray arrayWithObject:@""]
#else
#define faceIconNameDef [NSMutableArray arrayWithObject:@""]
#define faceValueDef [NSMutableArray arrayWithObject:@""]

#define faceAfterName [NSMutableArray arrayWithObjects:@"wx",@"han",@"am",@"by",\
@"bs",@"bz",@"bx",@"dk",\
@"dx",@"tx",@"baib",@"gz2",\
@"heng",@"yhh",@"hxiao",@"hy",\
@"je",@"jy",@"jl",@"ku",\
@"lhan",@"llei",@"shh",@"tc",\
@"xia",@"xu",@"yx",@"zhk",\
@"tu",@"tp",@"ex",@"nu",\
@"gg",@"hxiu",@"hx",@"jk",\
@"ka",@"kl",@"kun",@"lh",\
@"ng",@"girl",@"wq",@"qq",\
@"se",@"shuai",@"yun",@"zhu",\
@"yw",@"fd",@"fdou",@"qd",\
@"money",@"huiy",@"ws",@"gz1",\
@"ok",@"bq",@"cj",@"lh2",\
@"sl",@"yb",@"coffee",@"xh",\
@"xs",@"ax",@"ppq",@"dao",\
@"zq",@"ndshu",@"nlhai",@"nnguo",\
@"ngirl",@"nyb",@"ndd",@"ndl",\
@"ngl",@"nheng",@"njr",@"njiong",\
@"ndk",@"nku",@"nkun",@"nmg",\
@"nsx",@"ncs",@"nsh",@"ntc",\
@"ntx",@"nwq",@"nzd",@"nok",\
@"nno",@"ncc",@"ndy",@"ndnfz",\
@"nds",@"ndbq",@"nfd",@"nfdn",\
@"nfn",@"nhxiu",@"nhx",@"njy",\
@"nkj",@"nlei",@"nnlmm",@"nnb",\
@"ntq",@"ntqiu",@"nxx",@"nxhnf",\
@"nxw",@"nyw",@"nzan",@"nzxr",\
@"nzk",@"dh",@"dsj",@"email",\
@"jiub",@"lw",@"music",@"pj",\
@"sj",@"xg",@"yaow",@"fjding",\
@"fjdy",@"fjfw",@"fjhang",@"fjku",\
@"fjrz",@"fjwq",@"fjwx",@"fjyun",nil\
]

#endif

#endif
