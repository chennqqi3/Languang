//群发消息的文本消息的界面
#import <UIKit/UIKit.h>
#import "MassParentCell.h"

@class ConvRecord;

#define reply_label_tag (1001)
#define reply_bg_btn_tag (1002)
#define reply_bg_btn_height (60.0)
#define min_body_height (60.0)
@interface MassTextCell : MassParentCell

+(float)cellHeight:(ConvRecord*)_convRecord;

-(void)configureCell:(ConvRecord*)_convRecord;

//增加回复label 和 分割线
+(void)addCommonView:(UITableViewCell*)cell;

//显示多少条回复label 和 分隔线的高度
+(float)getCommonHeight;

//给reply label赋值
+(void)configureCommonView:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord;

+(float)getHeightByBodyHeight:(float)bodyHeight;

+(void)setBodyViewFrame:(UITableViewCell*)cell;

@end
