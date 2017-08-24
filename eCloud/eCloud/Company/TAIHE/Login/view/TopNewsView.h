//
//  TopNewsView.h
//  WanDaOAP3_IM
//
//  Created by SF on 16/4/12.
//  Copyright © 2016年 Wanda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OANewsEntity.h"

@interface TopNewsView : UIView

+ (TopNewsView *)loadFromXib;
- (void)displayWithModel:(OANewsEntity *)entity;

@end
