//
//  ChineseToPinyin.h
//  LianPu
//
//  Created by shawnlee on 10-12-16.
//  Copyright 2010 lianpu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define pinyin_all_with_space @"pinyin_all_with_space"
#define pinyin_all @"pinyin_all"
#define pinyin_simple @"pinyin_simple"

@interface ChineseToPinyin : NSObject {

}

+ (NSString *) pinyinFromChiniseString:(NSString *)string;

//add by shisp
//返回一个带空格的全拼 一个不带空格的全拼 一个简拼
+ (NSDictionary *)getPinyinFromString:(NSString *)string;
@end
