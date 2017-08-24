
#import "StatusMonitor.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "conn.h"

static StatusMonitor *statusMoniter;

@implementation StatusMonitor

@synthesize connStatus;
@synthesize downloadOrgTips;

+ (StatusMonitor *)getStatusMonitor
{
    if (statusMoniter == nil) {
        statusMoniter = [[StatusMonitor alloc]init];
    }
    return statusMoniter;
}

- (NSString *)getTips
{
    conn *_conn = [conn getConn];
    NSString *tips = [_conn getTips];// @"";
//    switch (_conn.connStatus) {
//		case not_connect_type:
//			tips = [StringUtil getLocalizableString:@"contact_noConnecting"];
//			break;
//		case linking_type:
//			tips = [StringUtil getLocalizableString:@"contact_connecting"];
//			break;
//		case download_org:
//            tips = _conn.downloadOrgTips;
//			break;
//		case rcv_type:
//            tips = [StringUtil getLocalizableString:@"contact_loading"];
//			break;
//		case normal_type:
//			tips = [StringUtil getAppLocalizableString:@"main_chats"];
//			break;
//			
//		default:
//			break;
//	}
    return tips;
}

@end
