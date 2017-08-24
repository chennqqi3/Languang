//
//  contactViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//
#import "contactViewController.h"
#import "CreateGroupUtil.h"
#import "WXOrgUtil.h"
#import "MiLiaoUtilArc.h"
#import "NewAPPTagUtil.h"
#import "JsObjectCViewController.h"
#ifdef _LANGUANG_FLAG_
#import "MiLiaoConvListViewController.h"
#import "LGAppMsgViewControllerARC.h"
#import "LGRootChooseMemberViewController.h"

#endif

#import "ScannerViewController.h"

#ifdef _GOME_FLAG_

//是否启用高级搜索功能
#define _GOME_FLAG_ADV_SEARCH_
#import "ISRDataHelper.h"
#import "EncryptFileManege.h"
#import "talkSessionUtil2.h"
#import "AdvSearchFileCell.h"
//查到文件后，如果文件还未下载，那么下载先
#import "talkSessionUtil.h"
#import "DownloadFileUtil.h"
#import "DownloadFileObject.h"

#import "ViewMoreSearchResultsController.h"
#import "UploadFileModel.h"
#import "DownloadFileModel.h"
#import "FileAssistantUtil.h"
#import "RobotDisplayUtil.h"
#import "GOMEAppViewController.h"
#import "GOMEAppMsgListViewController.h"
/** 高级查询有关的代码 */
#import "WXAdvSearchUtil.h"
#import "WXAdvSearchModel.h"
#import "AdvSearchHeaderView.h"
#import "AdvSearchFooterView.h"
#import <iflyMSC/IFlyMSC.h>
#import "ScanQRCodeViewControllerArc.h"
#import "FileRecord.h"

#endif

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#import "WXCacheUtil.h"
#import "MsgSyncUtil.h"
#endif

#if defined(_HUAXIA_FLAG_)
#import "HuaXiaUserInterfaceDefine.h"
#endif

#ifdef _XINHUA_FLAG_
#import "XINHUAOrgSelectedViewControllerArc.h"
#import "XINHUADefineHeader.h"
#endif
#import "UserDataDAO.h"

//#import "TestMifengViewController.h"
#import "GXViewController.h"
#import "DirectoryWatcher.h"
#import "folderSizeAndList.h"
#import "ServiceMessage.h"
#import "ServiceModel.h"

#ifdef _NANHANG_FLAG_
#import "AttentionViewController.h"
#import "RemindViewController.h"
#endif

#import "OpenCtxManager.h"


#import "APPListModel.h"

#import "AppItemCell.h"
#import "AgentListViewController.h"

#import "APPPlatformDOA.h"
#import "OpenNotificationDefine.h"

#import "HDNotificationView.h"

#import "eCloudUser.h"
#import "Conversation.h"
#import "ApplicationManager.h"
#import "AccessConn.h"
#import "ConnResult.h"
#import "eCloudDefine.h"
#import "conn.h"

#import "TestRecordViewController.h"
#import "chatRecordViewController.h"

#import "TabbarUtil.h"

#import "UserDefaults.h"

#import "NewChooseMemberViewController.h"
#import "chooseMemberViewController.h"
#import "personGroupViewController.h"

#import "AppDelegate.h"
#import "personInfoViewController.h"
#import "talkSessionViewController.h"
#import "mainViewController.h"
#import "UserInfo.h"
#import "LCLLoadingView.h"

#import "ConvNotification.h"
#import "eCloudDAO.h"
#import "FLTGroupListViewController.h"
#import "PSMsgListViewController.h"
#import "MonthHelperViewController.h"
#import "broadcastListViewController.h"
#import "MassDAO.h"
#import "PublicServiceDAO.h"
#import "PSUtil.h"
#import "PSMsgDtlViewController.h"
#import "UserDisplayUtil.h"
#import "NewMsgNumberUtil.h"
#import "QueryResultCell.h"
#import "QueryDAO.h"
#import "QueryResultViewController.h"
#import "QueryResultHeaderCell.h"
#import "APPPushDetailViewController.h"
#import "UIAdapterUtil.h"
#import "DAOverlayView.h"
#import "MLNavigationController.h"
#import "StatusConn.h"
#import "ImageUtil.h"
#import "CreateTestDataUtil.h"
#import "UserTipsUtil.h"
#import "NotificationUtil.h"

#import "JSONKit.h"
#import "RSAEncryptor.h"
#import "NSData+AES256.h"

#import "KxMenu.h"

#ifdef _TAIHE_FLAG_
#import "TAIHEAppMsgViewController.h"
#endif

#define CONV_SECTION_HEADER_HEIGHT (30.0)

#define GET_APP_UNREAD_REQ_EMPID_KEY @"employeeId"

#define GET_APP_UNREAD_RES_RESULT_KEY @"result"
#define GET_APP_UNREAD_RES_MESSAGE_KEY @"message"
#define GET_APP_UNREAD_RES_DATA_KEY @"data"
#define GET_APP_UNREAD_RES_EMPID_KEY @"employeeId"
#define GET_APP_UNREAD_RES_TOTALCOUNT_KEY @"totalCount"
#define GET_APP_UNREAD_RES_UNREADCOUNT_KEY @"unReadCount"
#define app_name_tag (102)

/**
 * RSA加密公钥
 */
static NSString *RSA_ENCRYPT_PUBLIC_KEY = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCICjluGEKsq0BhamkhCRtyD5JTMt/3hJa0BlrVWuDwyQeeEw7p/AYe6347tDneewWjabMhuizuJqh3YWNz89v9IRB3IMr0uRGu5a5gUmA7xcUsmip7TMLnkjF4vbGHz53xi4Cgb9CUE4bXoYtyv0Ag4Z9cnV48wa/jciaTxH0ddwIDAQAB";



#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
@interface contactViewController ()<menuCellDelegate,DirectoryWatcherDelegate,ChooseMemberDelegate,HuaXiaOrgProtocol>
#elif defined(_GOME_FLAG_)
@interface contactViewController ()<menuCellDelegate,DirectoryWatcherDelegate,ChooseMemberDelegate,IFlySpeechRecognizerDelegate, IFlyPcmRecorderDelegate,AdvSearchProtocol,QLPreviewControllerDataSource>
#else
@interface contactViewController ()<menuCellDelegate,DirectoryWatcherDelegate,ChooseMemberDelegate>
#endif
{
    DirectoryWatcher *docWatcher;
    BOOL _isMiLiao;
    BOOL _isRecognition;
    BOOL _isWannaCancel;
    
    UIButton *scanQRcodeBtn;
    // tabbar上显示的未读数
    int tabbarUnReadCount;
    CGFloat _tableViewLineX;

}
@property (nonatomic, retain) MonthHelperViewController *mainVC;

@property (nonatomic, strong) UIView *recognitionView;
@property (nonatomic, strong) UIImageView *recognitionImageView;
@property (nonatomic, strong) UILabel *recognitionLabel;

//cell左滑菜单
@property (retain, nonatomic) QueryResultCell *cellDisplayingMenuOptions;
@property (retain, nonatomic) DAOverlayView *overlayView;
@property (assign, nonatomic) BOOL customEditing;
@property (assign, nonatomic) BOOL customEditingAnimationInProgress;
@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;

//有哪些轻应用
@property (retain,nonatomic) NSMutableArray *appItemArray;

@property(nonatomic, retain) NSMutableArray *deleteArr;//删除数据的数组

//获取轻应用未读数的请求
@property (nonatomic,retain) ASIFormDataRequest *unReadRequest;


#ifdef _GOME_FLAG_
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入
#endif

@end

@implementation contactViewController
{
    /** 用户预览的文件所在的indexpath */
    NSIndexPath *previewFileIndex;
    
	eCloudDAO *_ecloud ;
	PublicServiceDAO *_psDAO;
    
    StatusConn *_statusConn;
    UISearchDisplayController * searchdispalyCtrl;
    UIActivityIndicatorView *_topIndicator;
    
    UIButton *readedButton;
    UIButton *editBtn;//删除
    UIView *bottomToolBar;
    UIButton *leftButton;//编辑按钮
    UIButton *chooseBtn;//全选
    
    /** 密聊按钮上的新消息数量父view */
    UIView *encryptNewMsgParentView;
}

@synthesize unReadRequest;

@synthesize isLoad;

@synthesize searchTimer;
@synthesize searchStr;
@synthesize searchResults;
@synthesize convSearchResults;

@synthesize delegete;
@synthesize itemArray;
@synthesize itemDic;
@synthesize talkSession = _talkSession;
@synthesize searchText = _searchText;


@synthesize personTable = _personTable;

@synthesize reLinkView = _reLinkView;

@synthesize appItemArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (id)init
{
    self = [super init];
    
    if (self) {
//     如果会话标签不是第一个标签，那么如果用户不点击会话标签，那么viewdidload方法就不会调用，这样有些通知就无法接收，所以把以下初始化及接收通知的代码从viewdidload移动到init方法里   update by shisp
        _conn = [conn getConn];
        
        _ecloud = [eCloudDAO getDatabase];
        _psDAO = [PublicServiceDAO getDatabase];
        
        _statusConn = [StatusConn getConn];

        if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processAppNotification:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGetUserInfoFromHX:) name:GET_USER_INFO_FROM_HX_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToContactViewController:) name:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToContactViewControllerFromRobot:) name:BACK_TO_CONTACTVIEW_FROM_ROBOT object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rcvOfflineMsgFinish) name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];
        
        //监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
        
        [_conn addObserver:self forKeyPath:@"connStatus" options:NSKeyValueObservingOptionNew context:nil];
        [_conn addObserver:self forKeyPath:@"downloadOrgTips" options:NSKeyValueObservingOptionNew context:nil];
        
        self.appItemArray = [NSMutableArray array];
        
        self.deleteArr = [NSMutableArray array];
        //监控文件夹目录 清理飞信提示
        docWatcher = [[DirectoryWatcher alloc]init];
        [docWatcher watchFolderWithPath:[StringUtil newRcvFilePath] witchDelegate:self];
        
        //    DirectoryWatcher *docWatcher = [DirectoryWatcher watchFolderWithPath:[StringUtil newRcvFilePath] delegate:self];
        
        [self directoryDidChange:docWatcher];

        
    }
    return self;
}
-(void)refreshData
{
//    独立版不用采用异步方式
//    dispatch_queue_t _queue = dispatch_queue_create(@"refresh recent contact", NULL);
//
//    dispatch_async(_queue, ^(){
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
        NSArray *array = [_ecloud getRecentConversation:normal_conv_type];
        array = [array sortedArrayUsingSelector:@selector(compareByLastMsgTime:)];

        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
        if (array.count > 0) {
            for (Conversation *_conv in array) {
                [mDic setObject:_conv forKey:_conv.conv_id];
            }
        }
        
        int count = [_ecloud getAllNumNotReadedMessge];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
    
            [self displayAllUnreadMsgCount:count];
            
            self.itemArray = [NSMutableArray arrayWithArray:array];
            self.itemDic = [NSMutableDictionary dictionaryWithDictionary:mDic];
            
            [self exeReloadData];
    
    [[self class]autoGetGroupInfo:array];
            
//        });
//    });
//    dispatch_release(_queue);
}

-(void)refreshDataAsync
{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
    
    dispatch_queue_t _queue = dispatch_queue_create(@"refresh recent contact", NULL);
    
    dispatch_async(_queue, ^(){
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
        NSArray *array = [_ecloud getRecentConversation:normal_conv_type];
        array = [array sortedArrayUsingSelector:@selector(compareByLastMsgTime:)];
        
        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
        if (array.count > 0) {
            for (Conversation *_conv in array) {
                [mDic setObject:_conv forKey:_conv.conv_id];
            }
        }
        
        int count = [_ecloud getAllNumNotReadedMessge];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self displayAllUnreadMsgCount:count];
            
            self.itemArray = [NSMutableArray arrayWithArray:array];
            self.itemDic = [NSMutableDictionary dictionaryWithDictionary:mDic];
            
            [self exeReloadData];
            [[self class]autoGetGroupInfo:array];
            
            [UserTipsUtil hideLoadingView];
        });
    });
    dispatch_release(_queue);
}

-(void)handleCmd:(NSNotification *)notification
{
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
            case receive_msg_read_notify:
            {
                NSDictionary *dic = _notification.info;
                if (dic) {
                    int _count = [[dic valueForKey:@"all_unread_msg_count"]intValue];
                    NSArray *_array = [dic valueForKey:@"unread_msg_count_array"];
                    
                    BOOL needReload = NO;
                    for (NSDictionary *_dic in _array) {
                        
                        NSString *convId = [_dic valueForKey:@"conv_id"];
                        Conversation *_conv = [self.itemDic valueForKey:convId];
                        if (_conv) {
                            _conv.unread = [[_dic valueForKey:@"unread_msg_count"]intValue];
                            _conv.is_tip_me = NO;
                            
                            needReload = YES;
                        }
                    }
                    if (needReload) {
                        [self exeReloadData];
                    }
                    [self displayAllUnreadMsgCount:_count];
                }
            }
                break;
            case group_member_change:
            {
                NSDictionary *dic = notification.userInfo;
                if (dic) {
                    NSString *convId = [dic valueForKey:@"conv_id"];
                    if (convId)
                    {
                        Conversation *_conv = [self.itemDic valueForKey:convId];
                        if (_conv) {
                            [_conv getGroupLogoEmpArray];
                            int index = [self.itemArray indexOfObject:_conv];
                            [self reloadDataAtIndex:index];
                        }
                    }
                }
            }
                break;
               
//            case send_msg_success://发送消息成功
//            {
//                NSDictionary *dic = _notification.info;
//                NSString *msgId = [dic objectForKey:@"MSG_ID"];
//                NSString *convId = [dic valueForKey:@"conv_id"];
//                if (convId) {
//                    Conversation *conv = [self.itemDic valueForKey:convId];
//                    if (conv && conv.last_msg_id == msgId.intValue ) {
////                        需要刷新
//                        conv.last_record.send_flag = send_success;
//                        
//                        int index = [self.itemArray indexOfObject:conv];
//                        
//                        [self reloadDataAtIndex:index];
//                    }
//                }
//            }
//                break;

//			case get_group_info_success://获取分组信息成功
//                //			case offline_msgs://收取离线消息
//			case send_msg_success://发送消息成功
//			case rev_msg:
//			case ps_msg_read://服务号消息已读
//			{//收到了消息
//				[self refreshData];
//			}
//				break;
			case login_timeout:
			{
				NSLog(@"%s登录超时",__FUNCTION__);
				[self stopLinking];
			}
				break;
			case login_failure:
			{
				NSLog(@"登录失败");
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
 				
                //				判断失败的原因
				NSDictionary * dic = _notification.info;
				ConnResult *result = [dic objectForKey:@"RESULT"];
                //                只有密码错的时候才弹框提示用户
                if(result.resultCode == RESULT_INVALIDPASSWD || result.resultCode == RESULT_SSO_USER_OR_PASSWD_ERR)
                {
                    //0825
                    [self setTitleViewFrameWithTitleStr:[_conn getTips]];
                    
                    [_topIndicator stopAnimating];
                    if(loginErrorAlert)
                    {
                        [loginErrorAlert dismissWithClickedButtonIndex:0 animated:YES];
                        [loginErrorAlert release];
                        loginErrorAlert = nil;
                    }
                    if(loginErrorAlert == nil)
                    {
                        loginErrorAlert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[result getResultMsg] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                        loginErrorAlert.tag = 0;
                    }
                    [loginErrorAlert show];
                }
                else if(result.resultCode == RESULT_FORBIDDENUSER || result.resultCode == RESULT_SSO_USER_FORBID_ERR)
                {
                    
                    [[ApplicationManager getManager] userDisable:nil];
                    //0825
                    [self setTitleViewFrameWithTitleStr:[_conn getTips]];
                    
                    [_topIndicator stopAnimating];
                    
                    [self beKick:nil];
                }else if (result.resultCode == RESULT_INVALIDUSER){
                    
                    if(loginErrorAlert)
                    {
                        [loginErrorAlert dismissWithClickedButtonIndex:0 animated:YES];
                        [loginErrorAlert release];
                        loginErrorAlert = nil;
                    }
                    if(loginErrorAlert == nil)
                    {
                        loginErrorAlert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[result getResultMsg] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                        loginErrorAlert.tag = 0;
                    }
                    [loginErrorAlert show];
                }
                else
                {
                    [self stopLinking];
                }
			}
				break;
			case login_success:
			{
				NSLog(@"%s,登录成功",__FUNCTION__);
                
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                
				[self displayStatus];
			}
				break;
            case start_check_network:
            case end_check_network:
            {
                [self displayStatus];
            }
                break;
			default:
				break;
		}
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertView.tag == 0)
	{//		登录失败，原因是密码错，返回到登录界面
        [UserDefaults saveUserIsExit:YES];
        
		[( (mainViewController*)self.delegete)backRoot];

	}
    else if (alertView.tag == 100)
    {
        if (buttonIndex == 1) {
            [self createTestData:nil];
        }
    }
    else if (alertView.tag == 1000)
    {
    
    }
}

- (void) showCreateTestDataAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"生成测试数据？" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    alert.tag = 100;
    [alert show];
    [alert release];
}

-(void) createTestData:(id) sender
{
     dispatch_queue_t _queue = dispatch_queue_create(@"create test data", NULL);
    dispatch_async(_queue,^{
        BOOL result = [CreateTestDataUtil createTestData];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UserTipsUtil showAlert:@"测试数据生成了" autoDimiss:YES];
                _conn.connStatus = normal_type;
                [self refreshData];
                [self setTipOK];
            });
        }
    });
    dispatch_release(_queue);
    
}

//全选
- (void)selectAllBtnClick:(UIButton *)button {

    if (!button.selected) {
        button.selected = YES;
        [button setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        for (int i = 0; i < self.itemArray.count; i ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.personTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            [self.deleteArr addObjectsFromArray:self.itemArray];
        }
    }else{
        button.selected = NO;
        [button setTitle:[StringUtil getLocalizableString:@"future_generations"] forState:UIControlStateNormal];
        for (int i = 0; i < self.itemArray.count; i ++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.personTable deselectRowAtIndexPath:indexPath animated:YES];
            [self.deleteArr removeObjectsInArray:self.itemArray];
        }
    }
    
}

 -(void)EditMode:(UIButton *)button
{
//    TestRecordViewController *testRecordVC = [[[TestRecordViewController alloc]init]autorelease];
//    [self.navigationController pushViewController:testRecordVC animated:YES];
   
    //支持同时选中多行
    self.personTable.allowsMultipleSelectionDuringEditing = YES;
    self.personTable.editing = !self.personTable.editing;
    if (self.personTable.editing) {
        [button setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        [self hideTabBar];
        [self.deleteArr removeAllObjects];
        readedButton.hidden = YES;
        bottomToolBar.hidden = NO;
        [UserDefaults setSessionIsEdit:@"是"];
        
    }else{
  
        [button setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
        [UIAdapterUtil showTabar:self];
        readedButton.hidden = NO;
        bottomToolBar.hidden = YES;
        [UserDefaults setSessionIsEdit:@"否"];
        chooseBtn.selected = NO;
        [chooseBtn setTitle:[StringUtil getLocalizableString:@"future_generations"] forState:UIControlStateNormal];
    }
}

- (void)deleteButton{
    
    [UserDefaults setSessionIsEdit:@"否"];
    chooseBtn.selected = NO;
    [chooseBtn setTitle:[StringUtil getLocalizableString:@"future_generations"] forState:UIControlStateNormal];
    for (int i = 0 ; i < self.deleteArr.count; i++) {
        
        Conversation *conv=[self.deleteArr objectAtIndex:i];
        
        [self setAllMsgToReadOfConv:conv];
        
        [_ecloud updateDisplayFlag:conv.conv_id andFlag:1];
        //    修改为从内存里删除这一条会话，然后刷新界面，不用从数据库再次获取
        [self.itemArray removeObject:conv];
        [self.itemDic removeObjectForKey:conv.conv_id];
        [self showNoReadNum];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新
        self.personTable.editing = !self.personTable.editing;
        //[leftButton setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
        [UIAdapterUtil showTabar:self];
        readedButton.hidden = NO;
        bottomToolBar.hidden = YES;
        [self.personTable reloadData];
    });
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
        //        第一部分是轻应用
       self.appItemArray = [[APPPlatformDOA getDatabase] getAPPList];
    }
    
    self.isLoad = YES;
    
    
#ifdef _BGY_FLAG_
    // 展示左边侧边栏
    [UIAdapterUtil setupLeftIconItem:self];
#endif
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(empStatusChange:) name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
    
    //设置背景
    [UIAdapterUtil setBackGroundColorOfController:self];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil processController:self];
    
    // 0901 添加indicator
//    _topIndicator = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)]autorelease];
//    [self.navigationController.navigationBar addSubview:_topIndicator];
    
         //    右边按钮
    UIButton *addButton = [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addButtonPressed:)];
    [addButton setImage:[StringUtil getImageByResName:@"add_ios_hl"] forState:UIControlStateHighlighted];
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        //   增加导航栏左边按钮 批量删除会话
//        leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"edit"] andTarget:self andSelector:@selector(EditMode:) andDisplayLeftButtonImage:NO];
    }
#ifdef _LANGUANG_FLAG_
//    leftButton = [UIAdapterUtil setLeftButtonItemWithTitle:[self getMiLiaoBtnTitle] andTarget:self andSelector:@selector(openMiLiaoVC) andDisplayLeftButtonImage:NO];
    
    if ([UserDefaults getLanGuangSecret]) {

        leftButton = [UIAdapterUtil setLeftButtonItemWithImageName:@"encrypt_message.png" andTarget:self andSelector:@selector(openMiLiaoVC)];
        
        [leftButton setImage:[StringUtil getImageByResName:@"encrypt_message_hl.png"] forState:UIControlStateHighlighted];
        
        encryptNewMsgParentView = [[[UIView alloc]initWithFrame:CGRectMake(0, 10, leftButton.frame.size.width - 5, leftButton.frame.size.height - 10)]autorelease];
        [leftButton addSubview:encryptNewMsgParentView];
        
//        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMiLiaoVC)]autorelease];
//        [encryptNewMsgParentView addGestureRecognizer:tap];
        
        encryptNewMsgParentView.userInteractionEnabled = YES;
        
        [NewMsgNumberUtil addNewMsgNumberView:encryptNewMsgParentView];
        
        [self displayUnreadEncryptMsg];

    }
    
#endif
        //最近会话展示窗口
	
    [self initSearch];
    
//    statusbar navigatorbar searchbar tabbar
    int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT - theSearchBar.frame.size.height;

    self.personTable= [[[UITableView alloc] initWithFrame:CGRectMake(0, theSearchBar.frame.size.height, self.view.frame.size.width, tableH) style:UITableViewStylePlain]autorelease];
    [UIAdapterUtil setPropertyOfTableView:self.personTable];
	
    [self.personTable setDelegate:self];
    [self.personTable setDataSource:self];
    self.personTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.personTable];
    
    //[UIAdapterUtil autoSizeTable:self.personTable];
    
	backgroudButton=[[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH)]autorelease];
    backgroudButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [self.personTable addSubview:backgroudButton];
    backgroudButton.hidden=YES;
    
    //
	if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
    
    //网络未链接，重新连接
#if defined(_GOME_FLAG_)
    UIButton *relinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relinkButton.layer.borderColor = GOME_SEPERATE_COLOR.CGColor;// [UIColor colorWithRed:0xe9/255.0 green:0xe9/255.0 blue:0xe9/255.0 alpha:1];
    relinkButton.layer.borderWidth = 1.0;
    relinkButton.frame = CGRectMake(-1, 0, SCREEN_WIDTH + 2, 48);
    UIImage *relinkImage = [StringUtil getImageByResName:@"relink_button.png"];
    [relinkButton setImage:relinkImage forState:UIControlStateNormal];
    
    NSString *title = [StringUtil getLocalizableString:@"contact_reconnect"];
    [relinkButton setTitle:title forState:UIControlStateNormal];
    [relinkButton setTitleColor:GOME_BLUE_COLOR forState:UIControlStateNormal];
    
    [relinkButton addTarget:self action:@selector(reLinkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [UIAdapterUtil customButtonStyle:relinkButton];
    
    UIView *relinkView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, relinkButton.frame.size.height)]autorelease];
    [relinkView setBackgroundColor:[UIColor whiteColor]];
    [relinkView addSubview:relinkButton];
    
    self.reLinkView = relinkView;
#else
    /** 重连view */
    self.reLinkView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    /** 重连view 背景 */
    UIImageView *_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,40)];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _imageView.image = [StringUtil getImageByResName:@"no-connect-bj.png"];
    [self.reLinkView addSubview:_imageView];
    [_imageView release];

    /** 重连按钮 */
    float btnWidth = 70;
    float btnHeight = 30;
    float btnX = SCREEN_WIDTH - btnWidth - 15;
    float btnY = (_reLinkView.frame.size.height - btnHeight) * 0.5;
    
    UIButton *reLinkButton=[[UIButton alloc]initWithFrame:CGRectMake(btnX,btnY,btnWidth,btnHeight)];
    reLinkButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [reLinkButton setTitle:[StringUtil getLocalizableString:@"contact_reconnect"] forState:UIControlStateNormal];
    //        [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    //        [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    //        [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    reLinkButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [reLinkButton addTarget:self action:@selector(reLinkButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.reLinkView addSubview:reLinkButton];
    reLinkButton.layer.cornerRadius = 3.0;
    [reLinkButton release];

#if defined (_LANGUANG_FLAG_)
    //    白底，字和边框颜色是0088c8
    reLinkButton.backgroundColor = [UIColor whiteColor];
    reLinkButton.layer.borderWidth = 1.0;
    reLinkButton.layer.borderColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0].CGColor;
    [reLinkButton setTitleColor: [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0] forState:UIControlStateNormal];
#elif defined (_HUAXIA_FLAG_)
//    华夏要求修改为灰色
    [reLinkButton setBackgroundImage:[StringUtil getImageByResName:@"contact_reconnect_btn"] forState:UIControlStateNormal];
    [reLinkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
#else
    //    49 93 155 深蓝色
    reLinkButton.backgroundColor = [UIColor colorWithRed:49/255.0 green:93/255.0 blue:155/255.0 alpha:1];
#endif
    
#endif
  
//    for (UIView *searchbuttons in _searchBar.subviews)
//    {
//        if ([searchbuttons isKindOfClass:[UIButton class]])
//        {
//            UIButton *cancelButton = (UIButton*)searchbuttons;
//            cancelButton.enabled = YES;
//            [cancelButton setBackgroundImage:[StringUtil getImageByResName:@"back_button_click。png"] forState:UIControlStateNormal];
//            break;
//        }
//    }
    
    //正在连接通知，显示正在连接
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connecting) name:CONNECTING_NOTIFICATION object:nil];
    
//	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noConnect:) name:NO_CONNECT_NOTIFICATION object:nil];
    
    //	被踢通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beKick:) name: @"noctiveOFFLINE" object: nil];
    //	被踢通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beKick:) name: USER_DISABLE_NOTIFICATION object: nil];
    
//    当群组成员变化时，刷新群组头像
  	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
  
    
    //监听离线通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:OFFLINE_NOTIFICATION object:nil];
	
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(helperCmd:) name:HELPER_MESSAGE_NOTIFICATION object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToMiLiao:) name:BACK_TO_CONTACTVIEW_TO_MILIAO object:nil];
    
    
    
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    
    
    self.recognitionView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 50)];
    self.recognitionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self.recognitionView];
    
    UIButton *recognitionButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    recognitionButton.frame = CGRectMake(20, 6, SCREEN_WIDTH-(2*20), 38);
    recognitionButton.layer.cornerRadius = 6;
    recognitionButton.clipsToBounds = YES;
    [recognitionButton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_audio"] forState:(UIControlStateNormal)];
    [recognitionButton setImage:[StringUtil getImageByResName:@"icon_record"] forState:(UIControlStateNormal)];
    [recognitionButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [recognitionButton setBackgroundImage:[ImageUtil imageWithColor:[UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1]] forState:(UIControlStateNormal)];
    [recognitionButton setBackgroundImage:[ImageUtil imageWithColor:[UIColor colorWithRed:0xe0/255.0 green:0xe0/255.0 blue:0xe0/255.0 alpha:1]] forState:(UIControlStateHighlighted)];
    [recognitionButton setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:(UIControlStateNormal)];
    recognitionButton.layer.borderColor = [[UIColor colorWithRed:0xe0/255.0 green:0xe0/255.0 blue:0xe0/255.0 alpha:1] CGColor];
    recognitionButton.layer.borderWidth = 1;
    
    [recognitionButton addTarget:self action:@selector(beginRecord) forControlEvents:(UIControlEventTouchDown)];
    [recognitionButton addTarget:self action:@selector(wannaCancelRecord) forControlEvents:(UIControlEventTouchDragExit)];
    [recognitionButton addTarget:self action:@selector(recoverRecord) forControlEvents:(UIControlEventTouchDragEnter)];
    [recognitionButton addTarget:self action:@selector(recordFinish) forControlEvents:(UIControlEventTouchUpInside)];
    [recognitionButton addTarget:self action:@selector(cancelRecord) forControlEvents:(UIControlEventTouchUpOutside)];
    [self.recognitionView addSubview:recognitionButton];
    
    
    
    self.recognitionLabel = [[UILabel alloc] init];
    self.recognitionLabel.frame = CGRectMake(0, (SCREEN_HEIGHT-100)/3, SCREEN_WIDTH, 30);
    self.recognitionLabel.textAlignment = NSTextAlignmentCenter;
    [self.recognitionLabel setFont:[UIFont systemFontOfSize:18]];
    self.recognitionLabel.hidden = YES;
    self.recognitionLabel.textColor = [UIColor whiteColor];
    self.recognitionLabel.text = @"未检测到语音";
    [delegate.window addSubview:self.recognitionLabel];
    
    
    // 初始化语言识别的属性
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
//    BOOL ret = [_iFlySpeechRecognizer startListening];
//    
//    if (ret) {
//        
//    }else{
//        NSLog(@"启动识别服务失败，请稍后重试"); //可能是上次请求未结束，暂不支持多路并发
//    }
    
#endif
    
    //应用推送相关变化
//    update by shisp 2014.8.22
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppRefresh) name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    
	//	初始化通知对象
	notificationObject = [[eCloudNotification alloc]init];
    
    footview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    /*
    UIButton *modifySignatureButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    modifySignatureButton.frame=CGRectMake(10, 5, 300, 30);
    [modifySignatureButton setBackgroundImage:[StringUtil getImageByResName:@"login_button.png"] forState:UIControlStateNormal];
    [modifySignatureButton setBackgroundImage:[StringUtil getImageByResName:@"login_button_click.png"] forState:UIControlStateHighlighted];
    [modifySignatureButton setBackgroundImage:[StringUtil getImageByResName:@"login_button_click.png"] forState:UIControlStateSelected];
    [modifySignatureButton setTitle:@"会话全部标为已读" forState:UIControlStateNormal];
	[modifySignatureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	modifySignatureButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [modifySignatureButton addTarget:self action:@selector(makeReaded) forControlEvents:UIControlEventTouchUpInside];
     */
    
    if ([UIAdapterUtil isGOMEApp]) {
        readedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        readedButton.layer.borderColor = GOME_SEPERATE_COLOR.CGColor;
        readedButton.layer.borderWidth = 1.0;
        readedButton.layer.cornerRadius = 5;
        
        [readedButton setTitleColor:[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1] forState:UIControlStateNormal];

        [readedButton setImage:[StringUtil getImageByResName:@"set_all_msg_read.png"] forState:UIControlStateNormal];
        
        float buttonWidth = 220.0;
        
        readedButton.frame = CGRectMake((SCREEN_WIDTH - buttonWidth) * 0.5, 10, 220,40);
        
        readedButton.backgroundColor = [UIColor whiteColor];
        
        readedButton.titleLabel.font = [UIFont systemFontOfSize:16.0];

    }else{
        readedButton = [UIAdapterUtil setNewButton:[StringUtil getLocalizableString:@"contact_allReaded"] andBackgroundImage:[ImageUtil createImageWithColor:[StringUtil colorWithHexString:@"#2481FC"]]];
        
        readedButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        readedButton.frame = CGRectMake(10, 5, self.view.frame.size.width - 20,30);
        
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        //        按钮变为红色
        [readedButton setBackgroundImage:nil forState:UIControlStateNormal];
        [readedButton setBackgroundColor:HX_LIGHT_RED_COLOR];
        
        [readedButton.layer setMasksToBounds:YES];
        [readedButton.layer setCornerRadius:3];
        
#endif

    }

    [readedButton addTarget:self action:@selector(makeReaded) forControlEvents:UIControlEventTouchUpInside];
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        bottomToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT- 44-22-50, SCREEN_WIDTH,50.0)];
        bottomToolBar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
        bottomToolBar.hidden = YES;
        [self.view addSubview:bottomToolBar];
        [bottomToolBar release];
        
        //分割线
        UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 1.0)];
        lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
        [bottomToolBar addSubview:lineLab];
        [lineLab release];
        
        //        按钮
        editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,1,SCREEN_WIDTH /2,49.0)];
        editBtn.backgroundColor = [UIColor clearColor];
       
        [editBtn setTitleColor:[UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0] forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        editBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        [editBtn addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];
        [editBtn setTitle:[StringUtil getLocalizableString:@"delete_contact"] forState:UIControlStateNormal];
        [bottomToolBar addSubview:editBtn];
        [editBtn release];
        
        chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2,1,SCREEN_WIDTH/2,49.0)];
        chooseBtn.backgroundColor = [UIColor clearColor];
        //        editBtn.tag = file_edit_button_tag + i;
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_normal.png"] forState:UIControlStateNormal];
        //        [editBtn setImage:[StringUtil getImageByResName:@"delete_pressed.png"] forState:UIControlStateHighlighted];
        
        [chooseBtn setTitleColor:[UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0] forState:UIControlStateNormal];
//        [chooseBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        chooseBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        [chooseBtn addTarget:self action:@selector(selectAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [chooseBtn setTitle:[StringUtil getLocalizableString:@"future_generations"] forState:UIControlStateNormal];
        [bottomToolBar addSubview:chooseBtn];
        [chooseBtn release];
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 1, 1, 49.0)];
        label.backgroundColor = [UIColor grayColor];
        [bottomToolBar addSubview:label];
    }
    [footview addSubview:readedButton];
    
//  update by shisp 为了加快切换速度，修改为在didload里从数据库里加载数据
//    收到消息，发送消息都采用局部刷新
//    收取完离线消息则全部刷新
//    修改为已读也采用全部刷新
    if ([eCloudConfig getConfig].conversationIndex == 0) {
        [self refreshData];
    }
    else
    {
        [self refreshDataAsync];
    }
}

- (void)removeRecognitionLabel
{
    self.recognitionLabel.hidden = YES;
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
#ifdef _GOME_FLAG_
    
    NSLog(@"%s",__func__);
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置语言
        [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant LANGUAGE_CHINESE] forKey:[IFlySpeechConstant LANGUAGE]];
        //设置方言
        [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant ACCENT_MANDARIN] forKey:[IFlySpeechConstant ACCENT]];\
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:[IFlySpeechConstant ASR_PTT_NODOT] forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
    //初始化录音器
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }
    
    _pcmRecorder.delegate = self;
    
    [_pcmRecorder setSample:[IFlySpeechConstant SAMPLE_RATE_16K]];
    
    [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件
    
#endif
}

#pragma mark - IFlyPcmRecorderDelegate
#ifdef _GOME_FLAG_

#pragma mark - IFlySpeechRecognizerDelegate
/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    NSString *vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    if (_isWannaCancel == NO)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            int index = volume - 1;
            if (index < 0) {
                index = 0;
            }
            if (index > 9) {
                index = 9;
            }
            self.recognitionImageView.image = [StringUtil getImageByResName:[NSString stringWithFormat:@"record_%d",index]];
        });
    }
//    NSLog(@"%s %@-%d",__FUNCTION__,vol,volume/3);
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"%s onBeginOfSpeech",__FUNCTION__);
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"%s onEndOfSpeech",__FUNCTION__);
    
    [_pcmRecorder stop];
}


/*!
 *  识别结果回调
 *  @param errorCode 错误描述
 */
- (void) onError:(IFlySpeechError *) errorCode
{
    NSLog(@"%s xunfeierror %@",__FUNCTION__, errorCode.errorDesc);
    if ([errorCode.errorDesc isEqualToString:@"服务正常"])
    {
        
    }
    else
    {
        self.recognitionLabel.hidden = NO;
        [self performSelector:@selector(removeRecognitionLabel) withObject:nil afterDelay:3];
        
        [_pcmRecorder stop];
        NSLog(@"%s 停止识别",__FUNCTION__);
        
        _isRecognition = NO;
    }
    
    [UserTipsUtil hideLoadingView];
}

/*!
 *  识别结果回调
 *
 *  @param results  -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度。
 *  @param isLast   -[out] 是否最后一个结果
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    [_pcmRecorder stop];
    
    [UserTipsUtil hideLoadingView];

    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    if (resultFromJson.length) {
        theSearchBar.text = resultFromJson;
        self.searchStr = resultFromJson;
        [self searchBarSearchButtonClicked:theSearchBar];

    }else{
        self.recognitionLabel.hidden = NO;
        [self performSelector:@selector(removeRecognitionLabel) withObject:nil afterDelay:3];
    }
    
    NSLog(@"%s resultFromJson=%@",__FUNCTION__,resultFromJson);
//    NSLog(@"isLast=%d,_textView.text=%@",isLast,_textView.text);
}

- (void)beginRecord
{
    NSLog(@"%s 开始录音",__FUNCTION__);
    
    _isRecognition = YES;
    
    UIImage *tempImage = [StringUtil getImageByResName:@"record_0"];
    
    self.recognitionImageView = [[[UIImageView alloc] init] autorelease];
    self.recognitionImageView.frame = CGRectMake((SCREEN_WIDTH-tempImage.size.width)/2, (SCREEN_HEIGHT-tempImage.size.height)/4, tempImage.size.width, tempImage.size.height);
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self.recognitionImageView];
    self.recognitionImageView.image = tempImage;
    
    
    
    
    
//    [_textView setText:@""];
//    [_textView resignFirstResponder];
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        
    }else{
        NSLog(@"启动识别服务失败，请稍后重试"); //可能是上次请求未结束，暂不支持多路并发
    }
}

- (void)recordFinish
{
    NSLog(@"%s 录音结束",__FUNCTION__);
    
    [self.recognitionImageView removeFromSuperview];
    
    if (_isRecognition == YES && _iFlySpeechRecognizer.isListening)
    {
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"正在识别"]];
    }
    
    
    _isRecognition = NO;
}

- (void)wannaCancelRecord
{
    NSLog(@"想要取消录音");
    self.recognitionImageView.image = [StringUtil getImageByResName:@"cancel_record"];
    _isWannaCancel = YES;
}
- (void)recoverRecord
{
    NSLog(@"恢复录音");
    self.recognitionImageView.image = [StringUtil getImageByResName:@"record_0"];
    _isWannaCancel = NO;
}

- (void)cancelRecord
{
    NSLog(@"取消录音");
    [self.recognitionImageView removeFromSuperview];
    
    theSearchBar.text = @"";
    [_pcmRecorder stop];
}

#endif

- (void)keyboardWillChangeFrame:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"height %f y %f SCREEN_WIDTH%f",keyboardF.size.height,keyboardF.origin.y,SCREEN_HEIGHT);
    
    CGFloat keyboard_Y = keyboardF.origin.y;
    CGRect rect = self.recognitionView.frame;
    rect.origin.y = (keyboard_Y==SCREEN_HEIGHT) ? keyboard_Y : keyboard_Y-50;
    self.recognitionView.frame = rect;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isMiLiao)
    {
        talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
        talksession.fromType = 0;
        
        [self.navigationController pushViewController:talksession animated:YES];
    }
    
    _isMiLiao = NO;
    
    // 调整 UISearchBarTextField 位置
    if (!self.searchDisplayController.isActive)
    {
        [self adjustUISearchBarTextField:theSearchBar];
    }
}

- (void)goToMiLiao:(NSNotification *)noti
{
    _isMiLiao = YES;
}

-(void)helperCmd:(NSNotification *)notification
{
	if (_ecloud!=nil) {
        hObject=[_ecloud getNewestHelperSchedule];
        [self.personTable reloadData];
    }
}
-(void)makeReaded
{
    NSLog(@"-----makeReaded");
    [_ecloud setAllUnReadToReaded];
    
    //    直接遍历一下，发现unread大于0，则设置为0
    for (Conversation *conv in self.itemArray)
    {
        if (conv.unread > 0)
        {
            conv.unread = 0;
        }
        if (conv.is_tip_me) {
            conv.is_tip_me = NO;
        }
    }
    [self exeReloadData];
    [self displayAllUnreadMsgCount:0];
    
//    [self refreshData];
}

-(void)reLinkButtonAction
{
    if([ApplicationManager getManager].isNetworkOk)
	{
        [[NotificationUtil getUtil]sendNotificationWithName:CONNECTING_NOTIFICATION andObject:nil andUserInfo:nil];
        
		[NSThread detachNewThreadSelector:@selector(reLink) toTarget:self withObject:nil];
    }else
    {
        UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"contact_noConnection"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [linkalert show];
        [linkalert release];
    }
}
-(void)reLink
{
	[[ApplicationManager getManager] stopAutoConnTimer];
	if(_conn.connStatus == linking_type)
	{
		return;
	}
	if(![_conn initConn] || ![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
	{
        [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
	}
    //  NSLog(@"--user-password-- %@  %@",_conn.userEmail,_conn.userPasswd);
    
    
}
//隐藏查询bar输入框键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[searchTextView resignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    _statusConn.curViewController = nil;
    
    [_topIndicator removeFromSuperview]; //0901
    _topIndicator = nil;
    
    [listenModeView removeFromSuperview];
    listenModeView = nil;
//    _topIndicator.hidden  = YES;
    
    if (self.cellDisplayingMenuOptions !=nil) {
        [self hideMenuOptionsAnimated:YES];
    }
    
	[super viewWillDisappear:animated];
    
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
#endif
}



-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
#endif
    
    
    if ([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp]) {
        [self getAppUnread];
    }
    
    //适配ios7
    if(IOS7_OR_LATER)
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    NSLog(@"%s",__FUNCTION__);
    
    _topIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.navigationController.navigationBar addSubview:_topIndicator];
    [_topIndicator release];
    
    if (!listenModeView) {
        listenModeView = [[self class] addListenModeView:self];
    }

    // 0901 添加Indicator
//    _topIndicator.hidden = NO;
    
    
    if (_conn.curConvId) {
        _conn.curConvId = nil;
        [[talkSessionViewController getTalkSession]removeConvNotification];
    }
    
    _statusConn.curViewController = self;
    [_statusConn getStatus];
    
    
#ifdef _GOME_FLAG_
    theSearchBar.placeholder= [StringUtil getLocalizableString:@"search_tips "];
#else
    theSearchBar.placeholder= [StringUtil getLocalizableString:@"search_tips"];
#endif
    
    if (!self.searchDisplayController.active) {

        [self displayTabBar];
    }
 
    [self displayStatus];
//    如果查询未激活，那么显示tabbar
//    [self displayTabBar];
    _conn = [conn getConn];
    //----监测---重新连接-------
    // [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkIsReLogin:) userInfo:nil repeats:YES];
    
    [self reCalculateFrame];
    //切换语言后重新赋值
    [chooseBtn setTitle:[StringUtil getLocalizableString:@"future_generations"] forState:UIControlStateNormal];
    [readedButton setTitle:[StringUtil getAppLocalizableString:@"contact_allReaded"]forState:UIControlStateNormal];
    if ([UIAdapterUtil isGOMEApp]) {
        [UIAdapterUtil customButtonStyle:readedButton];
    }
    if ([UIAdapterUtil isHongHuApp]) {
        //[leftButton setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
    }
    [editBtn setTitle:[StringUtil getLocalizableString:@"delete_contact"] forState:UIControlStateNormal];
 
    // 检查底部未读总数是否与会话列表中的未读数一致
    [self reloadDataWithDisplayAllUnreadNotSame];
}

// 动态设置titleView的宽度/根据传入的title设置titleView的宽度
- (void)setTitleViewFrameWithTitleStr:(NSString *)str{
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
     self.navigationItem.title = str;
#else
    self.title = str;
#endif


    CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:17]];
    // 设置Indicator位置
    [_topIndicator setFrame:CGRectMake(SCREEN_WIDTH/2.0-size.width/2.0 - 35, 0, 30, 40)];
    
    [[self class]setListenModeViewFrame:listenModeView andTitleWidth:size.width];
}

-(void)backToContactViewController:(NSNotification *)_notification
{
    self.searchDisplayController.active = NO;
    
    talkSessionViewController *talkSessionViewController = [_notification object];
    [UIAdapterUtil showChatPage:self];
    
    if ([self.navigationController.topViewController isKindOfClass:[talkSessionViewController class]]) {
//        刷新数据
        [talkSessionViewController refresh];
        return;
    }
    
    for (UIViewController *childController in self.navigationController.childViewControllers)
    {
        if ([childController isKindOfClass:[talkSessionViewController class]])
        {
            [self.navigationController popToViewController:childController animated:YES];
            return;
        }
    }
    
    [self.navigationController pushViewController:talkSessionViewController animated:NO];
    
}
- (void)backToContactViewControllerFromRobot:(NSNotification *)_notification
{
    self.searchDisplayController.active = NO;
    
    talkSessionViewController *talkSessionViewController = [_notification object];
//    self.talkSession.needUpdateTag=1;
    [UIAdapterUtil showChatPage:self];
    [self.navigationController pushViewController:talkSessionViewController animated:YES];
    [self hideTabBar];
}

- (void)displayStatus
{
    [self performSelectorOnMainThread:@selector(displayStatusOnMainThread) withObject:nil waitUntilDone:YES];
}

- (void)displayStatusOnMainThread
{
    switch (_conn.connStatus) {
		case not_connect_type:
			[self stopLinking];
			break;
		case linking_type:
			[self setTipStart];
			break;
		case download_org:
			[self setTipDownloadOrg];
			break;
		case rcv_type:
			[self setTipRcving];
			break;
		case normal_type:
        {
            [self setTipOK];
        }
			break;
			
		default:
			break;
	}
}

-(void)checkIsReLogin:(NSTimer *)timer
{
    
    
    
}

-(void)showNoReadNum
{
    int count=0;
	count=[_ecloud getAllNumNotReadedMessge];
    [self displayAllUnreadMsgCount:count];
}
-(void)beKick:(NSNotification *)notification
{
	self.personTable.tableHeaderView=self.reLinkView;
}
-(void)noConnect:(NSNotification *)notification
{
//    仍然接收通知，但不处理
//	[self performSelectorOnMainThread:@selector(stopLinking) withObject:nil waitUntilDone:YES];
}
-(void)repeatReLinkForFiveTime
{
    [NSThread detachNewThreadSelector:@selector(reLink) toTarget:self withObject:nil];
}

-(void)stopLinking
{
    
    // 0825
    [self setTitleViewFrameWithTitleStr:[_conn getTips]];

    self.personTable.contentOffset=CGPointMake(0, 0);
    
//    update by shisp 如果是未连接状态 并且是被踢或者被禁用，或者登录未成功，则显示重连按钮
    if (_conn.connStatus == not_connect_type && (_conn.isKick || _conn.isDisable || _conn.isInvalidPassword))
    {
        self.personTable.tableHeaderView = self.reLinkView;
    }
    
    [_topIndicator stopAnimating];
    
    if([[ApplicationManager getManager]needAutoConnect]){
        if ([[AccessConn getConn]displayLinkingStatusTime] > 0) {
            [LogUtil debug:@"还会自动连接，因此不显示 未连接 仍然显示连接中..."];
            //        如果还会继续连接 那么 就不显示未连接
            [self setTitleViewFrameWithTitleStr:[_conn getTips]];
            [_topIndicator startAnimating];
        }
    }
    
	if(_conn.connStatus == linking_type)
	{
		return;
	}
	[[ApplicationManager getManager] startAutoConnTimer];
}

-(void)rcvOfflineMsgFinish{
#ifdef _LANGUANG_FLAG_
    [self displayUnreadEncryptMsg];
#endif
    [self displayAllUnreadMsgCount:[_ecloud getAllNumNotReadedMessge]];
    [[self class]autoGetGroupInfo:self.itemArray];
     [_conn autoSendMsgAndGetGroupInfo];
}
/*
{
    dispatch_queue_t _queue = dispatch_queue_create(@"refresh recent contact offline msg finish", NULL);
    dispatch_async(_queue, ^{
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

        NSArray *array = [_ecloud getRecentConversation:normal_conv_type];
        array = [array sortedArrayUsingSelector:@selector(compareByLastMsgTime:)];

        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:array.count];
        for (Conversation *_conv in array) {
            [mDic setObject:_conv forKey:_conv.conv_id];
        }
        
        int count = [_ecloud getAllNumNotReadedMessge];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            int unCount = 0;
            for (Conversation *conv in array) {
                unCount += conv.unread;
            }
            // 当处理离线通知在接受离线广播之前或之后
            if ([[ApplicationManager getManager] noReadCount] == unCount) {
                [self displayAllUnreadMsgCount:count];
                
                self.itemArray = [NSMutableArray arrayWithArray:array];
                self.itemDic = [NSMutableDictionary dictionaryWithDictionary:mDic];
                [self exeReloadData];
                [LogUtil debug:[NSString stringWithFormat:@"处理离线消息 开始的离线消息个数与此时离线个数相等=%d",count]];
                
                [[self class]autoGetGroupInfo:array];
                //                会话列表界面刷新后，自动发送 未发送的消息 自动获取还没有获取群组资料的群组 update by shisp
                [_conn autoSendMsgAndGetGroupInfo];
                
                [LogUtil debug:[NSString stringWithFormat:@"%s end",__FUNCTION__]];
            }else{ // 当处理离线通知过程中，收到了离线广播
                [LogUtil debug:[NSString stringWithFormat:@"处理离线消息 一开始获取的离线消息个数=%d,此时离线消息个数 = %d",unCount,[[ApplicationManager getManager] noReadCount]]];
                // 若处理离线通知开始获取的数据库离线消息个数不等于此时数据库中离线消息个数，重新进行离线通知操作
                [self rcvOfflineMsgFinish];
            }
            
        });
    });
    dispatch_release(_queue);
}
*/

-(void)connecting
{
//    update by shisp 仍然接收通知 但不处理
//	[self performSelectorOnMainThread:@selector(setTipStart) withObject:nil waitUntilDone:YES];
}
-(void)setTipDownloadOrg
{
    if (_conn.downloadOrgTips) {

        // 0831 下载部门组织情况已经做了字符串本地化处理 
        [self setTitleViewFrameWithTitleStr:[NSString stringWithFormat:@"%@",_conn.downloadOrgTips]];
    }
    else
    {
        [self setTitleViewFrameWithTitleStr:[NSString stringWithFormat:@"%@",[StringUtil getAppLocalizableString:@"conn_sync_org"]]];
    
    }
//	self.title = @"下载组织架构...";
	[_topIndicator startAnimating];
	self.personTable.tableHeaderView = nil;
}
-(void)setTipRcving
{
    // 0825
    [self setTitleViewFrameWithTitleStr:[_conn getTips]];
    
	[_topIndicator startAnimating];
	self.personTable.tableHeaderView = nil;
}
-(void)setTipStart
{
    //	NSLog(@"%s",__FUNCTION__);
    //	根据网络显示不同状态
	if([ApplicationManager getManager].isNetworkOk)
	{
        //		NSLog(@"有网络，正在连接，需要隐藏手动连接提示框");
        
        [self setTitleViewFrameWithTitleStr:[_conn getTips]];

		[_topIndicator startAnimating];
		self.personTable.tableHeaderView = nil;
    }else
    {
		NSLog(@"没有网络，提示未连接，显示手动连接提示框");
		[self stopLinking];
    }
}

-(void)setTipOK
{
    //	NSLog(@"%s",__FUNCTION__);
    // 0825
    NSString *title = [StringUtil getAppLocalizableString:@"main_chats"];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    int _count = [[eCloudDAO getDatabase]getAllNumNotReadedMessge];
    if (_count) {
        title = [NSString stringWithFormat:@"%@(%d)",[StringUtil getAppLocalizableString:@"main_chats"],_count];
    }
#endif

    [self setTitleViewFrameWithTitleStr:title];
	self.personTable.tableHeaderView = nil;
 
        [_topIndicator stopAnimating];
    
}

-(void)dealloc
{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
	NSLog(@"%s,remove observer",__FUNCTION__);
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    self.iFlySpeechRecognizer.delegate = nil;
#endif
    
    
    [footview release];
    footview = nil;

    [docWatcher release];
    docWatcher = nil;
    
    if (self.unReadRequest) {
        if (self.unReadRequest.finished || self.unReadRequest.complete) {
//已经结束
        }else{
//            取消
            [self.unReadRequest clearDelegatesAndCancel];
        }
    }
    self.unReadRequest = nil;
    
    self.appItemArray = nil;

    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [_conn removeObserver:self forKeyPath:@"connStatus"];
    [_conn removeObserver:self forKeyPath:@"downloadOrgTips"];
    self.searchStr = nil;
    self.searchTimer = nil;
    self.searchResults = nil;
    self.convSearchResults = nil;
    
    if(loginErrorAlert)
    {
        [loginErrorAlert release];
        loginErrorAlert = nil;
    }
    
	[notificationObject release];
	notificationObject = nil;
    
//	self.delegete = nil;
	self.talkSession = nil;
	self.itemArray = nil;
    self.itemDic = nil;
	
	self.personTable = nil;
	self.reLinkView = nil;
	
	self.searchText = nil;
    
    self.cellDisplayingMenuOptions = nil;
    self.overlayView = nil;
    
//    if (([UIAdapterUtil isCsairApp] && [UIAdapterUtil isCombineApp])) {
//        [[NSNotificationCenter defaultCenter]removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
//    }
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMP_STATUS_CHANGE_NOTIFICATION object:nil];
//    
////	[[NSNotificationCenter defaultCenter]removeObserver:self name:NO_CONNECT_NOTIFICATION object:nil];
//    
////    [[NSNotificationCenter defaultCenter]removeObserver:self name:CONNECTING_NOTIFICATION object:nil];
//    
////    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"noctiveOFFLINE" object:nil];
////    [[NSNotificationCenter defaultCenter]removeObserver:self name:USER_DISABLE_NOTIFICATION object:nil];
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:NEW_CONVERSATION_NOTIFICATION object:nil];
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFFLINE_NOTIFICATION object:nil];
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
//	
//	[[NSNotificationCenter defaultCenter]removeObserver:self name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:HELPER_MESSAGE_NOTIFICATION object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:BACK_TO_CONTACTVIEW_FROM_ROBOT object:nil];
////    [[NSNotificationCenter defaultCenter]removeObserver:self name:APP_PUSH_REFRESH_NOTIFICATION object:nil];
//    
////    增加一个通知，当群组成员变化的时候，刷新下群组的头像
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
	[super dealloc];
}

-(void)dismissKeybordByClickBackground
{
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}


//回到首页
-(void) backButtonPressed:(id) sender
{
    [( (mainViewController*)self.delegete)back];
}

- (void)bannerClick:(id)sender
{
    NSString *stringValue = @"XXX安排给你一个XXX任务，请查看";
    
    [HDNotificationView showNotificationViewWithImage:[UIImage imageNamed:@"sampleIcon"]
                                                title:@"龙信"
                                              message:stringValue
                                           isAutoHide:YES
                                              onTouch:^{
                                                  
                                                  [HDNotificationView hideNotificationViewOnComplete:nil];
                                                  NSLog(@"121111111");
                                              }];
}

//新建会话
-(void) addButtonPressed:(id) sender{
    
    //测试代码
//    TestMifengViewController *vc = [[TestMifengViewController alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
//    return;
    
//    [[OpenCtxManager getManager]createTestAppRemindsData];
//    return;
	[searchTextView resignFirstResponder];
    
#ifdef _XIANGYUAN_FLAG_
    
    NSMutableArray *menuItems = [NSMutableArray array];

    KxMenuItem *shortCutMenuItem1 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_create_new_chat"]
                                                   image:[StringUtil getImageByResName:@"faqihuihua.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem1)];
    
    KxMenuItem *shortCutMenuItem2 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"scan_the_code"]
                                                   image:[StringUtil getImageByResName:@"jiqiren.png"]
                                                  target:self
                                                  action:@selector(scanAction)];
    
    KxMenuItem *shortCutMenuItem3 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_FileTransfer"]
                                                   image:[StringUtil getImageByResName:@"wenjianzhushou.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem3)];
    
    [menuItems addObject:shortCutMenuItem1];
    [menuItems addObject:shortCutMenuItem2];
    [menuItems addObject:shortCutMenuItem3];
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 30, 0, 0, 0) menuItems:menuItems];
    
#else
    
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_wanda) {
        NSMutableArray *menuItems = [NSMutableArray array];
        UIImage *image = [StringUtil getImageByResName:@"faqihuihua.png"];
        
        KxMenuItem *shortCutMenuItem1 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_create_new_chat"]
                                                       image:[StringUtil getImageByResName:@"faqihuihua.png"]
                                                      target:self
                                                      action:@selector(selectMenuItem1)];
        
        KxMenuItem *shortCutMenuItem2 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_iRobot"]
                                                       image:[StringUtil getImageByResName:@"jiqiren.png"]
                                                      target:self
                                                      action:@selector(selectMenuItem2)];
        
        KxMenuItem *shortCutMenuItem3 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_FileTransfer"]
                                                       image:[StringUtil getImageByResName:@"wenjianzhushou.png"]
                                                      target:self
                                                      action:@selector(selectMenuItem3)];
        
        [menuItems addObject:shortCutMenuItem1];
        [menuItems addObject:shortCutMenuItem2];
        [menuItems addObject:shortCutMenuItem3];
        
        [KxMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 30, 0, 0, 0) menuItems:menuItems];
    }else{
 
        
#ifdef _XINHUA_FLAG_
        
        XINHUAOrgSelectedViewControllerArc *orgSelectedVc = [[XINHUAOrgSelectedViewControllerArc alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:orgSelectedVc];
        orgSelectedVc.delegate = self;
        
        [self presentViewController:navi animated:YES completion:nil];
        
        
        return;
#endif
        
        
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
  /*      int _flag = [[MsgSyncUtil getUtil] getMsgSyncFlag];
        if (_flag == rcv_msg_when_pc_leave_or_offline) {
            _flag = rcv_msg_all_the_time;
        }else{
            _flag = rcv_msg_when_pc_leave_or_offline;
        }
        
        [[MsgSyncUtil getUtil]setMsgSyncFlag:_flag completionHandler:^(int resultCode, NSString *resultMsg) {
            [LogUtil debug:[NSString stringWithFormat:@"%s resultcode is %d resultMsg is %@",__FUNCTION__,resultCode,resultMsg]];
        }];
        return;*/
        
//        [[WXCacheUtil getUtil]clearAllData];
//        return;
        
        [HuaXiaOrgUtil getUtil].maxUserCount = [conn getConn].maxGroupMember - 1;
        NSMutableArray *mArray = [NSMutableArray array];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[conn getConn].curUser.emp_id],EMP_ID_KEY, nil];
        [mArray addObject:dic];
        [HuaXiaOrgUtil getUtil].disableSelectUserArray = mArray;

        [HuaXiaOrgUtil getUtil].orgDelegate = self;
        [HuaXiaOrgUtil getUtil].orgOpenType = org_open_type_present;
        [HuaXiaOrgUtil getUtil].openVC = self;

        [[HuaXiaOrgUtil getUtil]openSelectHXUserVC];
#elif defined(_LANGUANG_FLAG_)
        LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
        vc.chooseMemberDelegate = self;
        vc.maxSelectCount = [conn getConn].maxGroupMember - 1;;
        vc.oldEmpIdArray = [NSArray arrayWithObject:[conn getConn].curUser];
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:vc];
        [self presentViewController:navController animated:YES completion:^{
            
        }];
#else
        
//        ViewMoreSearchResultsController *vc = [[[ViewMoreSearchResultsController alloc]init]autorelease];
//        vc.searchModel = nil;
//        [self.navigationController pushViewController:vc animated:NO];
//        return;
        
//        JsObjectCViewController *vc = [[[JsObjectCViewController alloc]init]autorelease];
//        [self.navigationController pushViewController:vc animated:YES];
//        return;
        NewChooseMemberViewController *_controller = [[[NewChooseMemberViewController alloc]init]autorelease];
        _controller.typeTag = type_create_conversation;
        _controller.chooseMemberDelegate = self;
        
        _controller.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
        
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:_controller];
        
        [UIAdapterUtil presentVC:navController];
        
#endif
        
        
//        [((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController presentViewController:navController animated:YES completion:nil];
//        [self.navigationController presentModalViewController:navController animated:YES];
    }
    
    //一呼百应 权限
//    specialChooseMemberViewController *_controller = [[specialChooseMemberViewController alloc]init];
//    _controller.typeTag=0;
//	[self hideTabBar];
//	[self.navigationController pushViewController:_controller animated:YES];
//    [_controller release];
    
    
    //创建会话
//    NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
//    _controller.typeTag = type_create_conversation;
//    [self hideTabBar];
//    [self.navigationController pushViewController:_controller animated:YES];
//    [_controller release];
    /*
   
    
    */
//    if (!_shouldShowMenu)
//    {
//    }
//    else
//    {
//        [KxMenu dismissMenu];
//    }
//    _shouldShowMenu = !_shouldShowMenu;
   
#endif
}

// 点击发起群聊
- (void)selectMenuItem1
{
    NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
    _controller.typeTag = type_create_conversation;
    
    _controller.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
    
    UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:_controller];
    
    [UIAdapterUtil presentVC:navController];
//    [self.navigationController presentModalViewController:navController animated:YES];
    [_controller release];
}
// 点击小万
- (void)selectMenuItem2
{
    Emp *emp = [_ecloud getEmpInfoByUsercode:USERCODE_OF_IROBOT];
    if (!emp) {
        return;
    }
    Conversation *conv = [[[Conversation alloc] init] autorelease];
    conv.emp = emp;
    conv.conv_id = [StringUtil getStringValue:emp.emp_id];
    conv.conv_type = singleType;
    conv.recordType = normal_conv_type;
    
    [self openConversation:conv];
}
// 点击文件助手
- (void)selectMenuItem3
{
    Emp *emp = [_ecloud getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
    if (!emp) {
        return;
    }
    Conversation *conv = [[[Conversation alloc] init] autorelease];
    conv.emp = emp;
    conv.conv_id = [StringUtil getStringValue:emp.emp_id];
    conv.conv_type = singleType;
    conv.recordType = normal_conv_type;
    
    [self openConversation:conv];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        if (section == 0) {
//
//            tableView dequeueReusableHeaderFooterViewWithIdentifier:<#(NSString *)#>
//            if (self.convSearchResults && self.convSearchResults.count > 0) {
//                return @"会话";
//            }
//        }
//        else
//        {
//            if (self.searchResults && self.searchResults.count > 0) {
//                return @"聊天记录";
//            }
//        }
//    }
//    return nil;
//}

#pragma mark - 更新Tabar提示
- (void)handleAppRefresh{
    [self showNoReadNum];
}


#pragma  mark tableview delegate



#ifdef _GOME_FLAG_ADV_SEARCH_

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == self.searchResults.count - 1) {
            return 0.0;
        }
        return 20;
    }
    return 0.0;
}
#endif

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
#ifdef _GOME_FLAG_ADV_SEARCH_
        return 0.0;
#else
        if (section == 0) {
            if (self.convSearchResults && self.convSearchResults.count > 0) {
                return search_result_header_view_hight;
            }
        }
        else
        {
            if (self.searchResults && self.searchResults.count > 0) {
                return search_result_header_view_hight;
            }
        }
#endif

      
    }else{
        if (section > 0) {
            return CONV_SECTION_HEADER_HEIGHT;
        }
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
#ifdef _GOME_FLAG_ADV_SEARCH_
        return nil;
#else
        if (section == 0) {
            if (self.convSearchResults && self.convSearchResults.count > 0) {
                QueryResultHeaderCell *headerCell = [[[QueryResultHeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                [headerCell configCell:[StringUtil getAppLocalizableString:@"main_chats"]];
                return headerCell;
            }
        }
        else
        {
            if (self.searchResults && self.searchResults.count > 0) {
                QueryResultHeaderCell *headerCell = [[[QueryResultHeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                [headerCell configCell:[StringUtil getLocalizableString:@"conv_records"]];
                return headerCell;
            }
        }
#endif
       
    }else{
        if (section > 0) {
            return [self getConvHeaderView];
        }
    }
    return nil;
}

- (UIView *)getConvHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIAdapterUtil getTableCellContentWidth], CONV_SECTION_HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1];;
    
    UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, [UIAdapterUtil getTableCellContentWidth] - 40, CONV_SECTION_HEADER_HEIGHT)];
    titlelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titlelabel.numberOfLines = 0;
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.font=[UIFont systemFontOfSize:14.0];
    titlelabel.textColor = [UIColor grayColor];
    titlelabel.text= @"信息";
    [headerView addSubview:titlelabel];
    [titlelabel release];
    
    return [headerView autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
#ifdef _GOME_FLAG_ADV_SEARCH_
        return self.searchResults.count;
#else
        return 2;
#endif
    }else{
        if (self.appItemArray.count) {
            return 2;
        }
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    // Return the number of rows in the section
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
#ifdef _GOME_FLAG_ADV_SEARCH_
        WXAdvSearchModel *_model = self.searchResults[section];
        return _model.dspItemArray.count;
#else
        if (section == 0) {
            return self.convSearchResults.count;
        }
        
        return self.searchResults.count;
#endif
    }
    else
    {
        if (self.appItemArray.count) {
            if (section == 0) {
                return self.appItemArray.count;
            }else{
                return self.itemArray.count;
            }
        }
        return [self.itemArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef _GOME_FLAG_ADV_SEARCH_
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        WXAdvSearchModel *_model = self.searchResults[indexPath.section];
        id _id = _model.dspItemArray[indexPath.row];
        if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
            return ADV_SEARCH_HEADER_VIEW_HEIGHT;
        }
        if ([_id isKindOfClass:[AdvSearchFooterView class]]){
            return ADV_SEARCH_FOOTER_VIEW_HEIGHT;
        }
    }
#endif
    
    return conv_row_height;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(QueryResultCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView != self.searchDisplayController.searchResultsTableView)
    {
        if (self.appItemArray.count == 0 || (self.appItemArray.count && indexPath.section == 1)) {
            Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
            
            if (conv.isSetTop) {
                cell.cellView.backgroundColor = [UIColor colorWithRed:246/255.0 green:245/255.0 blue:250/255.0 alpha:1];
                
            }
            else
            {
                cell.cellView.backgroundColor = [UIColor whiteColor];
            }
            cell.backgroundColor = cell.cellView.backgroundColor;
        }
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, _tableViewLineX, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell1";
    QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
//        add by shisp
        cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
        [cell initSubView];
        [cell addCustomGesture];
        
        //分割线对齐
        UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:conv_name_tag];
//        [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.personTable withOriginX:fileNameLab.frame.origin.x];
        _tableViewLineX = fileNameLab.frame.origin.x;
        if (indexPath.row == self.itemArray.count-1) {
            
            _tableViewLineX = 0;
        }

    }
    
    cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
    
    Conversation *conv;
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
#ifdef _GOME_FLAG_ADV_SEARCH_
        WXAdvSearchModel *_model = self.searchResults[indexPath.section];
        id _id = _model.dspItemArray[indexPath.row];
        if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
            return [[[AdvSearchHeaderView alloc]initViewWithTitle:_model.headerTitle]autorelease];
        }
        if ([_id isKindOfClass:[AdvSearchFooterView class]]){
            return [[[AdvSearchFooterView alloc]initViewWithTitle:_model.footerTitle]autorelease];
        }
        
        switch (_model.searchResultType) {
            case search_result_type_group:
            case search_result_type_contact:
            case search_result_type_convrecord:
            {
                conv = _model.dspItemArray[indexPath.row];
                conv.displayTime = NO;
                conv.displayRcvMsgFlag = NO;
                [cell configSearchResultCell:conv];
            }
                break;
            case search_result_type_app:{
                conv = _model.dspItemArray[indexPath.row];
                conv.conv_title = conv.appModel.appname;
                conv.displayTime = NO;
                conv.displayRcvMsgFlag = NO;
                [cell configSearchResultCell:conv];
                [cell configAppLogo:conv];

            }
                break;
            case search_result_type_filerecord:
            {
//                复用文件助手的cell
                static NSString *CellName = @"FileCellName";
                AdvSearchFileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
                if (cell == nil){
                    cell = [[[AdvSearchFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
                }
                
                ConvRecord *_convRecord = _model.dspItemArray[indexPath.row];
                [cell configCellWithConvRecord:_convRecord];
                
                if (_convRecord.isFileExists) {
                    [talkSessionUtil hideProgressView:cell.progressView];
                }else{
                    if (_convRecord.downloadRequest && _convRecord.downloadRequest.isExecuting) {
                        //配置下载参数
                        [talkSessionUtil displayProgressView:cell.progressView];
                        _convRecord.downloadRequest.downloadProgressDelegate = cell.progressView;
                        _convRecord.downloadRequest.delegate = self;
                        [_convRecord.downloadRequest setDidFinishSelector:@selector(downloadFileComplete:)];
                        [_convRecord.downloadRequest setDidFailSelector:@selector(downloadFileFail:)];
                    }else{
                        [talkSessionUtil hideProgressView:cell.progressView];
                    }
                }
                
                return cell;
            }
                break;
            case search_result_type_webpage:
            {
                NSString *titleStr = _model.dspItemArray[indexPath.row];

                UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
                
                cell.textLabel.font = [UIFont systemFontOfSize:17];
                cell.textLabel.textColor = GOME_NAME_COLOR;
                
                cell.textLabel.text = titleStr;
                cell.imageView.image = [StringUtil getImageByResName:@"search_webpage.png"];
                [UIAdapterUtil customSelectBackgroundOfCell:cell];
                return  cell;
            }
            break;
                
            default:
                break;
        }
        

#else
        if (indexPath.section == 0) {
            conv = [self.convSearchResults objectAtIndex:indexPath.row];
            conv.displayTime = NO;
            conv.displayRcvMsgFlag = NO;
            [cell configSearchResultCell:conv];
            
        }
        else
        {
            conv = [self.searchResults objectAtIndex:indexPath.row];
            conv.displayTime = NO;
            conv.displayRcvMsgFlag = NO;
            conv.specialStr = self.searchStr;
            [cell configSearchResultCell:conv];
           
        }
#endif
    }
    else
    {
        if (self.appItemArray.count && indexPath.section == 0) {
            static NSString *appCellID = @"appCell";
            AppItemCell *cell = [tableView dequeueReusableCellWithIdentifier:appCellID];
            if (cell == nil) {
                cell = [[[AppItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:appCellID]autorelease];
            }
             APPListModel *appModel = self.appItemArray[indexPath.row];
            appModel.unread = [UserDefaults getAppUnreadWithAppId:appModel.appid];
            [cell configCell:appModel];
           
            return cell;
        }else{
            conv = [self.itemArray objectAtIndex:indexPath.row];
            conv.displayTime = YES;
            conv.displayRcvMsgFlag = YES;
            cell.delegate = self;
            [cell configCell:conv];
           
        }
    }
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
        cell.tintColor = _color;
    }
    
    return cell;
}

//取消选中时 将存放在self.deleteArr中的数据移除
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        if (self.personTable.editing) {
            
            [self.deleteArr removeObject:[self.itemArray objectAtIndex:indexPath.row]];
            
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIAdapterUtil isHongHuApp]) {
        
        if (self.personTable.editing) {
            
            [self.deleteArr addObject:[self.itemArray objectAtIndex:indexPath.row]];
        
            return;
        }
    }
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    if (![self.navigationController.topViewController isKindOfClass:[self class]]) {
//        如果top不是会话列表，则不跳转
        return;
    }

	[tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
#ifdef _GOME_FLAG_ADV_SEARCH_
        WXAdvSearchModel *_model = self.searchResults[indexPath.section];
        id _id = _model.dspItemArray[indexPath.row];
        if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
            return;
        }
        if ([_id isKindOfClass:[AdvSearchFooterView class]]) {
            ViewMoreSearchResultsController *vc = [[[ViewMoreSearchResultsController alloc]init]autorelease];
            vc.searchModel = _model;
            [self.navigationController pushViewController:vc animated:NO];
            return;
        }
        
        switch (_model.searchResultType) {
            case search_result_type_contact:
            case search_result_type_group:
            {
                Conversation *conv = _model.dspItemArray[indexPath.row];
                [[self class]openSearchConv:conv andCurVC:self];
            }
                break;
            case search_result_type_convrecord:{
                Conversation *conv = _model.dspItemArray[indexPath.row];
                [[self class]openSearchConvRecords:conv andCurVC:self andSearchStr:self.searchStr];
            }
                break;
            case search_result_type_filerecord:
            {
                ConvRecord *_convRecord = _model.dspItemArray[indexPath.row];

                if (_convRecord.isFileExists) {
                    previewFileIndex = indexPath;
                    [[RobotDisplayUtil getUtil]openNormalFile:self andCurVC:self];
                }else{
//                    下载文件
                    AdvSearchFileCell *cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                    
                    UIProgressView *_progressView = cell.progressView;
                    
                    [talkSessionUtil displayProgressView:_progressView];
                    
                    DownloadFileObject *_object = [[[DownloadFileObject alloc]init]autorelease];
                    
                    NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];;
                    _object.downloadFilePath = filePath;
                    
                    _object.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:indexPath,@"download_file_indexpath", nil];
                    
                    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],_convRecord.msg_body,[StringUtil getResumeDownloadAddStr]];
                    _object.downloadUrl = urlStr;
                    
                    _object.progressView = _progressView;
                    
                    ASIHTTPRequest *request = [DownloadFileUtil getRequestWith:_object];
                    request.delegate = self;
                    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_convRecord.msgId],@"MSG_ID", nil]];
                    [request setDidFinishSelector:@selector(downloadFileComplete:)];
                    [request setDidFailSelector:@selector(downloadFileFail:)];
                    [request startAsynchronous];
                    
                    _convRecord.downloadRequest = request;
                    
                    [[talkSessionUtil2 getTalkSessionUtil]addRecordToDownloadList:_convRecord];
                }
            }
                break;
            case search_result_type_app:{
                self.searchDisplayController.active = NO;
                Conversation *conv = _model.dspItemArray[indexPath.row];
                BOOL result = [GOMEAppViewController openGomeApp:conv.appModel andCurVC:self];
                if (result) {
                    [self hideTabBar];
                }
            }
                break;
            case search_result_type_webpage:{
                NSString*url = [NSString stringWithFormat:@"https://www.baidu.com/from=844b/s?word=%@&ts=3999338&t_kt=0&ie=utf-8&ms=1",theSearchBar.text];
                url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                NSLog(@"搜索网页");
            }
                break;
                
            default:
                break;
        }
#else
        if (indexPath.section == 0) {
            Conversation *conv=[self.convSearchResults objectAtIndex:indexPath.row];
            
            //            如果搜索结果是广播类型，也只打开广播数据
            if (conv.conv_type == broadcastConvType || conv.conv_type == imNoticeBroadcastConvType || conv.conv_type == appNoticeBroadcastConvType) {
                [self openConversation:conv];
                return;
            }
            [[self class]openSearchConv:conv andCurVC:self];
        }
        else
        {
            Conversation *conv=[self.searchResults objectAtIndex:indexPath.row];
            [[self class]openSearchConvRecords:conv andCurVC:self andSearchStr:self.searchStr];
        }
#endif
        
    }
    else
    {
        if (self.appItemArray.count && indexPath.section == 0) {
            if (indexPath.row == 0) {
//                南航版本 打开 待办
#ifdef _NANHANG_FLAG_
                AttentionViewController *vc = [[[AttentionViewController alloc]init]autorelease];
                vc.appModel = self.appItemArray[0];
                [self.navigationController pushViewController:vc animated:YES];
#endif
            }
        }else{
            Conversation* conv=[self.itemArray objectAtIndex:indexPath.row];
            [self openConversation:conv];
        }
    }
}

//打开会话
- (void)openConversation:(Conversation *)conv{
    [contactViewController openConversation:conv andVC:self];
}
//{
//    if(conv.conv_type == serviceConvType)
//    {
//        int serviceId = [conv.conv_id intValue];
//        
//        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
//        talkSession.serviceModel = [_psDAO getServiceByServiceId:serviceId];
//        talkSession.needUpdateTag = 1;
//        talkSession.talkType = publicServiceMsgDtlConvType;
//        [self.navigationController pushViewController:talkSession animated:YES];
//    }
//    else if(conv.conv_type == serviceNotInConvType)
//    {
//        PSMsgListViewController *controller = [[PSMsgListViewController alloc]init];
//        [self hideTabBar];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
//    }
//    else if(conv.conv_type == fltGroupConvType)
//    {
//        //		[LogUtil debug:[NSString stringWithFormat:@"flt group"]];
//        FLTGroupListViewController *controller = [[FLTGroupListViewController alloc]init];
//        //		controller.hidesBottomBarWhenPushed = YES;
//        [self hideTabBar];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
//    }
//    else if(conv.conv_type == appInConvType){
//        //应用推送消息
//        APPPushDetailViewController *controller = [[APPPushDetailViewController alloc]initWithConversation:conv];
//        [self hideTabBar];
//        [self.navigationController pushViewController:controller animated:YES];
//        [controller release];
//    }
//    else if(conv.conv_type == broadcastConvType){
//        //广播消息消息
//        broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
//        //广播在会话表里的id
//        broadcastList.convId = conv.conv_id;
//        broadcastList.broadcastType = normal_broadcast;
//        [self hideTabBar];
//        [self.navigationController pushViewController:broadcastList animated:YES];
//        [broadcastList release];
//    }else if (conv.conv_type == imNoticeBroadcastConvType){
//        
//        // 用类型区分普通广播 和 IM提醒消息
//        broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
//        //IM提醒消息在会话表里的id
//        broadcastList.convId = conv.conv_id;
//        broadcastList.broadcastType = imNotice_broadcast;
//        [self hideTabBar];
//        [self.navigationController pushViewController:broadcastList animated:YES];
//        [broadcastList release];
//    }
//    
//    else if (conv.recordType == normal_conv_type)
//    {
//        if(conv.conv_type==singleType)
//        {
//            self.talkSession.talkType = singleType;
//            self.talkSession.titleStr = [conv.emp getEmpName];
//            self.talkSession.convId =conv.conv_id;
//            self.talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
//            //         self.talkSession.delegete=self;
//            self.talkSession.needUpdateTag=1;
//            //			self.talkSession.hidesBottomBarWhenPushed = YES;
//            [UIAdapterUtil showChatPage:self];
//            [self.navigationController pushViewController:self.talkSession animated:YES];
//            [self hideTabBar];
//            
//        }
//        else if(conv.conv_type == rcvMassType)
//        {
//            MassDAO *massDAO = [MassDAO getDatabase];
//            BOOL needMerge = NO;// = [massDAO mergeMassMessageToSingleConv:conv];
//            if(needMerge)
//            {
//                self.talkSession.talkType = singleType;
//                self.talkSession.titleStr = [conv.emp getEmpName];
//                self.talkSession.convId = [StringUtil getStringValue:conv.emp.emp_id];
//            }
//            else
//            {
//                self.talkSession.talkType = rcvMassType;
//                self.talkSession.titleStr = [conv.emp getEmpName];
//                self.talkSession.convId =conv.conv_id;
//            }
//            
//            self.talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
//            //         self.talkSession.delegete=self;
//            self.talkSession.needUpdateTag=1;
//            //			self.talkSession.hidesBottomBarWhenPushed = YES;
//            
//            [self hideTabBar];
//            [self.navigationController pushViewController:self.talkSession animated:YES];
//        }
//        else
//        {
//            self.talkSession.talkType = mutiableType;
//            self.talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
//            self.talkSession.convId = conv.conv_id;
//            self.talkSession.needUpdateTag=1;
//            self.talkSession.convEmps =[_ecloud getAllConvEmpBy:conv.conv_id];
//            self.talkSession.last_msg_id=conv.last_msg_id;
//            //			self.talkSession.hidesBottomBarWhenPushed = YES;
//            
//            
//            [self.navigationController pushViewController:self.talkSession animated:YES];
//            [self hideTabBar];
//        }
//    }
//}

//打开会话 静态方法 在查询历史记录或者其它情况 时 可以使用
+ (void)openConversation:(Conversation *)conv andVC:(UIViewController *)curViewController
{
    if(conv.conv_type == serviceConvType)
    {
        int serviceId = [conv.conv_id intValue];
        
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        talkSession.serviceModel = [[PublicServiceDAO getDatabase] getServiceByServiceId:serviceId];
        talkSession.needUpdateTag = 1;
        talkSession.talkType = publicServiceMsgDtlConvType;
        [curViewController.navigationController pushViewController:talkSession animated:YES];
    }
    else if(conv.conv_type == serviceNotInConvType)
    {
        PSMsgListViewController *controller = [[PSMsgListViewController alloc]init];
        [curViewController.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if(conv.conv_type == fltGroupConvType)
    {
        //		[LogUtil debug:[NSString stringWithFormat:@"flt group"]];
        FLTGroupListViewController *controller = [[FLTGroupListViewController alloc]init];
        //		controller.hidesBottomBarWhenPushed = YES;
        [curViewController.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if(conv.conv_type == appInConvType){
        //应用推送消息
        APPPushDetailViewController *controller = [[APPPushDetailViewController alloc]initWithConversation:conv];
        [curViewController.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else if(conv.conv_type == broadcastConvType){
        //广播消息消息
        broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
        //广播在会话表里的id
        broadcastList.convId = conv.conv_id;
        broadcastList.broadcastType = normal_broadcast;
        [curViewController.navigationController pushViewController:broadcastList animated:YES];
        [broadcastList release];
    }else if (conv.conv_type == imNoticeBroadcastConvType){
        
        // 用类型区分普通广播 和 IM提醒消息
        broadcastListViewController *broadcastList=[[broadcastListViewController alloc]init];
        //IM提醒消息在会话表里的id
        broadcastList.convId = conv.conv_id;
        broadcastList.broadcastType = imNotice_broadcast;
        [curViewController.navigationController pushViewController:broadcastList animated:YES];
        [broadcastList release];
    }else if (conv.conv_type == appNoticeBroadcastConvType){
#ifdef _GOME_FLAG_
        GOMEAppMsgListViewController *vc = [[[GOMEAppMsgListViewController alloc]init]autorelease];
        [curViewController.navigationController pushViewController:vc animated:YES];
#endif

#ifdef _NANHANG_FLAG_
        //       打开南航的界面
        RemindViewController *vc = [[[RemindViewController alloc]init]autorelease];
        [curViewController.navigationController pushViewController:vc animated:YES];
        
        [[eCloudDAO getDatabase] setAllBroadcastToRead:appNotice_broadcast];
        NSLog(@"%s 设置所有提醒类型的广播为已读",__FUNCTION__);
#endif
    }
    
    else if (conv.recordType == normal_conv_type)
    {
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        
        if ([curViewController isKindOfClass:[chatRecordViewController class]]) {
            talkSession.fromType = talksession_from_chatRecordView;
        }
        
        if(conv.conv_type==singleType)
        {
            
            // 进入泰禾的服务号界面  控制器的创建使用宏定义进行包裹，不然未引入类的前提下编译会报错
#ifdef _TAIHE_FLAG_
            if ([UIAdapterUtil isTAIHEApp] && conv.emp.isAppNoticeAccount) {
                TAIHEAppMsgViewController *vc = [[[TAIHEAppMsgViewController alloc]init]autorelease];
                vc.conv = conv;
                [curViewController.navigationController pushViewController:vc animated:YES];
                
                return;
            }
#endif
            
#ifdef _LANGUANG_FLAG_
            
            if ([UIAdapterUtil isLANGUANGApp] && conv.emp.isAppNoticeAccount) {
                LGAppMsgViewControllerARC *vc = [[[LGAppMsgViewControllerARC alloc]init]autorelease];
                vc.conv = conv;
                [curViewController.navigationController pushViewController:vc animated:YES];
                
                return;
            }
            
#endif
            talkSession.talkType = singleType;
            talkSession.titleStr = [conv.emp getEmpName];
            talkSession.convId =conv.conv_id;
            talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
            //         self.talkSession.delegete=self;
            talkSession.needUpdateTag=1;
            //			self.talkSession.hidesBottomBarWhenPushed = YES;
            [curViewController.navigationController pushViewController:talkSession animated:YES];
            
        }
        else if(conv.conv_type == rcvMassType)
        {
            MassDAO *massDAO = [MassDAO getDatabase];
            BOOL needMerge = NO;// = [massDAO mergeMassMessageToSingleConv:conv];
            if(needMerge)
            {
                talkSession.talkType = singleType;
                talkSession.titleStr = [conv.emp getEmpName];
                talkSession.convId = [StringUtil getStringValue:conv.emp.emp_id];
            }
            else
            {
                talkSession.talkType = rcvMassType;
                talkSession.titleStr = [conv.emp getEmpName];
                talkSession.convId =conv.conv_id;
            }
            
            talkSession.convEmps = [NSArray arrayWithObject:conv.emp];
            //         self.talkSession.delegete=self;
            talkSession.needUpdateTag=1;
            //			self.talkSession.hidesBottomBarWhenPushed = YES;
            
            [curViewController.navigationController pushViewController:talkSession animated:YES];
        }
        else
        {
            talkSession.talkType = mutiableType;
            talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
            talkSession.convId = conv.conv_id;
            talkSession.needUpdateTag=1;
            talkSession.convEmps =[[eCloudDAO getDatabase] getAllConvEmpBy:conv.conv_id];
            talkSession.last_msg_id=conv.last_msg_id;
            //			self.talkSession.hidesBottomBarWhenPushed = YES;
            
            
            [curViewController.navigationController pushViewController:talkSession animated:YES];
        }
    }
    
//    不显示tabbar
    if ([curViewController isKindOfClass:[contactViewController class]]) {
        contactViewController *contactVC = (contactViewController *)curViewController;
        [contactVC hideTabBar];
        [UIAdapterUtil showChatPage:contactVC];
    }
}

//修改删除按钮的文字
/*
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
    if(conv.isSetTop)
    {
        return @"取消置顶";
    }
    else
    {
        return @"置顶";
    }

    return @"移除";
}
*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.searchDisplayController.searchResultsTableView)
    {
        return NO;
    }
    return YES;
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        置顶功能测试
        Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
        if(conv.isSetTop)
        {
            [_ecloud SetTopFlag:0 andConv:conv.conv_id];
            conv.isSetTop = NO;
        }
        else
        {
            int setTopTime = [_ecloud SetTopFlag:1 andConv:conv.conv_id];
            conv.isSetTop = YES;
            conv.setTopTime = setTopTime;
        }
        
         [self reloadData];
   
        
//        移除代码
//		Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
//		[_ecloud updateDisplayFlag:conv.conv_id andFlag:1];
//        
//        [self refreshData];
        
        
//		[self.itemArray removeObjectAtIndex:indexPath.row];
//        [self.itemDic removeObjectForKey:conv.conv_id];
// 		[tableView reloadData];
//        
//        [self showNoReadNum];
   }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//    NSLog(@"-----scrollViewDidScroll");
    //	if (!backgroudButton) {
    //		[_searchBar resignFirstResponder];
    //		backgroudButton.hidden=YES;
    //	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //    NSLog(@"-----scrollViewDidEndDragging");
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    
}

-(void)displayTabBar
{
    /*
	//	add by shisp 2013.6.16
	//	在隐藏的情况下，显示出来，并且
	if(self.tabBarController && self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上减去tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height - _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		self.tabBarController.tabBar.hidden = NO;
		
	}
    */
    
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}
-(void)hideTabBar
{
	
    /*
	//	add by shisp 2013.6.16
	//	如果tabbar是显示的状态那么
	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上加上tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		//NSLog(@"height is %.0f",contentView.frame.size.height);
		
		//		隐藏UITabBar
		self.tabBarController.tabBar.hidden = YES;
		
	}
     */
    [UIAdapterUtil hideTabBar:self];
}

#pragma mark 会话界面的搜索

- (void)initSearch
{
    //    会话搜索
    
    
#ifdef _LANGUANG_FLAG_

    
#else
    
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    //    theSearchBar.placeholder=[StringUtil getLocalizableString:@"search_tips"];
    theSearchBar.delegate = self;
    theSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [UIAdapterUtil removeBorderOfSearchBar:theSearchBar];
    [self.view addSubview:theSearchBar];
    
    //    self.personTable.tableHeaderView = theSearchBar;  //将searchBar添加到tableView的头,注意滚动出屏幕后，搜索框也不在了，只出现在首页
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
    
    searchdispalyCtrl.active = NO;
    
    searchdispalyCtrl.delegate = self;
    
    searchdispalyCtrl.searchResultsDelegate=self;
    
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [theSearchBar release];
#endif
    
    
    
    // 调整 UISearchBarTextField 位置
    [self adjustUISearchBarTextField:theSearchBar];
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    // 添加二维码扫描按钮
    scanQRcodeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    scanQRcodeBtn.frame = CGRectMake(5, 5, 35, 35);
    [scanQRcodeBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [scanQRcodeBtn setImage:[StringUtil getImageByResName:@"QRCode"] forState:(UIControlStateNormal)];
    [scanQRcodeBtn addTarget:self action:@selector(scanQRcode) forControlEvents:(UIControlEventTouchUpInside)];
    [theSearchBar addSubview:scanQRcodeBtn];
#endif
    
    
#ifdef _XINHUA_FLAG_
        //修改取消按钮颜色
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
         setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          XINHUA_DEEP_BLUE,
          UITextAttributeTextColor,
          nil]
         forState:UIControlStateNormal];
#endif
    
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];

//    [UIAdapterUtil alignHeadIconAndCellSeperateLine:searchdispalyCtrl.searchResultsTableView];
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
    self.convSearchResults = [NSMutableArray array];
}

- (void)scanQRcode
{
#ifdef _GOME_FLAG_
    [self openCamara];
    
#endif
    NSLog(@"打开二维码扫描");
}

-(void)openCamara
{
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

    if(authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
        alert.tag = 1000;
        [alert show];
    }
    else if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusNotDetermined){
#ifdef _GOME_FLAG_
        
        ScanQRCodeViewControllerArc *QRCodeVC = [[[ScanQRCodeViewControllerArc alloc] initWithNibName:@"ScanQRCodeViewControllerArc" bundle:nil] autorelease];
        [self.navigationController pushViewController:QRCodeVC animated:YES];
        
#endif
    }else {
        NSLog(@"Unknown authorization status");
    }

}

#pragma mark =====================

-(void)processNewConvNotification:(NSNotification *)notification
{
	eCloudNotification *_notification = [notification object];
    int cmdId = _notification.cmdId;

	if(_notification != nil)
	{
        NSDictionary *dic = _notification.info;

#ifdef _LANGUANG_FLAG_
        NSString *convId = [dic valueForKey:@"conv_id"];
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:convId]) {
            
            switch (cmdId) {
                case add_new_conv_record:
                case read_one_msg:
                case read_all_msg:
                {
                    [self displayUnreadEncryptMsg];
                }
                    break;
                    
                default:
                    break;
            }
            
//            if (cmdId == add_new_conv_record ) {
//                获取最新的密聊消息的未读数，并且显示在会话列表左上角
//                [leftButton setTitle:[self getMiLiaoBtnTitle] forState:UIControlStateNormal];
//            }
            [LogUtil debug:[NSString stringWithFormat:@"%s 密聊消息不处理",__FUNCTION__]];
            return;
        }
        if ([convId rangeOfString:@"666666"].length) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 审批群消息不处理",__FUNCTION__]];
            return;
        }
#endif

#ifdef _XIANGYUAN_FLAG_
        
        /** 祥源超级管理员这个用户的消息不处理 ，用来推送待办的*/
        NSString *convId = [dic valueForKey:@"conv_id"];
        if ([convId isEqualToString:@"79340"]) {
            
            return;
        }
#endif
		switch (cmdId) {
            case update_rcv_msg_flag:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                int rcvMsgFlag = [[dic valueForKey:@"rcv_msg_flag"]intValue];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.recv_flag = rcvMsgFlag;
                    int index = [self.itemArray indexOfObject:_conv];
                    [self reloadDataAtIndex:index];
                }
            }
                break;
            case update_last_msg_id_to_0:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.last_msg_id = 0;
                }
            }
                break;
            case user_logo_changed:
            {
                //                    需要处理下头像的刷新
                [self refreshConvListLogo:_notification];
            }
                break;

            case add_new_conversation:
            case reuse_conversation:
            case add_new_conv_record:
            case delete_one_msg:
            {
                if (cmdId == add_new_conv_record) {
                    [self changeBadgeValue];
                }
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
//                从数据库取出这个会话的信息
                Conversation *_conv = [_ecloud getConversationByConvId:convId];
                
                //如果新加会话是广播则也刷新tabbar计数
                if (_conv.conv_type == broadcastConvType || _conv.conv_type == imNoticeBroadcastConvType || _conv.conv_type == appNoticeBroadcastConvType)
                {
                    [self changeBadgeValue];
                }
                
                if (_conv) {
                    Conversation *tempConv = [self.itemDic objectForKey:convId];
                    if (tempConv) {
                        NSInteger _index = [self.itemArray indexOfObject:tempConv];
                        if (_index == NSNotFound) {
                            return;
                        }
                        else
                        {
                            [self.itemArray replaceObjectAtIndex:_index withObject:_conv];
                            [self.itemDic setObject:_conv forKey:convId];
                            [self reloadData];
                        }
                     }
                    else
                    {
                        NSMutableArray *mArray = [NSMutableArray arrayWithObject:_conv];
                        [mArray addObjectsFromArray:self.itemArray];
                        if (mArray.count > max_recent_conv_count) {
                            [self setAllMsgToReadOfConv:mArray.lastObject];
                            [mArray removeLastObject];
                        }
                        
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                        for (Conversation *conv in mArray) {
                            [mDic setValue:conv forKey:conv.conv_id];
                        }
                        
                        NSArray *sortedArray = [NSArray arrayWithArray:[mArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];
                        
                        self.itemArray = [NSMutableArray arrayWithArray:sortedArray];
                        self.itemDic = [NSMutableDictionary dictionaryWithDictionary:mDic];
                        
                        [self exeReloadData];
                        
//不使用插入的方式，插入时有时会发生异常
//                        [self.itemArray insertObject:_conv atIndex:0];
//                        [self.itemDic setObject:_conv forKey:convId];
//                        
//                        //                    如果超过了最大值则需要去掉最后的object
//                        if (self.itemArray.count > max_recent_conv_count) {
//                            _conv = [self.itemArray lastObject];
//                            [self.itemArray removeLastObject];
//                            [self.itemDic removeObjectForKey:_conv.conv_id];
//                        }
                    }
//                    
//                    self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];

//                    [self reloadData];
                }

            }
                break;
            case update_conversaion_info:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *convTitle = [dic valueForKey:@"conv_title"];
                NSString *createEmpId = [dic valueForKey:@"create_emp_id"];
                NSString *createTime = [dic valueForKey:@"create_time"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.conv_title = convTitle;
                    _conv.create_emp_id = createEmpId.intValue;
                    _conv.create_time = createTime;
                    
                    int index = [self.itemArray indexOfObject:_conv];
                    [self reloadDataAtIndex:index];
                }
            }
                break;
            case delete_all_conversation:
            {
                [self.itemArray removeAllObjects];
                [self.itemDic removeAllObjects];
                [self changeBadgeValue];
                [self reloadData];
            }
                break;
            case update_conv_title:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *convTitle = [dic valueForKey:@"conv_title"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.conv_title = convTitle;
                    int index = [self.itemArray indexOfObject:_conv];
                    [self reloadDataAtIndex:index];
                }
            }
                break;
            case delete_conversation:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    [self.itemArray removeObject:_conv];
                    [self.itemDic removeObjectForKey:convId];
                    [self reloadData];
                    [self showNoReadNum];
                }
            }
                break;
            case save_draft:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *convDraft= [dic valueForKey:@"conv_draft"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if ([_conv.lastInput_msg isEqualToString:convDraft] == YES) {
                        return;
                    }
                    _conv.lastInput_msg = convDraft;
                }
                else
                {
                    //                从数据库取出这个会话的信息
                    _conv = [_ecloud getConversationByConvId:convId];

                    if (_conv)
                    {
                        [self.itemArray insertObject:_conv atIndex:0];
                        [self.itemDic setObject:_conv forKey:convId];
                        
                        //                    如果超过了最大值则需要去掉最后的object
                        if (self.itemArray.count > max_recent_conv_count) {
                            _conv = [self.itemArray lastObject];
                            [self setAllMsgToReadOfConv:_conv];

                            [self.itemArray removeLastObject];
                            [self.itemDic removeObjectForKey:_conv.conv_id];
                        }
                    }
                    
                }
                [self reloadData];
            }
                break;
            case save_last_msg_time:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *lastMsgTime= [dic valueForKey:@"last_msg_time"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.last_record.msg_time = lastMsgTime;
//                    self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];
                    [self reloadData];
                }
            }
                break;
            case read_one_msg:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.unread > 0) {
                        _conv.unread = _conv.unread - 1;
                        _conv.is_tip_me = NO;
                        int index = [self.itemArray indexOfObject:_conv];
                        [self reloadDataAtIndex:index];
                        [self changeBadgeValue];
                    }
                }
            }
                break;
            case read_all_msg:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.unread > 0) {
                        if (_conv.conv_type == serviceNotInConvType) {
                            _conv.unread = [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
                        }else{
                            _conv.unread = 0;
                        }
                        _conv.is_tip_me = NO;
                        int index = [self.itemArray indexOfObject:_conv];
                        [self reloadDataAtIndex:index];
                        [self changeBadgeValue];
                    }
                }
            }
                break;
            case update_send_flag:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                int sendFlag = [[dic valueForKey:@"send_flag"]intValue];
                int msgId = [[dic valueForKey:@"msg_id"]intValue];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.last_msg_id == msgId && _conv.last_record.send_flag != sendFlag) {
                        _conv.last_record.send_flag = sendFlag;
                        int index = [self.itemArray indexOfObject:_conv];
                        [self reloadDataAtIndex:index];
                    }
                }
            }
                break;
            case update_isSet_top:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                int setTopFlag  = [[dic valueForKey:@"setTop_Flag"] integerValue];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                _conv.isSetTop = setTopFlag;
                [self reloadData];
            }
                break;
            case update_broadcast_read_flag:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.unread = [[dic valueForKey:@"unread_msg_count"]intValue];
                    int index = [self.itemArray indexOfObject:_conv];
                    [self reloadDataAtIndex:index];
                    [self changeBadgeValue];
                }
            }
                break;
            default:
                break;
        }
    }
}
- (void)reloadData
{
    self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];

    [self performSelectorOnMainThread:@selector(exeReloadData) withObject:nil waitUntilDone:NO];
}
- (void)reloadDataWithSort:(BOOL)needSort
{
    if (needSort)
    {
        self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];
    }
    
    [self performSelectorOnMainThread:@selector(exeReloadData) withObject:nil waitUntilDone:NO];
}
- (void)exeReloadData
{
     [self.personTable reloadData];
}

- (void)reloadDataAtIndex:(int)index
{
    if (index == NSNotFound) {
        [LogUtil debug:@"没有找到符合条件的行"];
        return;
    }
    if (index >=0 && index < self.itemArray.count) {
        int section = 0;
        if (self.appItemArray.count) {
            section = 1;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
        [self performSelectorOnMainThread:@selector(exeReloadDataAtIndex:) withObject:indexPath waitUntilDone:YES];
    }
    else
    {
        [self reloadData];
    }
}
- (void)exeReloadDataAtIndex:(NSIndexPath *)indexPath
{
//    if (_conn.connStatus == normal_type)
//    {
        if ([self.personTable cellForRowAtIndexPath:indexPath])
        {
            
            [self.personTable beginUpdates];
            [self.personTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.personTable endUpdates];
        }
//    }
}

- (void)changeBadgeValue
{
    [self performSelectorOnMainThread:@selector(showNoReadNum) withObject:nil waitUntilDone:YES];
}

//处理用户头像变化，无论是个人修改头像，还是下载了其它用户的头像，都需要处理
- (void)refreshConvListLogo:(eCloudNotification *)notification
{
    NSDictionary *dic = notification.info;
//    
//    NSLog(@"%s,%@",__FUNCTION__,dic);
    
    int empId = [[dic valueForKey:@"emp_id"]intValue];
    
    NSString *empLogo = [dic valueForKey:@"emp_logo"];
    
    BOOL needReload = NO;
    
    for (int i = 0; i < self.itemArray.count; i++) {
        Conversation *_conv = [self.itemArray objectAtIndex:i];
        if(_conv.conv_type == mutiableType)
        {
            for (Emp *_emp in _conv.groupLogoEmpArray)
            {
                if (_emp.emp_id == empId) {
                    
                    [_ecloud asynCreateMergedLogoWithConvId:_conv.conv_id andConvTitle:_conv.conv_title];
                    _emp.logoImage = [ImageUtil getLogo:_emp];
                    needReload = YES;
                    break;
                }
            }
        }
        else if(_conv.conv_type == singleType)
        {
            if (_conv.conv_id.intValue == empId) {
                //                [LogUtil debug:@"修改单聊里的empLogo"];
                _conv.emp.emp_logo = empLogo;
                needReload = YES;
            }
        }
        
        if (needReload)
        {
            //            NSLog(@"%s,需要刷新",__FUNCTION__);
            [self reloadDataAtIndex:i];
            needReload = NO;
        }
    }
}


#pragma mark ===========用户状态变化，需要刷新会话列表单聊用户状态=============
- (void)empStatusChange:(NSNotification *)_notification
{
    NSDictionary *dic = _notification.userInfo;
    if (dic)
    {
        BOOL needReload = NO;
        NSArray *statusChangeArray = [dic valueForKey:key_status_change_array];
        
        for (NSDictionary *dic in statusChangeArray)
        {
            int curEmpId = [[dic valueForKey:@"emp_id"]intValue];
            int empStatus = [[dic valueForKey:@"emp_status"]intValue];
            int loginType = [[dic valueForKey:@"emp_login_type"]intValue];
            
            for (Conversation *_conv in self.itemArray)
            {
                if (_conv.conv_type == singleType && _conv.emp.emp_id == curEmpId)
                {
                    NSLog(@"收到用户状态");
                    if (!needReload) {
//                        NSLog(@"contact view 发现一个用户状态改变了");
                        needReload = YES;
                    }
                    _conv.emp.emp_status = empStatus;
                    _conv.emp.loginType = loginType;
                    break;
                }
            }
        }
        if (needReload)
        {
            NSLog(@"刷新用户状态");
            [self performSelectorOnMainThread:@selector(exeReloadData) withObject:nil waitUntilDone:NO];
        }
    }
}

#pragma mark =============修改会话列表界面的标题=================
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelectorOnMainThread:@selector(changeTitle:) withObject:_conn.downloadOrgTips waitUntilDone:YES];

}

- (void)changeTitle:(NSString *)tips
{
    [self displayStatusOnMainThread];
}

#pragma mark * DAContextMenuCell delegate

- (void)contextMenuCellDidSelectMoreOption:(QueryResultCell *)cell
{
    NSIndexPath *indexPath = [self.personTable indexPathForCell:cell];
    Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
    if(conv.isSetTop)
    {
        [_ecloud SetTopFlag:0 andConv:conv.conv_id];
    }
    else
    {
        int setTopTime = [_ecloud SetTopFlag:1 andConv:conv.conv_id];
        conv.setTopTime = setTopTime;
    }
}

#pragma mark - Private

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    __block contactViewController *weakSelf = self;
    [self.cellDisplayingMenuOptions setMenuOptionsViewHidden:YES animated:animated completionHandler:^{
        weakSelf.customEditing = NO;
    }];
}

- (void)setCustomEditing:(BOOL)customEditing
{
    if (_customEditing != customEditing) {
        _customEditing = customEditing;
                self.personTable.scrollEnabled = !customEditing;
        if (customEditing) {
            if (!_overlayView) {
                _overlayView = [[DAOverlayView alloc] initWithFrame:self.view.bounds];
                _overlayView.backgroundColor = [UIColor clearColor];
                _overlayView.delegate = self;
                
            }
            self.overlayView.frame = self.view.bounds;
            [self.view addSubview:_overlayView];
            
            if (self.shouldDisableUserInteractionWhileEditing) {
                for (UIView *view in self.personTable.subviews) {
                    if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                        view.userInteractionEnabled = NO;
                    }
                }
            }
        } else {
            self.cellDisplayingMenuOptions = nil;
            [self.overlayView removeFromSuperview];
            
            for (UIView *view in self.personTable.subviews) {
                if ((view.gestureRecognizers.count == 0) && view != self.cellDisplayingMenuOptions && view != self.overlayView) {
                    view.userInteractionEnabled = YES;
                }
            }
        }
    }
}

#pragma mark * DAContextMenuCell delegate

- (void)contextMenuCellDidSelectDeleteOption:(QueryResultCell *)cell
{
    NSIndexPath *indexPath = [self.personTable indexPathForCell:cell];
    Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
//    [_ecloud updateDisplayFlag:conv.conv_id andFlag:1];
//    [_ecloud deleteConvAndConvRecordsBy:conv.conv_id];
//    [self refreshData];
    //删除未读消息的会话时 把未读置为已读
    [self setAllMsgToReadOfConv:conv];
    
    [_ecloud updateDisplayFlag:conv.conv_id andFlag:1];
    //    修改为从内存里删除这一条会话，然后刷新界面，不用从数据库再次获取
    [self.itemArray removeObject:conv];
    [self.itemDic removeObjectForKey:conv.conv_id];
    [self showNoReadNum];
    
//    self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新
        [self.personTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    });
}

- (void)contextMenuDidHideInCell:(QueryResultCell *)cell
{
    self.customEditing = NO;
    self.customEditingAnimationInProgress = NO;
}

- (void)contextMenuDidShowInCell:(QueryResultCell *)cell
{
    self.cellDisplayingMenuOptions = cell;
    self.customEditing = YES;
    self.customEditingAnimationInProgress = NO;
    
    NSIndexPath *indexPath = [self.personTable indexPathForCell:cell];
    Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
    if ([UIAdapterUtil isGOMEApp]) {
        [self.cellDisplayingMenuOptions.moreOptionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if(conv.isSetTop)
        {
            [self.cellDisplayingMenuOptions.moreOptionsButton setTitle:[StringUtil getLocalizableString:@"contact_unsettop"] forState:UIControlStateNormal];
        }else
        {
            [self.cellDisplayingMenuOptions.moreOptionsButton setTitle:[StringUtil getLocalizableString:@"contact_settop"] forState:UIControlStateNormal];
        }
    }else{
        if(conv.isSetTop)
        {
            [self.cellDisplayingMenuOptions.moreOptionsButton setBackgroundImage:[StringUtil getImageByResName:@"cellMenuDown.png"] forState:UIControlStateNormal];
        }else
        {
            [self.cellDisplayingMenuOptions.moreOptionsButton setBackgroundImage:[StringUtil getImageByResName:@"cellMenuUp.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)contextMenuWillHideInCell:(QueryResultCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}

- (void)contextMenuWillShowInCell:(QueryResultCell *)cell
{
    self.customEditingAnimationInProgress = YES;
}

- (BOOL)shouldShowMenuOptionsViewInCell:(QueryResultCell *)cell
{
    return self.customEditing && !self.customEditingAnimationInProgress;
}

#pragma mark * DAOverlayView delegate

- (UIView *)overlayView:(DAOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL shouldIterceptTouches = YES;
    CGPoint location = [self.view convertPoint:point fromView:view];
    CGRect rect = [self.personTable convertRect:self.cellDisplayingMenuOptions.frame toView:view];
    shouldIterceptTouches = CGRectContainsPoint(rect, location);
    if (!shouldIterceptTouches) {
        
        [self hideMenuOptionsAnimated:YES];
    }
    return (shouldIterceptTouches) ? [self.cellDisplayingMenuOptions hitTest:point withEvent:event] : view;
}

#pragma mark * UITableView delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.cellDisplayingMenuOptions) {
        [self hideMenuOptionsAnimated:YES];
        return NO;
    }
    return YES;
}

#pragma mark =======UISearchDisplayDelegate协议方法========
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.personTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    [UIAdapterUtil customCancelButton:self];
    if (scanQRcodeBtn) {
        scanQRcodeBtn.hidden = YES;
    }
}
/** 调整分割线 */
- (void)adjustUISearchBarSeperateLine:(UIView *)view
{
#ifdef _GOME_FLAG_ADV_SEARCH_
    for (UIView *subview in view.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]]){
            NSLog(@"subview %@",subview);
            subview.hidden = YES;
        }
        [self adjustUISearchBarSeperateLine:subview];
    }
#endif
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.personTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;

    [self displayTabBar];
    backgroudButton.hidden=YES;
    
    
    // 调整 UISearchBarTextField 位置
    [self adjustUISearchBarTextField:theSearchBar];
}

- (void)adjustUISearchBarTextField:(UIView *)view
{
#ifdef _GOME_FLAG_ADV_SEARCH_
    for (UIView *subview in view.subviews)
    {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UISearchBarTextField"])
        {
            CGRect rect = subview.frame;
            rect.origin.x   = SEARCHBAR_X;
            rect.size.width = SCREEN_WIDTH - SEARCHBAR_X-10;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                subview.frame = rect;
            });
            
            
            return;
        }
        [self adjustUISearchBarTextField:subview];
    }
#endif
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
#ifdef _GOME_FLAG_ADV_SEARCH_
    [self processFileRecords:self.searchResults];
#endif
    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    [self.convSearchResults removeAllObjects];
    self.convSearchResults = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    if (scanQRcodeBtn) {
        scanQRcodeBtn.hidden = NO;
    }
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
#ifdef _GOME_FLAG_ADV_SEARCH_
    [controller.searchBar.layer setBorderColor:GOME_SEPERATE_COLOR.CGColor];
#endif
    [self adjustUISearchBarSeperateLine:tableView];
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [UserTipsUtil setSearchResultsTitle:@"" andCurrentViewController:self];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    CGRect _frame = CGRectMake(0, 0, tableView.frame.size.width, SCREEN_HEIGHT - 64);
    tableView.frame = _frame;
    [UIAdapterUtil hideTabBar:self];
#else
    CGRect _frame = CGRectMake(0, 0, tableView.frame.size.width, SCREEN_HEIGHT - 108);
    tableView.frame = _frame;
#endif
    
}


#pragma mark ========UISearchBarDelegate实现========

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    backgroudButton.hidden=NO;
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //	NSLog(@"%s,searchText is %@",__FUNCTION__,searchText);
    //搜索框的文本有变化，但文本框没有内容时，显示所有内容，当有内容时则显示
    self.searchStr = [StringUtil trimString:searchBar.text];
    if(self.searchStr.length == 0)
    {
#ifdef _GOME_FLAG_ADV_SEARCH_
        [self processFileRecords:self.searchResults];
#endif
        [self.searchResults removeAllObjects];
        self.searchResults = nil;
        [self.convSearchResults removeAllObjects];
        self.convSearchResults = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        //        不即时搜索
        //        if (self.searchTimer && [self.searchTimer isValid])
        //        {
        //            //            NSLog(@"searchTimer is valid");
        //            [self.searchTimer invalidate];
        //        }
        //        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchConv) userInfo:nil repeats:NO];
    }
}
- (void)searchConv
{
    dispatch_queue_t queue = dispatch_queue_create("search Conv", NULL);
    
    dispatch_async(queue, ^{
        
        isSearch = YES;
        
        NSString *_searchStr = [NSString stringWithString:self.searchStr];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        QueryDAO *queryDAO = [QueryDAO getDatabase];
        
        self.convSearchResults = [queryDAO getConversationBy:_searchStr];
        
        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"1 查询条件有变化");
            return;
        }
        
        self.searchResults = [queryDAO getConversationBySearchConvRecord:_searchStr];
        
        [pool release];
        
        if (![_searchStr isEqualToString:self.searchStr]) {
            NSLog(@"2 查询条件有变化");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            if (![self.searchResults count] && ![self.convSearchResults count])
            {
                [UserTipsUtil setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"] andCurrentViewController:self];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    
    dispatch_release(queue);
}

//点击搜索按钮时才开始搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = [StringUtil trimString:searchBar.text];
    
#ifdef _GOME_FLAG_ADV_SEARCH_
    [searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    [WXAdvSearchUtil getUtil].delegate = self;
    [[WXAdvSearchUtil getUtil] advSearch:searchStr];
#else
    if ([self.searchStr length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [UserTipsUtil showSearchTip];
        return;
    }
    
    [searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchConv];
#endif
}

// 当tabbar上的未读数与会话列表中的未读数总数不一致时，强行刷新界面
- (void)reloadDataWithDisplayAllUnreadNotSame
{
    int singleOrGroupUnread = 0;
    if (self.itemArray && self.itemArray.count > 0) {
        for (Conversation *conv in self.itemArray) {
            singleOrGroupUnread += conv.unread;
        }
    }
    int appUnreadCount = 0;
    if (self.appItemArray && self.appItemArray.count > 0) {
        for (APPListModel *modelItem in self.appItemArray) {
            appUnreadCount += [UserDefaults getAppUnreadWithAppId:modelItem.appid];
        }
    }
    int allUnReadCount = singleOrGroupUnread + appUnreadCount;
    [LogUtil debug:[NSString stringWithFormat:@"计算得到的普通消息未读数为:%d,应该用的未读数为:%d",singleOrGroupUnread,appUnreadCount]];
    if (allUnReadCount != tabbarUnReadCount) {
        [LogUtil debug:[NSString stringWithFormat:@"计算得到的消息未读数为:%d,tabbar上显示的消息未读数为:%d",allUnReadCount,tabbarUnReadCount]];
        [self reloadData];
    }
}

//增加一个方法，根据count，设置会话列表标签的未读消息数
- (void)displayAllUnreadMsgCount:(int)msgUnreadCount
{
    int appUnread = 0;
    
    if (self.appItemArray.count > 0) {
        APPListModel *_model = self.appItemArray[0];
        appUnread = [UserDefaults getAppUnreadWithAppId:_model.appid];
    }
    
    int count = appUnread + msgUnreadCount;
    
    tabbarUnReadCount = count;
    
    if ((count) == 0) {
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].conversationIndex];
        [UIAdapterUtil setExtraCellLineHidden:self.personTable];
    }else
    {
        [TabbarUtil setTabbarBage:[NSString stringWithFormat:@"%d",count] andTabbarIndex:[eCloudConfig getConfig].conversationIndex];
        if (msgUnreadCount) {
            self.personTable.tableFooterView=footview;
        }else{
            self.personTable.tableFooterView = nil;
        }
    }
    
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//    如果是华夏，那么会话列表界面标题显示多了未读消息树
    if (_conn.connStatus == normal_type) {
        NSString *title = [StringUtil getAppLocalizableString:@"main_chats"];
        if (count) {
            title = [NSString stringWithFormat:@"%@(%d)",[StringUtil getAppLocalizableString:@"main_chats"],count];
        }
        [self setTitleViewFrameWithTitleStr:title];
    }
#endif
//    普通聊天有多少个未读记录
    [self sendImUnreadMsgCountNotification:msgUnreadCount];
//    [self sendImUnreadMsgCountNotification:count];
}

- (void)reCalculateFrame
{
//    NSLog(@"重新计算会话列表 tableview的高度 self.view.frame is %@ searchbar frame is %@ tabbar frame is %@",NSStringFromCGRect(self.view.frame),NSStringFromCGRect(theSearchBar.frame),NSStringFromCGRect(self.tabBarController.tabBar.frame));
    NSLog(@"%s",__FUNCTION__);
    int tableH = SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - theSearchBar.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    self.personTable.frame = CGRectMake(0, theSearchBar.frame.size.height, self.view.frame.size.width, tableH);
}


#pragma mark =======横竖屏切换========

- (void)layoutSubViewWhenOrientationChanged
{
    if (IS_IPHONE) {
        return;
    }
    
    CGRect _frame = CGRectZero;
    
    // 通过判断 readedButton宽度 查看是否需要重新布局
    _frame = readedButton.frame;
    if (_frame.size.width == SCREEN_WIDTH - 20) {
//        NSLog(@"%s 不需要重新布局 ",__FUNCTION__);
        return;
    }
//    NSLog(@"%s 需要重新布局",__FUNCTION__);
    
    _frame.size.width = SCREEN_WIDTH - 20;
    readedButton.frame = _frame;
    
    //    设置_topIndicator的frame
    if (_topIndicator) {
        CGSize size = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:17]];
        _frame = _topIndicator.frame;
        _frame.origin.x = (SCREEN_WIDTH - size.width) / 2.0 - 35;
        _topIndicator.frame = _frame;
    }
    _frame = self.personTable.frame;
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - self.tabBarController.tabBar.frame.size.height - theSearchBar.frame.size.height - NAVIGATIONBAR_HEIGHT;
    self.personTable.frame = _frame;
    
    [self.personTable reloadData];
}
//
- (void)orientationDidChange:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationUnknown:
//            NSLog(@"Unknown");
            break;
            
        case UIDeviceOrientationFaceUp:
//            NSLog(@"Device oriented flat, face up");
            break;
            
        case UIDeviceOrientationFaceDown:
//            NSLog(@"Device oriented flat, face down");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
//            NSLog(@"Device oriented horizontally, home button on the right");
            [self layoutSubViewWhenOrientationChanged];
            break;
            
        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"Device oriented horizontally, home button on the left");
            [self layoutSubViewWhenOrientationChanged];
//            NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
            break;
            
        case UIDeviceOrientationPortrait:
//            NSLog(@"Device oriented vertically, home button on the bottom");
            [self layoutSubViewWhenOrientationChanged];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
//            NSLog(@"Device oriented vertically, home button on the top");
            break;
            
        default:  
//            NSLog(@"cannot distinguish");  
            break;
    }
}

//如果将要显示的会话列表只有一个成员，那么发起获取群组资料
+ (void)autoGetGroupInfo:(NSArray *)_array
{
    for (Conversation *conv in _array) {
        if (conv.conv_type == mutiableType && conv.groupLogoEmpArray.count <= 1){
            //                如果是群组 并且 群组头像 数组 又只有1个，那么去获取群组名称
            [LogUtil debug:[NSString stringWithFormat:@"内存里需要获取群组资料 convid is %@",conv.conv_id]];
            [[conn getConn] getGroupInfo:conv.conv_id];
        }
    }
}

#pragma mark =====提供给SDK调用的接口======

- (UIButton *)rightBarButton
{
    UIImage *image = [StringUtil getImageByResName:@"add_ios.png"];
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_default) {
        image = [StringUtil getImageByResName:@"add_ios_plus.png"];
    }
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 46, 44);
    [_button setBackgroundImage:image forState:UIControlStateNormal];
    
    return _button;
}

- (void)onRightBarButton
{
    [self addButtonPressed:nil];
}

#pragma mark ======发送消息未读数给SDK调用程序=======
- (void)sendImUnreadMsgCountNotification:(int)count
{
    //    发出未读消息数通知
    [[NotificationUtil getUtil]sendNotificationWithName:IM_UNREAD_NOTIFICATION andObject:[NSNumber numberWithInt:count] andUserInfo:nil];
}

#pragma mark ======处理轻应用的通知=======

- (void)getAppUnread
{
    if (self.appItemArray.count == 0) {
        return;
    }
    
    NSLog(@"%s 获取未读数",__FUNCTION__);
    
    if (self.unReadRequest) {
        if (self.unReadRequest.complete || self.unReadRequest.finished) {
             NSLog(@"already finish");
            self.unReadRequest = nil;
        }else{
//            NSLog(@"已经在获取了，只是还没有收到应答");
//            return;
            [self.unReadRequest clearDelegatesAndCancel];
        }
    }

//    http://10.95.68.22:8088/mobileoa-shell-dmz/backlog/getEmployeeBlackLog
//    http://10.95.68.196:8088/mobileoa-shell-inside/backlog/getEmployeeBlackLog
    
    NSString *urlStr = [UserDefaults getDaibanUnreadUrl];
    if (urlStr.length == 0) {
        urlStr = @"https://imap.csair.com/moad/backlog/getEmployeeBlackLog.do";
    }
    self.unReadRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    conn *_conn = [conn getConn];
    mDic[GET_APP_UNREAD_REQ_EMPID_KEY] = _conn.user_code;
    NSData *jsonData = [mDic JSONData];
    // AES加密
    NSString *AESkey = [StringUtil getRandomString];
    NSData *AESData = [jsonData AES256EncryptWithKey:AESkey];
    NSString *base64Str = [AESData base64Encoding];
    NSLog(@"base64Str %@", base64Str);
    
    // RSA加密
    NSString *RSAStr = [RSAEncryptor encryptString:AESkey publicKey:RSA_ENCRYPT_PUBLIC_KEY];
    [self.unReadRequest setPostValue:base64Str forKey:@"data"];
    [self.unReadRequest setPostValue:RSAStr forKey:@"sign"];
    [self.unReadRequest setNumberOfTimesToRetryOnTimeout:1];
    [self.unReadRequest setTimeOutSeconds:5];
    [self.unReadRequest setDelegate:self];
    [self.unReadRequest setDidFinishSelector:@selector(unreadRequestCommitDone:)];
    [self.unReadRequest setDidFailSelector:@selector(unreadRequestCommitWrong:)];
    [self.unReadRequest startAsynchronous];
}

//{"result":"0","message":"成功","data":{ "EmployeeId": "732858", "TotalCount":"120", "UnReadCount": "23" }}
//其中，返回的数据data中的EmployeeId为当前登陆用户的账号即员工号;
//TotalCount为当前员工总共待办数量;
//UnReadCount为当前员工未读/未处理待办数量。

- (void)unreadRequestCommitDone:(ASIHTTPRequest *)request
{
    NSString *responseString = request.responseString;
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取未读数应答:%@",__FUNCTION__,responseString]];
   
    [self parseAppUnreadResponse:responseString];
}

- (void)parseAppUnreadResponse:(NSString *)responseString
{
    if (responseString.length) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        if (responseDic) {
            NSString *resultCode = responseDic[GET_APP_UNREAD_RES_RESULT_KEY];
            if (resultCode != nil && ![resultCode isKindOfClass:[NSNull class]] && resultCode.intValue == 0) {
                NSDictionary *dataDic = responseDic[GET_APP_UNREAD_RES_DATA_KEY];
                if (dataDic) {
                    NSString *empId = dataDic[GET_APP_UNREAD_RES_EMPID_KEY];
//                    if ([empId isEqualToString:_conn.userId]) {
                        NSString *unreadCound = dataDic[GET_APP_UNREAD_RES_UNREADCOUNT_KEY];
                        if (unreadCound != nil && ![resultCode isKindOfClass:[NSNull class]])
                        {
                            if (self.appItemArray.count) {
                                APPListModel *_model = self.appItemArray[0];
                                
                                if ([UserDefaults getAppUnreadWithAppId:_model.appid] == unreadCound.intValue) {
                                    //                                数量没有变化
                                }else{
                                    [UserDefaults saveAppUnreadWithAppId:_model.appid andUnread:unreadCound.intValue];
                                    //                                在主线程刷新UI
                                    [self reloadDataWithSort:NO];
                                    //                                刷新未读数
                                    [self performSelectorOnMainThread:@selector(showNoReadNum) withObject:nil waitUntilDone:YES];
                                }
                            }
                        }
//                    }
                }
            }
        }
    }
}


- (void)unreadRequestCommitWrong:(ASIHTTPRequest *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s 获取未读数应答:%d %@",__FUNCTION__,request.responseStatusCode,request.responseStatusMessage]];
    
//    一下是测试代码
//    NSString *tmpStr = @"{\"result\":\"0\",\"message\":\"成功\",\"data\":{ \"EmployeeId\": \"732858\", \"TotalCount\":\"120\", \"UnReadCount\": \"23\" }}";
//    [self parseAppUnreadResponse:tmpStr];
}

- (void)processAppNotification:(NSNotification *)notification
{
    eCloudNotification	*notifObj = (eCloudNotification *)[notification object];
    if (notifObj.cmdId == refresh_app_list) {
        //        刷新轻应用
        self.appItemArray = [[APPPlatformDOA getDatabase] getAPPList];
        [self reloadDataWithSort:NO];
        //        获取未读数
        [self getAppUnread];
        
    }else if(notifObj.cmdId == refresh_app_section){
        NSDictionary *dic = notifObj.info;
        if ([dic count] == 1) {
            APPListModel * refreshAppModel = [dic allValues][0];
            for (APPListModel *tmpModel in self.appItemArray) {
                if (refreshAppModel.appid == [tmpModel appid]) {
                    
                    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                    [self.personTable reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
            }
        }
    }
}

-(void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
    folderSizeAndList *fsl = [[folderSizeAndList alloc]init];
    long long allFileSizeLong =[fsl getALLFileSizeLong:[StringUtil newRcvFilePath]];
    [fsl release];
    
    if ([[self tabBarController] isKindOfClass:[GXViewController class]]) {
        conn *_conn=[conn getConn];
        if(!_conn.hasNewVersion)
        {
            if (allFileSizeLong >1024*1024*200)
            {
                [((GXViewController *)[self tabBarController]) setTabarbadgeValue:@"Push" withIndex:[eCloudConfig getConfig].settingIndex];
            }
            else{
                [((GXViewController *)[self tabBarController])setTabarbadgeValue:nil withIndex:[eCloudConfig getConfig].settingIndex];
            }
        }
    }
    
    //    NSLog(@"存储空间字节大小-------%lli",allFileSizeLong);
    //    [[NSNotificationCenter defaultCenter]postNotificationName:@"fileChange" object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = bottomToolBar.frame;
    NSLog(@"bottomToolBar1====%@",bottomToolBar);
    if (_frame.size.width == SCREEN_WIDTH) {
        
        return;
    }
   
    _frame.origin.y = SCREEN_HEIGHT- 44-22-50;
    _frame.size.width = SCREEN_WIDTH;
    bottomToolBar.frame = _frame;
    NSLog(@"bottomToolBar2====%@",bottomToolBar);
    
}

- (void)scrollToNextUnreadConv{
    NSArray *visiblePaths = [self.personTable indexPathsForVisibleRows];
    if (visiblePaths.count && !self.searchDisplayController.isActive) {
        
        int nextRow = -1;
        
        NSIndexPath *firstIndexPath = visiblePaths[0];
        NSIndexPath *lastIndexPath = visiblePaths.lastObject;

        for (int row = ((int)firstIndexPath.row + 1); row < self.itemArray.count; row++) {
            Conversation *_conv = self.itemArray[row];
            if (_conv.unread > 0) {
                nextRow = row;
                break;
            }
        }
        
        //            没有找到下一条未读的 或者说 已经显示了最后一条
        if ((nextRow == -1) || (lastIndexPath.row == self.itemArray.count - 1)) {
//            然后再从第一条开始找
            for (int row = 0; row < self.itemArray.count; row++) {
                Conversation *_conv = self.itemArray[row];
                if (_conv.unread > 0) {
                    nextRow = row;
                    break;
                }
            }
            if (nextRow == -1) {
//                已经没有未读的记录了，跳到第一条
                nextRow = 0;
            }
        }
        
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:nextRow inSection:firstIndexPath.section];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s nextIndexPath is %@",__FUNCTION__,[NSString stringWithFormat:@"%d-%d",(int)nextIndexPath.section,(int)nextIndexPath.row]]];

        [self.personTable scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


#pragma mark 在删除会话(不在最近会话列表显示)时或者会话记录太多被挤出时，修改会话对应记录为已读
- (void)setAllMsgToReadOfConv:(Conversation *)conv{
    //删除未读消息的会话时 把未读置为已读
    if(conv.conv_type == broadcastConvType){
        [_ecloud setAllBroadcastToRead:normal_broadcast];
    }else if(conv.conv_type == imNoticeBroadcastConvType)
    {
        [_ecloud setAllBroadcastToRead:imNotice_broadcast];
    }else if(conv.conv_type == appNoticeBroadcastConvType)
    {
        [_ecloud setAllBroadcastToRead:appNotice_broadcast];
    }
    else{
        if (conv.conv_type == singleType || conv.conv_type == mutiableType) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:conv.conv_id,@"conv_id",[NSNumber numberWithLong:INT_MAX],@"msg_timestamp", nil];
            
            NSArray *tempArray = [NSArray arrayWithObject:dic];
            [_ecloud updateMsgReadFlag:tempArray];
        }else{
            if (conv.conv_type == serviceConvType) {
                NSLog(@"%s 显示在会话列表里的服务号",__FUNCTION__);
                int serviceId = [conv.conv_id intValue];
                [[PublicServiceDAO getDatabase] updateReadFlagOfPSMsg:serviceId];
                
            }else if (conv.conv_type == serviceNotInConvType){
                NSLog(@"%s 服务号类型",__FUNCTION__);
                
                NSArray *allService = [[PublicServiceDAO getDatabase] getAllService:service_type_in_ps];
                
                int serviceId;
                for(ServiceModel *_service in allService)
                {
                    serviceId = _service.serviceId;
                    [[PublicServiceDAO getDatabase] updateReadFlagOfPSMsg:serviceId];
                }
            }else{
                NSLog(@"%s 还未来得及处理",__FUNCTION__);
                return;
            }
        }
    }
}

#pragma mark =====chooseMemberDelegate=======
- (void)didFinishSelectContacts:(NSArray *)userArray{
    [CreateGroupUtil getUtil].typeTag = type_create_conversation;
    [[CreateGroupUtil getUtil]createGroup:userArray];
}


#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
- (void)didSelectHXUsers:(NSArray *)usersArray{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    [CreateGroupUtil getUtil].typeTag = type_create_conversation;
    [[CreateGroupUtil getUtil]createGroup:usersArray];
}

-(void)processGetUserInfoFromHX:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    //            修改群组通知 某个会话的群组通知消息里，如果有某个id，则需要替换

    NSString *convId = userInfo[@"conv_id"];
    Emp *_emp = userInfo[@"EMP"];
    [LogUtil debug:[NSString stringWithFormat:@"%s %@ %@",__FUNCTION__,userInfo,_emp.emp_name]];
    int convType = [userInfo[@"conv_type"]intValue];
    if (convId.length && _emp) {
        if (convType == mutiableType) {

            [[eCloudDAO getDatabase]searchAndReplaceGroupInfoInConv:convId andEmp:_emp];
        }
        
        //        发送通知出来，更新会话
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
        [[eCloudDAO getDatabase] sendNewConvNotification:dic andCmdType:add_new_conversation];
        
    }
}

#endif

#ifdef _LANGUANG_FLAG_
- (void)openMiLiaoVC{
    
    MiLiaoConvListViewController *vc = [[[MiLiaoConvListViewController alloc]init]autorelease];
    UINavigationController *nav = [[[UINavigationController alloc]initWithRootViewController:vc]autorelease];
    [UIAdapterUtil presentVC:nav];
}
- (NSString *)getMiLiaoBtnTitle{
    int newCount = [[eCloudDAO getDatabase]getNewMiLiaoMsgNum];
    
    if (newCount) {
        return [NSString stringWithFormat:@"密聊(%d)",newCount];
    }else{
        return @"密聊";
    }
}

- (void)displayUnreadEncryptMsg{
    int newCount = [[eCloudDAO getDatabase]getNewMiLiaoMsgNum];
    [NewMsgNumberUtil displayNewMsgNumber:encryptNewMsgParentView andNewMsgNumber:newCount andNewMsgBgHeight:20.0 andNewMsgFontSize:10.0];
    [NewMsgNumberUtil setUnreadViewFrame:encryptNewMsgParentView];
}

#endif

/** 如果是听筒模式，那么在导航栏增加一个耳朵的图标 */
+ (UIView *)addListenModeView:(UIViewController *)curVC{
    UserInfo* userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:[conn getConn].userId];
    if (userinfo.receiver_model_Flag==1) {
        UIImageView *listenModeView=[[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)]autorelease];
        listenModeView.image=[StringUtil getImageByResName:@"listen_mode_er_now.png"];
        [curVC.navigationController.navigationBar addSubview:listenModeView];
        return listenModeView;
    }
    return nil;
}

/** 修改听筒模式图标的位置 */
+ (void)setListenModeViewFrame:(UIView *)modeView andTitleWidth:(float)titleWidth{
    if (modeView) {
        [modeView setFrame:CGRectMake(SCREEN_WIDTH/2.0+titleWidth/2.0+10, (NAVIGATIONBAR_HEIGHT - modeView.frame.size.width) * 0.5, modeView.frame.size.width, modeView.frame.size.height)];
    }
}

/** 打开搜索到的单人聊天或者群里 */
+ (void)openSearchConv:(Conversation *)conv andCurVC:(UIViewController *)curVC{
    
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = conv.conv_type;
    talkSession.convId = conv.conv_id;
    talkSession.needUpdateTag = 1;
    talkSession.titleStr = [conv getConvTitle];
    talkSession.convEmps = [conv getConvEmps];
    talkSession.fromConv = conv;
    
    //    代表从会话查询结果来到会话界面的
    talkSession.fromType = talksession_from_conv_query_result_need_position;
    if ([curVC respondsToSelector:@selector(hideTabBar)]) {
        [curVC hideTabBar];
    }
    [curVC.navigationController pushViewController:talkSession animated:YES];
}

/** 打开搜索到的聊天记录 */
+ (void)openSearchConvRecords:(Conversation *)conv andCurVC:(UIViewController *)curVC andSearchStr:(NSString *)searchStr{
    
    if (conv.last_record.tryCount > 1) {
        QueryResultViewController *controller = [[[QueryResultViewController alloc]init]autorelease];
        controller.conv = conv;
        controller.searchStr = searchStr;
        if ([curVC respondsToSelector:@selector(hideTabBar)]) {
            [curVC hideTabBar];
        }
        [curVC.navigationController pushViewController:controller animated:YES];
    }
    else if(conv.last_record.tryCount == 1)
    {
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        talkSession.talkType = conv.conv_type;
        talkSession.convId = conv.conv_id;
        talkSession.needUpdateTag = 1;
        talkSession.titleStr = [conv getConvTitle];
        talkSession.convEmps = [conv getConvEmps];
        talkSession.fromConv = conv;
        
        //    代表从会话查询结果来到会话界面的
        talkSession.fromType = talksession_from_conv_query_result_need_position;
        if ([curVC respondsToSelector:@selector(hideTabBar)]) {
            [curVC hideTabBar];
        }
        [curVC.navigationController pushViewController:talkSession animated:YES];
    }

}

- (void)initiateMeeting{
    
    
}

- (void)scanAction{
    
    ScannerViewController *scanner = [[ScannerViewController alloc]init];
    scanner.processType = 0;
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];
}
#pragma MARK ======advSearchProtocol=======
#ifdef _GOME_FLAG_ADV_SEARCH_
- (void)loadSearchResults:(NSArray *)searchResults{
    self.searchResults = [NSMutableArray arrayWithArray:searchResults];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil hideLoadingView];

        [self.searchDisplayController.searchResultsTableView reloadData];
        
        if (![self.searchResults count])
        {
            [UserTipsUtil setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"] andCurrentViewController:self];
        }
    });
}

//取消搜索状态
- (void)cancelSearchStatus{
    searchdispalyCtrl.active = NO;
}

- (void)processFileRecords:(NSArray *)searchResultsArray{
    for (id _id in searchResultsArray) {
        if ([_id isKindOfClass:[WXAdvSearchModel class]]) {
            WXAdvSearchModel *_model = (WXAdvSearchModel *)_id;
            if (_model.searchResultType == search_result_type_filerecord) {
                NSArray *tempArray = _model.dspItemArray;
                for (id tempId in tempArray) {
                    if ([tempId isKindOfClass:[ConvRecord class]]) {
                        ConvRecord *_convRecord = (ConvRecord *)tempId;
                        //解除下载的delegate
                        if (_convRecord.downloadRequest && _convRecord.downloadRequest.isExecuting) {
                            _convRecord.downloadRequest.downloadProgressDelegate = nil;
                            _convRecord.downloadRequest.delegate = nil;
                        }
                    }
                }
                break;
            }
        }
    }
}

- (NSIndexPath *)getIndexPathByMsgId:(int)msgId
{
    BOOL hasFind = NO;
    
    int section = 0;
    for (id _id in self.searchResults) {
        
        if ([_id isKindOfClass:[WXAdvSearchModel class]]) {
            
            WXAdvSearchModel *_model = (WXAdvSearchModel *)_id;
            
            if (_model.searchResultType == search_result_type_filerecord) {
                NSArray *_array = _model.dspItemArray;
                int row = 0;
                for (id tempId in _array) {
                    if ([tempId isKindOfClass:[ConvRecord class]]) {
                        ConvRecord *_convRecord = (ConvRecord *)tempId;
                        if (_convRecord.msgId == msgId) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                            return indexPath;
                        }
                    }
                    row++;
                }
            }
            
        }
        section++;
    }
    return nil;
}


- (ConvRecord*)getConvRecordByMsgId:(NSString*)msgId{
    ConvRecord *convRecord = [[eCloudDAO getDatabase] getConvRecordByMsgId:msgId];
    return convRecord;
}

//根据indexpath获取到convRecord
- (ConvRecord *)getConvRecordByIndexPath:(NSIndexPath *)indexPath
{
    WXAdvSearchModel *_model = self.searchResults[indexPath.section];
    ConvRecord *_convRecord = _model.dspItemArray[indexPath.row];
    return _convRecord;
}

- (UITableViewCell *)getCellAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    return cell;
}

/** 下载成功后 局部刷新 */
-(void)reloadRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
    
    [self.searchDisplayController.searchResultsTableView beginUpdates];
    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.searchDisplayController.searchResultsTableView endUpdates];
}


- (void)downloadFileComplete:(ASIHTTPRequest *)request
{
    int statuscode=[request responseStatusCode];
    [LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,statuscode]];
    
    NSDictionary *dic=[request userInfo];
    int _msgId = [[dic objectForKey:@"MSG_ID"]intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId];
    
    NSIndexPath *indexPath = [self getIndexPathByMsgId:_msgId];
    if (!indexPath) {
        ConvRecord *_convRecord = [[eCloudDAO getDatabase]getConvRecordByMsgId:[StringUtil getStringValue:_msgId]];
        [talkSessionUtil transferFile:_convRecord];

        return;
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    [talkSessionUtil transferFile:_convRecord];

    _convRecord.downloadRequest = nil;
    
    UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
    
    if(statuscode == 404){
        [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:nil];
    }
    else if(statuscode != 200){
        //下载失败
        [self downloadFileFail:request];
    }
    else{
        UIProgressView *progressView = (UIProgressView*)request.downloadProgressDelegate;
        [talkSessionUtil hideProgressView:progressView];
        [self reloadRowAtIndexPath:indexPath];
   }
}

-(void)downloadFileFail:(ASIHTTPRequest*)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    NSDictionary *dic=[request userInfo];
    NSString* _msgId = [dic objectForKey:@"MSG_ID"];
    
    NSIndexPath *indexPath = [self getIndexPathByMsgId:_msgId.intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    
    if (!indexPath) {
        return;
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    _convRecord.downloadRequest = nil;
    _convRecord.tryCount = 0;
}



#pragma mark ==========QLPreivew Datasource=============
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller;
{
    return 1;
}
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    if (self.searchDisplayController.isActive) {
        WXAdvSearchModel *model = self.searchResults[previewFileIndex.section];
        if (model.searchResultType == search_result_type_filerecord) {
            ConvRecord *convRecord = model.dspItemArray[previewFileIndex.row];
            FileRecord *_fileRecord = [[FileRecord alloc]init];
            _fileRecord.convRecord = convRecord;
            return [_fileRecord autorelease];
        }
    }
    return nil;
}

#endif

@end
