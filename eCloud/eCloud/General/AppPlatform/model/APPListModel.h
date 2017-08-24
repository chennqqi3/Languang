//
//  APPModel.h
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

//-----应用信息--------//
#import <Foundation/Foundation.h>

@interface APPListModel : NSObject
/*
 以下属性对应了管理台里轻应用的配置
 */
/** 应用编号      (NSString->int) */
@property(assign) int appid;
/** 应用名称 */
@property(nonatomic,retain) NSString *appname;
/** 鉴权账号 */
@property(nonatomic,retain) NSString *appauthname;
/** 鉴权密码 */
@property(nonatomic,retain) NSString *appauthpwd;
/** 轻应用是否具备全员属性 1：企业全员均具备此轻应用 */
@property(assign) int appauthtype;
/** 应用首页链接 */
@property(nonatomic,retain) NSString *apphomepage;
/** 应用其他链接 */
@property(nonatomic,retain) NSString *apppage1;
/** 应用其他链接 */
@property(nonatomic,retain) NSString *apppage2;
/** logo下载路径 */
@property(nonatomic,retain) NSString *logopath;
/** 应用排序位  客户端显示排序 */
@property (assign) int sort;
/** 更新时间 */
@property (assign) int update_time;
/** 更新类型：1 新增、2 修改、3 删除(更新类型为3时后面的元素都不需要)   (synctype->updatetype) */
@property(assign) int updatetype;
/** 应用状态 */
@property(nonatomic,retain) NSString *status;
/** 分组 */
@property(assign) int groupId;
/*
 以下属性可能不在需要
 */
@property(assign) int apptype; //应用类型：1  HTML5、2 原生app
@property(assign) int appscope;//应用范围：1 指定、2 公共
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

//增加一个属性 应用未读消息数
@property (nonatomic,assign) int unread;

@end
