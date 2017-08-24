//
//  TestCoreTextView.h
//  testCoreText
//
//  Created by  lyong on 13-8-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "RegexKitLite.h"
#import "eCloudDefine.h"
@interface TestCoreTextView : UIView
{
    NSMutableAttributedString *content;
    CTFrameRef _frame;
    NSString*originalStr;
    
    NSMutableString*new_originalStr;
    UIColor *nowColor;
    NSMutableArray *activieArray;
    int activieIndex;
    NSMutableArray *imageArray;
}
@property(nonatomic,retain)NSString*originalStr;
@property(nonatomic,retain) NSMutableArray *imageArray;
@property(nonatomic,retain) NSMutableAttributedString *content;
- (int)getAttributedStringHeightWithString:(NSAttributedString *)  string  WidthValue:(int) width;
-(void)buildAttribute;
@end

// 图文混合，点击事件
//http://www.2cto.com/kf/201307/225778.html