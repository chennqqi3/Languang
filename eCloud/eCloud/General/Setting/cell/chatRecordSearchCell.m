//
//  chatRecordSearchCell.m
//  eCloud
//
//  Created by shinehey on 15/2/3.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "chatRecordSearchCell.h"

@implementation chatRecordSearchCell

-(void)dealloc
{
//    self.convName = nil;
    self.convNameLalbel = nil;
    [super dealloc];
}

-(void)configCell:(Conversation *)conv andSearchStr:(NSString *)searchStr
{
    [self configLogo:conv];
    
    [self configConvName:conv andSearchStr:searchStr];
    
    [self configTime:conv];
    
    [self configDetail:conv];
    [self configRcvFlagView:conv];
}

//不要自定义左滑
-(void)configCell:(Conversation *)conv
{
    [self configLogo:conv];
    
    [self configConvName:conv];
    
    [self configTime:conv];
    
    [self configDetail:conv];
    [self configRcvFlagView:conv];
}


- (void)configConvName:(Conversation *)conv andSearchStr:(NSString *)searchStr
{
    NSString *convName = conv.conv_title;
    
    UILabel *namelabel = (UILabel *)[self.contentView viewWithTag:conv_name_tag];
    namelabel.font = [UIFont boldSystemFontOfSize:14];
    float contentWidth = [self getContentWidth];
    
    float width = contentWidth;
    
    if (conv.displayTime)
    {
        width = contentWidth - time_width;
    }
    CGRect _frame = namelabel.frame;
    _frame.size.width = width;
    
    [namelabel removeFromSuperview];
    
    if (self.convNameLalbel == nil) {
        self.convNameLalbel = [[LastRecordView alloc] initWithFrame:_frame];
    }
    self.convNameLalbel.specialColor = [UIColor colorWithRed:63.0/255.0 green:180.8/255.0 blue:8.0/255.0 alpha:1];
    self.convNameLalbel.specialStr = conv.specialStr;
    self.convNameLalbel.msgBody = convName;
    self.convNameLalbel.textFont = [UIFont systemFontOfSize:16.5f];
    self.convNameLalbel.textColor = [UIColor darkGrayColor];
    self.convNameLalbel.maxWidth = width;// [self getContentWidth]-2;
    [self.convNameLalbel display];
    
    [self.cellView addSubview:self.convNameLalbel];
    
//    LastRecordView *convNameLalbel = [[LastRecordView alloc] initWithFrame:_frame];
//    
//    convNameLalbel.specialColor = [UIColor colorWithRed:65/255.0 green:180/255.0 blue:245/255.0 alpha:1];
//    convNameLalbel.specialStr = searchStr;
//    convNameLalbel.msgBody = convName;
//    convNameLalbel.textFont = [UIFont systemFontOfSize:16.5f];
//    convNameLalbel.textColor = [UIColor darkGrayColor];
//    convNameLalbel.maxWidth = [self getContentWidth]-2;
//    [convNameLalbel display];
//    
//    [self.cellView addSubview:convNameLalbel];
//    [convNameLalbel release];
}

//- (float)getContentWidth
//{
//    return self.frame.size.width - 20 - chatview_logo_size - 10 - 20;
//}

/*
- (void)configConvName:(Conversation *)conv andSearchStr:(NSString *)searchStr
{
//    startIndex = 0;
//    endIndex = 0;
    
    NSString *convName = conv.conv_title;
//    NSLog(@"%@",[self get:convName1 and:searchStr]);
//    NSString *convName = [self get:convName1 and:searchStr];
    
    UILabel *namelabel = (UILabel *)[self.contentView viewWithTag:conv_name_tag];
    namelabel.font = [UIFont boldSystemFontOfSize:14];
    float contentWidth = [self getContentWidth];
    
    float width = contentWidth;
    
    if (conv.displayTime)
    {
        width = contentWidth *0.8;
    }
    CGRect _frame = namelabel.frame;
    _frame.size.width = width;
    
    
    //搜索词只包含一次
    if (([[convName componentsSeparatedByString:searchStr] count]-1) == 1) {
        NSRange colorStrRange = [convName rangeOfString:searchStr options:NSCaseInsensitiveSearch];
        NSMutableAttributedString *tempStr = [[[NSMutableAttributedString alloc] initWithString:convName] autorelease];
        [tempStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:65/255.0 green:180/255.0 blue:245/255.0 alpha:1] range:colorStrRange];
        namelabel.attributedText = tempStr;
    }else
    {
        self.convName = [[NSMutableAttributedString alloc]initWithString:convName];
        namelabel.attributedText = [self getMutableIncludeStr:convName andSearchStr:searchStr];
    }
}

-(NSMutableAttributedString *)getMutableIncludeStr:(NSString *)convName andSearchStr:(NSString *)searchStr
{
    NSRange colorStrRange = [convName rangeOfString:searchStr options:NSCaseInsensitiveSearch];
    
    colorStrRange =  NSMakeRange(colorStrRange.location+startIndex, colorStrRange.length);
    
    [self.convName addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:65/255.0 green:180/255.0 blue:245/255.0 alpha:1] range:colorStrRange];
    
    startIndex =colorStrRange.location+colorStrRange.length;
    endIndex = convName.length -startIndex;
    
    NSString *subStr = [convName substringWithRange:NSMakeRange(startIndex, endIndex)];

    if (subStr.length>0) {
        [self getMutableIncludeStr:subStr andSearchStr:searchStr];
    }
    
    return self.convName;
}

-(NSString *)get:(NSString *)convName and:(NSString *)searchStr
{
    static NSString *moreStr = @"...";
    float moreStrWidth = [moreStr sizeWithFont:[UIFont systemFontOfSize:16.5]].width;
    
    //    如果特殊字符很长，或者特殊字符比较靠后，不能够首先显示，则要先处理后
    if (searchStr && searchStr.length > 0) {
        NSRange _range = [convName rangeOfString:searchStr options:NSCaseInsensitiveSearch];
        
        if (_range.length > 0) {
            int loc = _range.location;
            if (loc > 0) {
                NSString *tailStr = [convName substringFromIndex:(_range.location + _range.length)];
                NSString *headerStr = [convName substringToIndex:(_range.location + _range.length)];
                
                //                特殊字符的尺寸
                float specialStrWidth = [searchStr sizeWithFont:[UIFont systemFontOfSize:16.5]].width;
                
                CGSize _size = [headerStr sizeWithFont:[UIFont systemFontOfSize:16.5]];
                if (_size.width + specialStrWidth >= [self getContentWidth] - 2 * moreStrWidth) {
                    int subIndex = 0;
                    while (_size.width + specialStrWidth >= [self getContentWidth] - 2 * moreStrWidth ) {
                        if (subIndex == loc) {
                            break;
                        }
                        headerStr = [headerStr substringFromIndex:1];
                        subIndex ++ ;
                        _size = [headerStr sizeWithFont:[UIFont systemFontOfSize:16.5]];
                    }
                    convName = [NSString stringWithFormat:@"%@%@%@",moreStr,headerStr,tailStr];
                    return convName;
                    //                    NSLog(@"缩减后的msgbody:%@",self.msgBody);
                }else
                {
                    return convName;
                }
            }
            else
            {
                return convName;
            }
        }
        else
        {
            return convName;
        }
    }
}
*/

@end
