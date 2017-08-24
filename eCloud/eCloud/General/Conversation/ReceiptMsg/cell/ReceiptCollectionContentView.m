//
//  ReceiptCollectionContentView.m
//  eCloud
//
//  Created by Alex L on 15/12/11.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptCollectionContentView.h"

@implementation ReceiptCollectionContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 105)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 85, 25)];
        [self.timeLabel setTextColor:[UIColor lightGrayColor]];
        [self.timeLabel setFont:[UIFont systemFontOfSize:12]];
        [headerView addSubview:self.timeLabel];
        
        UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, [UIScreen mainScreen].bounds.size.width, 15)];
        separateView.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
        [headerView addSubview:separateView];
        
        [self addSubview:headerView];
    }
    return self;
}

@end
