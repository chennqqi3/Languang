//
//  LocationCell.h
//  eCloud
//
//  Created by Dave William on 2017/8/8.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionParentCell.h"

//	最大宽度、高度
#define MSG_MAX_LOCATION_WIDTH (224)
#define MSG_MAX_LOCATION_HEIGHT (163)

// 地址控件的一些属性  高度、字体颜色、字体大小
#define MSG_ADDRESS_SPACE (8.5)
#define MSG_ADDRESS_HEIGHT (37)
#define MSG_ADDRESS_FONTSIZE (17)
#define MSG_ADDRESS_FONTCOLOR @"#000000"

// 图片控件的一些属性  高度
#define MSG_PIC_HEIGHT (126)


@interface LocationCell : CollectionParentCell

@property (nonatomic, strong) UIImageView *locationImage;
@property (nonatomic, strong) UILabel *address;

@end
