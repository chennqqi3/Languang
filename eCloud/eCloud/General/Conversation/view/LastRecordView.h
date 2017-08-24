/*
 会话列表界面 每个会话最后一条消息 使用的View
 add by shisp
 */
//包含表情的UIView
//可以采用不同颜色显示文字的view
//在会话列表，草稿，[有人@wo]，需要显示红色
//显示查询结果时，使用绿色显示匹配的聊天记录和会话等
//可以设置显示的内容，最大宽度，特殊显示的字符串，特殊显示的字体颜色，字体，颜色等

#import <UIKit/UIKit.h>

@interface LastRecordView : UIView

/** 消息内容 */
@property (nonatomic,retain) NSString *msgBody;

/** 显示的最大宽度 */
@property (nonatomic,assign) float maxWidth;

/** 需要特殊显示的内容 */
@property (nonatomic,retain) NSString *specialStr;

/** 特殊内容的显示颜色 */
@property (nonatomic,retain) UIColor *specialColor;

/** 使用的字体 */
@property (nonatomic,retain) UIFont *textFont;

/** 使用的字体颜色 */
@property (nonatomic,retain) UIColor *textColor;


/**
 按照要求显示消息
 */
- (void)display;

@end
