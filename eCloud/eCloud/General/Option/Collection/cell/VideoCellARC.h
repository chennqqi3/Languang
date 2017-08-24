//
//  VideoCell.h
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

@interface VideoCellARC : CollectionParentCell

@property (nonatomic, strong) UIImageView *picture;
@property (nonatomic, strong) UILabel *durationLabel;

@end
