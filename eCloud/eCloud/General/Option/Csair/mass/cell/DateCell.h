//显示聊天日期

#import <UIKit/UIKit.h>
@class ConvRecord;

@interface DateCell : UITableViewCell
-(void)configureCell:(ConvRecord*)_convRecord;
@end
