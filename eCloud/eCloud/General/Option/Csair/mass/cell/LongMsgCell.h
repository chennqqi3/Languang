//长消息cell

#import <UIKit/UIKit.h>
#import "MassParentCell.h"

@class ConvRecord;

@interface LongMsgCell : MassParentCell

+(float)cellHeight:(ConvRecord*)_convRecord;

-(void)configureCell:(ConvRecord*)_convRecord;
@end
