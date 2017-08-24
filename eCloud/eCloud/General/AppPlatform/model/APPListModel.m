//
//  APPModel.m
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPListModel.h"

@implementation APPListModel
@synthesize update_time;
@synthesize apptype;
@synthesize appscope;
@synthesize appname;
@synthesize appicon;
@synthesize appvers;
@synthesize uptime;
@synthesize serverurl;
@synthesize permission;
@synthesize cacheurl;

@synthesize isnew;
@synthesize appShowFlag;
@synthesize downloadFlag;
@synthesize appdesc;
@synthesize apppics;

@synthesize unread;
@synthesize status;

- (void)dealloc{
    self.appauthname = nil;
    self.appauthpwd = nil;
    self.apphomepage = nil;
    self.apppage1 = nil;
    self.apppage2 = nil;
    self.logopath = nil;
    self.appname = nil;
    self.appicon = nil;
    self.appvers = nil;
    self.uptime = nil;
    self.serverurl = nil;
    self.cacheurl = nil;
    self.appdesc = nil;
    self.apppics = nil;
    self.status = nil;
    [super dealloc];
}

/*
 这是以前 潘德为 的 定义
 @property (nonatomic,retain) NSString *appid; //应用编号
 @property(assign) int synctype;//更新类型：1 新增、2 修改、3 删除(更新类型为3时后面的元素都不需要)
 @property(assign) int apptype; //应用类型：1  HTML5、2 原生app
 @property(assign) int appscope;//应用范围：1 指定、2 公共
 @property(nonatomic,retain) NSString *appname; //应用名称
 @property(nonatomic,retain) NSString *appicon;//应用图标url
 @property(nonatomic,retain) NSString *appvers;   //应用版本号
 @property(nonatomic,retain) NSString *uptime;    //更新时间
 @property(nonatomic,retain) NSString *serverurl; //服务URL：应用类型为 1 表示主页URL、为2 表示app下载地址
 @property(assign) int permission;//应用权限：两个字节转成2进制16位每位代表一个权限该位为1表示具有该权限 第三方应用使用接口的权限
 @property(nonatomic,retain) NSArray *cacheurl;  //缓存URL：最多5个
 
 @property(assign) int isnew;                 //0.不是新应用 1.新应用
 @property(assign) int appShowFlag;              //是否添加到我的页面 0.没有 1.已添加到我的页面
 
 @property(assign) int showflag;              //应用推送是否在首页显示：1 显示 0 不显示
 @property(assign) int downloadFlag;              //应用是否已经下载：1 已下载 0 未下载
 
 @property(nonatomic,retain) NSString *appdesc; //应用简介文字描述
 @property(nonatomic,retain) NSArray *apppics;  //应用简介图片
 */
@end
