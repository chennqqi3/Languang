//
//  SettingItem.h
//  eCloud
//
//  Created by shisuping on 15-9-6.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

// 默认行高
#define DEFAULT_ROW_HEIGHT (51.00)
// 第一个组header的高度
#define FIRST_SECTION_HEADER_HEIGHT (25.0)
// 默认组header的高度
#define DEFAULT_SECTION_HEADER_HEIGHT (5.0)
// 第一个组footer的高度
#define FIRST_SECTION_FOOTER_HEIGHT (20.0)
// 默认组footer的高度
#define DEFAULT_SECTION_FOOTER_HEIGHT (5.0)

@interface SettingItem : NSObject

/** 设置项的名称 */
@property (nonatomic,retain) NSString *itemName;
/** 图片名称 */
@property (nonatomic,retain) NSString *imageName;
/** 右侧样式 */
@property (nonatomic,assign) UITableViewCellAccessoryType accessoryType;
/** 选中后的样式 */
@property (nonatomic,assign) UITableViewCellSelectionStyle selectionStyle;
/** 点击后执行的方法 */
@property (nonatomic,assign) SEL clickSelector;
/** header高度 */
@property (nonatomic,assign) float headerHight;
/** 自定义头视图 */
@property (nonatomic,retain) UIView *headerView;
/** 定制选中后sel */
@property (nonatomic,assign) SEL customCellSelector;
/** 对应cell的高度 */
@property (nonatomic,assign) float cellHeight;
/** 详细内容的size */
@property (nonatomic,assign) CGSize detailValueSize;
/** 详细内容的颜色 */
@property (nonatomic,retain) UIColor *detailValueColor;
/** 对应的设置项的值 */
@property (nonatomic,retain) NSString *itemValue;
/** 需要显示进行处理的数据对象 */
@property (nonatomic,retain) id dataObject;

/** 头像的大小 头像的颜色 要显示的文本 文本的大小 文本的颜色 */
@property (nonatomic,retain) NSDictionary *logoDic;

/** 是否显示选择按钮 */
@property (nonatomic,assign) BOOL displaySelectBtn;

/** 搜索内容 */
@property (nonatomic,retain) NSString *searchContent;

@end
