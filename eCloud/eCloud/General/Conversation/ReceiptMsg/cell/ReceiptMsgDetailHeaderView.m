//
//  ReceiptMsgDetailHeaderView.m
//  OpenCtx2017
//
//  Created by shisuping on 17/6/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "ReceiptMsgDetailHeaderView.h"
#import "UserInterfaceUtil.h"

#define HEADER_LABEL_X 20
#define HEADER_LABEL_Y 5
#define HEADER_LABEL_WIDTH 120
#define HEADER_LABEL_HEIGHT 20

#define HEADER_LABEL_FONT 13


@implementation ReceiptMsgDetailHeaderView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UIView *seperateView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, SEPERATE_VIEW_HEIGHT)]autorelease];
        seperateView.backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
        
        [self addSubview:seperateView];
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_LABEL_X, HEADER_LABEL_Y + SEPERATE_VIEW_HEIGHT, HEADER_LABEL_WIDTH, HEADER_LABEL_HEIGHT)];
        [self.headerLabel setFont:[UIFont systemFontOfSize:HEADER_LABEL_FONT]];
        [self.headerLabel setTextColor:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/252.0 alpha:1]];
        [self addSubview:self.headerLabel];
    }
    return self;
}


@end
