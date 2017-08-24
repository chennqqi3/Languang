//显示提示信息的cell

#import <UIKit/UIKit.h>
#import "MassParentCell.h"

@class ConvRecord;
@class MassParentCell;
@interface GroupInfoCell : MassParentCell

-(void)configureCell:(ConvRecord*)_convRecord;

+(float)cellHeight:(ConvRecord*)_convRecord;
@end
