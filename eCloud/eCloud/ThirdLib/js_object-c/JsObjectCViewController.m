//
//  JsObjectCViewController.m
//  eCloud
//
//  Created by  lyong on 14-5-26.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "JsObjectCViewController.h"
#import "JSSDKObject.h"
#import "TabbarUtil.h"

#import "FGalleryViewController.h"

#import "UploadFileObject.h"

#import "PictureUtil.h"

#import "UIAdapterUtil.h"
#import "RecordUtil.h"
#import "VideoUtil.h"
#import "CurrentLocationUtil.h"

#import "AgentListViewController.h"

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

#import "talkSessionViewController.h"
#import "APPPermissionModel.h"
#import "JSONKit.h"
#import "Emp.h"

@interface JsObjectCViewController () <ChooseMemberDelegate,ScannerViewDelegate,RecordStatusDelegate,PictureDelegate,IMLocationDelegate>{
    APPPermissionModel *permissionModel;
    talkSessionViewController *talkSession;
    int maxGroupNum;
    conn *_conn;
    
    JSSDKObject *jssdk;
}

@property (nonatomic,retain) WebViewJavascriptBridge* bridge;

@end

@implementation JsObjectCViewController
@synthesize dataArray;
@synthesize bridge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)backButtonPressed:(id)sender
{
    self.bridge = nil;
    
    jssdk.bridge = nil;
    jssdk.curVC = nil;
    
    [jssdk release];
    jssdk = nil;

    [self.navigationController popViewControllerAnimated:YES];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"videoPath"];
    [user setObject:nil forKey:@"videoPath"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 接收通知
- (void)addObserver
{
    //回调消息中心
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(js_choose:) name:js_choose_NOTIFICATION object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"js object_c 交互";

    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.tag = WEBVIEW_TAG;
    [self.view addSubview:webView];
    
    //权限控制
    if (!permissionModel) {
        permissionModel = [[APPPermissionModel alloc] init];
    }
    [permissionModel setPermission:5];
    

    [self addObserver];
    _conn = [conn getConn];
    maxGroupNum = _conn.maxGroupMember;
    
    
    __weak UIViewController *weakSelf =self;

    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:webView webViewDelegate:weakSelf handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取self.bridge----");
    }];
    
    jssdk = [[JSSDKObject alloc]init];
    jssdk.bridge = self.bridge;
    jssdk.curVC = self;

    [jssdk initSDK];
    
    //获取通信录
    [self.bridge registerHandler:@"openContacts" handler:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"openContacts called: %@", data);
        /*
        if ([permissionModel canOpenContactList]) {
            //允许访问通讯录
            if (chooseMember==nil) {
                chooseMember=[[specialChooseMemberViewController alloc]init];
            }
            chooseMember.typeTag=3;
            
            [self.navigationController pushViewController:chooseMember animated:YES];
            responseCallback(@"true");
        }else{
            //不允许访问通讯录
            responseCallback(@"false");
        }
        */
        
        //允许访问通讯录
        if (chooseMember==nil) {
            chooseMember=[[specialChooseMemberViewController alloc]init];
        }
        chooseMember.typeTag=3;
        [self.navigationController pushViewController:chooseMember animated:YES];
        responseCallback(@"true");
    }];
    
    //发起会话
    [self.bridge registerHandler:@"inviteChat" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"inviteChat called: %@", data);
        
        BOOL selectContact = [[data objectForKey:@"selectContact"] boolValue];
        NSMutableArray *usercodesArr = [NSMutableArray arrayWithArray:[data objectForKey:@"usercodes"]];
        
        if (selectContact) {
            
            if(!self.dataArray){
               self.dataArray  = [[NSMutableArray alloc] init];
            }
            
            if([self.dataArray count]){
                [self.dataArray removeAllObjects];
            }
            
            NSString *user_code = _conn.user_code;
            for (NSString *usercodeStr in usercodesArr){
                Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:usercodeStr];
                [self.dataArray addObject:_emp];
            }
            
            if (![usercodesArr containsObject:user_code]){
                Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:user_code];
                [self.dataArray addObject:_emp];
            }
            
            //打开联系人界面
            if (chooseMember==nil) {
                chooseMember=[[specialChooseMemberViewController alloc]init];
            }
            chooseMember.typeTag = 4;
            chooseMember.delegete = self;
            [self.navigationController pushViewController:chooseMember animated:YES];
            
        }else{
            //直接发其会话
            [self createConventWithUsercodesArr:usercodesArr];
            
            responseCallback(@"直接发其会话");
        }
        
    }];
    
    //查看联系人信息
    [self.bridge registerHandler:@"openContact" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"openContact called: %@", data);
        NSString *usercode = [data objectForKey:@"usercode"];
        NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];
        responseCallback([userinfoDic JSONString]);
    }];
    
    //状态感知
    [self.bridge registerHandler:@"getUserStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"getUserStatus called: %@", data);
        
        NSString *usercode = [data objectForKey:@"usercode"];
        NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];
        NSString *emp_status = [userinfoDic objectForKey:@"emp_status"];
        responseCallback(emp_status);
    }];
    
    //分享
    [self.bridge registerHandler:@"share2wangxin" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"share2wangxin called: %@", data);
        
        NSMutableDictionary *sharInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"content"],@"content",[data objectForKey:@"contenturl"],@"contenturl",[data objectForKey:@"messagetype"],@"messagetype", nil];

        responseCallback(@"share");
    }];
    
//    [self initScanQRCode];
//    
//    [self initSelectContacts];
//    
//    [self initCreateConv];
//    
//    [self initChangeDirection];
//    
//    [self initRecord];
//    
//    [self initImage];
//    
//    [self initVideo];
//    
//    [self initlocation];
    
    /*
    [self.bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
         [self.navigationController popViewControllerAnimated:YES];
      //  [[NSNotificationCenter defaultCenter ]postNotificationName:js_list_NOTIFICATION object:nil userInfo:nil];
        responseCallback(@"通讯录");
    }];

    [self.bridge registerHandler:@"getUserStatus" handler:^(id data, WVJBResponseCallback responseCallback) {

         NSString *user_Id=[data objectForKey:@"user_id"];
        
         NSLog(@"getUserStatus called: %@ ",data, user_Id);
        Emp* emp=[[eCloudDAO getDatabase] getEmpInfo:user_Id];
        NSString *emp_name=@"史素萍";
        NSString *tip_str=nil;
        if (emp.emp_status==status_online||emp.emp_status==status_leave)
        {
            tip_str=[NSString stringWithFormat:@"%@ 在线",emp_name];

        }
        else
        {
            tip_str=[NSString stringWithFormat:@"%@ 不在线",emp_name];

        }
        
        responseCallback(tip_str);
    }];
    
    
    [self.bridge registerHandler:@"testObjcCallback_2" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback_2 called: %@", data);
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter ] postNotificationName:BACK_TO_CONV_LIST_NOTIFICATION object:nil userInfo:nil];
        responseCallback(@"会话列表");
    }];
    */
    
    
//    [self.bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
//        NSLog(@"objc got response! %@", responseData);
//    }];
//    
//    [self.bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
   // [self renderButtons:webView];
   [self loadExamplePage:webView];
   
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];

    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - 直接发起会话
- (void)createConventWithUsercodesArr:(NSArray *)usercodesArr{
    
    if (![usercodesArr count]) {
        return;
    }
    
    NSMutableArray *nowSelectedEmpArray = [[NSMutableArray alloc] init];
    
    NSString *user_code = _conn.user_code;
    
    for (NSString *usercodeStr in usercodesArr) {
        Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:usercodeStr];
        [nowSelectedEmpArray addObject:_emp];
    }
    
    
    NSLog(@"nowSelectedEmpArray.count-------------%i",[nowSelectedEmpArray count]);
    
    
    if(talkSession == nil)
        talkSession=[[talkSessionViewController alloc]init];
    
    
    if ([nowSelectedEmpArray count]==1){
        //创建单聊
        Emp *emp = [nowSelectedEmpArray objectAtIndex:0];
        talkSession.titleStr=emp.emp_name;
        talkSession.talkType=singleType;
                
        talkSession.convEmps = nowSelectedEmpArray;
        //如果是群聊，则不设置convId
        talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
        talkSession.needUpdateTag = 1;
    }
    else
    {

        if (![usercodesArr containsObject:user_code]) {
            Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:user_code];
            [nowSelectedEmpArray addObject:_emp];
        }
        
        
        //			判断选中的人员数量
        if([nowSelectedEmpArray count] > maxGroupNum )
        {
            [self showGroupNumExceedAlert];
            return;
        }
        
        //	创建多人会话
        talkSession.titleStr=@"多人会话";
        talkSession.talkType=mutiableType;
        talkSession.convId=nil;
        talkSession.convEmps = nowSelectedEmpArray;
        
        talkSession.needUpdateTag = 1;
    }
    //打开会话窗口
    [self.navigationController pushViewController:talkSession animated:YES];
}


#pragma mark - 提醒用户选择人数已经超过最大值
-(void)showGroupNumExceedAlert
{
	NSString *titlestr=[NSString stringWithFormat:@"群组的成员个数最多为%d个",maxGroupNum];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAppName] message:titlestr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}


#pragma mark - 获取通讯录数据回调消息中心
-(void)js_choose:(NSNotification *)notification
{
    [self.bridge callHandler:@"openContactsHandler" data:[notification.object JSONString] responseCallback:^(id response) {
        NSLog(@"openContactsHandler responded: %@", response);
    }];
}


#pragma mark ------------------------------------------------------------------------------------------------

-(void)doAction:(UIWebView *)webView
{
[self loadExamplePage:webView];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(UIWebView*)webView {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.view insertSubview:messageButton aboveSubview:webView];
	messageButton.frame = CGRectMake(20, 360, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
	callbackButton.frame = CGRectMake(170, 360, 130, 45);
}

- (void)sendMessage:(id)sender {
    [self.bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    NSArray *array=[[NSArray alloc]initWithObjects:@"大国",@"中国",@"好天气",@"饿饿饿", nil];
    [self.bridge callHandler:@"testJavascriptHandler" data:array responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
   // NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"testHtml" ofType:@"html"];

    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];

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
        
        [self.navigationController pushViewController:scanner animated:YES];
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
                    
                    NSString *msgBody = [NSString stringWithFormat:@"%@",msg];
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
                
                [self.navigationController pushViewController:talkSession animated:YES];
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
        
        [AgentListViewController changeOrientation:self andDirection:direction];
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
    for (UploadFileObject *uploadFileObject in result) {
        NSString *uploadResponse = uploadFileObject.uploadResponse;
        if (uploadResponse.length) {
            if (mStr.length > 0) {
                [mStr appendFormat:@",%@",uploadResponse];
            }else{
                [mStr appendString:uploadResponse];
            }
        }
    }

//    [self.bridge callHandler:@"logHandler" data:mStr responseCallback:^(id responseData) {
//     
//    }];
}

//// 显示状态
- (void)dspStatus:(NSString *)statusStr
{
    NSString *_titleStr = @"js object-c 交互";
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = statusStr
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
            [[PictureUtil getUtil]presentSheet:self];
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
        if (previewImageArray.count > 0) {
            FGalleryViewController *gallery = [[PictureUtil getUtil]previewImages:previewImageArray andCurUrl:curUrl];
            if (gallery) {
                [self.navigationController pushViewController:gallery animated:YES];
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
    [self.bridge callHandler:UPLOAD_IMAGE_HANDLER data:imageUrlArray responseCallback:^(id responseData) {
        
    }];
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
#define CURRENT_LOCATION_HANDLER @"currentLocationHandler"

- (void)initlocation
{
    
    [CurrentLocation getUtil].delegate = self;
    [self.bridge registerHandler:CURRENT_LOCATION handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[CurrentLocation getUtil]getUSerLocation];
    }];
}

#pragma mark IMLocationDelegate

- (void)didGetCurrentLocation:(NSString *)locationStr
{
    [self.bridge callHandler:CURRENT_LOCATION_HANDLER data:locationStr responseCallback:^(id response) {
       
    }];
}


- (void)dealloc
{
    self.dataArray = nil;
    self.bridge = nil;
    [super dealloc];
}
@end
