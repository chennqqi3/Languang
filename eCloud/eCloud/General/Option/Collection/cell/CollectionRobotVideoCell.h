//
//  CollectionRobotVideoCell.h
//  OpenCtx
//
//  Created by Alex L on 16/3/9.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

@interface CollectionRobotVideoCell : CollectionParentCell

@property (nonatomic, strong) UIImageView *typeImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *fileSizeLabel;

@end
