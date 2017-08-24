//
//  AdvSearchFooterView.m
//  eCloud
//
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "AdvSearchFooterView.h"
#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"
#import "VerticallyAlignedLabel.h"
#import "UserInterfaceUtil.h"
#import "StringUtil.h"


@implementation AdvSearchFooterView

- (instancetype)initViewWithTitle:(NSString *)title{
//    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ADV_SEARCH_FOOTER_VIEW_HEIGHT)];
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (self) {
//        不再需要这条线，所以高度设置为0
        UIView *topLine = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)]autorelease];
        [topLine setBackgroundColor:GOME_SEPERATE_COLOR];
        [self addSubview:topLine];
        
        UIView *parentView = [[UIView alloc]initWithFrame:CGRectMake(0, topLine.frame.size.height, SCREEN_WIDTH, ADV_SEARCH_FOOTER_VIEW_HEIGHT - topLine.frame.size.height)];
        [self addSubview:parentView];
        
        UIImage *searchImage = [StringUtil getImageByResName:@"search.png"];
        
        UIImageView *searchView = [[[UIImageView alloc]initWithFrame:CGRectMake(10, (parentView.frame.size.height - searchImage.size.height) * 0.5, searchImage.size.width, searchImage.size.height)]autorelease];
        searchView.image = searchImage;
        [parentView addSubview:searchView];
        
        float labelX = searchView.frame.size.width + 2 * searchView.frame.origin.x;
        
        VerticallyAlignedLabel *_label = [[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(labelX, 0, SCREEN_WIDTH - labelX * 2 , parentView.frame.size.height)]autorelease];
        _label.verticalAlignment = VerticalAlignmentMiddle;
        _label.textColor = GOME_NAME_COLOR;
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.text = title;
        
        [parentView addSubview:_label];
        
        UIImage *viewMoreImage = [StringUtil getImageByResName:@"view_more_search_records.png"];
        
        UIImageView *viewMoreView = [[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - viewMoreImage.size.width, (parentView.frame.size.height - viewMoreImage.size.height) * 0.5, viewMoreImage.size.width, viewMoreImage.size.height)]autorelease];
        viewMoreView.image = viewMoreImage;
        [parentView addSubview:viewMoreView];

        
//        UIView *bottomeLine = [[[UIView alloc]initWithFrame:CGRectMake(0, parentView.frame.size.height + parentView.frame.origin.y, SCREEN_WIDTH, 1)]autorelease];
//        [bottomeLine setBackgroundColor:GOME_SEPERATE_COLOR];
//        [self addSubview:bottomeLine];
        
    }
    return self;
}


@end
