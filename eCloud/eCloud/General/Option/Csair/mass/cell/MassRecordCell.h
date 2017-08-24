//群发录音cell

#import <UIKit/UIKit.h>
#import "MassParentCell.h"
@class ConvRecord;

@interface MassRecordCell : MassParentCell

-(void)configureCell:(ConvRecord*)_convRecord;

+(float)cellHeight:(ConvRecord*)_convRecord;

@end
