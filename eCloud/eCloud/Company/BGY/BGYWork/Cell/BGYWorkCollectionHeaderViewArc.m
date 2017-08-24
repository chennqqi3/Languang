//
//  BGYWorkCollectionHeaderView.m
//  eCloud
//
//  Created by Alex-L on 2017/1/3.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYWorkCollectionHeaderViewArc.h"

@implementation BGYWorkCollectionHeaderViewArc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 140, 40)];
        [self.headerLabel setFont:[UIFont systemFontOfSize:14]];
        self.headerLabel.textColor = [UIColor colorWithRed:0X5b/255.0 green:0X5b/255.0 blue:0X5b/255.0 alpha:1];
        [self addSubview:self.headerLabel];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

@end
