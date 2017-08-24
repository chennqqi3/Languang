//
//  ReceiptCollectionContentView.h
//  eCloud
//
//  Created by Alex L on 15/12/11.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptCollectionContentView : UICollectionReusableView

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *textMessage;
@property (nonatomic, strong) UIImageView *picture;

@property (nonatomic, strong) UIButton *contentView;

@end
