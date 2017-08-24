//
//  Screen.h
//  InsectScoring
//
//  Created by lidianchao on 2017/7/17.
//  Copyright © 2017年 lidianchao. All rights reserved.
//

#ifndef Screen_h
#define Screen_h


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIImageSize(image) image.size
#define RealSize(size) (size)/2
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenRect [UIScreen mainScreen].bounds
#define kIPHONE5sWIDTH 375
#define kIPHONE5sHEIGHT 667

#define NavigationBarHeight [[UIApplication sharedApplication] statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height

#define FixedHeight(fixedHeight) fixedHeight/([UIScreen mainScreen].bounds.size.height/IPHONE5sHEIGHT)

#define kGetCurrentValue(value) value

#define ZeroX 0
#define ZeroY 0

#endif /* Screen_h */
