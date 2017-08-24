//
//  NewsCellARC.h
//  eCloud
//
//  Created by Alex-L on 2017/6/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentMsgCell.h"
@class ConvRecord;

@interface NewsCellARC : ParentMsgCell

- (void)configureCell:(ConvRecord *)_convRecord;

@end
