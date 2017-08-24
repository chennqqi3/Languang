//
//  TopNewsView.h
//  WanDaOAP3_IM
//
//  Created by SF on 16/4/12.
//  Copyright © 2016年 Wanda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGYOANewsEntity.h"

@interface TopNewsView : UIView

+ (TopNewsView *)loadFromXib;
- (void)displayWithModel:(BGYOANewsEntity *)entity;

@end
