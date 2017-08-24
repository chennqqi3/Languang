//
//  CollectFileCell.h
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

@interface CollectFileCell : CollectionParentCell

@property (nonatomic, strong) UIImageView *fileImgView;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *fileSize;

@end
