//
//  CollectionController.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "CollectionController.h"

#import "CollectionDetailController.h"
#import "ForwardingRecentViewController.h"

#import "AppDelegate.h"
#import "CollectionConn.h"

#import "LCLLoadingView.h"
#import "EncryptFileManege.h"

#import "CollectionDAO.h"
#import "ConvRecord.h"

#import "CollectFileCell.h"
#import "VideoCellARC.h"
#import "VoiceCell.h"
#import "TextMsgCell.h"
#import "PictureCell.h"
#import "LongTextMsgCell.h"
#import "CollectionRobotVideoCell.h"
#import "CollectionImgTextCell.h"

#import "MyCollectionModel.h"

#import "CollectionUtil.h"
#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "talkSessionUtil.h"
#import "UIAdapterUtil.h"

#import "WXRefreshHeader.h"
#import "MJRefresh.h"
#import "LocationCell.h"
#import "LocationModel.h"
#import "NewsCell.h"
#import "LGNewsMdelARC.h"
#import "StringUtil.h"
#import "UIImageOfCrop.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define WINDOW_TAG 650

#define SEARCHBAR_BACKGROUND_X 0
#define SEARCHRAR_BACKGROUND_Y -20
#define SEARCHRAR_BACKGROUND_HEIGHT 64

#define SEARCHBAR_X 0
#define SEARCHBAR_Y 0
#define SEARCHBAR_HEIGHT 44

#define TYPEBUTTON_X (-2)
#define TYPEBUTTON_Y 15
#define TYPEBUTTON_WIRTH 47
#define TYPEBUTTON_HEIGHT 43

#define GRAY_BACKGROUND_X 0

#define PICTURECELL_PICTURE_HEIGHT 80

#define SELECT_BUTTON_Y 0
#define SELECT_BUTTON_HEIGHT 35

#define COLLECTION_TABLEVIEW_X 0
#define COLLECTION_TABLEVIEW_Y 0

#define EDITINGHEADVIEW_X 0
#define EDITINGHEADVIEW_Y 0
#define EDITINGHEADVIEW_HEIGHT 64

#define EDITINGFOOTERVIEW_X 0
#define EDITINGFOOTERVIEW_HEIGHT 45

#define CANCEL_BUTTON_Y 20
#define CANCEL_BUTTON_WIRTH 60
#define CANCEL_BUTTON_HEIGHT 44

#define DELECT_BUTTON_X 10
#define DELECT_BUTTON_Y 5
#define DELECT_BUTTON_WIRTH 70
#define DELECT_BUTTON_HEIGHT 44

#define ALL_TYPE 2000

#define TEXT_MSG_HEIGHT @(80)
#define PIC_MSG_HEIGHT @(140)
#define RECORD_MSG_HEIGHT @(80)
#define VIDEO_MSG_HEIGHT @(120)
#define FILE_MSG_HEIGHT @(107)
#define IMGTEXT_MSG_HEIGHT @(80)
#define LONGTEXT_MSG_HEIGHT @(70)
#define GROUP_INFO_HEIGHT @(70)

#define ADDRESSFONT 15
#define VOICE_ORG_X 12
#define VOICE_ORG_PLUS_X 52
#define VOICE_WIDTH 63
#define VOICE_ORG_Y 55
#define VOICE_HEIGHT 37

@interface CollectionController ()<UISearchBarDelegate, UISearchDisplayDelegate,UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, deleteDelegate, CollectionConnDelegate>
{
    UIButton *_preTypeBtn;
    NSIndexPath *_preIndexPath;
    BOOL _searchFlag;
    BOOL _isSearching;
    BOOL _isEditing;
    UIButton *addButton;
    UILabel *tipLabel;
    UIImageView *tipImageView;
    CGFloat voiceOrginX;
    BOOL _isVoiceEditing;
    UIView *line;
    NSString *selectStr;
    UIButton *selectBtn;
    
}
@property (nonatomic, strong) UITableView *collectionTableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *displayController;
@property (nonatomic, strong) UIButton *typeButton;
@property (nonatomic, strong) NSMutableArray *myCollectionData;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) UIView *grayBackGround;
@property (nonatomic, strong) UIView *editingFooterView;
@property (nonatomic, strong) UIButton *selectAllBtn;
@property (nonatomic, strong) NSMutableDictionary *editingBtn_IsSelected_Dic;
@property (nonatomic, strong) NSMutableArray *editingArray;    /**  被选中的收藏 */
@property (nonatomic, strong) NSArray *rowHeightArray;

@end

static NSString *fileCellIdentify    = @"fileCellIdentify";
static NSString *videoCellIdentify   = @"videoCellIdentify";
static NSString *voiceCellIdentify   = @"voiceCellIdentify";
static NSString *textMsgCellIdentify = @"textMsgCellIdentify";
static NSString *pictureCellIdentify = @"pictureCellIdentify";
static NSString *longTextMsgCellIdentify = @"longTextMsgCellIdentify";
static NSString *locationCellIdentify = @"locationCellIdentify";
static NSString *newsCellIdentify = @"newsCellidentify";

@implementation CollectionController
{
    UIButton *_rightBarButton;
    UIButton *_leftBarButton;
    UIButton *_forwardBtn;
    UIButton *_delectBtn;
}
- (void)dealloc
{
    [CollectionConn getConn].delegate = nil;
}

- (NSMutableArray *)myCollectionData
{
    if (_myCollectionData == nil)
    {
        CollectionDAO *cellectionDAO = [CollectionDAO shareDatabase];
        _myCollectionData = [cellectionDAO getCollectionData:0];
    }
    return _myCollectionData;
}

- (void)loadData
{
    // 初始化收藏获取的条数
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"noMoreData"];
    self.collectionTableView.footer.state = MJRefreshStateIdle;
    
    _myCollectionData = nil;
    CollectionDAO *cellectionDAO = [CollectionDAO shareDatabase];
    _myCollectionData = [cellectionDAO getCollectionData:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionTableView reloadData];
    });
    [self.collectionTableView.header endRefreshing];
}

- (void)updateData
{
    CollectionDAO *cellectionDAO = [CollectionDAO shareDatabase];
    [_myCollectionData addObjectsFromArray:[cellectionDAO getCollectionData:_myCollectionData.count]];
    
    [self.collectionTableView reloadData];
    [self.collectionTableView.footer endRefreshing];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"noMoreData"])
    {
//        self.collectionTableView.footer.state = MJRefreshStateNoMoreData;
        [self createTableFooterWithTitle:@"已经加载全部数据"];
    }
}

- (void)createTableFooterWithTitle:(NSString *)_title{
    
    
    self.collectionTableView.tableFooterView = nil;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.collectionTableView.bounds.size.width, 40.0f)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    
   UILabel * loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0, 40.0f)];
    loadMoreText.backgroundColor = [UIColor clearColor];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setTextAlignment:NSTextAlignmentCenter];
    [loadMoreText setFont:[UIFont systemFontOfSize:12.0]];
    [loadMoreText setText:_title];
    [tableFooterView addSubview:loadMoreText];
//    [loadMoreText release];
    
    //上拉提示
   UIActivityIndicatorView * loadingIndic =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndic.frame=CGRectMake(40.0,5, 30.0f,30.0f);
    loadingIndic.hidden = YES;
    loadingIndic.hidesWhenStopped = YES;
    [tableFooterView addSubview:loadingIndic];
//    [loadingIndic release];
    
    self.collectionTableView.tableFooterView = tableFooterView;
}


- (NSArray *)typeArray
{
    if (_typeArray == nil)
    {
        _typeArray = @[@(type_text),@(type_pic),@(type_record),@(type_file),@(type_imgtxt)];
    }
    return _typeArray;
}

- (NSArray *)rowHeightArray
{
    if (_rowHeightArray == nil)
    {
        _rowHeightArray = @[TEXT_MSG_HEIGHT,PIC_MSG_HEIGHT,RECORD_MSG_HEIGHT,FILE_MSG_HEIGHT,IMGTEXT_MSG_HEIGHT];
    }
    return _rowHeightArray;
}

- (NSMutableArray *)editingArray
{
    if (_editingArray == nil)
    {
        _editingArray = [NSMutableArray array];
    }
    return _editingArray;
}

- (NSMutableDictionary *)editingBtn_IsSelected_Dic
{
    if (_editingBtn_IsSelected_Dic == nil)
    {
        _editingBtn_IsSelected_Dic = [NSMutableDictionary dictionary];
    }
    return _editingBtn_IsSelected_Dic;
}

- (NSMutableArray *)searchResultArray
{
    if (_searchResultArray == nil)
    {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isVoiceEditing = NO;
    // 加载数据
    //    [self loadData];
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    // 设置标题
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//    [titleLabel setFont:[UIFont systemFontOfSize:17]];
//    titleLabel.text = [StringUtil getLocalizableString:@"collections"];
//    [titleLabel setTextColor:[UIColor whiteColor]];
//    self.navigationItem.titleView = titleLabel;
    
    self.title = [StringUtil getLocalizableString:@"collections"];
    
    // 添加左边按钮
    _leftBarButton = [UIAdapterUtil setLeftButtonItemWithTitle:@"返回" andTarget:self andSelector:@selector(backButtonPressed:)];
    
    // 在navigationBar右边添加编辑按钮
    _rightBarButton = [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"editing"] andTarget:self andSelector:@selector(editingButtonClicked)];
    
    self.collectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(COLLECTION_TABLEVIEW_X, COLLECTION_TABLEVIEW_Y, KSCREEN_SIZE.width, KSCREEN_SIZE.height - COLLECTION_TABLEVIEW_Y-64) style:UITableViewStyleGrouped];
    
    // 给collectionTableView添加想要进入时的长按手势
    UILongPressGestureRecognizer *editLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editLongPress:)];
    [self.collectionTableView addGestureRecognizer:editLongPress];
    
    self.collectionTableView.header = [WXRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.collectionTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(updateData)];
    
    // 设置数据源和代理
    self.collectionTableView.dataSource = self;
    self.collectionTableView.delegate   = self;
    
    self.collectionTableView.delaysContentTouches = NO;
    
    self.collectionTableView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    
    [self.view addSubview:self.collectionTableView];
    
    // 把多余的分割线去掉
    [self.collectionTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.collectionTableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(SEARCHBAR_X, SEARCHBAR_Y, KSCREEN_SIZE.width, SEARCHBAR_HEIGHT)];
    
    _searchBar.placeholder = [StringUtil getLocalizableString:@"search_tips"];
    _searchBar.delegate = self;
    
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), KSCREEN_SIZE.width, 0.4)];
    line.tag = 199;
//    line.backgroundColor = [StringUtil colorWithHexString:@"#A9A9A9"];
    line.backgroundColor = [StringUtil colorWithHexString:@"#E4E4E4"];
    
    self.displayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.delegate = self;
    self.displayController.searchResultsDelegate = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchBar.placeholder = @"搜索";
    
    self.collectionTableView.tableHeaderView = self.searchBar;
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:line];
    [self.view addSubview:_searchBar];
    
    self.grayBackGround = [[UIView alloc] initWithFrame:CGRectMake(GRAY_BACKGROUND_X, 64, KSCREEN_SIZE.width, KSCREEN_SIZE.height)];
    
    self.grayBackGround.backgroundColor = [UIColor whiteColor];
    self.grayBackGround.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    [self.grayBackGround addGestureRecognizer:tap];
    
    NSMutableString *msg_type_imgtxt = [NSMutableString stringWithString:[StringUtil getLocalizableString:@"msg_type_imgtxt"]];
    [msg_type_imgtxt deleteCharactersInRange:NSMakeRange(msg_type_imgtxt.length - 1, 1)];
    [msg_type_imgtxt deleteCharactersInRange:NSMakeRange(0, 1)];
    NSArray *typeArray = [NSArray arrayWithObjects:[StringUtil getLocalizableString:@"search_By_Text_Type"],[StringUtil getLocalizableString:@"search_By_Pic_Type"],[StringUtil getLocalizableString:@"search_By_Record_Type"],[StringUtil getLocalizableString:@"search_By_File_Type"],msg_type_imgtxt, nil];
    NSInteger count = typeArray.count;
    for (int i = 0; i < count; i++)
    {
        selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(i * (KSCREEN_SIZE.width/count), SELECT_BUTTON_Y, KSCREEN_SIZE.width/count, SELECT_BUTTON_HEIGHT);
        [selectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [selectBtn setTitleColor:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/252.0 alpha:1] forState:UIControlStateSelected];
        [selectBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        selectBtn.tag = 200 + i;
        [selectBtn setTitle:typeArray[i] forState:UIControlStateNormal];
        [selectBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.grayBackGround addSubview:selectBtn];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    window.backgroundColor = [UIColor whiteColor];
    [window addSubview:self.grayBackGround];
    
    // 设置CollectionConn代理
    [CollectionConn getConn].delegate = self;
    
    //收藏删除成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeleteSuccess) name:COLLECT_DELETED_SUCCESSFULLY object:nil];
    
    tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 203.5, SCREEN_WIDTH, 50)];
    tipLabel.text = [StringUtil getLocalizableString:@"collection_tip"];
    tipLabel.textColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1/1.0];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.numberOfLines = 0;
    tipLabel.tag = 100;
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    tipLabel.hidden = YES;
    [self.view addSubview:tipLabel];
    
#define imageWidth 90
    tipImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-imageWidth/2, 80, imageWidth, 110)];
    tipImageView.image = [StringUtil getImageByResName:@"img_meeting_nothing"];
    tipImageView.hidden = YES;
    [self.view addSubview:tipImageView];
    

}



#pragma mark - CollectionConnDelegate
- (void)deleteCollectionByArray:(NSArray *)array
{
    for (NSString *originID in array)
    {
        for (int i = 0; i < self.myCollectionData.count; i++)
        {
            MyCollectionModel *model = self.myCollectionData[i];
            if ([model.originID isEqualToString:originID])
            {
                [self.myCollectionData removeObjectAtIndex:i];
                break;
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionTableView reloadData];
    });
}

- (void)addCollection
{
    [self loadData];
}

#pragma mark - collectionTableView进入编辑状态时的长按手势
- (void)editLongPress:(UIGestureRecognizer *)sender
{
    if (_isEditing)
    {
        return;
    }
    
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self editingButtonClicked];
    }
}

- (void)editingButtonClicked
{
    if (_isEditing)
    {
        _isVoiceEditing = NO;
        [_rightBarButton setTitle:[StringUtil getLocalizableString:@"editing"] forState:UIControlStateNormal];
        [self setNavigationItemTitle:[StringUtil getLocalizableString:@"我的收藏"]];
        _leftBarButton.hidden = NO;
        [self cancelEditing];
        [self.collectionTableView reloadData];
        _isEditing = NO;
        return;
    }
    else
    {
        _isVoiceEditing = YES;
        _isEditing = YES;
        [self setNavigationItemTitle:[NSString stringWithFormat:@"已选%d个",(int)self.editingArray.count]];
        [_rightBarButton setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        _leftBarButton.hidden = YES;
//        self.selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
//        self.selectAllBtn.backgroundColor = _color;//[UIColor colorWithRed:37/255.0 green:81/255.0 blue:144/255.0 alpha:1];
//        [self.selectAllBtn setTitle:[StringUtil getLocalizableString:@"select_all"] forState:UIControlStateNormal];
//        self.selectAllBtn.frame = CGRectMake(0, 20, 110, 44);
//        [self.selectAllBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 45)];
//        [self.selectAllBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
//        [self.selectAllBtn addTarget:self action:@selector(selectAllOrNotSelectAll) forControlEvents:UIControlEventTouchUpInside];
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        UIWindow *window = delegate.window;
        [window addSubview:self.selectAllBtn];
        
        [self.collectionTableView reloadData];
    }
    
    /*
     self.editingHeaderView = [[UIView alloc] initWithFrame:CGRectMake(EDITINGHEADVIEW_X, EDITINGHEADVIEW_Y, KSCREEN_SIZE.width, EDITINGHEADVIEW_HEIGHT)];
     self.editingHeaderView.backgroundColor = [UIColor colorWithRed:37/255.0 green:81/255.0 blue:144/255.0 alpha:1];
     
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((KSCREEN_SIZE.width-85)/2, 19, 85, 45)];
     titleLabel.textAlignment = NSTextAlignmentCenter;
     [titleLabel setFont:[UIFont systemFontOfSize:17]];
     titleLabel.text = [StringUtil getLocalizableString:@"collections"];
     [titleLabel setTextColor:[UIColor whiteColor]];
     
     UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [cancelBtn setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
     [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
     cancelBtn.frame = CGRectMake(KSCREEN_SIZE.width - CANCEL_BUTTON_WIRTH, CANCEL_BUTTON_Y, CANCEL_BUTTON_WIRTH, CANCEL_BUTTON_HEIGHT);
     [cancelBtn addTarget:self action:@selector(cancelEditing) forControlEvents:UIControlEventTouchUpInside];
     */
    
    CGFloat btnWidth = KSCREEN_SIZE.width/2;
    _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardBtn.frame = CGRectMake(0, 0, btnWidth, 45);
    [_forwardBtn setTitle:[StringUtil getLocalizableString:@"forward"] forState:UIControlStateNormal];
    [_forwardBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_forwardBtn setTitleColor:UIColorFromRGB(0x2481FC) forState:UIControlStateNormal];
    [_forwardBtn addTarget:self action:@selector(forwardToSomebody) forControlEvents:UIControlEventTouchUpInside];
    
    _delectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delectBtn setTitle:[StringUtil getLocalizableString:@"delete"] forState:UIControlStateNormal];
    [_delectBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_delectBtn setTitleColor:UIColorFromRGB(0x2481FC) forState:UIControlStateNormal];
    _delectBtn.frame = CGRectMake(btnWidth, 0, btnWidth, 45);
    [_delectBtn addTarget:self action:@selector(removeTheSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.editingFooterView = [[UIView alloc] initWithFrame:CGRectMake(EDITINGFOOTERVIEW_X, KSCREEN_SIZE.height - EDITINGFOOTERVIEW_HEIGHT-64, KSCREEN_SIZE.width, EDITINGFOOTERVIEW_HEIGHT)];
    self.editingFooterView.backgroundColor = [UIColor whiteColor];
    
    UIView *footerSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_SIZE.width, 1)];
    footerSeparatorView.backgroundColor = [StringUtil colorWithHexString:@"#E4E4E4"];
    
    [self.editingFooterView addSubview:footerSeparatorView];
    [self.editingFooterView addSubview:_delectBtn];
    [self.editingFooterView addSubview:_forwardBtn];
    
    [self.view addSubview:self.editingFooterView];
    
    _searchBar.hidden = YES;
    line.hidden = YES;
    
    if (self.collectionTableView.frame.origin.y == COLLECTION_TABLEVIEW_Y)
    {
        [UIView animateWithDuration:.3 animations:^{
            
            // 进入编辑状态时让collectionTableView上移
            CGRect rect1 = self.collectionTableView.frame;
            rect1.origin.y -= 44;
            self.collectionTableView.frame = rect1;
        }];
    }
}

- (void)setNavigationItemTitle:(NSString *)title
{
    self.title = title;
}

- (void)configBottomBtnClicked:(UIButton *)changeBtn unChangeButton:(UIButton *)unChangeBtn
{
    changeBtn.backgroundColor = UIColorFromRGB(0x2481FC);
    [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    unChangeBtn.backgroundColor = [UIColor clearColor];
    [unChangeBtn setTitleColor:UIColorFromRGB(0x2481FC) forState:UIControlStateNormal];
}
- (void)forwardToSomebody
{
    [self configBottomBtnClicked:_forwardBtn unChangeButton:_delectBtn];
    if (self.editingArray.count == 0)
    {
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"please_choose_what_you_want_to_edit"]  message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        
        [alertView1 show];
        
        return;
    }
    
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:self.editingArray.count];
    for (MyCollectionModel *model in self.editingArray)
    {
        ConvRecord *_convRecord = [CollectionDetailController getConvRecordByCollectModel:model];
        if (!_convRecord) {
            continue;
        }
        //        [[ConvRecord alloc]init];
        //        _convRecord.msg_type = model.type;
        //        if (model.type==type_long_msg || model.type==type_record)
        //        {
        //            _convRecord.msg_body = model.fileName;
        //        }
        //        else
        //        {
        //            _convRecord.msg_body = model.body;
        //        }
        //        _convRecord.file_size = [NSString stringWithFormat:@"%f",model.fileSize.floatValue * 1000];
        //        _convRecord.file_name = model.fileName;
        
        [mArr addObject:_convRecord];
    }
    
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc]init];
    forwarding.fromType = transfer_from_collection;
    forwarding.fromVC = self;
    
    forwarding.forwardRecordsArray = [NSArray arrayWithArray:mArr];
    
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [self presentModalViewController:nav animated:YES];
}

#pragma mark =======转发提示=======
- (void)showTransferTips
{
    // 取消编辑状态
    [self cancelEditing];
    
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

- (void)selectAllOrNotSelectAll
{
    if (self.editingArray.count == self.myCollectionData.count)
    {
        [self.editingArray removeAllObjects];
        
        for (int i = 0; i < self.myCollectionData.count; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            if ([self.editingBtn_IsSelected_Dic objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]])
            {
                UITableViewCell *cell = [self.collectionTableView cellForRowAtIndexPath:indexPath];
                UIImageView *editingBtn = [cell viewWithTag:102];
                [self.editingBtn_IsSelected_Dic removeObjectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
                [editingBtn setImage:[StringUtil getImageByResName:@"photo_Selection.png"]];
            }
        }
    }
    else
    {
        [self.editingArray removeAllObjects];
        [self.editingArray addObjectsFromArray:self.myCollectionData];
        
        for (int i = 0; i < self.myCollectionData.count; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            if (![self.editingBtn_IsSelected_Dic objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]])
            {
                UITableViewCell *cell = [self.collectionTableView cellForRowAtIndexPath:indexPath];
                UIImageView *editingBtn = [cell viewWithTag:102];
                [self.editingBtn_IsSelected_Dic setObject:@"1" forKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
                [editingBtn setImage:[StringUtil getImageByResName:@"btn_checkbox_pressed"]];
            }
        }
    }
}

#pragma mark - 点击删除按钮时
- (void)removeTheSelectedItems
{
    [self configBottomBtnClicked:_delectBtn unChangeButton:_forwardBtn];
    if (self.editingArray.count == 0)
    {
        UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"please_choose_what_you_want_to_edit"]  message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        
        [alertView1 show];
    }
    else
    {
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %lu %@?",[StringUtil getLocalizableString:@"are_you_sure_to_delete_the"],(unsigned long)self.editingArray.count,[StringUtil getLocalizableString:@"options_you_choose"]] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [alertView2 show];
    }
}

#pragma mark - 点击确定时
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1)
    {
        // 去掉重复的
        NSSet *set = [NSSet setWithArray:self.editingArray];
        
        NSMutableArray *mArr = [NSMutableArray array];
        for (MyCollectionModel *model in set)
        {
            if ([self.searchResultArray containsObject:model])
            {
                [self.searchResultArray removeObject:model];
            }
            
            [self.myCollectionData removeObject:model];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"origin_id"] = model.originID;
            dic[@"file_name"] = model.fileName;
            dic[@"msg_type"] = @(model.type);
            [mArr addObject:dic];
        }
        // 删除数据库中对应内容
        CollectionDAO *collectionDAO = [CollectionDAO shareDatabase];
        [collectionDAO deleteCollection:mArr];
        
    }
}

- (void)DeleteSuccess{
    
    [self.editingArray removeAllObjects];
    [self.editingBtn_IsSelected_Dic removeAllObjects];
    [self.collectionTableView reloadData];
    
}
#pragma mark - 按取消编辑按钮时调用
- (void)cancelEditing
{
    _isEditing = NO;
    [self.collectionTableView reloadData];
    
    self.navigationItem.rightBarButtonItem.title = [StringUtil getLocalizableString:@"editing"];
    
    [self.editingFooterView removeFromSuperview];
    
    _searchBar.hidden = NO;
    
    [self.selectAllBtn removeFromSuperview];
    self.selectAllBtn = nil;
    
    if (self.navigationController.navigationBar.frame.origin.y == 20 && self.collectionTableView.frame.origin.y == COLLECTION_TABLEVIEW_Y - 44)
    {
        [UIView animateWithDuration:.3 animations:^{
            
            // 取消编辑状态时让collectionTableView上移
            CGRect rect1 = self.collectionTableView.frame;
            rect1.origin.y += 44;
            //            rect1.size.height -= 44;
            self.collectionTableView.frame = rect1;
        }];
    }
    
    // 移除所选的收藏
    [self.editingArray removeAllObjects];
    // 移除所有键值对
    [self.editingBtn_IsSelected_Dic removeAllObjects];
}

- (void)tapBackGround
{
    [_displayController setActive:NO animated:YES];
}

#pragma mark - 显示选择类型的按钮
- (void)showChooseTypeBtn:(UIButton *)sender
{
    // 搜索结果不显示headerView
    _searchFlag = NO;
    
    if (self.grayBackGround.hidden)
    {
        self.grayBackGround.hidden = NO;
    }
    else
    {
        self.grayBackGround.hidden = YES;
    }
}

#pragma mark - 按下选择类型的按钮时调用
- (void)chooseType:(UIButton *)sender
{
    // 搜索结果不显示headerView
    _searchFlag = NO;
    selectStr = sender.titleLabel.text;
    self.grayBackGround.hidden = YES;
    
    [_typeButton setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    _typeButton.tag = sender.tag;
    
    if (_preTypeBtn != sender)
    {
        sender.selected = YES;
    }
    else if (sender.selected)
    {
        if (sender.selected)
        {
            [_typeButton setTitle:[StringUtil getLocalizableString:@"search_By_All_Type"] forState:UIControlStateNormal];
        }
    }
    
    if (_preTypeBtn)
    {
        _preTypeBtn.selected = !_preTypeBtn.selected;
        if (_preTypeBtn != sender)
        {
            _preTypeBtn.selected = NO;
        }
    }
    
    _preTypeBtn = sender;
    
    _typeButton.selected = sender.selected;
    
    NSInteger type = [self.typeArray[sender.tag-200] integerValue];
    
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getData:) object:@(type)];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(reloadResultTableView) object:nil];
    // 设置依赖
    [operation2 addDependency:operation1];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    
    self.searchDisplayController.searchBar.text = _typeButton.selected ? @" " : @"";
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)getData:(NSNumber *)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    });
    
    self.searchResultArray = [[CollectionDAO shareDatabase] getCollectionByType:type.integerValue];
}

- (void)getDataBySearchStr:(NSString *)searchString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    });
    
    NSInteger index = _preTypeBtn.tag - 200;
    if (index < 0 || index > 4) {
        index = 0;
    }
    
    NSInteger msgType = [self.typeArray[index] integerValue];
    NSInteger type = _typeButton.selected ? msgType : ALL_TYPE;
    self.searchResultArray = [[CollectionDAO shareDatabase] searchByType:type withWord:searchString withCount:self.searchResultArray.count];
}

- (void)reCalculateFrame
{
    self.grayBackGround.frame = CGRectMake(0, 0, self.view.frame.size.width , 64+[StringUtil getStatusBarHeight]);
}


- (void)reloadResultTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        
        self.searchDisplayController.searchResultsTableView.contentOffset = CGPointMake(0, 0);
        [self.searchDisplayController.searchResultsTableView reloadData];
    });
}

static bool flag = YES;
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    flag = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIAdapterUtil disableDragBackOfNavigationController:self];

    if (_isSearching)
    {
        [self.searchBar becomeFirstResponder];
    }
    
    if (_isEditing)
    {
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        UIWindow *window = delegate.window;
        [window addSubview:self.selectAllBtn];
        [self setNavigationItemTitle:[NSString stringWithFormat:@"已选%d个",(int)self.editingArray.count]];
    }
    else
    {
        [self setNavigationItemTitle:[StringUtil getLocalizableString:@"我的收藏"]];
    }
    
    
}



-(void)viewWillLayoutSubviews
{
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];

    if (statusBarRect.size.height == 40)
        
    {
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView animateWithDuration:duration+0.3 animations:^{
            self.grayBackGround.frame = CGRectMake(0,  64+20, self.view.frame.size.width ,self.view.frame.size.height);

        }];
    }

    else

    {
        self.grayBackGround.frame = CGRectMake(0, 64, self.view.frame.size.width , self.view.frame.size.height);
        
    }
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIAdapterUtil enableDragBackOfNavigationController:self];

    if (self.selectAllBtn != nil)
    {
        [self.selectAllBtn removeFromSuperview];
    }
    
    NSInteger count = self.navigationController.viewControllers.count;
    if (self.navigationController.viewControllers.count == 1)
    {
        if (self.navigationController.navigationBar.frame.origin.y == -44)
        {
            CGRect rect = self.navigationController.navigationBar.frame;
            rect.origin.y += 64;
            self.navigationController.navigationBar.frame = rect;
        }
        if (self.navigationController.navigationBar.alpha == 0)
        {
            self.navigationController.navigationBar.alpha = 1;
        }
    }
    
    flag = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索Begin");
    self.searchDisplayController.searchBar.searchTextPositionAdjustment = UIOffsetMake(30, 0);
    if (_typeButton == nil)
    {
        _typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeButton.frame = CGRectMake(23, 3, 45, 25);
        [_typeButton setTitle:[StringUtil getLocalizableString:@"search_By_All_Type"] forState:UIControlStateNormal];
        [_typeButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_typeButton setTitleColor:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/252.0 alpha:1] forState:UIControlStateNormal];
        [_typeButton addTarget:self action:@selector(showChooseTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
        _typeButton.titleEdgeInsets = UIEdgeInsetsMake(12, 7, 0, 0); // top left bottom right
        
        [self.searchDisplayController.searchBar addSubview:_typeButton];
    }
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(nonnull UITableView *)tableView
{
    for (UIView *subview in tableView.subviews) {
        NSString *text;
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([_searchBar.text isEqualToString:@" "])
            {
//                text = [text stringByReplacingOccurrencesOfString:@"%@" withString:selectStr];
                text = [StringUtil getLocalizableString:@"noresult"];
                
            }else{
                text = [StringUtil getLocalizableString:@"no_search_result"];
                text = [text stringByReplacingOccurrencesOfString:@"%@" withString:self.searchBar.text];
                
            }
            
            [(UILabel *)subview setText:text];
        }
    }
   
}

// 进入搜索状态时
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _isSearching = YES;
    self.grayBackGround.hidden = NO;
    
    [UIAdapterUtil customCancelButton:self];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.collectionTableView reloadData];
}

// 点击取消搜索时
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    _isSearching = NO;
    
    _preTypeBtn.selected = NO;
    _preTypeBtn = _typeButton;   /**  为了让_preTypeBtn和上次纪录的不一样  */
    [_typeButton.titleLabel setText:[StringUtil getLocalizableString:@"search_By_All_Type"]];
    
    self.searchDisplayController.searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 0);
    [_typeButton removeFromSuperview];
    _typeButton = nil;
    self.grayBackGround.hidden = YES;
    
    [self.collectionTableView reloadData];
}

//点击搜索按钮时才开始搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar.text length] < 2) {
        [UserTipsUtil showSearchTip];
        return;
    }
    
    [searchBar resignFirstResponder];
    //    backgroudButton.hidden=YES;
    
    //搜索提示
    //    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    //    [[LCLLoadingView currentIndicator] show];
    
    
    if (!self.grayBackGround.hidden)
    {
        self.grayBackGround.hidden = YES;
    }
    
    _searchFlag = YES;
    
    NSString *searchString = searchBar.text;
    NSRange range = [searchString rangeOfString:@" "];
    if (range.location != NSNotFound)
    {
        if (range.location == 0)
        {
            if (searchString.length == 1)
            {
                return ;
            }
            NSMutableString *searchStr = [NSMutableString stringWithString:searchString];
            [searchStr deleteCharactersInRange:range];
            searchString = searchStr;
        }
    }
    
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getDataBySearchStr:) object:searchString];
    NSInvocationOperation *operation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(reloadResultTableView) object:nil];
    // 设置依赖
    [operation2 addDependency:operation1];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    
    if (self.grayBackGround.hidden == NO)
    {
        self.grayBackGround.hidden = YES;
    }
    
    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

// 搜索内容改变时
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    if (searchString.length == 0)
    {
        [_typeButton setTitle:[StringUtil getLocalizableString:@"search_By_All_Type"] forState:UIControlStateNormal];
        self.grayBackGround.hidden = NO;
        _typeButton.selected = NO;
        _preTypeBtn.selected = NO;
    }
    
    return NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.myCollectionData.count == 0) {
        
        _searchBar.hidden = YES;
        addButton.hidden = YES;
        line.hidden = YES;
        tipImageView.hidden = NO;
        tipLabel.hidden = NO;
        _rightBarButton.hidden = YES;
        self.collectionTableView.frame = CGRectMake(COLLECTION_TABLEVIEW_X, COLLECTION_TABLEVIEW_Y-64, KSCREEN_SIZE.width, KSCREEN_SIZE.height - COLLECTION_TABLEVIEW_Y);

        
    }else{
        
        _searchBar.hidden = NO;
        addButton.hidden = NO;
        line.hidden = NO;
        tipImageView.hidden = YES;
        tipLabel.hidden = YES;
        _rightBarButton.hidden = NO;
         self.collectionTableView.frame = CGRectMake(COLLECTION_TABLEVIEW_X, COLLECTION_TABLEVIEW_Y, KSCREEN_SIZE.width, KSCREEN_SIZE.height - COLLECTION_TABLEVIEW_Y-64);
        
    }
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return self.searchResultArray.count;
    }
    else
    {
        return self.myCollectionData.count;
    }
}
- (NSInteger)getIndexBreakLine:(NSString *)text font:(UIFont *)font
{
    NSMutableString *str = [[NSMutableString alloc] init];
    NSInteger breakLineIndex = 0;
    for (int i = 0; i < text.length; i++)
    {
        unichar s = [text characterAtIndex:i];
        [str appendString:[NSString stringWithFormat:@"%c",s]];
        CGSize size = [str sizeWithFont:font];
        if(size.width >= [UIScreen mainScreen].bounds.size.width - 24)
        {
            breakLineIndex = i;
            break;
        }
    }
    return breakLineIndex;
}
#pragma mark - tableView dataSouce
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionModel* myCollectionModel = nil;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        myCollectionModel = self.searchResultArray[indexPath.row];
    }
    else
    {
        myCollectionModel = self.myCollectionData[indexPath.row];
    }
    
    
    CollectionParentCell *cell = nil;
    
    switch (myCollectionModel.realType) {
        case type_text:
        {
            NSMutableArray *array = [NSMutableArray array];
            [StringUtil seperateMsg:myCollectionModel.body andImageArray:array];
            //            if (array.count == 1)
            //            {
            //                TextMsgCell *textMsgCell = [tableView dequeueReusableCellWithIdentifier:textMsgCellIdentify];
            //
            //                if (textMsgCell == nil)
            //                {
            //                    textMsgCell = [[TextMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textMsgCellIdentify];
            //                }
            //
            //                textMsgCell.collectionModel = myCollectionModel;
            //
            //                [textMsgCell.textMessage setEmojiText:myCollectionModel.body];
            //                // 获取该cell
            //                cell = textMsgCell;
            //            }
            //            else
            //            {
            NSMutableString *text =[[NSMutableString alloc] init];
            for (int i = 0; i < array.count; i++)
            {
                NSString *str = array[i];
                
                //                    NSLog(@"%s str is %@",__FUNCTION__,str);
                if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
                {
                    [array replaceObjectAtIndex:i withObject:[StringUtil getLocalizableString:@"msg_type_pic"]];
                    str = array[i];
                }
                [text appendString:str];
            }
            
            TextMsgCell *imgtextCell = [tableView dequeueReusableCellWithIdentifier:textMsgCellIdentify];
            
            if (imgtextCell == nil)
            {
                imgtextCell = [[TextMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textMsgCellIdentify];
            }
//            NSInteger breakLineIndex = [self getIndexBreakLine:text font:imgtextCell.textMessage.font];
//            [text insertString:@"..." atIndex:breakLineIndex];

            imgtextCell.collectionModel = myCollectionModel;
            [imgtextCell.textMessage setEmojiText:text];
            // 获取该cell
            cell = imgtextCell;
            //            }
        }
            break;
            
        case type_long_msg:
        {
            LongTextMsgCell *longTextMsgCell = [tableView dequeueReusableCellWithIdentifier:longTextMsgCellIdentify];
            
            if (longTextMsgCell == nil)
            {
                longTextMsgCell = [[LongTextMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:longTextMsgCellIdentify];
            }
            
            longTextMsgCell.collectionModel = myCollectionModel;
            
            longTextMsgCell.textMessage.text = myCollectionModel.body;
            
            // 获取该cell
            cell = longTextMsgCell;
        }
            break;
        case type_file:
        {
            CollectFileCell* fileCell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentify];
            
            if (fileCell == nil)
            {
                fileCell = [[CollectFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellIdentify];
            }
            
            fileCell.collectionModel = myCollectionModel;
            
            fileCell.fileName.text = myCollectionModel.fileName;
            fileCell.fileImgView.image = [StringUtil getImageByResName:@"ic_chat_file"];
            //[StringUtil getFileDefaultImage:myCollectionModel.fileName];
            fileCell.fileSize.text = [StringUtil getDisplayFileSize:myCollectionModel.fileSize.intValue];
            
            // 获取该cell
            cell = fileCell;
        }
            break;
            
        case type_record:
        {
             if (myCollectionModel.title)
             {
//                 小万的音频 也要 显示成 文件样式
                 CollectFileCell* fileCell = [tableView dequeueReusableCellWithIdentifier:fileCellIdentify];
                 
                 if (fileCell == nil)
                 {
                     fileCell = [[CollectFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellIdentify];
                 }
                 
                 fileCell.collectionModel = myCollectionModel;
                 
                 fileCell.fileName.text = myCollectionModel.title;
                 fileCell.fileImgView.image = [StringUtil getFileDefaultImage:myCollectionModel.fileName];
                 fileCell.fileSize.text = myCollectionModel.fileSize;
                 
                 // 获取该cell
                 cell = fileCell;
             }else{
                 VoiceCell* voiceCell = [tableView dequeueReusableCellWithIdentifier:voiceCellIdentify];
                 
                 if (voiceCell == nil)
                 {
                     voiceCell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:voiceCellIdentify];
                 }
                 voiceCell.collectionModel = myCollectionModel;
                 
                  // 设置录音时长
                  voiceCell.audio_time.text = myCollectionModel.fileSize ? [NSString stringWithFormat:@"%@''",myCollectionModel.fileSize] : @"";
                 voiceCell.voiceLength = [voiceCell.audio_time.text floatValue];
                 if (_isVoiceEditing == YES) {
                     voiceOrginX = VOICE_ORG_PLUS_X;
                 }else{
                     voiceOrginX = VOICE_ORG_X;
                 }
                 voiceCell.greenBackground.frame = CGRectMake(voiceOrginX, VOICE_ORG_Y, VOICE_WIDTH + VOICE_WIDTH/20*(voiceCell.voiceLength-1), VOICE_HEIGHT);
                 
                 cell = voiceCell;
             }
        }
            break;
            
        case type_video:
        {
            if (myCollectionModel.title)
            {
                static NSString *robotVideoCellIdentify = @"robotVideoCellIdentify";
                
                CollectionRobotVideoCell *robotVideoCell = [tableView dequeueReusableCellWithIdentifier:robotVideoCellIdentify];
                if (robotVideoCell == nil)
                {
                    robotVideoCell = [[CollectionRobotVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:robotVideoCellIdentify];
                }
                robotVideoCell.collectionModel = myCollectionModel;
                
                robotVideoCell.typeImgView.image = [StringUtil getFileDefaultImage:myCollectionModel.title];
                robotVideoCell.titleLabel.text = myCollectionModel.title;
                robotVideoCell.fileSizeLabel.text = myCollectionModel.fileSize;
                
                cell = robotVideoCell;
            }
            else
            {
                VideoCellARC *videoCell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentify];
                
                if (videoCell == nil)
                {
                    videoCell = [[VideoCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoCellIdentify];
                }
                videoCell.collectionModel = myCollectionModel;
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:myCollectionModel.body] options:nil];
                NSInteger *sec = asset.duration.value / asset.duration.timescale;
                videoCell.durationLabel.text = [talkSessionUtil lessSecondToDay:sec];
                UIImage *image = [myCollectionModel.picture imageByScalingAndCroppingForSize:CGSizeMake(videoCell.picture.frame.size.width, videoCell.picture.frame.size.height)];

                videoCell.picture.image = image;
                
                // 获取该cell
                cell = videoCell;
            }
        }
            break;
            
        case type_normal_imgtxt:
        {
            NSMutableArray *array = [NSMutableArray array];
            [StringUtil seperateMsg:myCollectionModel.body andImageArray:array];
            
            NSMutableString *text =[[NSMutableString alloc] init];
            for (int i = 0; i < array.count; i++)
            {
                NSString *str = array[i];
                
                if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
                {
                    [array replaceObjectAtIndex:i withObject:[StringUtil getLocalizableString:@"msg_type_pic"]];
                    str = array[i];
                }
                [text appendString:str];
            }
            
            TextMsgCell *imgtextCell = [tableView dequeueReusableCellWithIdentifier:textMsgCellIdentify];
            
            if (imgtextCell == nil)
            {
                imgtextCell = [[TextMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textMsgCellIdentify];
            }
            
            imgtextCell.collectionModel = myCollectionModel;
            
            [imgtextCell.textMessage setEmojiText:text];
            // 获取该cell
            cell = imgtextCell;
        }
            break;
            
        case type_imgtxt:
        {
            CollectionImgTextCell *imgTextCell = [tableView dequeueReusableCellWithIdentifier:@""];
            if (imgTextCell == nil)
            {
                imgTextCell = [[CollectionImgTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            }
            imgTextCell.collectionModel = myCollectionModel;
            /*
             imgTextCell.imgView.image = myCollectionModel.picture;
             imgTextCell.titleLabel.text = myCollectionModel.title;
             imgTextCell.desLabel.text = myCollectionModel.fileName;
             */
            
            cell = imgTextCell;
        }
            break;
            
        case type_pic:
        {
            PictureCell *pictureCell = [tableView dequeueReusableCellWithIdentifier:pictureCellIdentify];
            
            if (pictureCell == nil)
            {
                pictureCell = [[PictureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pictureCellIdentify];
            }
            
            pictureCell.collectionModel = myCollectionModel;
            UIImage *image = [myCollectionModel.picture imageByScalingAndCroppingForSize:CGSizeMake(pictureCell.picture.frame.size.width, pictureCell.picture.frame.size.height)];
            pictureCell.picture.image = image;
            
            // 获取该cell
            cell = pictureCell;
        }
            break;
        case type_location:
        {
            
            LocationCell *locationCells = [tableView dequeueReusableCellWithIdentifier:locationCellIdentify];
            if (locationCells == nil) {
                locationCells = [[LocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationCellIdentify];
                
            }
            locationCells.collectionModel = myCollectionModel;
            NewLocationModel *model = [self getLocationModleFrom:myCollectionModel.body];

            NSString *mapPath = [StringUtil getMapPath:model.lantitudeStr withLongitude:model.longtitudeStr];
            UIImage *img=[UIImage imageWithContentsOfFile:mapPath];
            UIImage *image = [img imageByScalingAndCroppingForSize:CGSizeMake(locationCells.locationImage.frame.size.width, locationCells.locationImage.frame.size.height)];
            locationCells.locationImage.image = image;
            NSAttributedString *address = [[self class]getAddress:model.address];
            locationCells.address.attributedText = address;
            
            cell = locationCells;
        }
            break;
        case type_news:
        {
            NewsCell *newsCell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentify];
            if (newsCell == nil) {
                newsCell = [[NewsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newsCellIdentify];
            }
            newsCell.collectionModel = myCollectionModel;
            LGNewsMdelARC *model = [self getNewsModleFrom:myCollectionModel.body];
            newsCell.titleLabel.text = model.title;
            newsCell.logoImage.image = [StringUtil getImageByResName:@"chat_files_image.png"];
            cell = newsCell;
        }
        default:
            break;
    }
    
    UIImageView *editingBtn = [cell viewWithTag:102];
    
    BOOL isEditing = _isEditing;
    if (!isEditing)
    {
        UIImageView *userIcon = [cell viewWithTag:103];
        if (userIcon.frame.origin.x != 12)
        {
            CGRect iconRect = userIcon.frame;
            iconRect.origin.x -= 40;
            userIcon.frame = iconRect;
            
            UILabel *userName = [cell viewWithTag:104];
            CGRect userNameRect = userName.frame;
            userNameRect.origin.x -= 40;
            userName.frame = userNameRect;
            
            UIView *view = [cell viewWithTag:105];
            CGFloat x = view.frame.origin.x;
            CGFloat y = view.frame.origin.y;
            CGRect viewRect = view.frame;
            viewRect.origin.x -= 40;
            view.frame = viewRect;
//            
            if (myCollectionModel.realType == type_record && !myCollectionModel.robotModel)
            {
//                普通语音
//                UIView *background = [cell viewWithTag:115];
//                CGRect backgroundRect = background.frame;
//                backgroundRect.origin.x -= 40;
//                background.frame = backgroundRect;

            }
            else if (myCollectionModel.realType == type_video)
            {
                UILabel *duration = [cell viewWithTag:535];
                CGRect durationRect = duration.frame;
                durationRect.origin.x -= 40;
                duration.frame = durationRect;
            }
            else if ( myCollectionModel.realType == type_file)
            {
                UIView *imgViews = [cell viewWithTag:515];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x -= 40;
                imgViews.frame = imgViewRects;

            }
            else if (myCollectionModel.realType == type_location)
            {
                UIView *imgViews = [cell viewWithTag:603];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x -= 40;
                imgViews.frame = imgViewRects;
                
                
            }
            else if (myCollectionModel.realType == type_news)
            {
                UIView *imgViews = [cell viewWithTag:703];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x -= 40;

                imgViews.frame = imgViewRects;

            }

            
            editingBtn.hidden = YES;
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *userIcon = [cell viewWithTag:103];
        if (userIcon.frame.origin.x != 52)
        {
            CGRect iconRect = userIcon.frame;
            iconRect.origin.x += 40;
            userIcon.frame = iconRect;
            
            UILabel *userName = [cell viewWithTag:104];
            CGRect userNameRect = userName.frame;
            userNameRect.origin.x += 40;
            userName.frame = userNameRect;
            
            UILabel *view = [cell viewWithTag:105];
            CGRect viewRect = view.frame;
            viewRect.origin.x += 40;
            view.frame = viewRect;
            
            if (myCollectionModel.realType == type_record && !myCollectionModel.robotModel)
            {
////                普通的语音片段
//                UIView *background = [cell viewWithTag:115];
//                CGRect backgroundRect = background.frame;
//                backgroundRect.origin.x += 40;
//                background.frame = backgroundRect;

            }
            else if (myCollectionModel.realType == type_video )
            {
                UILabel *duration = [cell viewWithTag:535];
                CGRect durationRect = duration.frame;
                durationRect.origin.x += 40;
                duration.frame = durationRect;
            }
            else if (myCollectionModel.realType == type_file)
            {
                UIView *imgViews = [cell viewWithTag:515];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x += 40;
                imgViews.frame = imgViewRects;
            }
            else if (myCollectionModel.realType == type_location)
            {
                
                UIView *imgViews = [cell viewWithTag:603];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x += 40;
                imgViews.frame = imgViewRects;
                
               
            }
            else if (myCollectionModel.realType == type_news){
                UIView *imgViews = [cell viewWithTag:703];
                CGRect imgViewRects = imgViews.frame;
                imgViewRects.origin.x += 40;

                imgViews.frame = imgViewRects;

            }
            
            editingBtn.hidden = NO;
        }
        
        if ([self.editingBtn_IsSelected_Dic objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]])
        {
            UIImage *iamge = [StringUtil getImageByResName:@"btn_checkbox_pressed"];
            editingBtn.image = iamge;
        }
        else
        {
            [editingBtn setImage:[StringUtil getImageByResName:@"photo_Selection.png"]];

        }
    }
    
    return cell;
}




#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionModel *model = nil;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        model = self.searchResultArray[indexPath.row];
    }
    else
    {
        model = self.myCollectionData[indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isEditing)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *editingBtn = [cell viewWithTag:102];
        if ([self.editingBtn_IsSelected_Dic objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]])
        {
            [self.editingBtn_IsSelected_Dic removeObjectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
            [editingBtn setImage:[StringUtil getImageByResName:@"photo_Selection.png"]];
            [self.editingArray removeObject:model];
        }
        else
        {
            [self.editingBtn_IsSelected_Dic setObject:@"1" forKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]];
            [editingBtn setImage:[StringUtil getImageByResName:@"btn_checkbox_pressed"]];
            
            [self.editingArray addObject:model];
        }
        [self setNavigationItemTitle:[NSString stringWithFormat:@"已选%d个",(int)self.editingArray.count]];

    }
    else
    {
        // 动画取消被选中状态
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIViewController *topViewController = self.navigationController.topViewController;
        if ([topViewController isKindOfClass:[CollectionDetailController class]]) {
            NSLog(@"top view controller is CollectionDetailController");
            return;
        }
        
        CollectionDetailController *detailController = [[CollectionDetailController alloc] init];
        detailController.delegate = self;
        detailController.collectionModel = model;
        
        _preIndexPath = indexPath;
        
        CollectionParentCell *cell = (CollectionParentCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        // 设置返回按钮的标题
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.backBarButtonItem = backItem;
        backItem.title = [StringUtil getLocalizableString:@"collections"];
        [self.navigationController pushViewController:detailController animated:YES];
    }
}
// 编辑状态时 删除按钮的标题
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [StringUtil getLocalizableString:@"me_common_departments_delete"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - deleteDelegate
- (void)deleteCollection:(MyCollectionModel *)collectionModel
{
    //删除对应数据
    CollectionDAO *collectionDAO = [CollectionDAO shareDatabase];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"origin_id"] = collectionModel.originID;
    dic[@"file_name"] = collectionModel.fileName;
    dic[@"msg_type"] = @(collectionModel.type);
    [collectionDAO deleteCollection:@[dic]];
    
    if (_isSearching)
    {
        [self.searchResultArray removeObjectAtIndex:_preIndexPath.row];
        for (int i = 0; i < self.myCollectionData.count; i++)
        {
            MyCollectionModel *model = self.myCollectionData[i];
            if ([model.originID isEqual:collectionModel.originID])
            {
                [self.myCollectionData removeObject:model];
            }
        }
        
        //刷新tableview
        [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[_preIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        [self.myCollectionData removeObject:collectionModel];
        
        //刷新tableview
        [self.collectionTableView deleteRowsAtIndexPaths:@[_preIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *editingBtn = [cell viewWithTag:102];
    if ([self.editingBtn_IsSelected_Dic objectForKey:[NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row]])
    {
        [editingBtn setImage:[StringUtil getImageByResName:@"photo_Selection"] forState:UIControlStateNormal];
    }
    else
    {
        [editingBtn setImage:[StringUtil getImageByResName:@"btn_checkbox_pressed"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - 设置是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEditing)
    {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //删除对应数据
        MyCollectionModel *collectionModel = nil;
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            collectionModel = self.searchResultArray[indexPath.row];
        }
        else
        {
            collectionModel = self.myCollectionData[indexPath.row];
        }
        
        CollectionDAO *collectionDAO = [CollectionDAO shareDatabase];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"origin_id"] = collectionModel.originID;
        dic[@"file_name"] = collectionModel.fileName;
        dic[@"msg_type"] = @(collectionModel.type);
        [collectionDAO deleteCollection:@[dic]];
        
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            for (int i = 0; i < self.myCollectionData.count; i++)
            {
                MyCollectionModel *model = self.myCollectionData[i];
                
                if ([model.originID isEqual:collectionModel.originID])
                {
                    [self.myCollectionData removeObject:model];
                }
            }
        }
        else
        {
            [self.myCollectionData removeObject:collectionModel];
        }
        if (tableView==self.searchDisplayController.searchResultsTableView)
        {
            [self.searchResultArray removeObjectAtIndex:indexPath.row];
        }

        //刷新tableview
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        
        
        
    }
}

#pragma mark - searchResultHeaderView
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KSCREEN_SIZE.width, 25)];
//    headerView.backgroundColor = [UIColor whiteColor];
//    if (section == 0)
//    {
//        [headerView setText:@"  用户"];
//    }
//    else if (section == 1)
//    {
//        [headerView setText:@"  内容"];
//    }
//
//    return headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (tableView==self.searchDisplayController.searchResultsTableView)
//    {
//        if (_searchFlag && self.searchResultArray != 0)
//        {
//            return 25;
//        }
//    }
//    return 0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionModel* myCollectionModel = nil;
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        myCollectionModel = self.searchResultArray[indexPath.row];
    }
    else
    {
        myCollectionModel = self.myCollectionData[indexPath.row];
    }
    
    switch (myCollectionModel.realType) {
        case type_text:
        case type_long_msg:
            return 117;
            break;
            
        case type_record:
            if (myCollectionModel.title) {
                return 107;
            }
            return 112;
            break;
            
        case type_file:
            return 144;
            break;
            
        case type_pic:
            return 195;
            break;
            
        case type_imgtxt:
            return 80;
            break;
            
        case type_video:
        {
            if (myCollectionModel.title)
                return 105;
            
            return 165;
        }
            break;
        case type_location:
        {
            return 237.5;
        }
            break;
        case type_news:
        {
            return 144;
        }
            
        default:
            break;
    }
    
    return 80;
}

-(NewLocationModel *)getLocationModleFrom:(NSString *)body
{
    
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    NSDictionary *dics = [dic objectForKey:@"location"];
    
    NewLocationModel *model = [[NewLocationModel alloc]init];
    model.address = [dics objectForKey:@"address"];
    
    
    model.lantitudeStr = [dics objectForKey:@"latitude"];
    model.longtitudeStr = [dics objectForKey:@"longitude"];

    return  model;
}
-(LGNewsMdelARC *)getNewsModleFrom:(NSString *)body
{
    
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    LGNewsMdelARC *model = [[LGNewsMdelARC alloc]init];
    model.type = [dic objectForKey:@"type"];
    model.title = [dic objectForKey:@"title"] ;
    model.url = [dic objectForKey:@"url"] ;
    
    return  model;
}


+(NSAttributedString *)getAddress:(NSString *)label
{
    NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
    UIFont *font = [UIFont systemFontOfSize:ADDRESSFONT];
    paraStyle01.alignment = NSTextAlignmentLeft;  //对齐
    paraStyle01.headIndent = 0.0f;//行首缩进
    CGFloat emptylen = font.pointSize * 0.5;
    paraStyle01.firstLineHeadIndent = emptylen;//首行缩进
    paraStyle01.tailIndent = 0.0f;//行尾缩进
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:label attributes:@{NSParagraphStyleAttributeName:paraStyle01}];
    //paraStyle01.lineSpacing = 2.0f;//行间距
    return attrText;
}

@end
