//
//  TextLinkView.h
//  eCloud
//
//  Created by  lyong on 13-10-11.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextLinkView : UIView
{
 NSString *textstr;
 float textWidth;
}
@property(nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) UIColor *linkTextColor;

@property(nonatomic, retain)  NSString *textstr;
@property (assign) float textWidth;
-(void)updateShowContent;
-(CGSize)getViewSize;

@property (nonatomic,retain) void(^robotClickTextBlock)(NSString *clickText,BOOL isAgent);
@end
