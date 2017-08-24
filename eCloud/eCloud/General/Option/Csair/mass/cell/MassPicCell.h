//图片消息cell

#import <UIKit/UIKit.h>
#import "MassParentCell.h"

@class ConvRecord;
@interface MassPicCell : MassParentCell

-(void)configureCell:(ConvRecord*)_convRecord;

+(float)cellHeight:(ConvRecord*)_convRecord;

@end
