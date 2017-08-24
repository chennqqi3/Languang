//
//  XIANGYUANMyCell.h
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emp.h"

@interface XIANGYUANMyCell : UITableViewCell


@property (nonatomic,strong)UILabel *homeDay;

@property (nonatomic,strong)UIImageView *homeImageView;
@property(retain,nonatomic) Emp *emp;

@end
