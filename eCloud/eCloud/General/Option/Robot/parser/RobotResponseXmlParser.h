//
//  RobotResponseXmlParser.h
//  eCloud
//  解析机器人回复
//  Created by yanlei on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RobotResponseModel.h"

#define type_musicmsg @"musicmsg"
#define type_imgtxtmsg @"imgtxtmsg"
#define type_wikimsg @"wiki"
#define type_videomsg @"videomsg"
#define type_imgmsg @"imgmsg"

#define IROBOT_SERVER @"xiaoi.wanda.cn"

@interface RobotResponseXmlParser : NSObject<NSXMLParserDelegate>

//机器人消息模型
@property (nonatomic,retain) RobotResponseModel *robotModel;

/*
 功能描述
 解析机器人回复
 
 参数
 syncRes:机器人回复
 flag:是否解析人工服务 在聊天界面显示时，要求解析人工服务，点击人工服务器，可以打开虚拟组会话
 */
-(bool)parse:(NSString*)syncRes andIsParseAgent:(BOOL)flag;

//#pragma mark - 解析图文信息
//- (void)parserImgtxtInfo:(NSString *)imgtxtInfo count:(int)imgtxtCount;

@end
