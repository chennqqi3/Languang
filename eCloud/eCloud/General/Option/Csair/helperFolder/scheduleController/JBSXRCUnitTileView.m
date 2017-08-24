//
//  JBSXRCUnitTileView.m
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

#import "JBSXRCUnitTileView.h"
#import <QuartzCore/QuartzCore.h>
#import "eCloudDAO.h"
#import "StringUtil.h"
@interface JBSXRCUnitTileView ()

@end

@implementation JBSXRCUnitTileView

- (id)initWithFrame:(CGRect)frame
{

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.eventCountLabel.hidden = YES;
        
        self.dayLabel.font = [UIFont systemFontOfSize:14];
//        self.dayLabel.layer.borderColor=[UIColor lightGrayColor].CGColor;
//        self.dayLabel.layer.borderWidth=0.5;

    }
    return self;
}


/**************************************************************
 *模版方法，设置Tile的显示
 **************************************************************/
- (void)updateUnitTileViewShowingWithOtherUnit:(BOOL)otherUnit Selected:(BOOL)selected Today:(BOOL)today eventsCount:(NSInteger)eventsCount
{
    [super updateUnitTileViewShowingWithOtherUnit:otherUnit Selected:selected Today:today eventsCount:eventsCount];
     self.selectedMarkImage.image=nil;
    if (otherUnit) {
        if (selected) {
             self.selectedMarkImage.image=[StringUtil getImageByResName:@"round_ico2.png"];
        }
        
    } else {
       // self.dayLabel.textColor = [UIColor blackColor];
        if (selected) {
           // self.dayLabel.textColor = [UIColor redColor];
          //  self.lunarLabel.textColor = [UIColor redColor];
            self.selectedMarkImage.image=[StringUtil getImageByResName:@"round_ico2.png"];
        }
//        else if (today) {
//          //  self.dayLabel.textColor = [UIColor blueColor];
//          //  self.lunarLabel.textColor = [UIColor blueColor];
//            self.selectedMarkImage.image=[StringUtil getImageByResName:@"round_ico1.png"];
//        }
        else {
          //  self.dayLabel.textColor = [UIColor blackColor];
           // self.lunarLabel.textColor = [UIColor blackColor];
            self.selectedMarkImage.image=nil;

        }

    }

    eCloudDAO*   db = [eCloudDAO getDatabase];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [fmt stringFromDate:[self.date nsDate]];
    BOOL ishas=[db isTheDateHasSchedule:startdate];
    UIButton *button=(UIButton *)[self.dayLabel viewWithTag:1];
   
    for (UIView *view in [self.dayLabel subviews]) {
        [view removeFromSuperview];
    }
    button.hidden=YES;
    [fmt release];

    if (ishas) {
        int num= [db getUnreadHelperNumByDate:startdate];
        if (num>0) {
            NSString*numstr=[NSString stringWithFormat:@"%d",num];
            UIButton *redbutton=[[UIButton alloc]initWithFrame:CGRectMake(30, 30, 16, 16)];
            [redbutton setBackgroundImage:[StringUtil getImageByResName:@"app_new_push.png"] forState:UIControlStateNormal];
            [redbutton setTitle:numstr forState:UIControlStateNormal];
            redbutton.titleLabel.font=[UIFont systemFontOfSize:12];
            redbutton.userInteractionEnabled=NO;
            redbutton.tag=1;
            [self.dayLabel addSubview:redbutton];
            [redbutton release];
        }else
        {
            int sumnum=[db getHadreadHelperNumByDate:startdate];
            NSString*numstr=[NSString stringWithFormat:@"%d",sumnum];
            UIButton *redbutton=[[UIButton alloc]initWithFrame:CGRectMake(30, 30, 16, 16)];
            [redbutton setBackgroundImage:[StringUtil getImageByResName:@"News_notes_gray.png"] forState:UIControlStateNormal];
            [redbutton setTitle:numstr forState:UIControlStateNormal];
            redbutton.titleLabel.font=[UIFont systemFontOfSize:12];
            redbutton.userInteractionEnabled=NO;
            redbutton.tag=1;
            [self.dayLabel addSubview:redbutton];
            [redbutton release];
        }
       
    }
//    if (eventsCount == 0) {
//        self.eventCountLabel.text = @"";
//    } else {
//        self.eventCountLabel.text = [NSString stringWithFormat:@"%i", eventsCount];
//    }
}

@end
