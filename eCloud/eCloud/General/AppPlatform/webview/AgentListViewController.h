//
//  AgentListViewController.h
//  eCloud
//
//  Created by yanlei on 15/8/19.
//  Copyright (c) 2015年  lyong. All rights reserved.
//  第三方轻应用(这里主要指办公界面除邮箱、文件助手)显示的界面

#import <UIKit/UIKit.h>

@class PictureManager;

/** 爱关怀  url拦截关键字 */
#define KEY_AIGUANHUAI @"g.aghcdn.com"

/** 面试官工作台  url拦截关键字 */
#define KEY_INTERVIEW_PLATFORM @"/interviewPlatform/"

/** 我要推荐  url拦截关键字 */
#define KEY_JUXIAN @"/juxian/"

typedef enum {
    direction_landscape = 0,    // 横屏
    direction_portrait = 1      // 竖屏
}directionType;

/** webview组件的tag标识 */
#define WEBVIEW_TAG (101)

@interface AgentListViewController : UIViewController{
    /** (已废弃) 第三方图片管理器 */
    PictureManager *pictureManager;
    /** (已废弃) 发送图片时用到的定时器 */
    NSTimer *manypicTimer;
    /** (已废弃) 多图发送时存放图片的数组 */
    NSMutableArray *manyPicArray;
    /** (已废弃) 多图发送时记录当前发送图片的下标 */
    int pic_index;
    
}
/** 要进行加载url字符串 */
@property(nonatomic,retain) NSString *urlstr;
/** 链接来源，如：点击的网页的链接 */
@property(nonatomic,assign) int navigationType;
/** 是否需要界面刷新 */
@property(nonatomic,assign) BOOL isrefresh;
/** 拦截所有接口 默认是YES；NO时只拦截标准的接口 */
@property (nonatomic,assign) BOOL interceptAll;
/** 记录来源，当点击左上角回退按钮时进行逻辑区分 */
@property(nonatomic,retain)NSString *isForm;
/** 是否需要隐藏左侧按钮 YES:进行隐藏   NO:不隐藏*/
@property (nonatomic,assign) BOOL isNeetHideLeftBtn;
/** (已废弃) 临时保存上次的url，作用与当前加载的url进行比对 */
@property(nonatomic,retain)	NSString *curUrlStr;
/** (已废弃) 代理变量 */
@property(assign)id delegete;

/**
 横竖屏切换

 @param curVC         当前操作的控制器
 @param directionType 0:横屏，1竖屏。
 */
+ (void)changeOrientation:(UIViewController *)curVC andDirection:(int)directionType;
@end
