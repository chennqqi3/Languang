//
//  MyCollectionViewCell.h
//  eCloud
//
//  Created by yanlei on 15/11/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyCollectionViewCellDelegate <NSObject>

- (void)clickButton:(UIButton *)button;

@end

@interface MyCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIButton *overlayView;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,assign) id<MyCollectionViewCellDelegate> delegate;

@end
