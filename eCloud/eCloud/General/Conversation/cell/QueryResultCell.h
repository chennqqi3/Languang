//考虑是 会话列表界面，查询会话结果页面，都使用这个cell add by shisp
//包括一个头像，一个会话标题，一个最后一条消息记录，一个消息时间，一个新消息通知图片
//在会话列表里，以上一个元素都会显示
//对于查询结果，则有时不显示消息时间，那么显示会话标题的时间就要加宽；如果不显示新消息不通知的图片，那么明细的内容就可以加宽显示，另外明细部门的字体，位置，字体颜色等都会根据不同情况使用不同的设置

#import <UIKit/UIKit.h>
#import "UserInterfaceUtil.h"

//估计是其它类使用到了 所以 放在了.h里
#define conv_name_tag 102
#define time_tag 103

//子view直接的间隔定义
#define group_logo_subview_spacing (1.5)
//时间固定宽度
#define time_width (50.0)


@class QueryResultCell;


@protocol menuCellDelegate <NSObject>


/**
 用户选择了置顶按钮

 @param cell 置顶按钮所在的cell
 */
- (void)contextMenuCellDidSelectMoreOption:(UITableViewCell *)cell;

/**
 左滑菜单消失

 @param cell 左滑菜单所在cell
 */
- (void)contextMenuDidHideInCell:(UITableViewCell *)cell;


/**
 显示左滑菜单

 @param cell 用户左滑的cell
 */
- (void)contextMenuDidShowInCell:(UITableViewCell *)cell;


/**
 左滑菜单将要隐藏

 @param cell 用户左滑的cell
 */
- (void)contextMenuWillHideInCell:(UITableViewCell *)cell;

/**
 左滑菜单将要显示

 @param cell 用户左滑的cell
 */
- (void)contextMenuWillShowInCell:(UITableViewCell *)cell;


/**
 是否显示菜单选项

 @param cell 用户左滑的cell
 @return 如果要显示返回YES，否则返回NO
 */
- (BOOL)shouldShowMenuOptionsViewInCell:(UITableViewCell *)cell;
@optional


/**
 用户点击了删除会话菜单选项

 @param cell 用户左滑的cell
 */
- (void)contextMenuCellDidSelectDeleteOption:(UITableViewCell *)cell;

@end

@class Conversation;

@interface QueryResultCell : UITableViewCell<UIGestureRecognizerDelegate>

/** cell宽度 */
@property (nonatomic,assign) float cellWidth;

/** cell视图的父view*/
@property (nonatomic,retain) UIView *cellView;

// cell左滑菜单属性

/** 左滑菜单是隐藏还是显示 */
@property (assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;

/** 删除按钮标题 */
@property (retain, nonatomic) NSString *deleteButtonTitle;

/** 是否显示删除按钮 */
@property (assign, nonatomic) BOOL editable;

/** 没有用到 */
@property (assign, nonatomic) CGFloat menuOptionButtonTitlePadding;

/** 左滑菜单的动画时间 */
@property (assign, nonatomic) CGFloat menuOptionsAnimationDuration;

/** 左滑菜单的bounce距离 */
@property (assign, nonatomic) CGFloat bounceValue;

/** 置顶按钮标题 */
@property (retain, nonatomic) NSString *moreOptionsButtonTitle;

/** 置顶按钮 */
@property (retain, nonatomic) UIButton *moreOptionsButton;
/** 删除按钮 */
@property (retain, nonatomic) UIButton *deleteButton;

/** cell delegate */
@property (assign, nonatomic) id<menuCellDelegate> delegate;


/**
 初始化cell
 */
- (void)initSubView;


/**
 显示具体内容的宽度 总宽度 - 两个边距 - 头像宽度 - 头像和内容的间隔

 @return 内容能显示的尺寸
 */
- (float)getContentWidth;

/**
 增加自定义左滑手势
 */
- (void)addCustomGesture;

/**
 显示会话列表里的会话

 @param conv 会话对应的模型
 */
- (void)configCell:(Conversation *)conv;

/**
 显示会话对应的头像

 @param conv 会话对应的模型
 */
- (void)configLogo:(Conversation *)conv;


/**
 显示会话的标题

 @param conv 会话对应的模型
 */
- (void)configConvName:(Conversation *)conv;


/**
 显示会话的最后一条消息时间

 @param conv 会话对应的模型
 */
- (void)configTime:(Conversation *)conv;


/**
 确定会话的最后一条消息具体内容

 @param conv 会话对应的模型
 */
- (void)configDetail:(Conversation *)conv;


/**
 显示会话是否关闭新消息提醒

 @param conv 会话对应的模型
 */
- (void)configRcvFlagView:(Conversation *)conv;

#pragma mark 配置查询结果界面

/**
 显示搜索结果

 @param conv 会话对应的模型
 */
- (void)configSearchResultCell:(Conversation *)conv;

#pragma mark cell左滑菜单

/**
 左滑菜单的宽度

 @return 左滑菜单的宽度
 */
- (CGFloat)contextMenuWidth;

/**
 显示或者隐藏左滑菜单

 @param hidden 显示左滑菜单还是隐藏
 @param animated 是否需要动画
 @param completionHandler 动画完成后后回调
 */
- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler;

#pragma mark =======万达需求 参照微信 生成群头像========
/**
 初始化群组头像view，群组头像是由最多四个小头像组成的

 @param iconview 头像view
 */
+ (void)initGroupLogoView:(UIImageView *)iconview;

/**
 根据会话模型，配置群组头像view

 @param conv 会话模型
 @param iconview 头像view
 */
+ (void)configGroupLogoView:(Conversation *)conv andIconView:(UIImageView *)iconview;

//获取下小头像有几行几列

/**
 根据会话模型，计算出群组头像需要显示成几行，每一行显示的头像个数

 @param conv 会话模型
 @return 返回一个二维数组，每个数组元素是要显示头像的Emp对象
 */
+ (NSArray *)getLogoRowsAndColsOfConv:(Conversation *)conv;

#pragma mark =====配置应用的logo======
/**
 显示国美应用消息列表时，可以显示相应应用的图标

 @param conv 会话模型
 */
- (void)configAppLogo:(Conversation *)conv;

@end
