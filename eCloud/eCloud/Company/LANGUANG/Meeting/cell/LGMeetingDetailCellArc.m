//
//  LGMettingDetailCellArc.m
//  mettingDetail
//
//  Created by Alex-L on 2017/5/31.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "LGMeetingDetailCellArc.h"
#import "LGMettingDetailViewControllerArc.h"
#import <BizConfSDK/BizConfVideoSDK.h>
#import "conn.h"
#import "eCloudDAO.h"
#import "Emp.h"
#import "JSONKit.h"
#import "WXMsgDialog.h"
#import "LGMeetingDetailEmpCellArc.h"
#import "NotificationUtil.h"
#import "LGMettingDefine.h"
#import "UserDefaults.h"
#import "LGMettingUtilARC.h"
#import "LANGUANGAppViewControllerARC.h"

@interface LGMeetingDetailCellArc ()<UIAlertViewDelegate>

- (IBAction)attendMeetingClick:(UIButton *)sender;
@property(strong,nonatomic) Emp *emp;
@end

@implementation LGMeetingDetailCellArc
{
    conn *_conn;
    eCloudDAO *db;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
    }
    
    return self;
}

- (IBAction)attendMeetingClick:(UIButton *)sender
{
//    - (NSDate *)getCurrentTime;
//    - (BOOL )compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
    
    if ([_dict[@"confType"] intValue] != 2) {
        
        NSDate *data =  [self AddserverTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        //    NSDate *endTime = [dateFormatter dateFromString:_dict[@"startTime"]];
        NSDate *startTime = [dateFormatter dateFromString:_dict[@"startTime"]];
        
        BOOL isEnd = [[LGMettingDetailViewControllerArc getLGMettingDetailViewControllerArc]compareOneDay:data withAnotherDay:startTime];
        
        
        if (!isEnd) {
            
            [[NotificationUtil getUtil]sendNotificationWithName:METTING_POP_TIP andObject:nil andUserInfo:nil];
            
            return;
        }
    }
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    self.emp = [db getEmpInfo:_conn.userId];
    NSLog(@"text=====%@",sender.titleLabel.text);
    if (sender.tag == 5)
    {
        if ([sender.titleLabel.text isEqualToString:@"发起会议"]) {
            
            if ([[BizConfVideoSDK sharedSDK] isAuthorized]) {
                BizConfVideoSDK *ms = [BizConfVideoSDK sharedSDK];
                if (ms) {
                    
                    //sfcloud://www.confcloud.cn/start?confno=1512093373&sid=-g1mtOuXTe6xIb-GOaUbVw&stype=100&uid=-g1mtOuXTe6xIb-GOaUbVw&uname=\U5218\U6d77&token=b_rNZ97v66MUeVnlurCJiWX02L2gLerOsTgn5Csiz6Q.BgMsUUFpcE44S3gwNlBFMjAzekRIZVBPNWkxTWpBK05LQWNzQ0xwbnBFODRqTT1AYWFjMTdhYWE0NWQ3MzhlMjQwZDZjOWQ0MmIxYzk5MzViY2I2YzMxMjQ3YWZjMTFlMGI4NTY1MThkYjg5NjgwNQAMM0NCQXVvaVlTM3M9
                    
                    //sfcloud://www.confcloud.cn/start?confno=1586659957&sid=I9qeVQKTSeCm-o3lPhI1eA&stype=100&uid=I9qeVQKTSeCm-o3lPhI1eA&uname=龙建福&token=1ZapPzjx1xb1hEx-UZtk3LNGfUYfbdb1NWI1sUKAYaE.BgMgM1NpbU5oc2lZQzhnSzdWYm5nWFFjMjUrZDJJZlJOallAZjJiY2VhZDNhZGEyMWQwMzc5ZTdlNWYyNzJmMDVlZmQ3NTA2ZjcyMWU1YmFkYWE3MDBjMDI5NWQ0YTkzNmEwNwAMM0NCQXVvaVlTM3M9
                    NSDictionary *dict = [LANGUANGAppViewControllerARC cutString:_dict[@"protocolHostStartUrl"]];
                
                    NSString * userID = dict[@"uid"];
                    NSString * meetingNum = dict[@"confno"];
                    NSString * userName = dict[@"uname"];
                    NSString * cuid = [NSString stringWithFormat:@"%d",self.emp.emp_id];
                    NSString *userToken = dict[@"token"];
                    
                    [ms startMeeting:userID userName:userName  userToken:userToken meetingNo:meetingNum cuid:cuid result:^(BizSDKMeetError result) {
                        // result为启会的结果，用于判断会议的错误信息
                        NSLog(@"会议错误信息%d",result);
                    }];
                }
            }
        }else if ([sender.titleLabel.text isEqualToString:@"立即入会"])
        {
            if ([[BizConfVideoSDK sharedSDK] isAuthorized]) {
                BizConfVideoSDK *ms = [BizConfVideoSDK sharedSDK];
                if (ms) {
                    //NSString * userID = @"I9qeVQKTSeCm-o3lPhI1eA";
                    NSDictionary *dict = [LANGUANGAppViewControllerARC cutString:_dict[@"protocolHostStartUrl"]];
                    NSString * meetingNum = dict[@"confno"];
                    NSString * userName = self.emp.emp_name;
                    NSString * cuid = [NSString stringWithFormat:@"%d",self.emp.emp_id];
                    //NSString *userToken = @"1ZapPzjx1xb1hEx-UZtk3LNGfUYfbdb1NWI1sUKAYaE.BgMgM1NpbU5oc2lZQzhnSzdWYm5nWFFjMjUrZDJJZlJOallAZjJiY2VhZDNhZGEyMWQwMzc5ZTdlNWYyNzJmMDVlZmQ3NTA2ZjcyMWU1YmFkYWE3MDBjMDI5NWQ0YTkzNmEwNwAMM0NCQXVvaVlTM3M9";
                    NSString *confPassword = _dict[@"confPassword"];
                    [ms joinMeeting:userName meetingNo:meetingNum uid:@"" password:confPassword cuid:cuid isAudio:YES isvideo:YES result:^(BizSDKMeetError result) {
                        
                        NSLog(@"会议的错误信息%u",result);
                        
                    }];
                }
            }
            
        }
        else if ([sender.titleLabel.text isEqualToString:@"加入会议"]){
            
            
//            NSDictionary *dict = [self cutString:_dict[@"protocolHostStartUrl"]];
            NSString * meetingNum = _dict[@"protocolHostStartUrl"];
            NSString *urlStr = [NSString stringWithFormat:@"H323:%@@meetex.me",meetingNum];
            NSURL *url = [NSURL URLWithString:urlStr];
            BOOL result = [[UIApplication sharedApplication] openURL:url];
            
            if (result == YES) {
                
                [[UIApplication sharedApplication] openURL:url];
                
            }else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getAlertTitle] message:@"您未安装宝利通客户端" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往下载", nil];
                
                [alert show];
            }
            
        }
     
    }
    else if([sender.titleLabel.text isEqualToString:@"电话入会"])
    {

        if(_dict[@"confNumber"]){
            
            NSString *telString = [NSString stringWithFormat:@"telprompt://%@",self.dict[@"tel"]?:@""];
            NSURL *url = [NSURL URLWithString:telString];
            [[UIApplication sharedApplication] openURL:url];
        }
        NSLog(@"电话入会");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickButtonAtIndex:%d",(int)buttonIndex);

    if (buttonIndex != 0) {
        
        //https://itunes.apple.com/cn/app/polycom-realpresence-mobile-for-iphone/id502583287?mt=8
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/polycom-realpresence-mobile-for-iphone/id502583287?mt=8"]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (NSDate *)AddserverTime{

    NSString *urlString = [NSString stringWithFormat:@"%@/middleware/conference/getDateTime?",[LGMettingUtilARC get9013Url]];
    NSDictionary *dict = [StringUtil getHtmlText:urlString];
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取服务器时间戳 == %@",__FUNCTION__,dict]];
    unsigned long long time = [dict[@"data"] unsignedLongLongValue];
    unsigned int iTime = (unsigned int)(time / 1000);

    NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:iTime];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime=[formatter stringFromDate:currentTime];
    NSDate *date = [formatter dateFromString:dateTime];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
    
}
@end
