//
//  ViewMoreSearchResultsController.m
//  eCloud
//
//  Created by shisuping on 17/6/23.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "ViewMoreSearchResultsController.h"
#import "DownloadFileObject.h"
#import "DownloadFileUtil.h"

#import "APPListModel.h"
#import "UploadFileModel.h"
#import "DownloadFileModel.h"
#import "FileAssistantUtil.h"
#import "FileAssistantListCell.h"
#import "RobotDisplayUtil.h"

#ifdef _GOME_FLAG_
#import "GOMEAppViewController.h"
#endif

/** 高级查询有关的代码 */
#import "AdvSearchFileCell.h"
#import "talkSessionUtil2.h"
#import "talkSessionUtil.h"

#import "WXAdvSearchUtil.h"
#import "WXAdvSearchModel.h"
#import "AdvSearchHeaderView.h"
#import "AdvSearchFooterView.h"
#import "FileRecord.h"

#import "contactViewController.h"


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



@interface ViewMoreSearchResultsController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate>
{
    UITableView *tableView;
    
    UISearchBar *theSearchBar;
    UITextField *searchTextView;

    UISearchDisplayController *searchdispalyCtrl;

    /** 用户预览的文件所在的indexpath */
    NSIndexPath *previewFileIndex;

}

@property (nonatomic,retain) NSMutableArray *itemArray;
@property (nonatomic,retain) NSMutableArray *searchResults;

@end

@implementation ViewMoreSearchResultsController
@synthesize itemArray;
@synthesize searchResults;

- (void)dealloc{
    
    [searchdispalyCtrl release];
    
    self.searchResults = nil;
    self.itemArray = nil;

    self.searchModel = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    //    会话搜索
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    theSearchBar.delegate = self;
    theSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [UIAdapterUtil removeBorderOfSearchBar:theSearchBar];
    
    // 添加返回按钮
    UIButton *goBackBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    goBackBtn.frame = CGRectMake(0, 5, 35, 35);
    [goBackBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [goBackBtn setImage:[StringUtil getImageByResName:@"goBack"] forState:(UIControlStateNormal)];
    [goBackBtn addTarget:self action:@selector(goBackClick) forControlEvents:(UIControlEventTouchUpInside)];
    [theSearchBar addSubview:goBackBtn];
    
    [self.view addSubview:theSearchBar];
    
    [theSearchBar release];
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:theSearchBar contentsController:self];
    
    searchdispalyCtrl.delegate = self;
    
    searchdispalyCtrl.searchResultsDelegate=self;
    
    searchdispalyCtrl.searchResultsDataSource = self;
    
    [UIAdapterUtil setExtraCellLineHidden:searchdispalyCtrl.searchResultsTableView];
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:searchdispalyCtrl.searchResultsTableView];
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];

    [UIAdapterUtil hideTabBar:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.searchDisplayController setActive:YES animated:YES];
        
        theSearchBar.text = self.searchModel.searchStr;
        
        self.searchResults = [NSMutableArray arrayWithArray:self.searchModel.allItemArray];
        
        [searchdispalyCtrl.searchResultsTableView reloadData];
    });

//#endif
}

- (void)goBackClick
{
    [self.searchDisplayController setActive:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    UIButton *backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        id _id = self.searchResults[indexPath.row];
        if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
            return ADV_SEARCH_HEADER_VIEW_HEIGHT;
        }
    }
    return conv_row_height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        id _id = self.searchResults[indexPath.row];
        if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
            return [[[AdvSearchHeaderView alloc]initViewWithTitle:self.searchModel.headerTitle]autorelease];
        }
        switch (self.searchModel.searchResultType) {
            case search_result_type_group:
            case search_result_type_contact:
            case search_result_type_convrecord:
            {
                static NSString *cellID = @"cellID";
                
                QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
                    [cell initSubView];
                }
                cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
                
                Conversation *conv = self.searchResults[indexPath.row];
                conv.displayTime = NO;
                conv.displayRcvMsgFlag = NO;
                [cell configSearchResultCell:conv];
                return cell;
            }
                break;
            case search_result_type_app:
            {
                static NSString *cellID = @"cellID";
                
                QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
                    [cell initSubView];
                }
                cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];

                Conversation *conv = self.searchResults[indexPath.row];

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
                    cell = [[[AdvSearchFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
                }
                
                ConvRecord *_convRecord = self.searchResults[indexPath.row];;
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
                
            default:
                break;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            id _id = self.searchResults[indexPath.row];
            if ([_id isKindOfClass:[AdvSearchHeaderView class]]) {
                return;
            }
            
            switch (self.searchModel.searchResultType) {
                case search_result_type_contact:
                case search_result_type_group:
                {
                    Conversation *conv = self.searchResults[indexPath.row];
                    [contactViewController openSearchConv:conv andCurVC:self];
                }
                    break;
                case search_result_type_convrecord:{
                    Conversation *conv = self.searchResults[indexPath.row];
                    [contactViewController openSearchConvRecords:conv andCurVC:self andSearchStr:theSearchBar.text];
                }
                    break;
                case search_result_type_filerecord:
                {
                    ConvRecord *_convRecord = self.searchResults[indexPath.row];
                    
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
#ifdef _GOME_FLAG_
                    Conversation *conv = self.searchResults[indexPath.row];
                    [GOMEAppViewController openGomeApp:conv.appModel andCurVC:self];
#endif
                }
                default:
                    break;
            }       
        }
        
     }
}

- (void)adjustUISearchBarTextField:(UIView *)view
{
#ifdef _GOME_FLAG_
    for (UIView *subview in view.subviews)
    {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UISearchBarTextField"])
        {
            CGRect rect = subview.frame;
            rect.origin.y = 8;
            rect.origin.x   = 37;
            rect.size.width = SCREEN_WIDTH - 37-50;
            rect.size.height = 28;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                subview.frame = rect;
            });
            
            return;
        }
        [self adjustUISearchBarTextField:subview];
    }
#endif
}


#pragma mark =======UISearchDisplayDelegate协议方法========
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.scrollsToTop = YES;
    [UIAdapterUtil customCancelButton:self];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.scrollsToTop = NO;
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self processFileRecords:self.searchResults];
    [self.searchResults removeAllObjects];
    self.searchResults = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [UserTipsUtil setSearchResultsTitle:@"" andCurrentViewController:self];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    CGRect _frame = CGRectMake(0, 0, tableView.frame.size.width, SCREEN_HEIGHT - 64);
    tableView.frame = _frame;
    
    [self adjustUISearchBarTextField:theSearchBar];
}


#pragma mark ========UISearchBarDelegate实现========
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    id bottomVC = self.navigationController.viewControllers[0];
    if ([bottomVC isKindOfClass:[contactViewController class]]) {
        contactViewController *contactView = (contactViewController *)bottomVC;
        [contactView cancelSearchStatus];
    }
    [self goBackClick];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //搜索框的文本有变化，但文本框没有内容时，显示所有内容，当有内容时则显示
    if (searchBar.text.length == 0) {
        [self processFileRecords:self.searchResults];
        
        [self.searchResults removeAllObjects];
        self.searchResults = nil;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

//点击搜索按钮时才开始搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    searchBar.text = [StringUtil trimString:searchBar.text];
    
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"searching"]];
    
    [self performSelector:@selector(searchAction) withObject:nil afterDelay:0.01];

}

- (void)searchAction{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    switch (self.searchModel.searchResultType) {
        case search_result_type_contact:
        {
            [[WXAdvSearchUtil getUtil]queryContact:theSearchBar.text andSearchResults:tempArray];
        }
            break;
        case search_result_type_group:
        {
            [[WXAdvSearchUtil getUtil]queryGroupConv:theSearchBar.text andSearchResults:tempArray];
        }
            break;
        case search_result_type_convrecord:
        {
            [[WXAdvSearchUtil getUtil]queryConvRecord:theSearchBar.text andSearchResults:tempArray];
        }
            break;
        case search_result_type_filerecord:
        {
            [[WXAdvSearchUtil getUtil]queryFileRecord:theSearchBar.text andSearchResults:tempArray];
        }
            break;
        case search_result_type_app:
        {
            [[WXAdvSearchUtil getUtil]queryGomeApp:theSearchBar.text andSearchResults:tempArray];
        }
            break;
        default:
            break;
    }
    
    if (tempArray.count) {
        WXAdvSearchModel *_model = tempArray[0];
        self.searchModel = _model;
        
        if (_model.allItemArray.count) {
            self.searchResults = [NSMutableArray arrayWithArray:_model.allItemArray];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil hideLoadingView];

        if (![self.searchResults count]) {
            [UserTipsUtil setSearchResultsTitle:[StringUtil getLocalizableString:@"no_search_result"] andCurrentViewController:self];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    });
}


- (void)processFileRecords:(NSArray *)searchResultsArray{
    for (id tempId in searchResultsArray) {
        if ([tempId isKindOfClass:[ConvRecord class]]) {
            ConvRecord *_convRecord = (ConvRecord *)tempId;
            //解除下载的delegate
            if (_convRecord.downloadRequest && _convRecord.downloadRequest.isExecuting) {
                _convRecord.downloadRequest.downloadProgressDelegate = nil;
                _convRecord.downloadRequest.delegate = nil;
            }
        }
    }
}

- (NSIndexPath *)getIndexPathByMsgId:(int)msgId
{
    int row = 0;

    for (id tempId in self.searchResults) {
        if ([tempId isKindOfClass:[ConvRecord class]]) {
            ConvRecord *_convRecord = (ConvRecord *)tempId;
            if (_convRecord.msgId == msgId) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                return indexPath;
            }
        }
        row++;
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
    ConvRecord *_convRecord = self.searchResults[indexPath.row];
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
    ConvRecord *convRecord = self.searchResults[previewFileIndex.row];
    FileRecord *_fileRecord = [[FileRecord alloc]init];
    _fileRecord.convRecord = convRecord;
    return [_fileRecord autorelease];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustUISearchBarTextField:theSearchBar];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    CGRect _frame = tableView.frame;
//    if (_frame.size.width == SCREEN_WIDTH) {
//        return;
//    }
//    
//    _frame.size.width = SCREEN_WIDTH;
//    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
//    
//    tableView.frame = _frame;
//    
//    [tableView reloadData];
    
}


@end
