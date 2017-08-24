//
//  LGWorkCollectionHeaderViewArc.m
//  eCloud
//
//  Created by Ji on 17/7/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGWorkCollectionHeaderViewArc.h"

@implementation LGWorkCollectionHeaderViewArc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 1, 140, 50)];
        [self.headerLabel setFont:[UIFont systemFontOfSize:16]];
        self.headerLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self addSubview:self.headerLabel];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

@end
