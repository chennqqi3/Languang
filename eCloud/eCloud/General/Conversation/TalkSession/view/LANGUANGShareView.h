//
//  LANGUANGShareView.h
//  eCloud
//
//  Created by Ji on 17/6/4.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConvRecord.h"

@interface LANGUANGShareView : UIView

@property(nonatomic,strong)ConvRecord *editRecord;

+(LANGUANGShareView *)getShareView;

- (UIView *)shareView;

- (UIImage *)compressedImageFiles:(UIImage *)image
                          imageKB:(CGFloat)fImageKBytes;

@end
