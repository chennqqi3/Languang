//
//  TextWithLinkView.m
//  eCloud
//
//  Created by  lyong on 13-10-11.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "TextWithLinkView.h"

@implementation TextWithLinkView
@synthesize maxwidth;
@synthesize message;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(CGSize)getViewSize
{
    if (textObject!=nil) {
        textObject=[[LinkTextViewController alloc]init];
    }
    textObject.textstr=self.message;
    textObject.textWidth=self.maxwidth;
    CGSize viewsize=textObject.view.frame.size;
    return viewsize;
}

-(void)updateShowContent
{
 
    self.frame=textObject.view.frame;
    [self addSubview:textObject.view];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
