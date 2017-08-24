//
//  CollectionHeaderView.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "CollectionHeaderView.h"

#define HEADER_LABEL_X 20
#define HEADER_LABEL_Y 5
#define HEADER_LABEL_WIDTH 120
#define HEADER_LABEL_HEIGHT 20

#define HEADER_LABEL_FONT 13

@implementation CollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_LABEL_X, HEADER_LABEL_Y, HEADER_LABEL_WIDTH, HEADER_LABEL_HEIGHT)];
        [self.headerLabel setFont:[UIFont systemFontOfSize:HEADER_LABEL_FONT]];
        [self.headerLabel setTextColor:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/252.0 alpha:1]];
        [self addSubview:self.headerLabel];
    }
    return self;
}

@end
