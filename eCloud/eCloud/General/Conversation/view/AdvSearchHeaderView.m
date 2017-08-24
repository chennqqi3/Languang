//
//  AdvSearchHeaderView.m
//  eCloud
//
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "AdvSearchHeaderView.h"
#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"
#import "VerticallyAlignedLabel.h"
#import "UserInterfaceUtil.h"

@implementation AdvSearchHeaderView

- (instancetype)initViewWithTitle:(NSString *)title{

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
//    UITableViewCell *cell = [[[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ADV_SEARCH_HEADER_VIEW_HEIGHT)]autorelease];
//    
//    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ADV_SEARCH_HEADER_VIEW_HEIGHT)];
    if (self) {
//        不再需要这条线，所以设置高度为0
        UIView *topLine = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)]autorelease];
        [topLine setBackgroundColor:GOME_SEPERATE_COLOR];
        [self addSubview:topLine];
        
        VerticallyAlignedLabel *_label = [[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(10, topLine.frame.size.height, SCREEN_WIDTH - 10, ADV_SEARCH_HEADER_VIEW_HEIGHT - 2 * topLine.frame.size.height)]autorelease];
        _label.verticalAlignment = VerticalAlignmentMiddle;
        _label.textColor = RCV_MSG_TEXT_COLOR;
        _label.font = [UIFont systemFontOfSize:14.0];
        _label.text = title;
        
        [self addSubview:_label];
        
//        不再需要这条线
//        UIView *bottomeLine = [[[UIView alloc]initWithFrame:CGRectMake(0, _label.frame.size.height + _label.frame.origin.y, SCREEN_WIDTH, 1)]autorelease];
//        [bottomeLine setBackgroundColor:GOME_SEPERATE_COLOR];
//        [self addSubview:bottomeLine];
    }
    return self;
}

@end
