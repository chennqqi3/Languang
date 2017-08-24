//
//  BGYUserInfoHeadCellARC.h
//  eCloud
//
//  Created by Alex-L on 2017/7/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGYUserInfoHeadCellARC : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *userLogo;
@property (retain, nonatomic) IBOutlet UILabel *empName;
@property (retain, nonatomic) IBOutlet UILabel *empCode;

@end
