//
//  redpacketViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/10.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "redpacketViewControllerARC.h"
#import "RedpacketViewControl.h"
#import "RedpacketUser.h"
#import "AESCipher.h"
#import "eCloudDefine.h"
#import "talkSessionViewController.h"
#import "TextMsgExtDefine.h"
#import "Emp.h"
#import "StringUtil.h"
#import "ServerConfig.h"

@interface redpacketViewControllerARC ()

@property(strong,nonatomic) Emp *emp;

@end

@implementation redpacketViewControllerARC

static redpacketViewControllerARC *_redpacketViewControllerARC;

+(redpacketViewControllerARC *)getRedpacketViewController
{
    if(_redpacketViewControllerARC == nil)
    {
        _redpacketViewControllerARC = [[self alloc]init];
    }
    return _redpacketViewControllerARC;
}

- (void)addRedPacket:(UIViewController *)curVC andConvType:(int)convType convEmps:(NSArray *)convEmp{
    
    RedpacketUserInfo *userInfo = [RedpacketUserInfo new];
    if (convEmp) {
   
        self.emp = convEmp[0];
        userInfo.userId = [NSString stringWithFormat:@"%d",self.emp.emp_id];
        userInfo.userNickname = self.emp.emp_name;
        ServerConfig *serverConfig = [ServerConfig shareServerConfig];
        userInfo.userAvatar = [serverConfig getLogoUrlByEmpId:[NSString stringWithFormat:@"%d",self.emp.emp_id]];
        
    }

    /** 发红包成功*/
    RedpacketSendBlock sendSuccessBlock = ^(RedpacketMessageModel *model) {
        
        NSDictionary *redpacket = @{@"1": model.redpacketMessageModelToDic};    //  1代表红包消息
        NSDictionary *redpacketDict = redpacket[@"1"];
        NSString *string = [NSString stringWithFormat:@"%@",redpacketDict[@"ID"]];
        NSString *key = @"brcredpacket9384";
        NSString *encryStr = [AESCipher encryptAES:string key:key];
        NSString *greeting = redpacketDict[@"money_greeting"];
        NSString *userId = redpacketDict[@"money_sender_id"];

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"redPacket",@"type", encryStr,@"redPacketId",greeting,@"greeting",userId,@"userId",nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [[talkSessionViewController getTalkSession]setConvStatusToNormal];
        [[talkSessionViewController getTalkSession] sendMessage:type_text message:jsonString filesize:-1 filename:nil andOldMsgId:nil];
        
    };
    /** 定向红包获取群成员列表, 如果不需要指定接收人，可以传nil */
    RedpacketMemberListBlock memeberListBlock = nil;
 
    if (convType == singleType){
        
        [RedpacketViewControl presentRedpacketViewController:RPRedpacketControllerTypeSingle
                                             fromeController:curVC
                                            groupMemberCount:2
                                       withRedpacketReceiver:userInfo
                                             andSuccessBlock:sendSuccessBlock
                               withFetchGroupMemberListBlock:memeberListBlock
                                 andGenerateRedpacketIDBlock:nil];
        
    }else if (convType == mutiableType){
        
        
        [RedpacketViewControl presentRedpacketViewController:RPRedpacketControllerTypeGroup
                                             fromeController:curVC
                                            groupMemberCount:0
                                       withRedpacketReceiver:userInfo
                                             andSuccessBlock:sendSuccessBlock
                               withFetchGroupMemberListBlock:memeberListBlock
                                 andGenerateRedpacketIDBlock:nil];
        
    }
}

- (void)redpacketTouched:(UIViewController *)curVC redpacketDic:(NSDictionary *)redpacketDic
{
    
    RedpacketMessageModel *model = [RedpacketMessageModel redpacketMessageModelWithDic:redpacketDic];
    
    [RedpacketViewControl redpacketTouchedWithMessageModel:model
                                        fromViewController:curVC
                                        redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
    
                                            /** 抢红包成功, 转账成功的回调*/
                                            NSDictionary *redpacket = @{@"2": messageModel.redpacketMessageModelToDic};    //  2代表红包被抢的消息
                                            
                                            NSDictionary *redpacketDict = redpacket[@"2"];
                                            NSString *string = [NSString stringWithFormat:@"%@",redpacketDict[@"ID"]];
                                            NSString *key = @"brcredpacket9384";
                                            NSString *encryStr = [AESCipher encryptAES:string key:key];
                                            NSString *guestId = redpacketDict[@"money_receiver_id"];
                                            NSString *guestName = redpacketDict[@"money_receiver"];
                                            NSString *hostId = redpacketDict[@"money_sender_id"];
                                            
                                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"redPacketAction",@"type", encryStr,@"redPacketId",guestId,@"guestId",guestName,@"guestName",hostId,@"hostId",nil];
                                            
                                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
                                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                            
                                            [[talkSessionViewController getTalkSession]setConvStatusToNormal];
                                            [[talkSessionViewController getTalkSession] sendMessage:type_text message:jsonString filesize:-1 filename:nil andOldMsgId:nil];
                                            
                                        } advertisementAction:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
