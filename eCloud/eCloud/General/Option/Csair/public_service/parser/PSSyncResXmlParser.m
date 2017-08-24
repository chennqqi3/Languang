//服务号同步结果解析

#import "PSSyncResXmlParser.h"
#import "LogUtil.h"
#import "ServiceModel.h"
#import "eCloudDefine.h"
#import "PublicServiceDAO.h"

//<xml>
//<sync>
//<sequence>123456</sequence>
//<accounts>
//<account>
//<gid>1</gid>
//<name>sxit_pb</name>
//<attention>0</attention>
//<present>1</present>
//<title>机组排班</title>
//<img>http://120.132.153.6:8080/face_sgroup_icon.png</img>
//<desc>航班查询、机组查询、天气查询</desc>
//</account>
//</accounts>
//</sync>
//</xml>
//

#define ele_sync @"sync"
#define ele_sequence @"sequence"
#define ele_accounts @"accounts"
#define ele_account @"account"
#define ele_gid @"gid"
#define ele_name @"name"
#define ele_attention @"attention"
#define ele_present @"present"
#define ele_title @"title"
#define ele_img @"img"
#define ele_desc @"desc"
#define ele_showType @"showType"
#define ele_appstatus @"appstatus"

@implementation PSSyncResXmlParser
{
	NSString *curValue;
	ServiceModel *curServiceModel;
}
@synthesize accounts;
@synthesize sequence;

-(void)dealloc
{
	if(curValue)
	{
		[curValue release];
		curValue = nil;
	}
	self.accounts = nil;
	[super dealloc];
}

-(bool)parse:(NSString*)syncRes
{
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
	[_parser release];
	
	return result;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//	[LogUtil debug:[NSString stringWithFormat:@"%s,elementName is %@,attributeDict is %@",__FUNCTION__,elementName,[attributeDict description]]];
	if(curValue)
	{
		[curValue release];
		curValue = nil;
	}
//	初始化服务号数组
	if([elementName isEqualToString:ele_accounts])
	{
		self.accounts = [NSMutableArray array];
	}
//	初始化服务号对象
	else if([elementName isEqualToString:ele_account])
	{
		curServiceModel = [[ServiceModel alloc]init];
//		默认的类型为0，不显示在会话列表
		curServiceModel.serviceType = 0;
		curServiceModel.serviceStatus = 0;
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//	[LogUtil debug:[NSString stringWithFormat:@"%s,string is %@",__FUNCTION__,string]];
	curValue = [string retain];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:ele_sequence])
	{
		self.sequence = [curValue intValue];
	}
	else if([elementName isEqualToString:ele_gid])
	{
		curServiceModel.serviceId = [curValue intValue];
	}
	else if([elementName isEqualToString:ele_name])
	{
		curServiceModel.serviceCode = curValue;
	}
	else if([elementName isEqualToString:ele_attention])
	{
		curServiceModel.followFlag = [curValue intValue];
	}
	else if([elementName isEqualToString:ele_present])
	{
		curServiceModel.rcvMsgFlag = [curValue intValue];
	}
	else if([elementName isEqualToString:ele_title])
	{
		curServiceModel.serviceName = curValue;
        NSLog(@"%s 服务号名字为 %@",__FUNCTION__,curValue);

		NSRange _range = [curServiceModel.serviceName rangeOfString:redian_name];
		if(_range.length > 0)
		{
			curServiceModel.serviceType = service_type_out_ps;
        }else{
            if ([UIAdapterUtil isCsairApp] && [curValue rangeOfString:csair_tongzhi_name].length > 0) {
                curServiceModel.serviceType = service_type_out_ps;
            }
        }
	}
	else if([elementName isEqualToString:ele_img])
	{
		curServiceModel.serviceIcon = curValue;
	}
	else if([elementName isEqualToString:ele_desc])
	{
		curServiceModel.serviceDesc = curValue;
	}
	else if([elementName isEqualToString:ele_showType])
    {
        NSRange _range = [curServiceModel.serviceName rangeOfString:redian_name];
        if(_range.length == 0)
        {
            _range = [curServiceModel.serviceName rangeOfString:csair_tongzhi_name];
            if (_range.length == 0) {
                curServiceModel.serviceType = curValue.intValue;
            }
        }
	}
	else if([elementName isEqualToString:ele_appstatus])
	{
		if(curValue.intValue == 0)
		{
			curServiceModel.serviceStatus = 1;
		}
	}
	else if([elementName isEqualToString:ele_account])
	{
		[self.accounts addObject:curServiceModel];
		[curServiceModel release];
	}
	
//	[LogUtil debug:[NSString stringWithFormat:@"%s,elementName is %@",__FUNCTION__,elementName]];
//	if(curValue)
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"%s,curValue is %@",__FUNCTION__,curValue]];
//	}
		
}

@end
