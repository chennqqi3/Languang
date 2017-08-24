//
//  JSSDKObject.m
//  eCloud
//
//  Created by shisuping on 16/7/21.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "JSSDKObject.h"
#import "JSONKit.h"
#import "specialChooseMemberViewController.h"
#import "NotificationUtil.h"
#import "FGalleryViewController.h"

#import "UploadFileObject.h"

#import "PictureUtil.h"

#import "UIAdapterUtil.h"
#import "RecordUtil.h"
#import "VideoUtil.h"
#import "CurrentLocationUtil.h"

#import "AgentListViewController.h"
#import "FileAssistantViewController.h"
#import "talkSessionUtil2.h"
#import "UserDefaults.h"
#import "OpenCtxUtil.h"
#import "UserTipsUtil.h"

#import "ScannerViewController.h"
#import "NewChooseMemberViewController.h"
#import "mainViewController.h"

#import "WebViewJavascriptBridge.h"
#import "eCloudDefine.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "ConnResult.h"
#import "talkSessionViewController.h"
#import "APPPermissionModel.h"
#import "JSONKit.h"
#import "Emp.h"
#import "openLocationoViewController.h"
#import "personInfoViewController.h"
#import "NewOrgViewController.h"
#import "eCloudUser.h"

#ifdef _LANGUANG_FLAG_
#import "LANGUANGAppViewControllerARC.h"
#import "LGMettingDetailViewControllerArc.h"
#endif

@interface JSSDKObject () <ChooseMemberDelegate,ScannerViewDelegate,RecordStatusDelegate,PictureDelegate,IMLocationDelegate> {
    eCloudDAO *_ecloud ;
}

@end

@implementation JSSDKObject

@synthesize curVC;
@synthesize bridge;

- (void)dealloc{
    [PictureUtil getUtil].delegate = nil;
    [CurrentLocation getUtil].delegate = nil;

    [RecordUtil getUtil].delegate = nil;
    self.curVC = nil;
    self.bridge = nil;
    [super dealloc];
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)initSDK
{
    [self initScanQRCode];
    
    [self initSelectContacts];
    
    [self initCreateConv];
    
    [self initChangeDirection];
    
    [self initRecord];
    
    [self initImage];
    
    [self initVideo];
    
    [self initlocation];
    
    [self initUserInfo];
    
    [self initFileAssistant];
    
    [self initIMEI];
    
    [self initOAToken];
    
    [self initCloseWindow];
    
    [self intSetMeetingID];
}


#pragma mark 扫描二维码
#define SCAN_QRCODE_NAME @"scanQRCode"
#define SCAN_QRCODE_HANDLER_NAME @"scanQRCodeHandler"
#define SCAN_TYPE @"scan_type"
- (void)initScanQRCode
{
    [self.bridge registerHandler:SCAN_QRCODE_NAME handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"scanQRCode called: %@", data);
        int type = [data[SCAN_TYPE]intValue];
        if (type == scanQRCode_open_result) {
            //            直接打开扫描结果
        }else {
            //            返回扫描结果
        }
        
        ScannerViewController *scanner = [[[ScannerViewController alloc]init]autorelease];
        scanner.processType = type;
        scanner.delegate = self;
        
        [curVC.navigationController pushViewController:scanner animated:YES];
        responseCallback(@"scanQRCode");
    }];
}

- (void)barcodeFound:(ScannerViewController *)scanner andBarcode:(NSString *)barCode
{
    [self.bridge callHandler:SCAN_QRCODE_HANDLER_NAME data:barCode responseCallback:^(id responseData) {
        NSLog(@"%s %@",__FUNCTION__,responseData);
    }];
    
}

#pragma mark ===从通讯录选择联系人功能===

#define SELECT_CONTACTS_NAME @"selectContacts"
#define SELECT_CONTACTS_HANDLER_NAME @"selectContactsHandler"
#define SELECT_CONTACTS_TYPE @"select_contacts_type"

- (void)initSelectContacts
{
    [self.bridge registerHandler:SELECT_CONTACTS_NAME handler:^(id data, WVJBResponseCallback responseCallback) {
        
        int type = [data[SELECT_CONTACTS_TYPE] intValue];
        
        NewChooseMemberViewController *newChoose = [[[NewChooseMemberViewController alloc]init]autorelease];
        newChoose.typeTag = type_app_select_contacts;
        newChoose.isSingleSelect = NO;
        
        if (type == select_type_single) {
            newChoose.isSingleSelect = YES;
        }
        
        newChoose.chooseMemberDelegate = self;
        
//        newChoose.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
        
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:newChoose];
        [UIAdapterUtil presentVC:navController];
    }];
}

- (void)didSelectContacts:(NSString *)retStr
{
    [self.bridge callHandler:SELECT_CONTACTS_HANDLER_NAME data:retStr responseCallback:^(id responseData) {
        NSLog(@"%@",responseData);
    }];
}

#pragma mark 创建会话功能

#define CREATE_CONV_NAME @"createConv"
#define USER_CODES_KEY @"userCodes"
#define USER_CODES_SEPERATOR @"#"
#define CONV_TITLE_KEY @"convTitle"
#define MSG_KEY @"message"

- (void)initCreateConv
{
    [self.bridge registerHandler:CREATE_CONV_NAME handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        [self performSelector:@selector(createConvsationWithData:) withObject:data afterDelay:0.05];
    }];
}

- (void)createConvsationWithData:(NSDictionary *)data
{
    NSString *userCodesStr = data[USER_CODES_KEY];
    NSString *convTitle = data[CONV_TITLE_KEY];
    NSString *msg = data[MSG_KEY];

    NSMutableArray *userCodesArray = [userCodesStr componentsSeparatedByString:USER_CODES_SEPERATOR];
    
    if (userCodesArray.count == 0) {
        //        没有找到用户
        [UserTipsUtil hideLoadingView];
    }else{
        
        OpenCtxUtil *openCtx = [OpenCtxUtil getUtil];
        NSArray *_array = userCodesArray;
        [openCtx createAndOpenConvWithEmpCodes:_array andConvTitle:convTitle andCompletionHandler:^(int result, UIViewController *talkSession) {
            [UserTipsUtil hideLoadingView];
            if (result == createAndOpenConvResult_ok)
            {
                talkSessionViewController *_talkSession = ((talkSessionViewController *)talkSession);
                [UserDefaults removeModifyGroupNameFlag:_talkSession.convId];
                
                //                    如果有url 那么就要发送到群聊里
                if (msg) {
                    
                    if (_talkSession.talkType == singleType) {
                        [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:_talkSession.convId andTitle:_talkSession.titleStr];
                    }
                    
                    conn *_conn = [conn getConn];
                    
                    NSString *msgBody;
                    if ([msg isKindOfClass:[NSDictionary class]]){
                        
                        NSString *jsonString = [msg JSONString];
                        msgBody = [NSString stringWithFormat:@"%@",jsonString];
                    }else{
                        
                        msgBody = [NSString stringWithFormat:@"%@",msg];
                    }
                    
                  NSString *convId = _talkSession.convId;
                    
                    int nowtimeInt= [_conn getCurrentTime];
                    NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
                    
                    //		信息类型
                    NSString *msgType = [StringUtil getStringValue:type_text];
                    
                    //		信息类型为发送信息
                    NSString *msgFlag = [StringUtil getStringValue:send_msg];
                    
                    //		发送状态为正在发送
                    NSString *sendFlag = [StringUtil getStringValue:sending];
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",msgBody,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:conv_status_normal],@"receipt_msg_flag", nil];
                    
                    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                    
                    NSDictionary *_dic =[_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
                    
                    if(_dic)
                    {
                        //				添加数据库成功
                        //                            msgId = [_dic valueForKey:@"msg_id"];
                        NSString *sendMsgId = [_dic valueForKey:@"origin_msg_id"];
                        
                        [_conn sendMsg:convId andConvType:_talkSession.talkType andMsgType:type_text andMsg:msgBody andMsgId:[sendMsgId longLongValue]  andTime:nowtimeInt andReceiptMsgFlag:conv_status_normal];
                    }
                }
                
                [curVC.navigationController pushViewController:talkSession animated:YES];
            }
            else
            {
                NSString *tipsStr = @"";
                switch (result) {
                    case createAndOpenConvResult_create_group_fail:
                        tipsStr = @"创建群组失败";
                        break;
                    case createAndOpenConvResult_create_group_timeout:
                        tipsStr = @"创建群组超时";
                        break;
                    case createAndOpenConvResult_user_not_login:
                        tipsStr = @"用户未登录";
                        break;
                    case createAndOpenConvResult_can_not_find_user:
                        tipsStr = @"没有找到用户";
                        break;
                    default:
                        break;
                }
                
                [UserTipsUtil showAlert:tipsStr];
            }
        }];
    };
}

#pragma mark 修改屏幕方向
#define CHANGE_DIRECTION_NAME @"changeDirection"
#define DIRECTION_KEY @"direction"

- (void)initChangeDirection
{
    [self.bridge registerHandler:CHANGE_DIRECTION_NAME handler:^(id data, WVJBResponseCallback responseCallback) {
        
        int direction = [data[DIRECTION_KEY]intValue];
        if (direction == direction_landscape) {
            //            横向
        }else{
            //            纵向
        }
        
        [AgentListViewController changeOrientation:self.curVC andDirection:direction];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化录音
#define START_RECORD @"startRecord"
#define STOP_RECORD @"stopRecord"
#define PLAY_VOICE @"playVoice"
#define PAUSE_VOICE @"pauseVoice"
#define STOP_VOICE @"stopVoice"
#define UPLOAD_VOICE @"uploadVoice"
#define DOWNLOAD_VOICE @"downloadVoice"
- (void)initRecord
{
    [RecordUtil getUtil].delegate = self;
    [self.bridge registerHandler:START_RECORD handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]startRecord];
    }];
    [self.bridge registerHandler:STOP_RECORD handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]stopRecord];
    }];
    [self.bridge registerHandler:PLAY_VOICE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]playVoice];
    }];
    [self.bridge registerHandler:PAUSE_VOICE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]pauseVoice];
    }];
    [self.bridge registerHandler:STOP_VOICE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]stopVoice];
    }];
    [self.bridge registerHandler:UPLOAD_VOICE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]uploadVoice];
    }];
    [self.bridge registerHandler:DOWNLOAD_VOICE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[RecordUtil getUtil]downloadVoice];
    }];
    
    
}


#pragma mark =======record status delegate========
- (void)willStartRecord
{
    [self dspStatus:@"开始录音..."];
}

- (void)willStopRecord
{
    [self dspStatus:@"停止录音"];
}

- (void)recordTime:(NSNumber *)_second
{
    [self dspStatus:[NSString stringWithFormat:@"录音持续时间:%d",[_second intValue]]];
}

- (void)willPlayVoice
{
    [self dspStatus:@"播放录音..."];
}

- (void)willStopVoice
{
    [self dspStatus:@"停止播放录音"];
}

- (void)willPauseVoice
{
    [self dspStatus:@"暂停播放录音"];
}

- (void)uploadFinished:(NSArray *)result{
    NSMutableString *mStr = [[NSMutableString alloc]init];
    NSString *token;
    for (UploadFileObject *uploadFileObject in result) {
        NSString *uploadResponse = uploadFileObject.uploadResponse;
        if (uploadResponse.length) {
            if (mStr.length > 0) {
                [mStr appendFormat:@",%@",uploadResponse];
            }else{
                [mStr appendString:uploadResponse];
            }
            
            NSData* jsonData = [uploadResponse dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [jsonData objectFromJSONData];
            token = dic[@"token"];
        }
        
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
    
    [self.bridge callHandler:@"uploadVoiceHandler" data:urlStr responseCallback:^(id responseData) {
    
        
    }];
}

//// 显示状态
- (void)dspStatus:(NSString *)statusStr
{
    NSString *_titleStr = @"js object-c 交互";
    dispatch_async(dispatch_get_main_queue(), ^{
        curVC.title = statusStr
        ;// [NSString stringWithFormat:@"%@(%@)",_titleStr,statusStr];
    });
    //    [self.bridge callHandler:@"logHandler" data:statusStr responseCallback:^(id responseData) {
    //
    //    }];
}

#pragma mark ======图像接口======

typedef enum
{
    //    拍照
    choose_image_type_camera = 0,
    //    从图片库选择
    choose_image_type_album = 1,
    //    两种都支持
    choose_image_type_both = 2
}chooseImageTypeDef;

#define CHOOSE_IMAGE @"chooseImage"
#define CHOOSE_IMAGE_TYPE @"chooseImageType"
#define CHOOSE_IMAGE_HANDLER @"chooseImageHandler"

#define PREVIEW_IMAGE @"previewImage"

#define UPLOAD_IMAGE @"uploadImage"
#define UPLOAD_IMAGE_HANDLER @"uploadImageHandler"

#define DOWNLOAD_IMAGE @"downloadImage"

#define PREVIEW_IAMGE_CUR_RUL @"current"
#define PREVIEW_IMAGE_URLS @"urls"

- (void)initImage
{
    [self.bridge registerHandler:CHOOSE_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        [PictureUtil getUtil].delegate = self;
        
        int chooseImageType = [data[CHOOSE_IMAGE_TYPE]intValue];
        
        if (chooseImageType == choose_image_type_camera) {
            [[PictureUtil getUtil]getCameraPicture];
        }else if (chooseImageType == choose_image_type_album){
            [[PictureUtil getUtil]selectExistingPicture];
        }else{
            [[PictureUtil getUtil]presentSheet:self.curVC];
        }
    }];
    [self.bridge registerHandler:UPLOAD_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[PictureUtil getUtil]uploadImage];
    }];
    [self.bridge registerHandler:DOWNLOAD_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        [[PictureUtil getUtil]downloadImage:nil];
    }];
    
    [self.bridge registerHandler:PREVIEW_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *curUrl = data[PREVIEW_IAMGE_CUR_RUL];
        NSArray *previewImageArray = data[PREVIEW_IMAGE_URLS];
        if (previewImageArray.count == 0) {

            NSArray *arr = [NSArray arrayWithObjects:curUrl, nil];
            previewImageArray = arr;
        }
        if (previewImageArray.count > 0) {
            FGalleryViewController *gallery = [[PictureUtil getUtil]previewImages:previewImageArray andCurUrl:curUrl];
            if (gallery) {
                [curVC.navigationController pushViewController:gallery animated:YES];
            }
        }
    }];
}

#pragma mark picture delegate
- (void)didSelectPicture:(NSArray *)imageArray
{
    if (imageArray.count) {
        [self.bridge callHandler:CHOOSE_IMAGE_HANDLER data:[StringUtil getStringValue:imageArray.count] responseCallback:^(id responseData) {
        }];
    }
}

- (void)didUploadPictureFinish:(NSArray *)imageUrlArray
{
    if (imageUrlArray.count == 0) {
        
        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        NSString *str = [accountDefaults objectForKey:@"errorMessage"];
        if (str != nil && [str isEqualToString:@"用户名或密码错误"]) {
            [UserTipsUtil showAlert:@"密码错误，请重新登录龙信"];
            return;
        }
        BOOL isUpload = [UserTipsUtil checkNetworkAndUserstatus];
        if (isUpload) {
            
            [self.bridge callHandler:UPLOAD_IMAGE_HANDLER data:@"0" responseCallback:^(id responseData) {
                
            }];
        }else{
            
//            [self.bridge callHandler:UPLOAD_IMAGE_HANDLER data:@"0" responseCallback:^(id responseData) {
//                
//            }];
        }
        
    }else{
        
        [self.bridge callHandler:UPLOAD_IMAGE_HANDLER data:imageUrlArray responseCallback:^(id responseData) {
         
        }];
    }
    
}


#pragma mark ======录像接口======
#define START_VIDEO @"startVideo"
#define PLAY_VIDEO @"playVideo"
- (void)initVideo
{
    
    [self.bridge registerHandler:START_VIDEO handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[VideoUtil getUtil] startVideo];
        
    }];
    
    [self.bridge registerHandler:PLAY_VIDEO handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *videoStr = [user objectForKey:@"videoPath"];
        if (videoStr) {
            [[VideoUtil getUtil] playVideo];
        }else{
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:nil message:@"请先拍摄视频" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            
            [alter show];
            [alter release];
        }
        
        
    }];
    
}

#pragma mark ======当前位置接口======
#define CURRENT_LOCATION @"currentLocation"
#define OPEN_LOCATION @"openLocation"
#define CURRENT_LOCATION_HANDLER @"currentLocationHandler"

- (void)initlocation
{
    
    [CurrentLocation getUtil].delegate = self;
    [self.bridge registerHandler:CURRENT_LOCATION handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[CurrentLocation getUtil]getUSerLocation];
    }];
    [self.bridge registerHandler:OPEN_LOCATION handler:^(id data, WVJBResponseCallback responseCallback) {
        
        openLocationoViewController *open = [[[openLocationoViewController alloc]init]autorelease];
        [curVC.navigationController pushViewController:open animated:YES];
        
    }];
    
}

#pragma mark IMLocationDelegate

- (void)didGetCurrentLocation:(NSString *)locationStr
{
    if (([[locationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) || [locationStr isKindOfClass:[NSNull class]]) {
        locationStr = @"0";
    }
    
    
    [self.bridge callHandler:CURRENT_LOCATION_HANDLER data:locationStr responseCallback:^(id response) {
            
        }];
    
}

#pragma mark ======个人详情页
#define GET_USER_INFO @"getUserInfo"
- (void)initUserInfo{
    
    [self.bridge registerHandler:GET_USER_INFO handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *usercode = [data objectForKey:@"usercode"];
        NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];        
        NSString *emp_id = [NSString stringWithFormat:@"%@",[userinfoDic objectForKey:@"emp_id"]];
//        personInfoViewController *personInfo = [[personInfoViewController alloc] init];
//        personInfo.emp = [[eCloudDAO getDatabase] getEmpInfo:emp_id];
        [NewOrgViewController openUserInfoById:emp_id andCurController:curVC];
        
//        [curVC.navigationController pushViewController:personInfo animated:YES];
//        [personInfo release];
        
    }];
}

#pragma mark ======文件助手
#define GET_FILE_ASSISTANT @"getFileAssistant"
- (void)initFileAssistant{
    
    [self.bridge registerHandler:GET_FILE_ASSISTANT handler:^(id data, WVJBResponseCallback responseCallback) {
        
        FileAssistantViewController *open = [[[FileAssistantViewController alloc]init]autorelease];
        [curVC.navigationController pushViewController:open animated:YES];
        
    }];
}

#pragma mark ======设备ID
#define GET_IMEI @"phone_model"
#define PHONE_MODEL_HANDLER @"phone_modelHandler"
- (void)initIMEI{
    
    [self.bridge registerHandler:GET_IMEI handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *IMIE = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [self.bridge callHandler:PHONE_MODEL_HANDLER data:IMIE responseCallback:^(id response) {
            
        }];
        
    }];
}

#pragma mark ======蓝光OAtoken
#define GET_OA_TOKEN @"getOAToken"
#define GET_OA_TOKEN_HANDLER @"getOATokenHandler"
- (void)initOAToken{
    
    [self.bridge registerHandler:GET_OA_TOKEN handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *oaToken = [UserDefaults getLoginToken];
        [LogUtil debug:[NSString stringWithFormat:@"%s oatoken is %@",__FUNCTION__,oaToken]];
        [self.bridge callHandler:GET_OA_TOKEN_HANDLER data:oaToken responseCallback:^(id response) {
            
        }];
        
    }];
    
    [self intSetRealTitle];
    
}

#pragma mark ======蓝光回首页
#define GET_CLOSE_WINDOW @"getCloseWindow"

- (void)initCloseWindow{

#ifdef _LANGUANG_FLAG_
    [self.bridge registerHandler:GET_CLOSE_WINDOW handler:^(id data, WVJBResponseCallback responseCallback) {

        if ([self.curVC isKindOfClass:[LANGUANGAppViewControllerARC class]]) {
            return;
        }
        UIViewController *target = nil;
        for (UIViewController * controller in curVC.navigationController.viewControllers) {
            if ([controller isKindOfClass:[LANGUANGAppViewControllerARC class]]){
                target = controller;
            }
        }
        if (target) {
            
            [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:nil];
            [curVC.navigationController popToViewController:target animated:YES];
        }
        
    }];
#endif
}

#pragma mark =====设置title的方法=====
#define SET_REAL_TITLE @"setRealTitle"
#define REAL_TITLE_KEY @"realTitle"
- (void)intSetRealTitle{
    [self.bridge registerHandler:SET_REAL_TITLE handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *realTitle = data[REAL_TITLE_KEY];
        
        self.curVC.title = realTitle;
    }];
}

#pragma mark =====获取会议id=====
#define SET_MEETING_ID @"setMeetingID"
#define MEETING_ID @"meetingID"
- (void)intSetMeetingID{
    [self.bridge registerHandler:SET_MEETING_ID handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *meetingID = data[MEETING_ID];
#ifdef _LANGUANG_FLAG_
        
        LGMettingDetailViewControllerArc *detail = [[[LGMettingDetailViewControllerArc alloc]init]autorelease];
        detail.idNum = meetingID;
        [self.curVC.navigationController pushViewController:detail animated:YES];
        
#endif

    }];
}
@end
