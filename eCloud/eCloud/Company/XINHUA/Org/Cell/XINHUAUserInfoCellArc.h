//
//  XINHUAUserInfoCell.h
//  eCloud
//
//  Created by Alex-L on 2017/5/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emp.h"

@protocol UserInfoCellDelegate <NSObject>

- (void)showBigLogo;

@end

@interface XINHUAUserInfoCellArc : UITableViewCell

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, assign) id<UserInfoCellDelegate> logoDelegate;

@end
