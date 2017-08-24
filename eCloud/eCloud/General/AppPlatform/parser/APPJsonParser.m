//
//  APPJsonParser.m
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPJsonParser.h"
#import "APPToken.h"
#import "APPListModel.h"
#import "APPStateRecord.h"
#import "APPPushNotification.h"

#import "JSONKit.h"
#import "LogUtil.h"
#import "eCloudDefine.h"


//应用列表消息定义
#define key_app_id  @"appid" //应用编号
#define key_app_synctype  @"synctype" //更新类型：1 新增、2 修改、3 删除(更新类型为3时后面的元素都不需要)
#define key_app_type  @"apptype"      //应用类型：1  HTML5、2 原生app
#define key_app_scope  @"appscope"    //应用范围：1 指定、2 公共
#define key_app_name  @"appname"      //应用名称
#define key_app_icon  @"appicon"      //应用图标url
#define key_app_vers  @"appvers"      //应用版本号
#define key_app_uptime  @"uptime"        //更新时间
#define key_app_serverurl  @"serverurl" //服务URL：应用类型为 1 表示主页URL、为2 表示app下载地址
#define key_app_permission  @"permission" //应用权限：两个字节转成2进制16位每位代表一个权限该位为1表示具有该权限
#define key_app_cacheurl  @"cacheurl"   //缓存URL：最多5个
#define key_app_showflag  @"showflag"              //应用推送是否在首页显示：1 显示 0 不显示
#define key_app_desc    @"appdesc"  //应用简介文字描述
#define key_app_pics    @"apppics"  //应用简介图片
#define key_app_groupId    @"groupId"  //分组
#define key_app_apphomepage    @"apphomepage"  //主页
#define key_app_apppage1    @"apppage1"  //备用页面
#define key_app_iosbundleid @"iosbudleid" //轻应用对应的类名
#define key_app_logopath    @"logopath"  //轻应用图标
#define key_app_sort    @"sort"  //应用序列
#define key_app_updatetime    @"updatetime"  //更新时间
#define key_app_updatetpe    @"updatetpe"  //操作类型
#define key_app_status    @"status"  //是否需要广告页


//token消息定义
#define key_app_usercode  @"usercode" //工号
#define key_app_token @"token"        //Token:工号+时间戳(到毫秒)+5位随机数做MD5加密

//应用推送通知
#define key_app_notinum  @"notinum" //相关通知数量
#define key_app_pri  @"pri"         //优先级 范围：0-10 数字越大优先级越高
#define key_app_title  @"title"     //通知标题
#define key_app_summary  @"summary" //概要
#define key_app_pushurl  @"pushurl" //推送消息URL
#define key_app_notitime  @"notitime" //通知时间:yyyymmddhhmiss
#define key_app_src  @"src" ////消息发送者

//NSString *str = @"{\"applist\":[{\"appid\":\"11111\",\"synctype\":\"1\",\"apptype\":\"1\",\"appscope\":\"2\",\"appname\":\"应用1\",\"appicon\":\"http://a4.att.hudong.com/57/83/300245751203132333832384935_950.jpg\",\"appvers\":\"2.1.3\",\"uptime\":\"2014-06-17\",\"serverurl\":\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\",\"cacheurl\":[\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\",\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\"],\"permission\":\"11111111111\"},{\"appid\":\"2222222\",\"synctype\":\"1\",\"apptype\":\"1\",\"appscope\":\"2\",\"appname\":\"应用2\",\"appicon\":\"http://www.kumi.cn/photo/48/2a/fb/482afbfa43cd971d.jpg\",\"appvers\":\"2.1.3\",\"uptime\":\"2014-06-17\",\"serverurl\":\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\",\"cacheurl\":[\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\",\"http://tech.firefox.163.com/14/0617/09/DY9SQV3XK4FEU2BH.html\"],\"permission\":\"11111111111\"}]}";


@implementation APPJsonParser

#pragma mark - 解析应用列表数据
-(NSMutableArray *)parseAPPListModel:(NSString*)appListStr{
	NSData* jsonData = [appListStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"appListStr--------%@",appListStr);
    
	NSDictionary *dic = [jsonData objectFromJSONData];
    NSMutableArray *temArr = [NSMutableArray arrayWithArray:[dic objectForKey:@"upapplist"]];
    NSLog(@"temArr--------%@",temArr);
    
    if (![temArr count]) {
        return nil;
    }
    
    NSMutableArray *APPListModelArr = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in temArr) {
        [APPListModelArr addObject:[self getAPPListModelFromDictionary:dic]];
    }
    
    return [APPListModelArr autorelease];
}

- (APPListModel *)getAPPListModelFromDictionary:(NSDictionary *)dic{
    APPListModel *appModel = [[APPListModel alloc] init];
//    appModel.synctype = [[dic objectForKey:key_app_synctype] intValue];
    appModel.updatetype = [[dic objectForKey:key_app_updatetpe]intValue];
    
    //根据应用类型区分
    if ( 1 == appModel.updatetype) {
        //新增
        appModel.appid = [[dic objectForKey:key_app_id]intValue];
        appModel.apptype = [[dic objectForKey:key_app_type] intValue];
        appModel.appscope = [[dic objectForKey:key_app_scope] intValue];
        appModel.appname = [dic objectForKey:key_app_name];
        appModel.appicon = [dic objectForKey:key_app_icon];
        appModel.appvers = [dic objectForKey:key_app_vers];
//        appModel.uptime = [dic objectForKey:key_app_uptime];
        appModel.serverurl = [dic objectForKey:key_app_serverurl];
        appModel.permission = [[dic objectForKey:key_app_permission] intValue];
        appModel.cacheurl = [dic objectForKey:key_app_cacheurl];
        appModel.showflag = [[dic objectForKey:key_app_showflag] intValue];
        appModel.appdesc = [dic objectForKey:key_app_desc];
        appModel.apppics = [dic objectForKey:key_app_pics];
        appModel.groupId = [[dic objectForKey:key_app_groupId] intValue];
        appModel.apphomepage = [dic objectForKey:key_app_apphomepage];
        if ([UIAdapterUtil isGOMEApp])
        {
            appModel.apppage1 = [dic objectForKey:key_app_iosbundleid];
        }
        else
        {
            appModel.apppage1 = [dic objectForKey:key_app_apppage1];
        }
        appModel.logopath = [dic objectForKey:key_app_logopath];
        appModel.sort = [[dic objectForKey:key_app_sort]intValue];
        appModel.uptime = [dic objectForKey:key_app_updatetime];
        appModel.updatetype = [[dic objectForKey:key_app_updatetpe]intValue];
        
        appModel.isnew = 1;//新应用
        appModel.appShowFlag = 0;//没有添加到我的页面
        appModel.downloadFlag = 0; //默认是未下载
        
        appModel.status = [dic objectForKey:[NSString stringWithFormat:@"%@",key_app_status]];
    }
    else if (2 == appModel.updatetype){
        //修改
        appModel.appid = [[dic objectForKey:key_app_id]intValue];
        appModel.apptype = [[dic objectForKey:key_app_type] intValue];
        appModel.appscope = [[dic objectForKey:key_app_scope] intValue];
        appModel.appname = [dic objectForKey:key_app_name];
        appModel.appicon = [dic objectForKey:key_app_icon];
        appModel.appvers = [dic objectForKey:key_app_vers];
//        appModel.uptime = [dic objectForKey:key_app_uptime];
        appModel.serverurl = [dic objectForKey:key_app_serverurl];
        appModel.permission = [[dic objectForKey:key_app_permission] intValue];
        appModel.cacheurl = [dic objectForKey:key_app_cacheurl];
        appModel.showflag = [[dic objectForKey:key_app_showflag] intValue];
        appModel.appdesc = [dic objectForKey:key_app_desc];
        appModel.apppics = [dic objectForKey:key_app_pics];
        appModel.groupId = [[dic objectForKey:key_app_groupId] intValue];
        appModel.apphomepage = [dic objectForKey:key_app_apphomepage];
        if ([UIAdapterUtil isGOMEApp])
        {
            appModel.apppage1 = [dic objectForKey:key_app_iosbundleid];
        }
        else
        {
            appModel.apppage1 = [dic objectForKey:key_app_apppage1];
        }
        appModel.logopath = [dic objectForKey:key_app_logopath];
        appModel.sort = [[dic objectForKey:key_app_sort]intValue];
        appModel.uptime = [dic objectForKey:key_app_updatetime];
        appModel.updatetype = [[dic objectForKey:key_app_updatetpe]intValue];
        appModel.status = [dic objectForKey:[NSString stringWithFormat:@"%@",key_app_status]];
    }
    else if (3 == appModel.updatetype){
        //删除
        appModel.appid = [dic objectForKey:key_app_id];
    }
    
    return [appModel autorelease];
}

#pragma mark - 解析token数据
-(APPToken *)parseAPPTokenModel:(NSString*)appTokenStr{
    APPToken *appToken = [[APPToken alloc] init];

    NSData* jsonData = [appTokenStr dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *dic = [jsonData objectFromJSONData];
    
    NSLog(@"dic--------%@",dic);
    
    if (![[dic objectForKey:key_app_usercode] length]) {
        return nil;
    }
    appToken.usercode = [dic objectForKey:key_app_usercode];
    appToken.token = [dic objectForKey:key_app_token];
    
    return [appToken autorelease];
}

#pragma mark - 解析应用推送通知数据
-(APPPushNotification *)parseAPPPushNotificationModel:(NSString*)appPushNotifStr{
    APPPushNotification *appPushNotification = [[APPPushNotification alloc] init];
    
    NSData* jsonData = [appPushNotifStr dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *dic = [jsonData objectFromJSONData];
    
    NSLog(@"dic--------%@",dic);
    
    if (![[dic objectForKey:key_app_id] length]) {
        return nil;
    }
    
    appPushNotification.appid = [dic objectForKey:key_app_id];
    appPushNotification.notinum = [[dic objectForKey:key_app_notinum] intValue];
    appPushNotification.pri = [[dic objectForKey:key_app_pri] intValue];
    appPushNotification.title = [dic objectForKey:key_app_title];
    appPushNotification.summary = [dic objectForKey:key_app_summary];
    appPushNotification.pushurl = [dic objectForKey:key_app_pushurl];
    appPushNotification.src = [dic valueForKey:key_app_src];
    
//    把时间的值转换一下才入库 2014-06-17 21:20:36
    NSString *formatDateStr = [dic objectForKey:key_app_notitime];
    
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *_date = [inputFormatter dateFromString:formatDateStr];
    appPushNotification.notitime = (int)[_date timeIntervalSince1970];
    appPushNotification.read_flag = 0;//未读
    
    return [appPushNotification autorelease];
}


//
//-(APPStateRecord *)parseAPPStateRecordModel:(NSString*)appStateRecordStr{
//    
//}
//
//


@end
