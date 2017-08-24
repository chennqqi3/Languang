//
//  PSMsgJsonParser.m
//  eCloud
//
//  Created by Richard on 13-10-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSMsgJsonParser.h"
#import "JSONKit.h"
#import "LogUtil.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"
#import "ServiceMenuModel.h"
#import "eCloudDefine.h"

//消息类型
#define msg_type_text @"text"
#define msg_type_news @"news"
#define msg_type_image @"image"

#define key_msg_time @"CreateTime"
#define key_service_id @"FromUserName"
#define key_msg_type @"MsgType"
#define key_msg_body @"content"
#define key_msg_image @"media_id"

#define key_detail_count @"ArticleCount"
#define key_detail @"Articles"
#define key_detail_desc @"description"
#define key_detail_pic @"picurl"
#define key_detail_title @"title"
#define key_detail_link @"url"


#define key_menulist_platformid @"appid"
#define key_menulist_create @"createtime"
#define key_menulist_button @"button"
#define key_menulist_subbutton @"subbutton"
#define key_menulist_sub_button @"sub_button"
#define key_menulist_name @"name"
#define key_menulist_type @"type"
#define key_menulist_url @"url"
#define key_menulist_key @"key"

@implementation PSMsgJsonParser
//{"ToUserName":"gmcc003","FromUserName":"1","CreateTime":"1383101992","MsgType":"text","content":"123"}

//{"ToUserName":"gmcc003","FromUserName":"1","CreateTime":"1383102697","MsgType":"news","ArticleCount":"4","Articles":[{"title":"垂直的天空,2013天津直升机展","description":"","picurl":"http://120.132.153.6:8080/20130907090935b0345.jpg","url":""},{"title":"AW139豪华直升机","description":"","picurl":"http://120.132.153.6:8080/20130907085345bda3f.jpg","url":""},{"title":"体验先进设备","description":"","picurl":"http://120.132.153.6:8080/20130907085347640ec.jpg","url":""},{"title":"体验豪华机舱","description":"","picurl":"http://120.132.153.6:8080/201309070853500b97a.jpg","url":""}]}

//{"ToUserName":"gmcc003","FromUserName":"1","CreateTime":"1383107593","MsgType":"news","ArticleCount":"1","Articles":[{"title":"垂直的天空,2013天津直升机展","description":"","picurl":"http://120.132.153.6:8080/20130907090935b0345.jpg","url":""}]}

-(ServiceMessage *)parsePsMsg:(NSString*)psMsg
{
	ServiceMessage *_msg = [[ServiceMessage alloc]init];
	_msg.msgFlag = rcv_msg;//收消息
	_msg.readFlag = 1;//未读
	
	NSData* jsonData = [psMsg dataUsingEncoding:NSUTF8StringEncoding];
    
	NSDictionary *dic = [jsonData objectFromJSONData];
//    NSLog(@"dic-------------%@",dic);
//    
	
//	消息时间
	int msgTime = [[dic valueForKey:key_msg_time]intValue];
	_msg.msgTime = msgTime;
	
//	发送人
	int serviceId = [[dic valueForKey:key_service_id]intValue];
	_msg.serviceId = serviceId;

//	消息类型，默认为文本类型
	_msg.msgType = -1;
	
	NSString *msgType = [dic valueForKey:key_msg_type];
	if([msgType isEqualToString:msg_type_text])
	{
		_msg.msgType = ps_msg_type_text;
//		普通文本消息
		NSString *msgBody = [dic valueForKey:key_msg_body];
		_msg.msgBody = msgBody;
	}
    else if ([msgType isEqualToString:msg_type_image])
    {
        _msg.msgType = ps_msg_type_pic;
        NSDictionary *imageDic = [dic valueForKey:msg_type_image];
        //  图片
        NSString *msgBody = [imageDic valueForKey:key_msg_image];
//        直接把URL保存在body里
        _msg.msgBody = msgBody;
//        _msg.msgUrl = msgBody;
    }
	else if([msgType isEqualToString:msg_type_news])
	{
//		新闻
		_msg.msgType = ps_msg_type_news;
		
//		明细条数
		int detailCount = [[dic valueForKey:key_detail_count]intValue];
		NSMutableArray *details = [[NSMutableArray alloc]initWithCapacity:detailCount];
		
//		消息明细内容
		NSArray *dtlArray = [dic valueForKey:key_detail];
		
		ServiceMessageDetail *_dtl;
		NSString *dtlTitle;
		NSString *dtlPic;
		NSString *dtlLink;
		NSString *dtlDesc;
		
		for(NSDictionary *dic in dtlArray)
		{
			dtlTitle = [dic valueForKey:key_detail_title];
			dtlPic = [dic valueForKey:key_detail_pic];
			dtlLink = [dic valueForKey:key_detail_link];
			dtlDesc = [dic valueForKey:key_detail_desc];

			_dtl = [[ServiceMessageDetail alloc]init];
			_dtl.msgBody = dtlTitle;
			_dtl.msgUrl = dtlPic;
			_dtl.msgLink = dtlLink;
			if(detailCount == 1)
			{
//				如果是单条图文消息，把描述信息保存在主表的msgBody当中
				_msg.msgBody = dtlDesc;
			}
			[details addObject:_dtl];
			[_dtl release];
		}
		_msg.detail = details;
		[details release];
	}
	
	return [_msg autorelease];
}

#pragma amrk - 解析公众平台菜单
-(NSMutableArray *)parsePSMenuList:(NSString*)menuListStr{
    NSData* jsonData = [menuListStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [jsonData objectFromJSONData];
    NSMutableArray *temArr = [NSMutableArray arrayWithArray:[dic objectForKey:@"Menus"]];

    if (![temArr count]) {
        return nil;
    }
    
    NSMutableArray *APPListModelArr = [[NSMutableArray alloc] init];
    for (NSDictionary *menu in temArr) {
//        // 创建时间和id
//        NSString *createtime = menu[key_menulist_create];
//        NSString *platformid = menu[key_menulist_platformid];
//        // 获取一级菜单集合
//        NSMutableArray *firstMenuArrays = menu[@"button"];
//    
//        // 解析一级菜单
//        for (int i = 0;i < firstMenuArrays.count;i++) {
//            NSDictionary *firstDictionary = firstMenuArrays[i];
//            // 处理子菜单
//            if (firstDictionary[key_menulist_sub_button] != nil)
//            {
//                NSMutableArray *subMenuArrays = menu[key_menulist_sub_button];
//                for (int j = 0;j < subMenuArrays.count;j++) {
//                    NSDictionary *subDictionary = subMenuArrays[j];
//                    
//                    [APPListModelArr addObject:[self getPSmenuListModelFromDictionary:subDictionary andParentIndex:i+1 andSubIndex:j+1 andPlatformid:platformid andCreatetime:createtime]];
//                }
//            }
//            // 有无子菜单都要添加
//            [APPListModelArr addObject:[self getPSmenuListModelFromDictionary:firstDictionary andParentIndex:i+1 andSubIndex:0 andPlatformid:platformid andCreatetime:createtime]];
//        }
        
        [APPListModelArr addObject:[self getPSmenuListModelFromDictionary:menu]];
    }
    
    return [APPListModelArr autorelease];
}
- (ServiceMenuModel *)getPSmenuListModelFromDictionary:(NSDictionary *)dic{
    ServiceMenuModel *menuModel = [[ServiceMenuModel alloc] init];
    menuModel.platformid = [[dic objectForKey:key_menulist_platformid] intValue];
    menuModel.createtime = [dic objectForKey:key_menulist_create];
    menuModel.button = [dic objectForKey:key_menulist_button];
    
    return [menuModel autorelease];
}
//- (ServiceMenuModel *)getPSmenuListModelFromDictionary:(NSDictionary *)dic  andParentIndex:(int)parentIndex andSubIndex:(int)subIndex andPlatformid:(NSString *)platformid andCreatetime:(NSString *)createtime{
//    ServiceMenuModel *menuModel = [[ServiceMenuModel alloc] init];
//    menuModel.platformid = [[dic objectForKey:key_menulist_platformid] intValue];
//    menuModel.createtime = [dic objectForKey:key_menulist_create];
//    menuModel.button = [dic objectForKey:key_menulist_button];
//    
//    return [menuModel autorelease];
//}

@end
