//
//  RobotResponseXmlParser.m
//  eCloud
//
//  Created by yanlei on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "RobotResponseXmlParser.h"
#import "LogUtil.h"
#import "RobotResponseModel.h"
#import "eCloudDefine.h"
#import "PersonServiceSingle.h"

/*
 <?xml version="1.0"?>
 <robotResponse>
 <commands>
 <args>钢琴曲</args>
 <args>http://xiaoi.wanda.cn/robot/attachments/20151104165003276</args>
 <args>20151104164934614</args>
 <args>http://xiaoi.wanda.cn/robot/attachments/20151104165003276</args>
 <name>musicmsg</name>
 <state>1</state>
 </commands>
 <moduleId>core</moduleId>
 <nodeId>000000004fedc0310150d1a8050062e2</nodeId>
 <similarity>1.0</similarity>
 <type>1</type>
 </robotResponse>
 */

#define ele_robotResponse @"robotResponse"
#define ele_commands @"commands"
#define ele_args @"args"
#define ele_name @"name"
#define ele_state @"state"
#define ele_moduleId @"moduleId"
#define ele_nodeId @"nodeId"
#define ele_similarity @"similarity"
#define ele_type @"type"
#define ele_content @"content"
#define ele_relatedQuestions @"relatedQuestions"

@implementation RobotResponseXmlParser
{
    NSString *curValue;
    
    // 要解析的字符串
    NSString *parseStr;
    
    int linkCount;
    // 存放标签<relatedQuestions>的集合
    NSMutableArray *relatedQuestionsArr;
}

@synthesize robotModel;
-(void)dealloc
{
    if(curValue)
    {
        [curValue release];
        curValue = nil;
    }
    if (self.robotModel) {
        [self.robotModel release];
        self.robotModel = nil;
    }
    [super dealloc];
}

-(bool)parse:(NSString*)syncRes andIsParseAgent:(BOOL)flag
{
    parseStr = syncRes;
    NSData *xmlData = [syncRes dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *_parser = [[NSXMLParser alloc]initWithData:xmlData];
    [_parser setShouldProcessNamespaces:NO];
    [_parser setShouldReportNamespacePrefixes:NO];
    [_parser setShouldResolveExternalEntities:NO];
    [_parser setDelegate:self];
    [_parser setShouldResolveExternalEntities:YES];
    [_parser parse];
    NSError *error = [_parser parserError];
    
    bool result = true;
    if(error)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,error.description]];
        result = false;
    }
    
    // 如果为图文，要进一步处理图文信息，第二个args为图文的个数，第四个args为图文信息用dictory存储
    if ([self.robotModel.nameString isEqualToString:type_imgtxtmsg]) {
        [self parserImgtxtInfo:syncRes count:[self.robotModel.argsArray[1] intValue]];
    }else if ([self.robotModel.nameString isEqualToString:type_wikimsg]){
        // 有时候wiki标签的描述获取不全，通过字符串截取获取
        NSArray *nameArr = [syncRes componentsSeparatedByString:@"</args><name>"];
        if (nameArr && nameArr.count > 0) {
            NSArray *desArr = [nameArr[0] componentsSeparatedByString:@"</args><args>"];
            if (desArr && desArr.count > 0) {
                robotModel.argsArray[3] = desArr[desArr.count - 1];
            }
        }
        
        NSMutableDictionary *dic = [[[NSMutableDictionary alloc]init]autorelease];
        [dic setValue:robotModel.argsArray[0] forKey:@"Title"];
        [dic setValue:robotModel.argsArray[3] forKey:@"Description"];
        [dic setValue:[robotModel.argsArray[2] stringByReplacingOccurrencesOfString:@"src=" withString:@""] forKey:@"PicUrl"];
        [dic setValue:robotModel.argsArray[1] forKey:@"Url"];
        [self.robotModel.imgtxtArray addObject:dic];
    }
    
    // 处理标签
    if (([syncRes rangeOfString:@"<relatedQuestions>"].length > 0 || [syncRes rangeOfString:@"[link]"].length > 0 || [syncRes rangeOfString:@"[link submit="].length > 0) && [syncRes rangeOfString:@"<content>"].length > 0) {
        
        NSMutableString *tmpStr = [NSMutableString string];
        
        NSRange totalStartRange = [syncRes rangeOfString:@"<content>"];
        NSRange totalEndRange = [syncRes rangeOfString:@"</content>"];
        totalStartRange.location = totalStartRange.location+totalStartRange.length;
        totalStartRange.length = totalEndRange.location - totalStartRange.location;
        [tmpStr appendString:[syncRes substringWithRange:totalStartRange]];
        
        /*
         对小万发送"万信"：
         <?xml version="1.0"?>
         <soap:Body>
         <ns2:askResponse xmlns:ns2="http://www.eastrobot.cn/ws/RobotService">
         <robotResponse>
         <content>为落实企业移动互联战略，提高内部办公和沟通效率，原有的RTX产品由于不能在手机上使用、程序容易死机、使用速度慢等原因已不能满足需求，因此，集团信息管理中心开发了RTX替换产品-万信。万信包括PC客户端、IOS客户端、Android客户端、Mac客户端，满足您全方位的沟通需求。
         </content>
         <moduleId>core</moduleId>
         <nodeId>000000004fedcb6e0150f528661208ca</nodeId>
         <relatedQuestions>日常办公各系统常见问题</relatedQuestions>
         <relatedQuestions>万信有什么版本</relatedQuestions>
         <relatedQuestions>万信聊天记录的位置</relatedQuestions>
         <relatedQuestions>万信可以发送文件大小的上限</relatedQuestions>
         <similarity>1.0</similarity>
         <type>1</type>
         </robotResponse>
         </ns2:askResponse>
         </soap:Body>
         */
        // 增加对<relatedQuestions>标签的处理
        if ([syncRes rangeOfString:@"<relatedQuestions>"].length > 0) {
            if (relatedQuestionsArr && relatedQuestionsArr.count > 0) {
                // 将<relatedQuestions>标签的内容拼接到content之后
                for (NSString *questionStr in relatedQuestionsArr) {
                    [tmpStr appendString:questionStr];
                }
            }
        }
        
        self.robotModel.content = tmpStr;
    }
    // 将人工服务保存到单例中
    if(flag && [syncRes rangeOfString:@"[AGENT]"].length > 0){
        PersonServiceSingle *personServiceSingle = [PersonServiceSingle sharePersonServiceSingle];
        if (!personServiceSingle.personServiceArray) {
            personServiceSingle.personServiceArray = [NSMutableArray array];
        }
        
        if ([syncRes rangeOfString:@"[AGENT]"].length > 0) {
            NSArray *agentsTmpArr = [syncRes componentsSeparatedByString:@"[AGENT]"];
            for (int i = 1; i < agentsTmpArr.count; i++) {
                NSString *agentName = [agentsTmpArr[i] componentsSeparatedByString:@"[/AGENT]"][0];
                for (NSString *personServiceName in personServiceSingle.personServiceArray) {
                    if ([agentName isEqualToString:personServiceName]) {
                        break;
                    }
                }
                [personServiceSingle.personServiceArray addObject:agentName];
            }
        }
        
    }
    // 处理<;a href=&quot;http://www.wanda.cn/navigation/weixin/&quot; target=&quot;_blank&quot;>;点击此处<;/a>;标签
    if ([self.robotModel.content rangeOfString:@"&lt;a href="].length > 0 && [syncRes rangeOfString:@"<content>"].length <= 0) {
        // 处理<;a href=标签，将显示的蓝色字体和跳转的链接放到一个数组中
        NSArray *alinksTmpArr = [self.robotModel.content componentsSeparatedByString:@"&lt;a href=\""];
        for (int i = 1; i < alinksTmpArr.count; i++) {
            NSString *hrefContent = alinksTmpArr[i];
            // 获取显示的内容
            NSString *hrefClickContent = [[[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0] componentsSeparatedByString:@"&gt;"] lastObject];
            
            // 将<a标签中没用的东西都去掉
            self.robotModel.content = [self.robotModel.content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@",@"&lt;a href=\"",[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0],@"&lt;/a&gt;"] withString:hrefClickContent];
        }
    }
    [_parser release];
    
    if (result) {
        [self saveMsgProperties];
        //    根据类型不同给新定义的属性赋值
    }
    return result;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,elementName is %@,attributeDict is %@",__FUNCTION__,elementName,[attributeDict description]]];
    //	初始化服务号数组
    if([elementName isEqualToString:ele_robotResponse])
    {
        self.robotModel = [[RobotResponseModel alloc]init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //    [LogUtil debug:[NSString stringWithFormat:@"%s,string is %@",__FUNCTION__,string]];
    curValue = [string retain];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:ele_args])
    {
        [self.robotModel.argsArray addObject:curValue];
    }
    else if([elementName isEqualToString:ele_name])
    {
        self.robotModel.nameString = curValue;
    }
    else if([elementName isEqualToString:ele_type])
    {
        self.robotModel.type = curValue;
    }
    else if([elementName isEqualToString:ele_content])
    {
        NSRange totalStartRange = [parseStr rangeOfString:@"<content>"];
        NSRange totalEndRange = [parseStr rangeOfString:@"</content>"];
        totalStartRange.location = totalStartRange.location+totalStartRange.length;
        totalStartRange.length = totalEndRange.location - totalStartRange.location;
        self.robotModel.content = [parseStr substringWithRange:totalStartRange];
    }
    else if([elementName isEqualToString:ele_relatedQuestions])
    {
        if (!relatedQuestionsArr) {
            linkCount = 1;
            relatedQuestionsArr = [NSMutableArray array];
        }
        // 万达广场楼层简介 --> [link]万达广场楼层简介[/link]&#xD;
        [relatedQuestionsArr addObject:[NSString stringWithFormat:@"%d.[link]%@[/link]&#xD;\n",linkCount++,curValue]];
    }
}

#pragma mark - 解析图文信息
- (void)parserImgtxtInfo:(NSString *)imgtxtInfo count:(int)imgtxtCount{
    NSArray * arr = [imgtxtInfo componentsSeparatedByString:@"&lt;![CDATA["];
    NSArray *labelArray = @[@"Title",@"Description",@"PicUrl",@"Url"];
    for (int i = 0; i < imgtxtCount; i++) {
        if (arr != nil && arr.count > 2) {
            NSMutableDictionary *dic = [[[NSMutableDictionary alloc]init]autorelease];
            for (int j = 2+(4*i); j < 2+(4*(i+1)) && j < arr.count; j++) {
                NSString *item = arr[j];
                NSArray * itemArray = [item componentsSeparatedByString:@"]]"];
                [dic setValue:itemArray[0] forKey:labelArray[(j-2)%4]];
            }
            // 进一步解析Title，分离出Title和Description
            // [TITLE]银河soho[/TITLE][DES]银河soho坐落于北京市朝阳s[/DES]
            //            NSString *titleTmpStr = [dic valueForKey:labelArray[0]];
            //
            //            NSRange titleStartRange = [titleTmpStr rangeOfString:@"[TITLE]"];
            //            NSRange titleEndRange = [titleTmpStr rangeOfString:@"[/TITLE]"];
            //            titleStartRange.location = titleStartRange.location+titleStartRange.length;
            //            titleStartRange.length = titleEndRange.location - titleStartRange.location;
            //            [dic setValue:[titleTmpStr substringWithRange:titleStartRange] forKey:labelArray[0]];
            //
            //            titleStartRange = [titleTmpStr rangeOfString:@"[DES]"];
            //            titleEndRange = [titleTmpStr rangeOfString:@"[/DES"];
            //            titleStartRange.location = titleStartRange.location+titleStartRange.length;
            //            titleStartRange.length = titleEndRange.location - titleStartRange.location;
            //            [dic setValue:[titleTmpStr substringWithRange:titleStartRange] forKey:labelArray[1]];
            
            NSArray * arrDes = [imgtxtInfo componentsSeparatedByString:@"auth=\""];
            if (arrDes.count < 2) {
                arrDes = [imgtxtInfo componentsSeparatedByString:@"auth=&quot;"];
                NSArray * itemDes = [arrDes[i+1] componentsSeparatedByString:@"&quot;&gt;&lt;![CDATA"];
                [dic setValue:itemDes[0] forKey:labelArray[1]];
            }else{
                NSArray * itemDes = [arrDes[i+1] componentsSeparatedByString:@"\"&gt;&lt;![CDATA"];
                [dic setValue:itemDes[0] forKey:labelArray[1]];
            }
            
            [self.robotModel.imgtxtArray addObject:dic];
        }
    }
}

//add by shisp
- (void)saveMsgProperties
{
    
    if([type_imgmsg isEqualToString:self.robotModel.nameString] && self.robotModel.argsArray.count >= 5 ){
        //        图片消息
        self.robotModel.msgType = type_pic;
        self.robotModel.msgFileDownloadUrl = self.robotModel.argsArray[0];
        self.robotModel.msgFileName = [NSString stringWithFormat:@"%@",self.robotModel.argsArray[2]];
    }else if ([type_musicmsg isEqualToString:self.robotModel.nameString] && self.robotModel.argsArray.count >=6 )
    {
        //        音频消息
        self.robotModel.msgType = type_record;
        self.robotModel.msgFileDownloadUrl = self.robotModel.argsArray[3];
        self.robotModel.msgFileName = [NSString stringWithFormat:@"%@",self.robotModel.argsArray[0]];
        self.robotModel.msgFileSize = self.robotModel.argsArray[5];
    }else if ([type_videomsg isEqualToString:self.robotModel.nameString] && self.robotModel.argsArray.count >=6)
    {
        //        视频消息
        self.robotModel.msgType = type_video;
        self.robotModel.msgFileDownloadUrl = self.robotModel.argsArray[0];
        self.robotModel.msgFileName = [NSString stringWithFormat:@"%@",self.robotModel.argsArray[3]];
        self.robotModel.msgFileSize = self.robotModel.argsArray[5];
    }else if ([type_imgtxtmsg isEqualToString:self.robotModel.nameString])
    {
        self.robotModel.msgType = type_imgtxt;
    }else if ([type_wikimsg isEqualToString:self.robotModel.nameString])
    {
        self.robotModel.msgType = type_wiki;
    }else {
        self.robotModel.msgType = type_text;
    }
}
@end
