//
//  FileAssistantViewController.m
//  eCloud
//
//  Created by Pain on 15-1-5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FileListViewController.h"
#import "RobotDisplayUtil.h"
#import "eCloudUser.h"
#import "ApplicationManager.h"
#import "CustomQLPreviewController.h"

#import "eCloudDefine.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "LCLLoadingView.h"
#import "eCloudDAO.h"
#import "talkSessionUtil.h"
#import "talkSessionUtil2.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import <QuickLook/QLPreviewController.h>
#import "FileRecord.h"
#import "ForwardingRecentViewController.h"
#import "UserDefaults.h"

#import "EncryptFileManege.h"

#import "FileAssistantDOA.h"
#import "FileAssistantUtil.h"
#import "ChooseFileListCell.h"
#import "FileAssistantListCell.h"
#import "DownloadFileModel.h"
#import "UploadFileModel.h"
#import "talkSessionViewController.h"
#import "IOSSystemDefine.h"

#define BOTTOM_BAR_HEIGHT (44.0)

#define download_file_msg_id_tag (101)

#define file_msg_gprs_alertview_tag (102)
#define file_msg_delete_alertview_tag (103)

@interface FileListViewController ()<QLPreviewControllerDataSource>{
    
    UITableView *orgTable;
    BOOL editing; //判断是否批量状态
    
    BOOL firstSearch;
    UIView *bottomNavibar;
    UILabel *sendLab;
    UIButton *sendeBtn;
    NSInteger allFileSize;
    
    NSObject <FileListViewControllerDelegate> *_locaLFilesDelegate;

    UISearchBar *_searchBar;
    UIButton *searchCancelBtn;
    UITextView *searchTextView;
    int searchDeptAndEmpTag;
    
    UISearchDisplayController * searchdispalyCtrl;
    
    eCloudDAO *_ecloud;
    int totalCount; //会话的总记录个数
    int loadCount; //已经加载的记录个数
    int limit; //查询会话时用到的参数
    int offset;
    UIActivityIndicatorView *loadingIndic;
    bool isLoading;
    
    int previewFileIndex;//当前预览的文件索引
 
    UILabel *lineLab;
    UILabel *tipLabel;
    UIImageView *tipImageView;
    CGFloat _tableViewLineX;

    
}

@property(nonatomic,assign)NSMutableArray *itemArray;
@end

@implementation FileListViewController

@synthesize locaLFilesDelegate = _locaLFilesDelegate;

- (void)dealloc{
    
//    for (ConvRecord *_convRecord in self.itemArray) {
//        //解除下载的delegate
//        if (_convRecord.download_flag = state_downloading && _convRecord.downloadRequest) {
//            _convRecord.downloadRequest.downloadProgressDelegate = nil;
//            _convRecord.downloadRequest.delegate = nil;
//        }
//        
//        if (_convRecord.uploadRequest && _convRecord.send_flag == state_uploading) {
//            //解除上传delegate
//            _convRecord.uploadRequest.uploadProgressDelegate = nil;
//        }
//    }
    
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    [self.itemArray removeAllObjects];
    self.itemArray = nil;
    
    [self.chooseResults removeAllObjects];
    self.chooseResults = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadFilesFinished" object:nil];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
//    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed)];
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed)];
    
    _ecloud = [eCloudDAO getDatabase] ;
    
    editing = YES;
    firstSearch = YES;
    self.itemArray = [[NSMutableArray alloc] init];
    self.chooseResults = [[NSMutableArray alloc] init];
    
    isLoading = false;
    
    [self initSearchBar];
    
    int tableH = (self.view.frame.size.height + self.view.frame.origin.y) - ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height) - _searchBar.frame.size.height - BOTTOM_BAR_HEIGHT;
//    -   460 - 80.0;
//    if(iPhone5)
//      {
//        tableH = tableH + i5_h_diff;
//      }else if(IS_IPHONE_6P){
//          
//        tableH = tableH = tableH + i5_h_diff + 168;
//      }else if(IS_IPHONE_6){
//          
//          tableH = tableH = tableH + i5_h_diff + 99;
//      }
    
    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH + 44) style:UITableViewStylePlain];
    [UIAdapterUtil setPropertyOfTableView:orgTable];
    orgTable.backgroundColor = [UIColor yellowColor];
    [orgTable setDelegate:self];
    [orgTable setDataSource:self];
    orgTable.scrollsToTop = YES;
    orgTable.backgroundColor=[UIColor clearColor];
    //[UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable];
    [self.view addSubview:orgTable];
    [orgTable release];
    
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    
    [self addBottomBar];
    
    //注册发送文件完成的消息中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFilesFinished) name:@"UploadFilesFinished" object:nil];
    
    tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 203.5, SCREEN_WIDTH, 50)];
    tipLabel.text = [StringUtil getLocalizableString:@"me_file_tip"];
    tipLabel.textColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1/1.0];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.numberOfLines = 0;
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    tipLabel.hidden = YES;
    [self.view addSubview:tipLabel];
    
#define imageWidth 90
    tipImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-imageWidth/2, 80, imageWidth, 110)];
    tipImageView.image = [StringUtil getImageByResName:@"img_meeting_nothing"];
    tipImageView.hidden = YES;
    [self.view addSubview:tipImageView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = [StringUtil getLocalizableString:@"me_file_assistant"];
    _searchBar.placeholder=[StringUtil getLocalizableString:@"file_search_tip"];
    [self.navigationItem setHidesBackButton:YES];
    [self initData];
    [self hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [searchTextView resignFirstResponder];
}

- (void)initSearchBar{
    //查询bar
    _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.delegate=self;
    _searchBar.placeholder=[StringUtil getLocalizableString:@"file_search_tip"];
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    _searchBar.backgroundColor=[UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
}

- (void)addBottomBar{
    //自定义底部导航栏
//    int toolbarY = self.view.frame.size.height - 44-25.0+6.0;
//    if (IOS7_OR_LATER)
//    {
//        toolbarY = toolbarY - 20;
//    }
    
    float toolbarY = orgTable.frame.origin.y + orgTable.frame.size.height;
    
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, BOTTOM_BAR_HEIGHT)];
    bottomNavibar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomNavibar];
    bottomNavibar.hidden = YES;
    [bottomNavibar release];
    
    //分割线
    lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1/1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    sendLab = [[UILabel alloc]initWithFrame:CGRectMake(10.0,0.0, 236.0, 42.0)];
    sendLab.backgroundColor = [UIColor clearColor];
    sendLab.textColor=[UIColor colorWithRed:162/255.0 green:162/255.0 blue:162/255.0 alpha:1/1.0];
    sendLab.text = @"";
    sendLab.font=[UIFont systemFontOfSize:13];
    sendLab.contentMode = UIViewContentModeTop;
    sendLab.textAlignment = UITextAlignmentLeft;
    sendLab.numberOfLines = 2;
    [bottomNavibar addSubview:sendLab];
    [sendLab release];
    
    sendeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendeBtn.frame = CGRectMake(self.view.frame.size.width - 70 - 10, 6.0, 70, 30);
    sendeBtn.enabled = NO;
    [sendeBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]forState:UIControlStateNormal];
    sendeBtn.layer.cornerRadius = 4.0;
//    sendeBtn.layer.borderColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0].CGColor;
//    sendeBtn.layer.borderWidth = 1.0f;
    sendeBtn.backgroundColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    [sendeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendeBtn setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
    sendeBtn.titleLabel.font=[UIFont boldSystemFontOfSize:13.0];
    [sendeBtn addTarget:self action:@selector(clickOnSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [bottomNavibar addSubview:sendeBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 注册发送文件完成的消息中心
- (void)uploadFilesFinished{
    [[LCLLoadingView currentIndicator] hiddenForcibly:true];
    [self backButtonPressed];
//    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - 按钮方法实现
- (void)clickOnSendBtn{
    
    int netType = [ApplicationManager getManager].netType;
    
    if(netType == type_gprs)
    {
        //提示发送
        if (self.fromCtrl && [self.fromCtrl isEqualToString:@"agentListCtrl"]) {
            if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(fileListViewControllerClickOnBackBtn: withSelectFiles:)]) {
                [_locaLFilesDelegate fileListViewControllerClickOnBackBtn:self withSelectFiles:self.chooseResults];
            }
        }else{
            NSString *fileSizeStr = [StringUtil getDisplayFileSize:allFileSize];
    //        //2G网络提示用户
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_file_gprs_tips"]  message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
            
            NSString *_title = [NSString stringWithFormat:[StringUtil  getLocalizableString:@"download_traffic_tips"],fileSizeStr];
            NSString *_message = [StringUtil  getLocalizableString:@"chats_talksession_message_file_gprs_tips"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
            
            alert.tag = 2;
            [alert show];
            [alert release];
        }
    }
    else{
        if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(fileListViewControllerClickOnBackBtn: withSelectFiles:)]) {
            [_locaLFilesDelegate fileListViewControllerClickOnBackBtn:self withSelectFiles:self.chooseResults];
        }
        
        //提示发送
        if (!(self.fromCtrl && [self.fromCtrl isEqualToString:@"agentListCtrl"])) {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"chats_talksession_message_file_sending"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
        }
    }
}


-(void)backButtonPressed{
    for (ConvRecord *_convRecord in self.itemArray) {
        //解除下载的delegate
        if (_convRecord.download_flag = state_downloading && _convRecord.downloadRequest) {
            _convRecord.downloadRequest.downloadProgressDelegate = nil;
            _convRecord.downloadRequest.delegate = nil;
        }
        
        if (_convRecord.uploadRequest && _convRecord.send_flag == state_uploading) {
            //解除上传delegate
            _convRecord.uploadRequest.uploadProgressDelegate = nil;
        }
    }
    
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.needUpdateTag = 1;
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark ============================批量操作============================

- (BOOL)isConvRecordInChooseResults:(ConvRecord *)_convRecord{
    BOOL isChosen = NO;
    for (ConvRecord *convRecord in self.chooseResults) {
        if (convRecord.msgId == _convRecord.msgId) {
            isChosen = YES;
            break;
        }
    }
    
    return isChosen;
}

- (void)removeConvRecordFromChooseResults:(ConvRecord *)_convRecord{
    int index = -1;
    int i = -1;
    for (ConvRecord *convRecord in self.chooseResults) {
        i ++;
        if (convRecord.msgId == _convRecord.msgId) {
            index = i;
            break;
        }
    }
    
    if (index >= 0 && index < [self.chooseResults count]) {
        ConvRecord *convRecord = [self.chooseResults objectAtIndex:index];
        convRecord.isChosen = NO;
        [self.chooseResults removeObjectAtIndex:index];
    }
}

- (void)addConvRecordToChooseResults:(ConvRecord *)_convRecord{
    int index = -1;
    int i = -1;
    for (ConvRecord *convRecord in self.chooseResults) {
        i ++;
        if (convRecord.msgId == _convRecord.msgId) {
            index = i;
            break;
        }
    }
    
    if (index >= 0 && index < [self.chooseResults count]) {
        //修改
        ConvRecord *convRecord = [self.chooseResults objectAtIndex:index];
        convRecord.isChosen = YES;
    }
    else{
        //重新添加
        [self.chooseResults addObject:_convRecord];
    }
}

- (void)setChooseResultsDesSelect{
    for (ConvRecord *convRecord in self.chooseResults) {
        convRecord.isChosen = NO;
    }
}

- (NSString *)getChooseResultsTotalSize{
    NSString *fileSize;
    int _size = 0;
    for (ConvRecord *_convRecord in self.chooseResults) {
        if(_convRecord.send_flag == send_upload_nonexistent){
            //已经下载本地的文件或者失效的文件，不再计算大小
            continue;
        }
        else{
            _size += [_convRecord.file_size intValue];
        }
    }
    fileSize = [StringUtil getDisplayFileSize:_size];
    return fileSize;
}

#pragma mark ========================================================

#pragma mark - 文件发送进度显示
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
    NSLog(@"bytes-------｜｜｜｜%lld",bytes);
    
    if (bytes) {
        NSString* response = [request responseString];
        NSDictionary *dic=[request userInfo];
        NSString *msgId = [dic valueForKey:@"MSG_ID"];
        NSString *token = [dic valueForKey:@"Token"];
        int currentIndex = [[dic valueForKey:@"Start_Index"] integerValue];
        
        
        NSString *upload_start_index = [NSString stringWithFormat:@"%d",currentIndex + (int)bytes];
        NSString *total_length = [dic valueForKey:@"Total_length"];
        NSDictionary *data_dic=[NSDictionary dictionaryWithObjectsAndKeys:msgId,@"MSG_ID",upload_start_index,@"Start_Index",total_length,@"Total_length",token,@"Token",nil];
        [request setUserInfo:data_dic];
        
        //发送文件，显示进度条
        int _index = [self getArrayIndexByMsgId:[msgId intValue]];
        
        UITableViewCell *cell = [self getCellAtIndex:_index];
        
        UIProgressView *_progressView = (UIProgressView * )[cell.contentView  viewWithTag:file_list_progressview_tag];
//        [FileAssistantUtil displayProgressView:_progressView];
        float progress = [upload_start_index floatValue]/[total_length floatValue];
        _progressView.progress = progress;
        
        NSLog(@"upload_start_index-------%@",upload_start_index);
        NSLog(@"total_length-------%@",total_length);
        NSLog(@"progress-------%f",progress);
    }
}

#pragma mark - 文件下载
- (void)downloadResumeFile:(int)msgId andCell:(UITableViewCell*)_cell{
    if(![ApplicationManager getManager].isNetworkOk){
        
        return;
    }
    
    int _index = [self getArrayIndexByMsgId:msgId];
    
    if(_index < 0) return;
    
    UITableViewCell *cell = [self getCellAtIndex:_index];
    if(cell == nil){
        cell = _cell;
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
    _convRecord.isDownLoading = true;
    _convRecord.download_flag = state_downloading;
    int msgType = _convRecord.msg_type;
    NSString *urlStr;
    NSURL *url;
    
    //判断是否是本地发送出去的文件，如果是那么如果本地没有了
    NSRange range = [_convRecord.msg_body rangeOfString:@"_"];
    
    float maxSendFileSize = [UserDefaults getMaxSendFileSize];
    
    if(range.length > 0){
        NSString *token = [NSString stringWithFormat:@"%@",[_convRecord.msg_body substringToIndex:range.location]];
        if (maxSendFileSize == 20) {
            //兼容旧版的url
            NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
            urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
        }
        else{
            urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
        }
    }
    else{
        NSString *token = [NSString stringWithFormat:@"%@",_convRecord.msg_body];
        if (maxSendFileSize == 20) {
            //兼容旧版的url
            NSString *oldUrlStr = [NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase] getServerConfig] getAudioFileDownloadUrl],token];
            urlStr = [NSString stringWithFormat:@"%@%@",oldUrlStr,[StringUtil getDownloadAddStr:token]];
        }
        else{
            urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,[StringUtil getResumeDownloadAddStr]];
        }
    }
    
    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],@"12111111212.zip"];
    //    url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,urlStr]];
    [request setDelegate:self];
    
    //设置文件进度
    UIProgressView *_progressView = (UIProgressView*)[cell.contentView viewWithTag:file_progressview_tag];
    [talkSessionUtil displayProgressView:_progressView];
    [request setDownloadProgressDelegate:_progressView];
    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    
    //设置保存路径
    NSString *pathStr = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
    [request setDownloadDestinationPath:pathStr];
    
    //设置文件缓存路径
    NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i_%@.zip",msgId,[talkSessionUtil getFileName:_convRecord]]];
    [request setTemporaryFileDownloadPath:tempPath];
    
    //[request addRequestHeader:@"Range" value:@"bytes=0-"];
    [request setDidFinishSelector:@selector(downloadFileComplete:)];
    [request setDidFailSelector:@selector(downloadFileFail:)];
    [request setAllowResumeForFileDownloads:YES];
    
    //传参数，文件传输完成后，根据参数进行不同的处理
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[StringUtil getStringValue:msgId],@"MSG_ID",nil]];
    [request setTimeOutSeconds:[self getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
    
    _convRecord.downloadRequest = request;
    [request release];
    
    DownloadFileModel *fileMode = [[FileAssistantDOA getDatabase] getDownloadFileWithUploadid:[StringUtil getStringValue:msgId]];
    int uploadstate =  state_downloading;
    if (fileMode.download_id) {
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:[StringUtil getStringValue:msgId] withState:uploadstate];
    }
    else{
        //往数据添加上传记录
        NSMutableDictionary *downEvent = [[NSMutableDictionary alloc] init];
        [downEvent setObject:[StringUtil getStringValue:msgId] forKey:@"download_id"];
        [downEvent setObject:[NSNumber numberWithInt:uploadstate] forKey:@"download_state"];
        [[FileAssistantDOA getDatabase] addOneFileDownloadRecord:downEvent];
        [downEvent release];
    }
    
    [[talkSessionUtil2 getTalkSessionUtil] addRecordToDownloadList:_convRecord];
}


- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    [LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,statuscode]];
    
    NSDictionary *dic=[request userInfo];
    NSString *_msgId = [dic objectForKey:@"MSG_ID"];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    if(_index < 0){
        ConvRecord *_convRecord = [self getConvRecordByMsgId:_msgId];
        [talkSessionUtil transferFile:_convRecord];
        if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        return;
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
    [talkSessionUtil transferFile:_convRecord];
    
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    
    UITableViewCell *cell = [self getCellAtIndex:_index];
    
    int msgType = _convRecord.msg_type;
    if(statuscode == 404){
        //文件不存在
        //记录至数据库中，下次不再加载，并移除目录文件
        [self updateSendFlagByMsgId:_msgId andSendFlag:send_upload_nonexistent];
        _convRecord.send_flag = send_upload_nonexistent;
        [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:nil];
        
        //该文件对应的所有消息记录设置为过期
        [self setConvRecordsHasExpiredWithUrl:_convRecord.msg_body];
        
        //更新下载的数据库，并刷新cell
        int uploadstate = state_download_nonexistent;
        _convRecord.download_flag = uploadstate;
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
        [self reloadRow:_index];
        
        //提示过期
        [FileAssistantUtil showFileNonexistViewInView:self.view inTalkSession:NO];
    }
    else if(statuscode != 200){
        //下载失败
        [self downloadFileFail:request];
    }
    else{
        //下载成功,如果文件存在，并且size大于0，显示给用户，否则按照文件不存在处理
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:request.downloadDestinationPath] && [[NSData dataWithContentsOfFile:request.downloadDestinationPath]length] > 0)
        {
            if( _convRecord.msg_type == type_file){
                UIProgressView *progressView = (UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
                
                //更新下载状态为成功
                int uploadstate =  state_download_success;
                [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
                
                _convRecord.download_flag = uploadstate;
            }
            
            [self reloadRow:_index];
            //            add by shisp 如果用户选择了转发文件，那么在文件下载成功后，应该打开选择联系人的界面
//            if (self.forwardRecord && (self.forwardRecord.msgId == _convRecord.msgId)) {
//                [self openRecentContacts];
//            }
        }
        else{
            [self updateSendFlagByMsgId:_msgId andSendFlag:-1];
            _convRecord.send_flag = -1;
            if( _convRecord.msg_type == type_file){
                UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
                [talkSessionUtil hideProgressView:progressView];
            }
        }
    }
    
    [EncryptFileManege encryptExistFile:request.downloadDestinationPath];
}

-(void)downloadFileFail:(ASIHTTPRequest*)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    NSDictionary *dic=[request userInfo];
    NSString* _msgId = [dic objectForKey:@"MSG_ID"];
    int _index = [self getArrayIndexByMsgId:_msgId.intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    if(request.error.code == ASIRequestTimedOutErrorType)
    {
        if(_index >= 0)
        {
            ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
            _convRecord.tryCount++;
            if(_convRecord.tryCount < max_try_count)
            {
                //继续尝试下载，否则报错
                if (_convRecord.msg_type == type_file) {
                    [self downloadResumeFile:_msgId.intValue andCell:nil];
                }
                return;
            }
        }
    }
    
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    
    if(_index < 0) return;
    
    ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    _convRecord.tryCount = 0;
    
    UITableViewCell *cell = [self getCellAtIndex:_index];
    
    if (_convRecord.msg_type == type_file) {
        int uploadstate = state_download_failure;
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
        _convRecord.download_flag = uploadstate;
        
        //文件下载失败,显示失败按钮
        [FileAssistantUtil configureChooseFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
}

-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag
{
    [_ecloud updateSendFlagByMsgId:msgId andSendFlag:flag];
}

-(void)setConvRecordsHasExpiredWithUrl:(NSString *)url{
    //修改数据库标记
    [_ecloud setConvRecordsHasExpiredWithUrl:url];
    
    //修改内存标记
    if ([self isSearchState]){
        for (ConvRecord *_convRecord in self.searchResults) {
            if (_convRecord.msg_type == type_file && [_convRecord.msg_body isEqualToString:url]) {
                _convRecord.send_flag = send_upload_nonexistent;
            }
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else{
        for (ConvRecord *_convRecord in self.searchResults) {
            if (_convRecord.msg_type == type_file && [_convRecord.msg_body isEqualToString:url]) {
                _convRecord.send_flag = send_upload_nonexistent;
            }
        }
    }
    
    [orgTable reloadData];
}


#pragma mark -  根据消息id获取纪录
- (ConvRecord *)getConvRecordByIndex:(NSInteger)index{
    ConvRecord *_convRecord;
    if ([self isSearchState]){
        if (index < [self.searchResults count]) {
            _convRecord = [self.searchResults objectAtIndex:index];
        }
    }
    else{
        if (index < [self.itemArray count]) {
            _convRecord = [self.itemArray objectAtIndex:index];
        }
    }
    
    return _convRecord;
}

- (UITableViewCell *)getCellAtIndex:(NSInteger)_index{
    UITableViewCell *cell;
    if ([self isSearchState]){
        cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    }
    else{
        cell = [orgTable cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    }
    return cell;
}

- (BOOL)isSearchState{
    //判断当前是否为搜索状态
    BOOL isSearch = NO;
    if ([self.searchResults count]) {
        isSearch = YES;
    }
    return isSearch;
}

#pragma mark 聊天记录修改后，局部刷新
-(void)reloadRow:(int)_index
{
    ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
    
    if ([self isSearchState]) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.searchDisplayController.searchResultsTableView endUpdates];
    }
    else{
        [orgTable beginUpdates];
        [orgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_index inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
        [orgTable endUpdates];
    }
}

#pragma 根据数组的下标，得到indexPath
-(NSIndexPath*)getIndexPathByIndex:(int)index
{
    return [NSIndexPath indexPathForRow:index inSection:0];
}

#pragma mark 根据msgId找到对应的下标
-(int)getArrayIndexByMsgId:(int)msgId
{
    if ([self isSearchState]) {
        for(int i = self.searchResults.count - 1;i>=0;i--)
        {
            ConvRecord *_convRecord = [self.searchResults objectAtIndex:i];
            if(_convRecord.msgId == msgId)
            {
                return i;
            }
        }
    }
    else{
        for(int i = self.itemArray.count - 1;i>=0;i--)
        {
            ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
            if(_convRecord.msgId == msgId)
            {
                return i;
            }
        }
    }
    
    return -1;
}

-(int)getRequestTimeout
{
    int timeout = 30;
    if([ApplicationManager getManager].netType == type_gprs)
    {
        timeout = 60;
    }
    return timeout;
}
    
#pragma mark - 获取文件消息
-(void)initData
{
    [self getFileConvRecords];
    
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //    NSArray *allDept = [_ecloud getLocalNextDeptInfoWithLevel:@"0" andLevel:0];
    //
    //    [self.itemArray removeAllObjects];
    //    [self.itemArray addObjectsFromArray:allDept];
    //    [self getCustomGroup];
    //    [pool release];
    
    
    
    
//    if (self.sendForwardMsgFlag)
//    {
//        self.sendForwardMsgFlag = NO;
//        [self sendForwardMsg];
//    }
//    
//    if (self.needUpdateTag==1)
//    {
//        //		需要加载页面
//        self.needUpdateTag=0;
//        
//        if(self.convRecordArray.count > 0)
//            [self.convRecordArray removeAllObjects];
//        
//        [self.chatTableView reloadData];
//        
//        //		获取当前会话对应的聊天记录
//        [self getRecordsByConvId];
//    }
//    else
//    {
//        if (self.fromType == 2)
//        {
//            if(self.convRecordArray.count > 0)
//                [self.convRecordArray removeAllObjects];
//            [self loadSearchResults:self.fromConv];
//        }
//    }
    
}

#pragma mark 获取该会话的聊天记录
-(void)getFileConvRecords
{
    totalCount = [self getFileConvRecordsCount];
    
    loadCount = self.itemArray.count;
    if(totalCount > (loadCount + num_convrecord))
    {
        limit = num_convrecord;
        offset = loadCount;
    }
    else
    {
        limit = totalCount - loadCount;
        offset = loadCount;
    }
    

    NSArray *recordList= [self getFileConvRecordsWithLimit:limit andOffset:offset];
    
    [self.itemArray addObjectsFromArray:recordList];
    for(int i=0;i<self.itemArray.count;i++){
        ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
        _convRecord.isChosen = [self isConvRecordInChooseResults:_convRecord];
    }
    
    int count=[recordList count];
    
    [self hideLoadingCell];
    
    [orgTable reloadData];
    
    
//    //    每屏显示记录数
//    int recordCountOfPage = 5;
//    
//    if (count>0)
//    {
//        //		默认是最下面
//        int _index = [self.convRecordArray count] ;
//        if(self.unReadMsgCount >= 10)
//        {
//            //			显示第一条
//            _index = 0;
//        }
//        else if(self.unReadMsgCount >= recordCountOfPage)
//        {
//            //			定位在未读的记录
//            _index = _index - (self.unReadMsgCount - recordCountOfPage);
//        }
//        
//        //		NSLog(@"%s,_index is %d",__FUNCTION__,_index);
//        if(self.talkType == massType)
//        {
//            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
//                                      atScrollPosition: UITableViewScrollPositionBottom
//                                              animated:NO];
//            
//        }
//        else
//        {
//            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]
//                                      atScrollPosition: UITableViewScrollPositionBottom
//                                              animated:NO];			
//        }
//    }
}

-(int)getFileConvRecordsCount{
    return [_ecloud getFileConvRecordsCount];
}

- (NSArray *)getFileConvRecordsWithLimit:(int)_limit andOffset:(int)_offset{
//    文件助手数据库
    NSArray *recordList;
#ifdef _XIANGYUAN_FLAG_
    
    recordList = [_ecloud getFileAssistantConvRecordsWithLimit:limit andOffset:offset];
#else
    recordList=[_ecloud getFileConvRecordsWithLimit:limit andOffset:offset];
    
#endif
    return recordList;
}

- (ConvRecord*)getConvRecordByMsgId:(NSString*)msgId{
    ConvRecord *convRecord = [_ecloud getConvRecordByMsgId:msgId];
    return convRecord;
}


#pragma mark - 上拉加载更多文件

- (void)createTableFooterWithTitle:(NSString *)_title{
    orgTable.tableFooterView = nil;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, orgTable.bounds.size.width, 40.0f)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0, 40.0f)];
    loadMoreText.backgroundColor = [UIColor clearColor];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setTextAlignment:NSTextAlignmentCenter];
    [loadMoreText setFont:[UIFont systemFontOfSize:12.0]];
    [loadMoreText setText:_title];
    [tableFooterView addSubview:loadMoreText];
    [loadMoreText release];
    
    //上拉提示
    loadingIndic =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndic.frame=CGRectMake(40.0,5, 30.0f,30.0f);
    loadingIndic.hidden = YES;
    loadingIndic.hidesWhenStopped = YES;
    [tableFooterView addSubview:loadingIndic];
    [loadingIndic release];
    
    orgTable.tableFooterView = tableFooterView;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    if(self.itemArray.count >= totalCount || [self isSearchState]){
        return;
    }
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    float reload_distance = 40.0;
    if(y > h + reload_distance) {
        //NSLog(@"load more rows");
        if(!isLoading){
            isLoading = true;
            loadingIndic.hidden = NO;
            [loadingIndic startAnimating];
            [self performSelector:@selector(getFileConvRecords) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)hideLoadingCell
{
    loadingIndic.hidden = YES;
    [loadingIndic stopAnimating];
    isLoading = false;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate 协议方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.itemArray.count == 0) {
        
        _searchBar.hidden = YES;
        bottomNavibar.hidden = YES;
        tipImageView.hidden = NO;
        tipLabel.hidden = NO;
        
    }else{
        
        //bottomNavibar.hidden = NO;
        _searchBar.hidden = NO;

    }
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.searchResults count];
    }
    else{
         return [self.itemArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return file_cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    ConvRecord *_convRecord;
    if(tableView == self.searchDisplayController.searchResultsTableView){
        _convRecord = (ConvRecord *)[self.searchResults objectAtIndex:[indexPath row]];
    }
    else{
        _convRecord = (ConvRecord *)[self.itemArray objectAtIndex:[indexPath row]];
    }
    
    if (_convRecord.send_flag == send_upload_nonexistent) {
        //文件不存在，不可选择
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *selectButton = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
    [self clickOnSelectButton:selectButton];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        static NSString *CellName = @"searchCellName";
        ChooseFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
        if (cell == nil){
            cell = [[[ChooseFileListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
        }
        
        ConvRecord *_convRecord = (ConvRecord *)[self.searchResults objectAtIndex:[indexPath row]];
        [cell configureCell:cell andConvRecord:_convRecord];
        [cell configureCell:cell editState:YES];
        
        [FileAssistantUtil configureChooseFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        if (_convRecord.downloadRequest && _convRecord.download_flag == state_downloading) {
            //配置下载参数
            UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
            _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
            _convRecord.downloadRequest.delegate = self;
            [_convRecord.downloadRequest setDidFinishSelector:@selector(downloadFileComplete:)];
            [_convRecord.downloadRequest setDidFailSelector:@selector(downloadFileFail:)];
        }
        
        if (_convRecord.uploadRequest && _convRecord.send_flag == state_uploading) {
            //配置文件上传参数
            _convRecord.uploadRequest.uploadProgressDelegate = self;
//            _convRecord.uploadRequest.delegate = self;
//            [_convRecord.uploadRequest setDidFinishSelector:@selector(uploadFileComplete:)];
//            [_convRecord.uploadRequest setDidFailSelector:@selector(uploadFileFail:)];
        }
        
        UIButton *selectButton = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
        if (_convRecord.send_flag == send_upload_nonexistent) {
            selectButton.hidden = YES;
        }
        else{
            [selectButton addTarget:self action:@selector(clickOnSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.titleLabel.text = [NSString stringWithFormat:@"%i",[indexPath row]];
            selectButton.titleLabel.hidden = YES;
        }
        
        UIButton *downLoadButton = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
        [downLoadButton addTarget:self action:@selector(clickOnDownLoadButton:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *downLoadlab = (UILabel *)[downLoadButton viewWithTag:file_download_button_lab_tag];
        downLoadlab.text = [NSString stringWithFormat:@"%i",[indexPath row]];
        
        UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
//        [UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable withOriginX:fileNameLab.frame.origin.x];
        _tableViewLineX = fileNameLab.frame.origin.x;

        return cell;
    }
    else{
        static NSString *CellName = @"CellName";
        ChooseFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
        if (cell == nil){
            cell = [[[ChooseFileListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
        }
        
        ConvRecord *_convRecord = (ConvRecord *)[self.itemArray objectAtIndex:[indexPath row]];
        [cell configureCell:cell andConvRecord:_convRecord];
        [cell configureCell:cell editState:YES];
        
        [FileAssistantUtil configureChooseFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        if (_convRecord.downloadRequest && _convRecord.download_flag == state_downloading) {
            //配置下载参数
            UIProgressView *_progressView = (UIProgressView *)[cell.contentView viewWithTag:file_list_progressview_tag];
            _convRecord.downloadRequest.downloadProgressDelegate = _progressView;
            _convRecord.downloadRequest.delegate = self;
            [_convRecord.downloadRequest setDidFinishSelector:@selector(downloadFileComplete:)];
            [_convRecord.downloadRequest setDidFailSelector:@selector(downloadFileFail:)];
        }
        
        if (_convRecord.uploadRequest && _convRecord.send_flag == state_uploading) {
            //配置文件上传参数
            _convRecord.uploadRequest.uploadProgressDelegate = self;
            //            _convRecord.uploadRequest.delegate = self;
            //            [_convRecord.uploadRequest setDidFinishSelector:@selector(uploadFileComplete:)];
            //            [_convRecord.uploadRequest setDidFailSelector:@selector(uploadFileFail:)];
        }
        
        UIButton *selectButton = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
        if (_convRecord.send_flag == send_upload_nonexistent) {
            selectButton.hidden = YES;
        }
        else{
            [selectButton addTarget:self action:@selector(clickOnSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.titleLabel.text = [NSString stringWithFormat:@"%i",[indexPath row]];
            selectButton.titleLabel.hidden = YES;
        }
        
        UIButton *downLoadButton = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
        [downLoadButton addTarget:self action:@selector(clickOnDownLoadButton:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *downLoadlab = (UILabel *)[downLoadButton viewWithTag:file_download_button_lab_tag];
        downLoadlab.text = [NSString stringWithFormat:@"%i",[indexPath row]];
        
        UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
//        [UIAdapterUtil alignHeadIconAndCellSeperateLine:orgTable withOriginX:fileNameLab.frame.origin.x];
        _tableViewLineX = fileNameLab.frame.origin.x;

        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == orgTable) {
        if (indexPath.row == [self.itemArray count] - 1){
            NSString *tilte;
            if(self.itemArray.count >= totalCount){
                tilte = [StringUtil getLocalizableString:@"file_no_more_records"];
            }
            else{
                tilte = [StringUtil getLocalizableString:@"file_pull_up_more_records"];
            }

            [self createTableFooterWithTitle:tilte];
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

#pragma mark - 编辑菜单
- (void)clickOnDownLoadButton:(UIButton *)sender{
    if (self.fromCtrl && [self.fromCtrl isEqualToString:@"agentListCtrl"]) {
        return;
    }
    UILabel *downLoadlab = (UILabel *)[sender viewWithTag:file_download_button_lab_tag];
    NSInteger row = [downLoadlab.text intValue];
    NSLog(@"clickOnDownLoadButton-----------------%i",row);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableView *tableView = [self getTableView];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self getConvRecordByIndex:row];
    NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    switch (_convRecord.download_flag) {
        case state_download_success:
        {
            //文件下载成功,点击查看
            [talkSessionUtil sendReadNotice:_convRecord];
            previewFileIndex = indexPath.row;
            [[RobotDisplayUtil getUtil]openNormalFile:self andCurVC:self];
        }
            break;
        case state_downloading:
        {
            //如果有文件在下载，那么从文件列表中移除，并且取消下载
            [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_convRecord.msgId];
            int uploadstate = state_download_stop;
            _convRecord.download_flag = uploadstate;
            [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:msgId withState:uploadstate];
        }
            break;
        case state_download_failure:
        {
            //下载失败,重新发送
            int netType = [ApplicationManager getManager].netType;
            if(netType == type_gprs)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:@"%@【%@】?", [StringUtil  getLocalizableString:@"confirm_to_download_file"],_convRecord.fileNameAndSize] delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
                alert.tag = file_msg_gprs_alertview_tag;
                
                UILabel *msgIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                msgIdLabel.text = [NSString stringWithFormat:@"%d",_convRecord.msgId];
                msgIdLabel.tag = download_file_msg_id_tag;
                [alert addSubview:msgIdLabel];
                [msgIdLabel release];
                
                [alert show];
                [alert release];
            }
            else{
                [self downloadResumeFile:_convRecord.msgId andCell:nil];
            }
        }
            break;
        case state_download_stop:
        case state_download_unknow:
        {
            //当前为暂停状态，则开始下载
            int netType = [ApplicationManager getManager].netType;
            if(netType == type_gprs)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:@"%@【%@】?", [StringUtil  getLocalizableString:@"confirm_to_download_file"],_convRecord.fileNameAndSize] delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
                alert.tag = file_msg_gprs_alertview_tag;
                UILabel *msgIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                msgIdLabel.text = [NSString stringWithFormat:@"%d",_convRecord.msgId];
                msgIdLabel.tag = download_file_msg_id_tag;
                [alert addSubview:msgIdLabel];
                [msgIdLabel release];
                
                [alert show];
                [alert release];
            }
            else{
                [self downloadResumeFile:_convRecord.msgId andCell:nil];
            }
        }
            break;
        default:
            break;
    }
    
    [FileAssistantUtil configureChooseFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
}

- (NSIndexPath *)getIndexPathForCell:(UITableViewCell *)cell{
    NSIndexPath *indexPath;
    if ([self isSearchState]){
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    }
    else{
        indexPath = [orgTable indexPathForCell:cell];
    }
    return indexPath;
}

- (UITableView *)getTableView{
    UITableView *tableView;
    if ([self isSearchState]){
        tableView = self.searchDisplayController.searchResultsTableView ;
    }
    else{
        tableView = orgTable;
    }
    return tableView;
}

- (void)clickOnSelectButton:(UIButton *)sender{
    NSInteger row = [sender.titleLabel.text intValue];
    NSLog(@"clickOnSelectButton-----------------%i",row);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    UITableView *tableView = [self getTableView];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self getConvRecordByIndex:row];
    NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    if (self.chooseResults && self.chooseResults.count > 0 && !_convRecord.isChosen && (self.fromCtrl && [self.fromCtrl isEqualToString:@"agentListCtrl"])) {
        return;
    }
    if (_convRecord.isChosen) {
        //当前为选中状态，则取消选中
        _convRecord.isChosen = NO;
        [self removeConvRecordFromChooseResults:_convRecord];
        
        [sender setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
    }
    else{
        //当前为未选中，则选中
        _convRecord.isChosen = YES;
        [self addConvRecordToChooseResults:_convRecord];
        
        [sender setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
    }
    
    [self reFreshSelectState];
}

- (void)reFreshSelectState{
    allFileSize = 0;
    NSInteger selectedFileCount = [self.chooseResults count];
    CGRect _frame = orgTable.frame;
    if ([self isSearchState]) {
        
        //_frame = self.searchDisplayController.searchResultsTableView.frame;
        if (selectedFileCount > 0) {
            
            if (bottomNavibar.hidden) {
//                _frame.size.height -= 44;
//                self.searchDisplayController.searchResultsTableView.frame = _frame;
                bottomNavibar.hidden = NO;
                _frame = bottomNavibar.frame;
                _frame.origin.y = self.searchDisplayController.searchResultsTableView.frame.origin.y + self.searchDisplayController.searchResultsTableView.frame.size.height;
                bottomNavibar.frame = _frame;
                _frame = self.searchDisplayController.searchResultsTableView.frame;
                _frame.size.height -= 44;
                self.searchDisplayController.searchResultsTableView.frame = _frame;
            }
            
        }else{
            
            if (!bottomNavibar.hidden) {
                
                _frame = self.searchDisplayController.searchResultsTableView.frame;
                _frame.size.height += 44;
                self.searchDisplayController.searchResultsTableView.frame = _frame;
                bottomNavibar.hidden = YES;
            }
        }
        
    }else
    {
        if (selectedFileCount > 0) {
            
            if (bottomNavibar.hidden) {
                
                bottomNavibar.hidden = NO;
                _frame.size.height -= 44;
                orgTable.frame = _frame;
                _frame = bottomNavibar.frame;
                _frame.origin.y = orgTable.frame.origin.y + orgTable.frame.size.height;
                bottomNavibar.frame = _frame;
            }
            
        }else{
            
            if (!bottomNavibar.hidden) {
                _frame.size.height += 44;
                orgTable.frame = _frame;
                bottomNavibar.hidden = YES;
            }
        }
    }
    
    for (ConvRecord *_convRecord in self.chooseResults) {
//        if(_convRecord.send_flag == send_upload_nonexistent){
//            //已经下载本地的文件或者失效的文件，不再计算大小
//            continue;
//        }
//        else{
//            allFileSize += [_convRecord.file_size integerValue];
//        }
        allFileSize += [_convRecord.file_size integerValue];
    }
    
    if (allFileSize) {
        sendeBtn.enabled = YES;
        //NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:allFileSize countStyle:NSByteCountFormatterCountStyleFile];
        NSString *fileSizeStr = [StringUtil getDisplayFileSize:allFileSize];
        sendLab.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"chats_talksession_message_file_selected"],fileSizeStr];
        NSString *str = [NSString stringWithFormat:@"%@(%i)",[StringUtil getLocalizableString:@"send"],selectedFileCount];
        
        [sendeBtn setTitle:str forState:UIControlStateNormal];
    }
    else {
        [sendeBtn setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
        sendeBtn.enabled = NO;
        sendLab.text = @"";
    }
}

#pragma mark - UIAlertViewDelegate 协议方法实现
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //确定转发文件
//            update by shisp 
//            if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(fileListViewControllerClickOnBackBtn: withSelectFiles:)]) {
//                [_locaLFilesDelegate fileListViewControllerClickOnBackBtn:self withSelectFiles:self.chooseResults];
//            }
//            
//            //提示发送
//            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"chats_talksession_message_file_sending"]];
//            [[LCLLoadingView currentIndicator]showSpinner];
//            [[LCLLoadingView currentIndicator]show];
        }
    }
    else if (alertView.tag == file_msg_gprs_alertview_tag){
        if (buttonIndex == 1) {
            //确定下载文件
            UILabel *msgIdLabel = (UILabel*)[alertView viewWithTag:download_file_msg_id_tag];
            int msgId = msgIdLabel.text.intValue;
            [self downloadResumeFile:msgId andCell:nil];
            
            //刷新cell
            int _index = [self getArrayIndexByMsgId:msgId];
            if(_index < 0) return;
            
            UITableViewCell *cell = [self getCellAtIndex:_index];
            if(cell == nil){
                return;
            }
            
            ConvRecord *_convRecord = [self getConvRecordByIndex:_index];
            [FileAssistantUtil configureChooseFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //提示发送
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"chats_talksession_message_file_sending"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            
            if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(fileListViewControllerClickOnBackBtn: withSelectFiles:)]) {
                [_locaLFilesDelegate fileListViewControllerClickOnBackBtn:self withSelectFiles:self.chooseResults];
            }
            
        }
    }
}

#pragma mark - 获得硬件版本
-(float)deviceVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller;
{
    return 1;
}
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index
{
    ConvRecord *_convRecord = [self getConvRecordByIndex:previewFileIndex];
    FileRecord *_fileRecord = [[FileRecord alloc]init];
    _fileRecord.convRecord = _convRecord;
    return [_fileRecord autorelease];
}

#pragma mark------UISearchBarDelegate-----
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //	isSearch	=	YES;
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSLog(@"%s",__FUNCTION__);
    self.searchStr = [StringUtil trimString:searchBar.text];
    if([self.searchStr length] == 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        /*
         if (self.searchTimer && [self.searchTimer isValid])
         {
         // NSLog(@"searchTimer is valid");
         [self.searchTimer invalidate];
         }
         self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchOrg) userInfo:nil repeats:NO];
         */
    }
}

- (void)searchOrg
{
    dispatch_queue_t queue = dispatch_queue_create("search org", NULL);
    
    dispatch_async(queue, ^{
        int _type = [StringUtil getStringType:self.searchStr];
        
        
        if(_type != other_type){
            searchDeptAndEmpTag=1;
            
            NSString *_searchStr = [NSString stringWithString:self.searchStr];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

            NSArray *recordList= [_ecloud searchConvRecordsWithStr:_searchStr];
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:recordList];
            for(int i=0;i<self.searchResults.count;i++)
            {
                ConvRecord *_convRecord = [self.searchResults objectAtIndex:i];
                [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
                [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
                _convRecord.isChosen = [self isConvRecordInChooseResults:_convRecord];
            }
            
            [pool release];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view bringSubviewToFront:bottomNavibar];
            
            [self.searchDisplayController.searchResultsTableView reloadData];

            if (![self.searchResults count]) {
                [self setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"]];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    dispatch_release(queue);
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchStr length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [self showSearchTip:[StringUtil getLocalizableString:@"search_tip"]];
        return;
    }
    
    [searchBar resignFirstResponder];
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchOrg];
}

#pragma mark - UISearchDisplayDelegate协议方法
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [UIAdapterUtil customCancelButton:self];
    orgTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;

//    [bottomNavibar setFrame:CGRectMake(0, bottomNavibar.frame.origin.y+40, self.view.frame.size.width, 44.0)];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    orgTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;

    searchDeptAndEmpTag = 0;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self refleshItemArray];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self setSearchResultsTitle:@""];
    
    CGRect frame = bottomNavibar.frame;
    // changed by toxicanty 0811  44 -> 40
    frame.origin.y += 40.0;
    bottomNavibar.frame = frame;
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    if (firstSearch) {
        CGRect searchFrame = self.searchDisplayController.searchResultsTableView.frame;
        //searchFrame.size.height -= 44.0;
        self.searchDisplayController.searchResultsTableView.frame = searchFrame;
        if (IOS7_OR_LATER) {
            firstSearch = NO;
        }
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    CGRect frame = bottomNavibar.frame;
    // changed by toxicanty 0811  44 -> 40
    frame.origin.y -= 40.0;
    bottomNavibar.frame = frame;
}

- (void)refleshItemArray{
    for (ConvRecord *_convRecord in self.itemArray) {
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
        _convRecord.isChosen = [self isConvRecordInChooseResults:_convRecord];
    }
    [orgTable reloadData];
}

#pragma mark - 搜索提示
- (void)setSearchResultsTitle:(NSString *)title{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

- (void)showSearchTip:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
    [alert show];
}

#pragma mark - 隐藏tabar
-(void)hideTabBar{
    [UIAdapterUtil hideTabBar:self];
}

-(void)displayTabBar{
    [UIAdapterUtil showTabar:self];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = orgTable.frame;
    if (orgTable.frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - _searchBar.frame.size.height - BOTTOM_BAR_HEIGHT;
    
    orgTable.frame = _frame;
    [orgTable reloadData];
    
    float toolbarY = orgTable.frame.origin.y + orgTable.frame.size.height;
    _frame = bottomNavibar.frame;
    _frame.origin.y = toolbarY;
    _frame.size.width = SCREEN_WIDTH;
    
    bottomNavibar.frame = _frame;
    
    _frame = lineLab.frame;
    _frame.size.width = SCREEN_WIDTH;
    lineLab.frame = _frame;
    
    _frame = sendeBtn.frame;
    _frame.origin.x = SCREEN_WIDTH - 60;
    sendeBtn.frame = _frame;
}

@end
