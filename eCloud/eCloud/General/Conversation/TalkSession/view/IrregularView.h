//
//  IrregularView.h
//  IrregularImages
//  显示图片类型消息时，图片显示成了一个气泡的形状
//  Created by OranWu on 13-4-10.
//  Copyright (c) 2013年 Oran Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface IrregularView : UIImageView
#warning Here you can Inherits from any UIView as you wish. 
#warning Such as UIImageView/UITextView/UILabel/UITextField

//need to be a shape, it means the start point must be the same with the end point
@property (nonatomic, strong)   NSMutableArray    *trackPoints;
@property (nonatomic, readwrite) UIBezierPath     *tempPath;
@property (nonatomic, readwrite) float            cornerRadius;
@property (nonatomic, readwrite) float            borderWidth;
@property (nonatomic, readwrite) UIColor          *borderColor;

- (void)setMask;
@end
