//
//  JBWeekdaysBarView.m
//  JBCalendar
//
//  Created by YongbinZhang on 7/23/13.
//  Copyright (c) 2013 YongbinZhang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JBWeekdaysBarView.h"

#ifndef DaysCountPerWeek
#define DaysCountPerWeek    7
#endif


@interface JBWeekdaysBarView ()

@property (nonatomic, retain) NSArray *weekdays;
@property (nonatomic, retain) NSMutableArray *weekdayLabels;

@end

@implementation JBWeekdaysBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.weekdays = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
        
        self.weekdayLabels = [[NSMutableArray alloc] init];
        CGFloat labelWidth = self.bounds.size.width / DaysCountPerWeek;
        for (NSUInteger i = 0; i < DaysCountPerWeek; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * labelWidth, 0.0f, labelWidth, DefaultWeekdaysBarHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor lightGrayColor];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
            label.textAlignment = NSTextAlignmentCenter;
#else
            label.textAlignment = UITextAlignmentCenter;
#endif
            
            label.text = [self.weekdays objectAtIndex:i];
            [self.weekdayLabels addObject:label];
            [self addSubview:label];
        }
    }
    return self;
}

@end
