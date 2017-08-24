//
//  AppListBtnModel.h
//  AppList
//
//  Created by Pain on 14-6-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

//apptype; //应用类型：1-10   1.应用汇 2.联系人 3.服务号 4.日程 5.南航热点  6.木棉童飞 7.一呼万应  10.第三方应用
// 8. 文件助手
#import <Foundation/Foundation.h>
@class APPListModel;

@interface AppListBtnModel : NSObject{
    
}
@property(nonatomic,retain) NSString *appname; //应用名称
@property(nonatomic) int apptype; //应用类型：1-10
@property(nonatomic) BOOL start_Delete; //应用类型：0:不显示  1：显示
@property(nonatomic,retain) NSString *appicon;//应用图标：系统应用为图片名称，第三方应用为空
@property(nonatomic,retain) APPListModel *appModel; //应用数据模型，系统的应用为空，第三方的应用不为空

@end
