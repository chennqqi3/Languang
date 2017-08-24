//
//  CollectionImgTextCell.h
//  OpenCtx
//
//  Created by Alex L on 16/3/9.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

@interface CollectionImgTextCell : CollectionParentCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;

@end
