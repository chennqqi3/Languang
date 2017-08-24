//
//  LGInvoiceUtilARC.m
//  eCloud
//
//  Created by Ji on 17/7/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceUtilARC.h"

@implementation LGInvoiceUtilARC


+ (BOOL)isLowerLetter:(NSString *)str
{
    if (str.length) {
        
        if (([str characterAtIndex:0] >= 'a' && [str characterAtIndex:0] <= 'z') || ([str characterAtIndex:0] >= 'A' && [str characterAtIndex:0] <= 'Z')){
            
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isChinese:(NSString *)str
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}

+ (UITextView *)contentSizeToFit:(UITextView *)View
{
    //先判断一下有没有文字（没文字就没必要设置居中了）
    UITextView * textView = View;
    //    if([textView.text length]>0)
    //    {
    //textView的contentSize属性
    CGSize contentSize = textView.contentSize;
    //textView的内边距属性
    UIEdgeInsets offset;
    CGSize newSize = contentSize;
    
    //如果文字内容高度没有超过textView的高度
    if(contentSize.height <= textView.frame.size.height)
    {
        //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
        CGFloat offsetY = (textView.frame.size.height - contentSize.height)/2;
        if ([textView.text length] == 0) {
            offsetY += 7;
        }
        offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    }
    //        else          //如果文字高度超出textView的高度
    //        {
    //            newSize = textView.frame.size;
    //            offset = UIEdgeInsetsZero;
    //            CGFloat fontSize = 18;
    //
    //            //通过一个while循环，设置textView的文字大小，使内容不超过整个textView的高度（这个根据需要可以自己设置）
    //            while (contentSize.height > textView.frame.size.height)
    //            {
    //                [textView setFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize--]];
    //                contentSize = textView.contentSize;
    //            }
    //            newSize = contentSize;
    //        }
    
    //根据前面计算设置textView的ContentSize和Y方向偏移量
    [textView setContentSize:newSize];
    [textView setContentInset:offset];
    
    //}
    
    return textView;
}

@end
