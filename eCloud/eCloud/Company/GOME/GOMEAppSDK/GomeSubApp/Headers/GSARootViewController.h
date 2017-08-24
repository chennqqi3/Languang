//
//  ViewController.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/25.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import "GSAHeader.h"

typedef NS_ENUM(NSInteger, GSARightBarItemType) {
    GSARightBarItemText = 0,
    GSARightBarItemImage
};

@interface GSARootViewController : UIViewController
/**
 设置title

 @param title titleStr
 */
- (void)setNaviTitle:(NSString *)title;
/**
 设置右侧按钮

 @param str 右侧按钮样式为文字时为Btn的Title,为图片是为ImageName
 */
- (void)setRightBarItemWithType:(GSARightBarItemType)type
                         String:(NSString *)str
                       Selector:(SEL)selector;

@end

