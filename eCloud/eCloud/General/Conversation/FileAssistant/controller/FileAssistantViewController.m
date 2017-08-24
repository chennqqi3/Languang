//
//  FileAssistantViewController.m
//  eCloud
//
//  Created by Pain on 15-1-5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FileAssistantViewController.h"
#import "RobotDisplayUtil.h"
#import "UserInterfaceUtil.h"
#import "eCloudUser.h"
#import "ApplicationManager.h"
#import "CustomQLPreviewController.h"

#import "FilesOfTime.h"
#import "TimeUtil.h"

#import "EncryptFileManege.h"

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

#import "FileAssistantDOA.h"
#import "FileAssistantUtil.h"
#import "FileAssistantListCell.h"
#import "DownloadFileModel.h"
#import "UploadFileModel.h"
#import "IOSSystemDefine.h"

#ifdef _XIANGYUAN_FLAG_
#import "FileAssistantRecordDOA.h"
#endif

#define download_file_msg_id_tag (101)

#define file_msg_gprs_alertview_tag (102)
#define file_msg_gprs_edit_alertview_tag (103)
#define file_msg_delete_alertview_tag (104)

#define BOTTOM_BAR_HEIGHT (44.0)

@interface FileAssistantViewController ()<QLPreviewControllerDataSource,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
    
    UITableView *orgTable;
    BOOL editing; //判断是否批量状态
    UIView *bottomNavibar;
    UIButton *addButton;
    
    BOOL isSearch;

    
    UISearchBar *_searchBar;
    UIButton *searchCancelBtn;
    UITextView *searchTextView;
    int searchDeptAndEmpTag;
    UIButton *backgroudButton;
    
    UISearchDisplayController * searchdispalyCtrl;
    
    eCloudDAO *_ecloud;
    int totalCount; //会话的总记录个数
    int loadCount; //已经加载的记录个数
    int limit; //查询会话时用到的参数
    int offset;
    UIActivityIndicatorView *loadingIndic;
    bool isLoading;
    
    NSIndexPath *previewFileIndex;//当前预览的文件索引
    
    UILabel *lineLab;
    UIView *_emptyFileView;
    UILabel *tipLabel;
    UIImageView *tipImageView;
    UILabel *loadMoreText;
    CGFloat _tableViewLineX;

}

@property (nonatomic,retain)NSMutableArray *searchResults;
@property (nonatomic,retain)NSMutableArray *chooseResults;
@property (nonatomic,retain) NSString *searchStr;


@property(nonatomic,assign)NSMutableArray *itemArray;

@property(nonatomic,retain)NSString *editMsgId; //复制或删除对应的消息记录
@property(nonatomic,retain)ConvRecord *editRecord;
@property(nonatomic,retain)NSIndexPath *editRow; //编辑的记录的行号

@property(nonatomic,retain) ConvRecord *forwardRecord; //转发的聊天记录

//按照时间进行分组的列表
@property (nonatomic,retain) NSMutableArray *itemArrayGroupByTime;

@end

@implementation FileAssistantViewController
@synthesize editMsgId;
@synthesize editRecord;
@synthesize editRow;
@synthesize forwardRecord;
@synthesize convId;
@synthesize fileDisplayType;
@synthesize itemArrayGroupByTime;

- (id)init
{
    self = [super init];
    if (self) {
        self.fileDisplayType = file_display_type_assistant;
    }
    return self;
}

- (void)dealloc{
    
    NSLog(@"%s ",__FUNCTION__);
    
    [searchdispalyCtrl release];
    searchdispalyCtrl = nil;
    
    for (ConvRecord *_convRecord in self.itemArray) {
        //解除下载的delegate
        if (_convRecord.download_flag == state_downloading && _convRecord.downloadRequest) {
            _convRecord.downloadRequest.downloadProgressDelegate = nil;
            _convRecord.downloadRequest.delegate = nil;
        }
        
        if (_convRecord.uploadRequest && _convRecord.send_flag == state_uploading) {
            //解除上传delegate
            _convRecord.uploadRequest.uploadProgressDelegate = nil;
        }
    }
    
    self.editRow = nil;
    
    self.convId = nil;
    
    [self.itemArray removeAllObjects];
    self.itemArray = nil;
    
    self.itemArrayGroupByTime = nil;
    
    [self.chooseResults removeAllObjects];
    self.chooseResults = nil;
    
    [self.editMsgId release];
    self.editMsgId = nil;
    
    [self.editRecord release];
    self.editRecord = nil;
    
    //监听系统菜单显示，隐藏
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FILE_ASSISTANT_REFRESH object:nil];
    
    [super dealloc];
}
//- (void)initViewFileEmpty
//{
//    _emptyFileView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    CGFloat imageViewWidth = 90;
//    CGFloat imageViewX = ([UIScreen mainScreen].bounds.size.width - imageViewWidth) / 2;
//    CGRect imageRect = CGRectMake(imageViewX, 80.5, imageViewWidth, 107.8);
//    UIImageView *emptyFileImageView = [[UIImageView alloc] initWithFrame:imageRect];
//    emptyFileImageView.backgroundColor = [UIColor greenColor];
//    [_emptyFileView addSubview:emptyFileImageView];
//    
//    
//    CGFloat labelWidth = 255.5;
//    CGFloat x = ([UIScreen mainScreen].bounds.size.width - labelWidth) / 2;
//    CGRect labelRect = CGRectMake(x, 204, labelWidth, 36);
//    UILabel *emptyFileLabel = [[UILabel alloc] initWithFrame:labelRect];
//    emptyFileLabel.text = @"暂时没有任何文件喔~\n你可以尝试从电脑发送文件到手机进行保存";
//    emptyFileLabel.textAlignment = NSTextAlignmentCenter;
//    emptyFileLabel.textColor = UIColorFromRGB(0xD0D0D0);
//    emptyFileLabel.numberOfLines = 0;
//    emptyFileLabel.font = [UIFont systemFontOfSize:13];
//    [_emptyFileView addSubview:emptyFileLabel];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    _ecloud = [eCloudDAO getDatabase] ;
    
    editing = NO;
    isSearch = NO;
    
    self.itemArray = [[NSMutableArray alloc] init];
    self.chooseResults = [[NSMutableArray alloc] init];
    
    self.itemArrayGroupByTime = [NSMutableArray array];

    isLoading = false;
    
    //右边按钮
    addButton = [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"edit"] andTarget:self andSelector:@selector(addButtonPressed:)];
    [self initSearchBar];

#ifdef _LANGUANG_FLAG_
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
  
#endif
//    int tableH = 460 - 80;
////    if(iPhone5)
////        tableH = tableH + i5_h_diff;
//    // 0810 适配
//    if(iPhone5){
//        tableH = tableH + i5_h_diff;
//    }else if(IS_IPHONE_6P){
//        tableH = tableH + i5_h_diff + 168;
//    }else if (IS_IPHONE_6){
//        tableH = tableH + i5_h_diff + 99;
//    }
    
    float tableH = (self.view.frame.size.height + self.view.frame.origin.y) - ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height) - _searchBar.frame.size.height;

    orgTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, _searchBar.frame.size.height, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:orgTable];
    [orgTable setDelegate:self];
    [orgTable setDataSource:self];
    orgTable.scrollsToTop = YES;
    orgTable.backgroundColor=[UIColor clearColor];
 
    [self.view addSubview:orgTable];
    [orgTable release];
    
    
    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(orgTable.frame.origin.x, orgTable.frame.origin.y, orgTable.frame.size.width, orgTable.frame.size.height)];
    [backgroudButton addTarget:self action:@selector(dismissKeybordByClickBackground) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backgroudButton];
    backgroudButton.hidden=YES;
    [backgroudButton release];
    [orgTable reloadData];
    
    [UIAdapterUtil setExtraCellLineHidden:orgTable];
    [UIAdapterUtil setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
    
    [self addBottomBar];
    
    //批量转发刷新页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFileList:) name:FILE_ASSISTANT_REFRESH object:nil];
    
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    longPress.minimumPressDuration = 0.5;
    [orgTable addGestureRecognizer:longPress];
    [longPress release];
    
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    longPress2.minimumPressDuration = 0.5;
    [self.searchDisplayController.searchResultsTableView  addGestureRecognizer:longPress2];
    [longPress2 release];
    
    //	监听系统菜单显示，隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuDisplay) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuHide) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    
#define labelWidth 280
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

- (void)refreshFileList:(NSNotification *)notification{
    if (editing) {
         [self addButtonPressed:addButton];
    }
    
    if (isSearch) {
        searchdispalyCtrl.active = NO;
        isSearch = NO;
    }
    
    [self.itemArray removeAllObjects];
//    [self initData];
}

//- (void)setViewEmpertyFile:(int)fileCount
//{
//    if(fileCount == 0)
//    {
//        [self.view addSubview:_emptyFileView];
//        [_searchBar removeFromSuperview];
//        [addButton setHidden:YES];
//        [orgTable setHidden:YES];
//    }
//    else
//    {
//        [_emptyFileView removeFromSuperview];
//    }
//}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (editing) {
        [addButton setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        [self setNavigationItemTitle:[NSString stringWithFormat:@"已选%d个",(int)self.chooseResults.count]];
    }
    else{
        [addButton setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
        [self setNavigationItemTitle:[StringUtil getAppLocalizableString:@"me_file_assistant"]];
    }
//    _searchBar.placeholder=[StringUtil getLocalizableString:@"file_search_tip"];
    _searchBar.placeholder=[StringUtil getLocalizableString:@"请输入文件名"];
    [self initData];
    [self hideTabBar];
    //[self setViewEmpertyFile:(int)self.itemArray.count];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [searchTextView resignFirstResponder];
}
- (void)setNavigationItemTitle:(NSString *)title
{
    self.title = title;
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
    
    searchdispalyCtrl = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    searchdispalyCtrl.active = NO;
    searchdispalyCtrl.delegate = self;
    searchdispalyCtrl.searchResultsDelegate=self;
    searchdispalyCtrl.searchResultsDataSource = self;
    [UIAdapterUtil setPropertyOfTableView:searchdispalyCtrl.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
}

- (void)addBottomBar{
    //自定义底部导航栏
//    int toolbarY = self.view.frame.size.height - 44-25.0;
//    if (IOS7_OR_LATER)
//    {
//        toolbarY = toolbarY - 20;
//    }

    float toolbarY = orgTable.frame.origin.y + orgTable.frame.size.height - BOTTOM_BAR_HEIGHT;
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, 46.0)];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    bottomNavibar.hidden = YES;
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    for (int i = 0; i < 3; i ++) {
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenW/3 *i, 0.0, screenW/3-1, 46.0)];
        editBtn.backgroundColor = [UIColor clearColor];
        editBtn.tag = file_edit_button_tag + i;
        [editBtn setTitleColor:[UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0] forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        editBtn.titleLabel.font=FILE_ASSISTANT_BOTTOMBAR_BTN_FONT;
        [editBtn addTarget:self action:@selector(clickOnBottomNavibarBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bottomNavibar addSubview:editBtn];
        [editBtn release];
        
        if (i == 0) {
            
            [editBtn setTitle:[StringUtil getLocalizableString:@"delete"] forState:UIControlStateNormal];
        }
        else if (i == 1){
            [editBtn setTitle:[StringUtil getLocalizableString:@"forward"] forState:UIControlStateNormal];
        }
        else{
            [editBtn setTitle:[StringUtil getLocalizableString:@"download"] forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 按钮方法实现
-(void) clickOnBottomNavibarBtn:(UIButton *)sender{
    NSInteger index = sender.tag - file_edit_button_tag;
    NSLog(@"clickOnEditBtn---------%li",(long)index);
    if ([self.chooseResults count]) {
        [self configBtnClickOnBottomNavibar:sender];
        if (0 == index) {
            //删除
            ConvRecord *_convRecord = [self.chooseResults objectAtIndex:0];
            NSInteger _count = [self.chooseResults count];
            NSString *_message;
            
            if (_count > 1) {
                _message = [NSString stringWithFormat:[StringUtil  getLocalizableString:@"confirm_delete_meaasge"], _convRecord.file_name,_count];
            }
            else{
                _message = [NSString stringWithFormat:@"%@", _convRecord.file_name];
            }
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil  getLocalizableString:@"confirm_delete"] message:_message delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
            alert.tag = file_msg_delete_alertview_tag;
            [alert show];
            [alert release];
            
                    }
        else if (1 == index){
            //转发
            [self Forwarding:sender];
        }
        else{
            //下载
            int netType = [ApplicationManager getManager].netType;
            if(netType == type_gprs)
            {
                NSString *_title = [NSString stringWithFormat:[StringUtil  getLocalizableString:@"download_traffic_tips"],[self getChooseResultsDownloadTotalSize]];
                NSString *_message = [StringUtil  getLocalizableString:@"download_gprs_tips"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
                alert.tag = file_msg_gprs_edit_alertview_tag;
                [alert show];
                [alert release];
            }
            else{
                [self downloadAction:sender];
            }

        }
    }
}
- (void)configBtnClickOnBottomNavibar:(UIButton *)changeBtn
{
    UIButton *unChangeBtn1 = nil;
    UIButton *unChangeBtn2 = nil;
    switch (changeBtn.tag - file_edit_button_tag) {
        case 0:
            unChangeBtn1 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 1];
            unChangeBtn2 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 2];
            break;
        case 1:
            unChangeBtn1 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 0];
            unChangeBtn2 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 2];
            break;
        case 2:
            unChangeBtn1 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 0];
            unChangeBtn2 = (UIButton *)[bottomNavibar viewWithTag:file_edit_button_tag + 1];
            break;
        default:
            break;
    }
    changeBtn.backgroundColor = UIColorFromRGB(0x2481FC);
    unChangeBtn1.backgroundColor = [UIColor clearColor];
    unChangeBtn2.backgroundColor = [UIColor clearColor];
    [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [unChangeBtn1 setTitleColor:UIColorFromRGB(0x2481FC) forState:UIControlStateNormal];
    [unChangeBtn2 setTitleColor:UIColorFromRGB(0x2481FC) forState:UIControlStateNormal];
}
- (void)addButtonPressed:(UIButton *) sender{
    [searchTextView resignFirstResponder];
    if (editing) {
        [sender setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
        editing = NO;
//        非编辑状态
        [self setChooseResultsDesSelect];
        [self.chooseResults removeAllObjects];
    }
    else{
        //编辑状态
        [sender setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        editing = YES;

    }
    [self configEditingState:editing];
    [orgTable reloadData];
}

-(void)dismissKeybordByClickBackground
{
    [_searchBar resignFirstResponder];
    backgroudButton.hidden=YES;
}

#pragma mark - 长按菜单
- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        UITableView *tableView = [self getTableView];
        CGPoint p = [gestureRecognizer locationInView:tableView];
        [self prepareToShowCopyMenu:p];
    }
}

-(void)prepareToShowCopyMenu:(CGPoint)p{
    UITableView *tableView = [self getTableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    NSString *pointY=[NSString stringWithFormat:@"%0.0f",p.y];
    if(indexPath){
        //点击位置对应的记录下标
        int row = [indexPath row];
        ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
        
        self.editMsgId = [StringUtil getStringValue:_convRecord.msgId];
        self.editRecord = _convRecord;
        self.editRow = indexPath;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self becomeFirstResponder];
        [self performSelector:@selector(showCopyMenu:)withObject:[NSDictionary dictionaryWithObjectsAndKeys:cell,@"LONG_CLICK_CELL",pointY,@"pointY", nil] afterDelay:0.05f];
    }
}

- (void)showCopyMenu:(id)dic{
    UITableViewCell *longClickCell =  (UITableViewCell*)[(NSDictionary *)dic objectForKey:@"LONG_CLICK_CELL"];
    UIImageView *bubbleView = (UIImageView*)longClickCell.contentView;
    NSString *pointY=[(NSDictionary*)dic objectForKey:@"pointY"];
    float copyX = bubbleView.frame.origin.x + bubbleView.frame.size.width/2;
    int copyY=[pointY intValue]-longClickCell.frame.origin.y;
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"delete"] action:@selector(deleteFileAction:)];
    UIMenuItem *menuItem2 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"forward"] action:@selector(forwardFileAction:)];
    UIMenuItem *menuItem3 = [[UIMenuItem alloc] initWithTitle:[StringUtil getLocalizableString:@"download"] action:@selector(downloadFileAction:)];
    
    [menu setMenuItems:[NSArray arrayWithObjects:menuItem,menuItem2,menuItem3,nil]];
    [menuItem release];
    [menuItem2 release];
    [menuItem3 release];
    
    [menu setTargetRect: CGRectMake(copyX , copyY, 1, 1) inView: longClickCell];
    [menu setMenuVisible: YES animated: YES];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    //编辑状态下无快捷菜单
    if (editing && ![self isSearchState]) {
        return NO;
    }
    
    
    BOOL retValue = NO;
    
    if (action == @selector(deleteFileAction:))
    {
        if(self.editRecord && self.editRecord.msg_type != type_group_info)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else if (action == @selector(forwardFileAction:)){
        if(self.editRecord && (self.editRecord.msg_type == type_file && editRecord.download_flag != state_download_nonexistent))
        {
            return YES;
        }
        else
        {
            return NO;
        }
        retValue = NO;
    }
    else if (action == @selector(downloadFileAction:)){
        if(self.editRecord && self.editRecord.msg_type == type_file)
        {
            if (self.editRecord.isFileExists) {
                retValue = NO;
            }
            else if(self.editRecord.isDownLoading) {
                retValue = NO;
            }
            else if (editRecord.download_flag == state_download_nonexistent){
                //文件不存在，不显示下载快捷菜单
                retValue = NO;
            }
            else{
                retValue = YES;
            }
        }
        else{
            retValue = NO;
        }
    }
    else{
        retValue = NO;
    }
    
    return retValue;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)deleteFileAction:(id)sender{
    if (self.editRecord) {
        ConvRecord *_convRecord = self.editRecord;
        NSString *deleteMsgId = [StringUtil getStringValue:_convRecord.msgId];
//        文件助手数据库
#ifdef _XIANGYUAN_FLAG_
        [[FileAssistantRecordDOA getFileDatabase]deleteFileRecordOneMsg:deleteMsgId];
#else
        [_ecloud deleteOneMsg:deleteMsgId];

#endif
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:deleteMsgId.intValue];
        
//      查询结果 也有长按操作 先删除长按
        if ([self isSearchState]){
            int _index = [self getSearchResulArrayIndexByMsgId:deleteMsgId.intValue];
            if(_index >= 0){
                [self.searchResults removeObjectAtIndex:_index];
            }
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
//        如果是长按删除了某一条记录
        if ([self isFileListGroupByTime]) {
            [self findAndDeleteFromItemArrayGroupByTimeWithMsgId:deleteMsgId.intValue];
        }else{
            int _index = [self getItemArrayIndexByMsgId:deleteMsgId.intValue];
            if(_index >= 0){
                [self.itemArray removeObjectAtIndex:_index];
            }
        }
        
       
        
        [orgTable reloadData];
    }
}

- (void)forwardFileAction:(id)sender{
    if (self.editRecord) {
        self.forwardRecord = self.editRecord;
        [self openForwardPage];
    }
}

- (void)openForwardPage{
    ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc] initWithConvRecord:nil];
    forwarding.isComeFromFileAssistant = YES;
    forwarding.forwardRecordsArray = [NSArray arrayWithObject:self.forwardRecord];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    [self presentViewController:nav animated:YES completion:nil];
#else
    [UIAdapterUtil presentVC:nav];
#endif
    
//    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (void)downloadFileAction:(id)sender{
    if (self.editRecord) {
        ConvRecord *_convRecord = self.editRecord;
        int netType = [ApplicationManager getManager].netType;
        if(netType == type_gprs)
        {
            NSString *fileSize = [StringUtil getDisplayFileSize:[_convRecord.file_size integerValue]];
            
            NSString *_title = [NSString stringWithFormat:[StringUtil  getLocalizableString:@"download_traffic_tips"],fileSize];
            NSString *_message = [StringUtil  getLocalizableString:@"download_gprs_tips"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
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
            
            //刷新cell
            NSIndexPath *indexPath = [self getIndexPathByMsgId:_convRecord.msgId];
            if (!indexPath) {
                return;
            }
            UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
            if(cell == nil){
                return;
            }
            
            [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:NO];
            
        }
        
    }
}

-(void)menuDisplay
{
    if(self.editMsgId)
    {
        UITableView *tableView = [self getTableView];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.editRow];
        cell.selected = YES;
    }
}

-(void)menuHide
{
    if(self.editMsgId)
    {
        UITableView *tableView = [self getTableView];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.editRow];
        cell.selected = NO;
        self.editRecord = nil;
    }
    self.editMsgId = nil;
    self.editRecord = nil;
}


#pragma mark ============================批量操作============================
-(void)Forwarding:(id)sender //转发
{
    [self openRecentContacts];
}


- (void)downloadAction:(id)sender{
    for (ConvRecord *_convRecord in self.chooseResults) {
        if(_convRecord.msg_type == type_file){
            if(_convRecord.download_flag == state_downloading || _convRecord.download_flag == state_download_success || _convRecord.send_flag == send_upload_nonexistent){
                //正在下载或者已经下载本地的文件，直接返回
                continue;
            }
            else{
                [self downloadResumeFile:_convRecord.msgId andCell:nil];
            }
        }
    }
    
    [self addButtonPressed:addButton];
}

-(void)deleteAction:(id)sender{
    for (ConvRecord *_convRecord in self.chooseResults) {
        NSString *deleteMsgId = [StringUtil getStringValue:_convRecord.msgId];
//        文件助手数据库
#ifdef _XIANGYUAN_FLAG_
        [[FileAssistantRecordDOA getFileDatabase]deleteFileRecordOneMsg:deleteMsgId];
#else
        [_ecloud deleteOneMsg:deleteMsgId];
        
#endif
        
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:deleteMsgId.intValue];
        
//        查询结果没有批量 因此只有分组和文件助手这两种情况
        if ([self isFileListGroupByTime]) {
            [self findAndDeleteFromItemArrayGroupByTimeWithMsgId:deleteMsgId.intValue];
        }else{
            int _index = [self getArrayIndexByMsgId:deleteMsgId.intValue];
            if (_index >= 0) {
                [self.itemArray removeObjectAtIndex:_index];
            }
        }
    }
    
    totalCount = [self getFileConvRecordsCount];
    [self addButtonPressed:addButton];
}

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

- (void)setChooseResultsDesSelect{
    for (ConvRecord *convRecord in self.chooseResults) {
        convRecord.isChosen = NO;
    }
}

- (NSString *)getChooseResultsForwardTotalSize{
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

- (NSString *)getChooseResultsDownloadTotalSize{
    NSString *fileSize;
    int _size = 0;
    for (ConvRecord *_convRecord in self.chooseResults) {
        if(_convRecord.download_flag == state_downloading || _convRecord.download_flag == state_download_success || _convRecord.send_flag == send_upload_nonexistent){
            //正在下载或已经下载本地的文件或者失效的文件，不再计算大小
            continue;
        }
        else{
            _size += [_convRecord.file_size intValue];
        }
    }
    fileSize = [StringUtil getDisplayFileSize:_size];
    return fileSize;
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case file_msg_gprs_alertview_tag:
        {
            //单个文件下载
            if (buttonIndex == 1) {
                UILabel *msgIdLabel = (UILabel*)[alertView viewWithTag:download_file_msg_id_tag];
                int msgId = msgIdLabel.text.intValue;
                [self downloadResumeFile:msgId andCell:nil];
                
                //刷新cell
                NSIndexPath *indexPath = [self getIndexPathByMsgId:msgId];
                if(!indexPath) return;
                
                UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
                if(cell == nil){
                    return;
                }
                
                ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
                [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:NO];
            }
        }
            break;
        case file_msg_gprs_edit_alertview_tag:
        {
            //批量下载
            if (buttonIndex == 1) {
                [self downloadAction:nil];
            }
        }
            break;
        case file_msg_delete_alertview_tag:
        {
            //删除
            if (buttonIndex == 1) {
                [self deleteAction:nil];
            }
        }
            break;
            
        default:
            break;
    }
}

//打开最近的联系人，用来转发
- (void)openRecentContacts{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (ConvRecord *_convRecord in self.chooseResults) {
        if(_convRecord.msg_type == type_file){
            if( _convRecord.send_flag == send_upload_nonexistent){
                //文件转发过滤已过期文件
                continue;
            }
            else{
                [tempArray addObject:_convRecord];
            }
        }
    }
    
    if ([tempArray count]) {
        ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc] initWithConvRecord:nil];
        forwarding.isComeFromFileAssistant = YES;
        forwarding.forwardRecordsArray = tempArray;
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
        [forwarding release];
        nav.navigationBar.tintColor=[UIColor blackColor];
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        [self presentViewController:nav animated:YES completion:nil];
#else
        [UIAdapterUtil presentVC:nav];
#endif
//        [self presentModalViewController:nav animated:YES];
        [nav release];
    }
    else{
        //提示用户选择有效的文件转发
        NSString *_message = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"file_forward_expired_tips"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
        [alert show];
        [alert release];
    }
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

        NSIndexPath *indexPath = [self getIndexPathByMsgId:msgId.intValue];

        UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
        
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
    
    NSIndexPath *indexPath = [self getIndexPathByMsgId:msgId];
    if (!indexPath) {
        return;
    }
    UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
    
//    if(cell == nil){
//        cell = _cell;
//    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
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
    
    NSIndexPath *indexPath = [self getIndexPathByMsgId:_msgId.intValue];
    if (!indexPath) {
        ConvRecord *_convRecord = [self getConvRecordByMsgId:_msgId];
        [talkSessionUtil transferFile:_convRecord];
        if( _convRecord.msg_type == type_file){
            UIProgressView *progressView =(UIProgressView*)request.downloadProgressDelegate;
            [talkSessionUtil hideProgressView:progressView];
        }
        return;
        
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    [talkSessionUtil transferFile:_convRecord];
    
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    
    UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
    
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
        [self reloadRowAtIndexPath:indexPath];
        
        //提示文件过期
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
            [self reloadRowAtIndexPath:indexPath];
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
    
    NSIndexPath *indexPath = [self getIndexPathByMsgId:_msgId.intValue];
    
    [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_msgId.intValue];
    
    if(request.error.code == ASIRequestTimedOutErrorType)
    {
        if (indexPath) {
            ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
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
    
    if (!indexPath) {
        return;
    }
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    _convRecord.isDownLoading = false;
    _convRecord.downloadRequest = nil;
    _convRecord.tryCount = 0;
    
    UITableViewCell *cell = [self getCellAtIndexPath:indexPath];
    
    if (_convRecord.msg_type == type_file) {
        int uploadstate = state_download_failure;
        [[FileAssistantDOA getDatabase] updateDownloadStateWithDownloadid:_msgId withState:uploadstate];
        _convRecord.download_flag = uploadstate;
        
        //文件下载失败,显示失败按钮
        [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:editing];
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
        for (ConvRecord *_convRecord in self.itemArray) {
            if (_convRecord.msg_type == type_file && [_convRecord.msg_body isEqualToString:url]) {
                _convRecord.send_flag = send_upload_nonexistent;
            }
        }
    }
    
    [orgTable reloadData];
}


#pragma mark -  根据消息id获取纪录
- (ConvRecord *)getConvRecordByIndex:(NSInteger)index{
    ConvRecord *_convRecord = nil;
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
    UITableViewCell *cell = nil;
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
    BOOL isSearching = NO;
    if (isSearch)//([self.searchResults count])
    {
        isSearching = YES;
    }
    return isSearching;
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

#pragma mark 根据msgId找到对应的indexPath
-(NSInteger)getArrayIndexByMsgId:(int)msgId
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

-(int)getSearchResulArrayIndexByMsgId:(int)msgId
{
    for(int i = self.searchResults.count - 1;i>=0;i--)
    {
        ConvRecord *_convRecord = [self.searchResults objectAtIndex:i];
        if(_convRecord.msgId == msgId)
        {
            return i;
        }
    }
    
    return -1;
}

-(int)getItemArrayIndexByMsgId:(int)msgId
{
    for(int i = self.itemArray.count - 1;i>=0;i--)
    {
        ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
        if(_convRecord.msgId == msgId)
        {
            return i;
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
    if ([self isFileListGroupByTime]) {
        return [_ecloud getFileConvRecordsCountWithConvId:self.convId];
    }
    return [_ecloud getFileConvRecordsCount];
}

- (NSArray *)getFileConvRecordsWithLimit:(int)_limit andOffset:(int)_offset{
    NSArray *recordList;
    if ([self isFileListGroupByTime]) {
        recordList = [_ecloud getFileConvRecordsWithConvId:self.convId WithLimit:_limit andOffset:_offset];
//        需要把数据进行分组
//        表格的数据源就是这个分组
        for (ConvRecord *_convRecord in recordList) {
            int msgTime = _convRecord.msg_time.intValue;
            NSString *curTime = [TimeUtil getMonthOfTime:msgTime];
            
            //第一个
            BOOL needCreateNew = NO;
            
            if (self.itemArrayGroupByTime.count == 0) {
                needCreateNew = YES;
            }else{
                //            取出上一个，如果月份一样，则把这个record加到数组里去
                FilesOfTime *filesOfTime = self.itemArrayGroupByTime[self.itemArrayGroupByTime.count - 1];
                if ([curTime isEqualToString:filesOfTime.curTime]) {
                    [filesOfTime.filesArray addObject:_convRecord];
                }else{
                    //            如果不一样，则生成一个新的对象
                    needCreateNew = YES;
                }
            }
            
            if (needCreateNew) {
                FilesOfTime *filesOfTime = [[[FilesOfTime alloc]init]autorelease];
                filesOfTime.curTime = curTime;
                filesOfTime.filesArray = [NSMutableArray arrayWithObject:_convRecord];
                
                [self.itemArrayGroupByTime addObject:filesOfTime];
            }
        }
    }else{
//        文件助手数据库
#ifdef _XIANGYUAN_FLAG_
        
        recordList = [_ecloud getFileAssistantConvRecordsWithLimit:limit andOffset:offset];
#else
        recordList=[_ecloud getFileConvRecordsWithLimit:limit andOffset:offset];

#endif
        
    }
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
    
    loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0, 40.0f)];
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
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self isFileListGroupByTime]) {
        FilesOfTime *filesOfTime = self.itemArrayGroupByTime[section];
        
        UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIAdapterUtil getTableCellContentWidth], 30)];
        _label.text = [NSString stringWithFormat:@"  %@",filesOfTime.curTime];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textColor = [UIAdapterUtil getCustomGrayFontColor];
        _label.tag = section;
        
        _label.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(extendOrShrink:)]autorelease];
        
        [_label addGestureRecognizer:singleTap];
        
        return [_label autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isFileListGroupByTime]) {
        return 30;
    }
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isFileListGroupByTime]) {
        return self.itemArrayGroupByTime.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.itemArray.count == 0) {
        
        _searchBar.hidden = YES;
        addButton.hidden = YES;
        tipImageView.hidden = NO;
        tipLabel.hidden = NO;
        loadMoreText.text = @"";
        
    }else{
        
        _searchBar.hidden = NO;
        addButton.hidden = NO;
    }
    
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.searchResults count];
    }
    else{
        if ([self isFileListGroupByTime]) {
            FilesOfTime *filesOfTime = self.itemArrayGroupByTime[section];
            if (filesOfTime.isExtend) {
                return filesOfTime.filesArray.count;
            }
            return 0;
        }
        return [self.itemArray count];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return file_cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editing){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *selectButton = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
        [self clickOnSelectButton:selectButton];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        static NSString *CellName = @"searchCellName";
        FileAssistantListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
        if (cell == nil){
            cell = [[[FileAssistantListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        ConvRecord *_convRecord = (ConvRecord *)[self.searchResults objectAtIndex:[indexPath row]];
        [cell configureCell:cell andConvRecord:_convRecord];
        [cell configureCell:cell editState:NO];
        
        [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:NO];
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
        
        UIButton *downLoadButton = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
        [downLoadButton addTarget:self action:@selector(clickOnDownLoadButton:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *downLoadlab = (UILabel *)[downLoadButton viewWithTag:file_download_button_lab_tag];
        downLoadlab.text = [NSString stringWithFormat:@"%i,%i",[indexPath section],[indexPath row]];
        UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
        _tableViewLineX = fileNameLab.frame.origin.x;
        return cell;
    }
    else{
        static NSString *CellName = @"CellName";
        FileAssistantListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
        if (cell == nil){
            cell = [[[FileAssistantListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
        
        [cell configureCell:cell andConvRecord:_convRecord];
        [cell configureCell:cell editState:editing];
        
        [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:editing];
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
        
        if (editing) {
            //批量状态
            UIButton *selectButton = (UIButton *)[cell.contentView viewWithTag:file_edit_button_tag];
            [selectButton addTarget:self action:@selector(clickOnSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            selectButton.titleLabel.text = [NSString stringWithFormat:@"%i,%i",[indexPath section],[indexPath row]];
            selectButton.titleLabel.hidden = YES;

        }
        else{
            UIButton *downLoadButton = (UIButton *)[cell.contentView viewWithTag:file_download_button_tag];
            [downLoadButton addTarget:self action:@selector(clickOnDownLoadButton:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *downLoadlab = (UILabel *)[downLoadButton viewWithTag:file_download_button_lab_tag];
            
            downLoadlab.text = [NSString stringWithFormat:@"%li,%li",(long)[indexPath section],(long)[indexPath row]];
        }
        UILabel *fileNameLab = (UILabel *)[cell.contentView viewWithTag:file_name_tag];
        _tableViewLineX = fileNameLab.frame.origin.x;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == orgTable) {
//        最后一行 显示 是否还有记录
        BOOL needFooter = NO;
        if ([self isFileListGroupByTime]) {
            if (indexPath.section == self.itemArrayGroupByTime.count - 1){
                FilesOfTime *filesOfTime  =self.itemArrayGroupByTime[self.itemArrayGroupByTime.count - 1];
                if (indexPath.row == filesOfTime.filesArray.count - 1) {
                    needFooter = YES;
                }
            }
        }else{
            if (indexPath.row == [self.itemArray count] - 1){
                needFooter = YES;
            }
        }
        if (needFooter) {
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
- (void)setTableAndSearchBarFrame:(BOOL)searchBarShow
{
    if(searchBarShow)
    {
        //编辑状态
        float tableH = self.view.frame.size.height - BOTTOM_BAR_HEIGHT;
        orgTable.frame = CGRectMake(0, 0, self.view.frame.size.width, tableH);
        _searchBar.hidden = YES;
        return;
    }
    float tableH = self.view.frame.size.height - _searchBar.frame.size.height;
    orgTable.frame = CGRectMake(0, _searchBar.frame.size.height, self.view.frame.size.width, tableH);
    _searchBar.hidden = NO;
}
- (void)configEditingState:(BOOL)isEditing
{
    [self setTableAndSearchBarFrame:isEditing];
    if(isEditing)
    {
        //编辑状态
        bottomNavibar.hidden = NO;
        [self setNavigationItemTitle:[NSString stringWithFormat:@"已选%d个",(int)self.chooseResults.count]];
        return;
    }
    [self setNavigationItemTitle:[StringUtil getAppLocalizableString:@"me_file_assistant"]];
    bottomNavibar.hidden = YES;
}
#pragma mark - 设置是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editing)
    {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
        NSInteger _count = [self.chooseResults count];
        NSString *_message;
        
        if (_count > 1) {
            _message = [NSString stringWithFormat:[StringUtil  getLocalizableString:@"confirm_delete_meaasge"], _convRecord.file_name,_count];
        }
        else{
            _message = [NSString stringWithFormat:@"%@", _convRecord.file_name];
        }
        
        NSString *deleteMsgId = [StringUtil getStringValue:_convRecord.msgId];
//        文件助手数据库
#ifdef _XIANGYUAN_FLAG_
        [[FileAssistantRecordDOA getFileDatabase]deleteFileRecordOneMsg:deleteMsgId];
#else
        [_ecloud deleteOneMsg:deleteMsgId];

#endif
        
        [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:deleteMsgId.intValue];
        
        //        查询结果没有批量 因此只有分组和文件助手这两种情况
        if ([self isFileListGroupByTime]) {
            [self findAndDeleteFromItemArrayGroupByTimeWithMsgId:deleteMsgId.intValue];
        }else{
            int _index = [self getArrayIndexByMsgId:deleteMsgId.intValue];
            if (_index >= 0) {
                [self.itemArray removeObjectAtIndex:_index];
            }
        }
        
        totalCount = [self getFileConvRecordsCount];
        editing = YES;
        [self addButtonPressed:addButton];
    }
}

#pragma mark - 编辑菜单
- (void)clickOnDownLoadButton:(UIButton *)sender{
    UILabel *downLoadlab = (UILabel *)[sender viewWithTag:file_download_button_lab_tag];
    
    NSString *textValue = downLoadlab.text;
    
    NSArray *_array = [textValue componentsSeparatedByString:@","];
    
    int section = [_array[0] intValue];
    int row = [_array[1] intValue];
    
    NSLog(@"clickOnDownLoadButton-----------------%i %i",section,row);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableView *tableView = [self getTableView];
   
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];

    NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    switch (_convRecord.download_flag) {
        case state_download_success:
        {
            //文件下载成功,点击查看
            [talkSessionUtil sendReadNotice:_convRecord];
            previewFileIndex = indexPath;
            
            [[RobotDisplayUtil getUtil]openNormalFile:self andCurVC:self];
        }
            break;
        case state_downloading:
        {
            //如果有文件在下载，那么从文件列表中移除，并且取消下载
            [[talkSessionUtil2 getTalkSessionUtil] removeRecordFromDownloadList:_convRecord.msgId];
            int uploadstate = state_download_stop;
            _convRecord.download_flag = uploadstate;
            _convRecord.isDownLoading = NO;
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
    
    [FileAssistantUtil configureFileResumeDownOrUpLoadSateLabelCell:cell convRecord:_convRecord editState:NO];
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
        tableView = self.searchDisplayController.searchResultsTableView;
    }
    else{
        tableView = orgTable;
    }
    return tableView;
}

- (void)clickOnSelectButton:(UIButton *)sender{
    NSString *textValue = sender.titleLabel.text;
    
    NSArray *_array = [textValue componentsSeparatedByString:@","];
    
    if (_array.count == 2) {
        int section = [_array[0] intValue];
        int row = [_array[1] intValue];
        
        NSLog(@"clickOnSelectButton-----------------%i %i",section,row);
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [orgTable cellForRowAtIndexPath:indexPath];
        
        ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
        
        NSString *msgId = [NSString stringWithFormat:@"%i",_convRecord.msgId];
        
        if (_convRecord.isChosen) {
            //当前为选中状态，则取消选中
            _convRecord.isChosen = NO;
            [self.chooseResults removeObject:_convRecord];
            
            [sender setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
        }
        else{
            //当前为未选中，则选中
            _convRecord.isChosen = YES;
            _convRecord.receiptMsgFlag = conv_status_normal;
            [self.chooseResults addObject:_convRecord];
            
            [sender setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
        }
        self.title = [NSString stringWithFormat:@"已选%d个",(int)self.chooseResults.count];
    }
    
//    NSInteger row = [sender.titleLabel.text intValue];
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
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:previewFileIndex];
    FileRecord *_fileRecord = [[FileRecord alloc]init];
    _fileRecord.convRecord = _convRecord;
    return [_fileRecord autorelease];
}

#pragma mark------UISearchBarDelegate-----
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //	isSearch	=	YES;
    backgroudButton.hidden=NO;
    isSearch = YES;
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
            
            if (self.convId) {
                for (ConvRecord *_convRecord in recordList) {
                    if ([_convRecord.conv_id isEqualToString:self.convId]) {
                        [self.searchResults addObject:_convRecord];
                    }
                }
            }else{
                [self.searchResults addObjectsFromArray:recordList];
            }
                
            for(int i=0;i<self.searchResults.count;i++)
            {
                ConvRecord *_convRecord = [self.searchResults objectAtIndex:i];
                [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
                [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
            }
            
            [pool release];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
    backgroudButton.hidden=YES;
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchOrg];
}

#pragma mark - UISearchDisplayDelegate协议方法
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    orgTable.scrollsToTop = NO;
    controller.searchResultsTableView.scrollsToTop = YES;
    [UIAdapterUtil customCancelButton:self];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    orgTable.scrollsToTop = YES;
    controller.searchResultsTableView.scrollsToTop = NO;
    
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    searchDeptAndEmpTag = 0;
    isSearch = NO;

    [self refleshItemArray];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self setSearchResultsTitle:@""];
    
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)refleshItemArray{
    for (ConvRecord *_convRecord in self.itemArray) {
        for (ConvRecord *convRecord in self.searchResults) {
            if (convRecord.msgId == _convRecord.msgId) {
                [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
            }
        }
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

#pragma mark ========文件按照时间分组相关代码===========

//判断是否是 按照时间分组显示文件
- (BOOL)isFileListGroupByTime
{
    if (self.fileDisplayType == file_display_type_group_by_time && ![self isSearchState]) {
        return YES;
    }
    return NO;
}

//根据indexpath获取到convRecord
- (ConvRecord *)getConvRecordByIndexPath:(NSIndexPath *)indexPath
{
    if ([self isFileListGroupByTime]) {
        FilesOfTime *_filesOfTime = self.itemArrayGroupByTime[indexPath.section];
        ConvRecord *_convRecord = _filesOfTime.filesArray[indexPath.row];
        return _convRecord;
    }else{
        return [self getConvRecordByIndex:indexPath.row];
    }
}

- (UITableViewCell *)getCellAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if ([self isSearchState]){
        cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    }
    else{
        cell = [orgTable cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

//根据msgId找到对应的indexPath
-(NSIndexPath *)getIndexPathByMsgId:(int)msgId
{
    if ([self isFileListGroupByTime]) {
        int row = -1;
        int section = -1;
        for (FilesOfTime *filesOfTime in self.itemArrayGroupByTime) {
            section++;
            row = -1;
            for (ConvRecord *_convRecord in filesOfTime.filesArray) {
                row++;
                if (_convRecord.msgId == msgId) {
                    return [NSIndexPath indexPathForRow:row inSection:section];
                }
            }
        }
    }else{
        if ([self isSearchState]) {
            for(int i = self.searchResults.count - 1;i>=0;i--)
            {
                ConvRecord *_convRecord = [self.searchResults objectAtIndex:i];
                if(_convRecord.msgId == msgId)
                {
                    return [NSIndexPath indexPathForRow:i inSection:0];
                }
            }
        }
        else{
            for(int i = self.itemArray.count - 1;i>=0;i--)
            {
                ConvRecord *_convRecord = [self.itemArray objectAtIndex:i];
                if(_convRecord.msgId == msgId)
                {
                    return [NSIndexPath indexPathForRow:i inSection:0];
                }
            }
        }
    }
    
    return nil;
}

#pragma mark 聊天记录修改后，局部刷新
-(void)reloadRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConvRecord *_convRecord = [self getConvRecordByIndexPath:indexPath];
    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
    
    if ([self isSearchState]) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.searchDisplayController.searchResultsTableView endUpdates];
    }
    else{
        [orgTable beginUpdates];
        [orgTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        [orgTable endUpdates];
    }
}

//展开或收起
- (void)extendOrShrink:(UITapGestureRecognizer *)gesture
{
    UILabel *_label = (UILabel *)gesture.view;
    
    int section = _label.tag;
    
    FilesOfTime *filesOfTime = self.itemArrayGroupByTime[section];
    filesOfTime.isExtend = !filesOfTime.isExtend;
    
    [orgTable reloadData];
}

//根据msgid找到对应的convrecord 并且删除
- (void)findAndDeleteFromItemArrayGroupByTimeWithMsgId:(int)msgId
{
    for (FilesOfTime *filesOfTime in self.itemArrayGroupByTime) {
        for (ConvRecord *_convRecord in filesOfTime.filesArray) {
            if (_convRecord.msgId == msgId) {
                [filesOfTime.filesArray removeObject:_convRecord];
                if (filesOfTime.filesArray.count == 0) {
                    [self.itemArrayGroupByTime removeObject:filesOfTime];
                }
                
//                同时查找itemArray，如果里面有 也相应的删除
                for (ConvRecord *_convRecord in self.itemArray) {
                    if (_convRecord.msgId == msgId) {
                        [self.itemArray removeObject:_convRecord];
                        break;
                    }
                }
                
                break;
            }
        }
    }
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    backgroudButton.frame = orgTable.frame;
    
    float toolbarY = orgTable.frame.origin.y + orgTable.frame.size.height;
    _frame = bottomNavibar.frame;
    _frame.origin.y = toolbarY;
    _frame.size.width = SCREEN_WIDTH;
    
    bottomNavibar.frame = _frame;
    
    _frame = lineLab.frame;
    _frame.size.width = SCREEN_WIDTH;
    lineLab.frame = _frame;
    
    for (int i = 0; i < 3; i ++) {
        int tag = file_edit_button_tag + i;
        UIButton *editBtn = (UIButton *)[bottomNavibar viewWithTag:tag];
        editBtn.frame = CGRectMake(SCREEN_WIDTH/3 *i, 0.0, SCREEN_WIDTH/3-1, 46.0);
    }
}




@end
