//
//  sendMapViewController.m
//  eCloud
//
//  Created by Alex L on 16/4/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "sendMapViewController.h"
#import "LocationMsgCell.h"
#import "LocationModel.h"
#import "LocationMsgUtil.h"
#import "eCloudDefine.h"

#import "UIAdapterUtil.h"

#import "StringUtil.h"
#import "UserTipsUtil.h"

#import "talkSessionViewController.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>  //引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>   //引入定位功能所有的头文件
//#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#define SEARCHBAR_X 0
#define SEARCHBAR_Y 0
#define SEARCHBAR_HEIGHT 45

#define TABLEVIEW_TAG 102
// 最多几页
#define MAX_PAGE_INDEX 6

#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

//地图高度 计算出来
#define CUR_MAP_HEIGHT ((KSCREEN_WIDTH * LOCATION_PIC_HEIGHT) / LOCATION_PIC_WIDTH)

static NSString *cellIdentify = @"cellIdentify";
static NSString *searchResultCellIdentify = @"searchResultCellIdentify";

@interface sendMapViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geocodesearch;
    BMKPoiSearch *_poiSearch;    //poi搜索
    BMKNearbySearchOption *_nearBySearchOption;
    
    NSString *_cityName;   // 检索城市名
    NSString *_keyWord;    // 检索关键字
    int currentPage;       // 当前页
    int pageNum;
    
    BOOL isClickFlag;
    BOOL flag;
    BOOL shouldAdjustSearchBarFrame;
    
    BOOL shouldLoadMoreData;
    
    
    UIButton *_locationBtn;
    
    NSInteger _searchSelectedCellIndex;
    BOOL searchCellIsSelected;        // 是不是点击了searchDisplayControllerTableVeiw
    
    NSInteger _selectedCellIndex;
    BMKLocationViewDisplayParam *_displayParam;
    UIImageView *_redPin;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) NSMutableDictionary *poiByLocationDic;
@property (nonatomic, strong) NSMutableDictionary *poiByKeywordDic;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *displayController;

@property (nonatomic, strong) UILabel *searchErrorTip;  /**     没有搜索结果时的提示  */
@property (nonatomic, weak) UIButton *cancelButton;   /**     搜索时的取消按钮     */

@end

@implementation sendMapViewController

- (void)dealloc
{
    if (_geocodesearch != nil)
    {
        _geocodesearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}

- (NSMutableDictionary *)poiByLocationDic
{
    if (_poiByLocationDic == nil)
    {
        _poiByLocationDic = [NSMutableDictionary dictionary];
        [_poiByLocationDic setObject:[NSMutableArray array] forKey:@"name"];
        [_poiByLocationDic setObject:[NSMutableArray array] forKey:@"address"];
        [_poiByLocationDic setObject:[NSMutableArray array] forKey:@"pt"];
    }
    return _poiByLocationDic;
}

- (NSMutableDictionary *)poiByKeywordDic
{
    if (_poiByKeywordDic == nil)
    {
        _poiByKeywordDic = [NSMutableDictionary dictionary];
        [_poiByKeywordDic setObject:[NSMutableArray array] forKey:@"name"];
        [_poiByKeywordDic setObject:[NSMutableArray array] forKey:@"address"];
        [_poiByKeywordDic setObject:[NSMutableArray array] forKey:@"pt"];
    }
    return _poiByKeywordDic;
}
- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //self.edgesForExtendedLayout = UIRectEdgeLeft;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = [StringUtil getLocalizableString:@"location"];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:[StringUtil getLocalizableString:@"send"] style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
    self.navigationItem.rightBarButtonItem = sendItem;
#ifdef _LANGUANG_FLAG_
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangHK-Regular" size:17],NSFontAttributeName, nil] forState:UIControlStateNormal];
#endif
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [self loadMapView];
    [self addTableView];
    [self addSearchBar];
    [self initPoiSearch];
    [self addLocationButton];
}

- (void)addLocationButton
{
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationBtn.frame = CGRectMake(KSCREEN_WIDTH - 56, CUR_MAP_HEIGHT-12, 44, 44);
    //[_locationBtn setTitle:@"定位" forState:UIControlStateNormal];
    //[_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_locationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [_locationBtn setImage:[StringUtil getImageByResName:@"btn_map_gps_normal"] forState:UIControlStateNormal];
    [_locationBtn setImage:[StringUtil getImageByResName:@"btn_map_gps_pressed"] forState:UIControlStateHighlighted];
    [self.view addSubview:_locationBtn];
}

- (void)startLocation
{
    [_locService startUserLocationService];
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL];
    
}

#pragma mark --初始化poi类
-(void)initPoiSearch
{
    _poiSearch = [[BMKPoiSearch alloc]init];
    _poiSearch.delegate = self;
    currentPage = 0;
    //附近云检索，其他检索方式见详细api
    _nearBySearchOption = [[BMKNearbySearchOption alloc]init];
    _nearBySearchOption.pageIndex = currentPage;    //第几页
    _nearBySearchOption.pageCapacity = 12;    //一页几个
    _nearBySearchOption.radius = 35000; //检索范围 m
    
}

#pragma mark --BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误号，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if(_searchErrorTip){
        [_searchErrorTip removeFromSuperview];
        _searchErrorTip=nil;
    }
    if (errorCode == BMK_SEARCH_NO_ERROR)
    {

        NSMutableArray *poiNameListArray = [self.poiByKeywordDic objectForKey:@"name"];
        NSMutableArray *poiAddressListArray = [self.poiByKeywordDic objectForKey:@"address"];
        NSMutableArray *poiPtListArray = [self.poiByKeywordDic objectForKey:@"pt"];
        //总页数
        pageNum = poiResult.pageNum;
        for (int i = 0; i < poiResult.poiInfoList.count; i++)
        {
            BMKPoiInfo* poi = [poiResult.poiInfoList objectAtIndex:i];
            [poiNameListArray addObject:poi.name];
            [poiAddressListArray addObject:poi.address];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:poi.pt.latitude longitude:poi.pt.longitude];
            [poiPtListArray addObject:location];
            //            BMKPoiInfo就是检索出来的poi信息
        }
        
        shouldLoadMoreData = YES;
  
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        if (((currentPage + 1) == pageNum))
        {
            self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = YES;  // 显示加载中
        }
        
    }
    
    else
    {
        NSMutableArray *poiNameListArray = [self.poiByKeywordDic objectForKey:@"name"];
        NSMutableArray *poiAddressListArray = [self.poiByKeywordDic objectForKey:@"address"];
        NSMutableArray *poiPtListArray = [self.poiByKeywordDic objectForKey:@"pt"];
        [poiNameListArray removeAllObjects];
        [poiAddressListArray removeAllObjects];
        [poiPtListArray removeAllObjects];
        
            
        _searchErrorTip = [[UILabel alloc] initWithFrame:CGRectMake((KSCREEN_WIDTH - 100)/2.0, 65, 100, 45)];
        _searchErrorTip.textAlignment = NSTextAlignmentCenter;
        [_searchErrorTip setFont:[UIFont systemFontOfSize:18]];
        _searchErrorTip.backgroundColor = [UIColor whiteColor];
        [_searchErrorTip setTextColor:[UIColor colorWithWhite:0.6 alpha:1]];
        _searchErrorTip.text = @"无结果";
        
        [self.view addSubview:_searchErrorTip];
        [self.searchDisplayController.searchResultsTableView reloadData];

    }
}

- (void)addSearchBar
{
  
    shouldAdjustSearchBarFrame = YES;

    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(SEARCHBAR_X, SEARCHBAR_Y, KSCREEN_WIDTH, SEARCHBAR_HEIGHT)];
    
    _searchBar.placeholder = [StringUtil getLocalizableString:@"search_tips"];
    _searchBar.delegate = self;
    [UIAdapterUtil setSearchColorForTextBarAndBackground:_searchBar];
    
    self.displayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.delegate = self;
    self.displayController.searchResultsDelegate = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchBar.placeholder = [StringUtil getLocalizableString:@"search_tips"];
    
    if (IOS9_OR_LATER) {
        
        self.displayController.searchResultsTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

    // 设置footerView
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH/2-20, 5, 70, 30)];
    label.text = @"加载中";
    [footerView addSubview:label];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH/2-50, 10, 20, 20)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityView startAnimating];
    [footerView addSubview:activityView];
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = footerView;
    self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = YES;
    
    [self.view addSubview:self.searchBar];
    
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"搜索Begin");
    if (shouldAdjustSearchBarFrame)
    {
        CGRect rect = searchBar.frame;
        rect.origin.y += 20;
        searchBar.frame = rect;
    }
    
    shouldAdjustSearchBarFrame = NO;
    
    return YES;
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(nonnull UITableView *)tableView
{
    for (UIView *subview in tableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [(UILabel *)subview setText:@""];
        }
    }
}

//输入文本实时更新时调用
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = YES;
    
}
// 进入搜索状态时
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    //self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = NO;  // 显示加载中
    NSMutableArray *poiNameListArray = [self.poiByKeywordDic objectForKey:@"name"];
    NSMutableArray *poiAddressListArray = [self.poiByKeywordDic objectForKey:@"address"];
    NSMutableArray *poiPtListArray = [self.poiByKeywordDic objectForKey:@"pt"];
    [poiNameListArray removeAllObjects];
    [poiAddressListArray removeAllObjects];
    [poiPtListArray removeAllObjects];
    
    self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = YES;

    [_searchErrorTip removeFromSuperview];
    _searchErrorTip = nil;
    

    
    [self.displayController.searchResultsTableView reloadData];
    
    
    [_searchBar setShowsCancelButton:YES animated:NO];
    UIView *topView = controller.searchBar.subviews[0];
    
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            _cancelButton = (UIButton*)subView;
            [_cancelButton setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];  //@"取消"
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
    [self.tableView reloadData];
    
}

// 点击取消搜索时
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    CGRect rect = _searchBar.frame;
    rect.origin.y -= 20;
    _searchBar.frame = rect;
    
    shouldAdjustSearchBarFrame = YES;
    if (_searchErrorTip) {
        [_searchErrorTip removeFromSuperview];
        _searchErrorTip = nil;
        
    }
}

//点击搜索按钮时才开始搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar.text length] < 2) {
        [UserTipsUtil showSearchTip];
        return;
    }
    
    NSMutableArray *poiNameListArray = [self.poiByKeywordDic objectForKey:@"name"];
    NSMutableArray *poiAddressListArray = [self.poiByKeywordDic objectForKey:@"address"];
    NSMutableArray *poiPtListArray = [self.poiByKeywordDic objectForKey:@"pt"];
    [poiNameListArray removeAllObjects];
    [poiAddressListArray removeAllObjects];
    [poiPtListArray removeAllObjects];
    
    self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = NO;  // 显示加载中
    shouldLoadMoreData = YES;
    currentPage = 0;
    
    // 取消第一响应者
    [searchBar resignFirstResponder];
    
    
    _nearBySearchOption.location = self.mapView.centerCoordinate; // poi检索点
    _nearBySearchOption.pageCapacity = 12;            //一页几个
    _nearBySearchOption.pageIndex = currentPage;
    _nearBySearchOption.keyword = searchBar.text;     //检索关键字
    BOOL flag = [_poiSearch poiSearchNearBy:_nearBySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
    
    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

// 搜索内容改变时
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    if (searchString.length == 0)
    {
        NSMutableArray *poiNameListArray = [self.poiByKeywordDic objectForKey:@"name"];
        NSMutableArray *poiAddressListArray = [self.poiByKeywordDic objectForKey:@"address"];
        NSMutableArray *poiPtListArray = [self.poiByKeywordDic objectForKey:@"pt"];
        [poiNameListArray removeAllObjects];
        [poiAddressListArray removeAllObjects];
        [poiPtListArray removeAllObjects];
        
        [self.displayController.searchResultsTableView reloadData];
        
        self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = NO;
        if (_searchErrorTip)
        {
            [_searchErrorTip removeFromSuperview];
            _searchErrorTip = nil;
            
        }
    }
    
    //    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    //    [self.searchDisplayController.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
    return NO;
}

- (void)addTableView
{
    float tempY = SEARCHBAR_HEIGHT + self.mapView.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tempY, KSCREEN_WIDTH, KSCREEN_HEIGHT- STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - tempY) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.tag = TABLEVIEW_TAG;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    if (IOS9_OR_LATER) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self.view addSubview:self.tableView];
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
}

- (void)sendLocation
{
    NSMutableArray *poiNameListArray = [self.poiByLocationDic objectForKey:@"name"];
    NSMutableArray *poiAddressListArray = [self.poiByLocationDic objectForKey:@"address"];
    NSMutableArray *poiPtListArray = [self.poiByLocationDic objectForKey:@"pt"];
    
    if (poiNameListArray.count == 0 || poiAddressListArray.count == 0 || poiPtListArray.count == 0) {
        return;
    }
    
    NSString *buildingName = poiNameListArray[_selectedCellIndex];
    NSString *address = poiAddressListArray[_selectedCellIndex];
    
    NSString *latitude  = [[NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude]stringValue];// [NSString stringWithFormat:@"%f",];
    NSString *longitude = [[NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude]stringValue];// [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude];
    
    BMKPointAnnotation *item = [[BMKPointAnnotation alloc]init];
    item.coordinate = self.mapView.centerCoordinate;
    [_mapView addAnnotation:item];
    
    // 截图前换成大头针，调用takeSnapshot也没用到大头针
    // 获取到大头针视图，更换图标
//    UIImageView *redPinView = [self.mapView viewWithTag:REDPIN_TAG];
//    redPinView.image = [StringUtil getImageByResName:@"ic_chat_map_pin"];
    //截图
    float mapHeight = (LOCATION_PIC_HEIGHT * KSCREEN_WIDTH) / LOCATION_PIC_WIDTH;

    UIImage *mapImage = [self.mapView takeSnapshot:CGRectMake(0, 0, self.mapView.frame.size.width, self.mapView.frame.size.height)];
    
    NSData *mapData = UIImagePNGRepresentation(mapImage);
    NSString *mapPath = [StringUtil getMapPath:latitude withLongitude:longitude];
    [mapData writeToFile:mapPath atomically:YES];
    
    NSDictionary *jsonDic = @{
                              KEY_MSG_TYPE: LOCATION_TYPE,
                              LOCATION_TYPE : @{
                                      KEY_LOCATION_URL : @"",
                                      KEY_LOCATION_LONGITUDE : longitude,
                                      KEY_LOCATION_LANTITUDE : latitude,
                                      KEY_LOCATION_ADDRESS  : [NSString stringWithFormat:@"%@-%@",buildingName,address]
                                      }
                              };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[talkSessionViewController getTalkSession]setConvStatusToNormal];
    [[talkSessionViewController getTalkSession] sendMessage:type_text message:jsonString filesize:-1 filename:nil andOldMsgId:nil];
    
    
    NSLog(@"发送位置");
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMapView
{
    self.mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 43, KSCREEN_WIDTH, CUR_MAP_HEIGHT)];
    //    self.mapView.showMapScaleBar = YES;
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUserLocation"];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([arr[0] floatValue], [arr[1] floatValue]);
    self.mapView.logoPosition = BMKLogoPositionLeftTop;
    
    _redPin = [LocationMsgUtil getRedPinImageView];
    CGRect _frame = _redPin.frame;
    _frame.origin = CGPointMake((self.mapView.frame.size.width - _frame.size.width) * 0.5 ,(self.mapView.frame.size.height - _frame.size.height) * 0.5 );
    
    _redPin.frame = _frame;
    [self.mapView addSubview:_redPin];
    
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
    [self.view addSubview:self.mapView];
    
#ifdef _LANGUANG_FLAG_
    
    //隐藏百度地图logo
    UIView *mView = _mapView.subviews.firstObject;
    for (id logoView in mView.subviews)
    {
        if ([logoView isKindOfClass:[UIImageView class]])
        {
            UIImageView *b_logo = (UIImageView*)logoView;
            b_logo.hidden = YES;
        }
    }
    
#endif
    
}

// 地图显示的区域改变时调用
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (isClickFlag == NO)
    {
        // 调用反地理编码的方法，完了后会调用反地理编码的代理方法
        [self reverseGeocode:self.mapView.centerCoordinate];
        NSLog(@"%f - %f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
        
        _selectedCellIndex = 0;
    }
    
    // 让tableview下去
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self adjustTableViewFrameWhenScroll:NO];
    
    isClickFlag = NO;
}

-(void)viewWillAppear:(BOOL)animated
{  
    [_mapView viewWillAppear];
    
    //适配ios7
    if(IOS7_OR_LATER)
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = self;
    
    //     去掉范围圈
    _displayParam = [[BMKLocationViewDisplayParam alloc]init];
    _displayParam.isRotateAngleValid = true;//跟随态旋转角度是否生效
    _displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    _displayParam.locationViewImgName= @"icon_center_point";//定位图标名称
    _displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    _displayParam.locationViewOffsetY = 10;//定位偏移量（纬度）
    
//#ifdef _LANGUANG_FLAG_
//    
//    _displayParam.isAccuracyCircleShow = YES;//精度圈是否显示
//    _displayParam.locationViewImgName= @"ic_map_gps_location";//定位图标名称
//    _displayParam.locationViewOffsetY = 6;//定位偏移量（纬度）
//    
//#endif
    [_mapView updateLocationViewWithParam:_displayParam];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    // 定位
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
}

- (void)viewDidAppear:(BOOL)animated {
    
    CLLocation *location = _locService.userLocation.location;
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
    self.mapView.centerCoordinate = _locService.userLocation.location.coordinate;
    
//    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态为跟随态
    _mapView.showsUserLocation = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时置为nil
    _mapView.showsUserLocation = NO;
}

#pragma mark - 定位成功后调用的代理方法
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    // 调用反地理编码的方法，不然不会调用反地理编码的代理方法
    [self reverseGeocode:userLocation.location.coordinate];
    
    [_mapView updateLocationData:userLocation];
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    [_locService stopUserLocationService];
    
    [[NSUserDefaults standardUserDefaults] setObject:@[@(userLocation.location.coordinate.latitude), @(userLocation.location.coordinate.longitude)] forKey:@"lastUserLocation"];
}

-(void)reverseGeocode:(CLLocationCoordinate2D)pt
{
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

// 反向地理编码 的 代理方法
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSMutableArray *poiNameListArray = [self.poiByLocationDic objectForKey:@"name"];
    NSMutableArray *poiAddressListArray = [self.poiByLocationDic objectForKey:@"address"];
    NSMutableArray *poiPtListArray = [self.poiByLocationDic objectForKey:@"pt"];
    [poiNameListArray removeAllObjects];
    [poiAddressListArray removeAllObjects];
    [poiPtListArray removeAllObjects];
    
    
    for(BMKPoiInfo *poiInfo in result.poiList)
    {
        
        NSLog(@"name = %@", poiInfo.name);
        [poiNameListArray addObject:poiInfo.name];
        [poiAddressListArray addObject:poiInfo.address];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:poiInfo.pt.latitude longitude:poiInfo.pt.longitude];
        [poiPtListArray addObject:location];
    }
    
    if (searchCellIsSelected)
    {
        NSMutableArray *nameListArray = [self.poiByKeywordDic objectForKey:@"name"];
        if (![[poiNameListArray firstObject] isEqual:nameListArray[_searchSelectedCellIndex]])
        {
            NSMutableArray *addressListArray = [self.poiByKeywordDic objectForKey:@"address"];
            NSMutableArray *ptListArray = [self.poiByKeywordDic objectForKey:@"pt"];
            
            [poiNameListArray insertObject:nameListArray[_searchSelectedCellIndex] atIndex:0];
            [poiAddressListArray insertObject:addressListArray[_searchSelectedCellIndex] atIndex:0];
            [poiPtListArray insertObject:ptListArray[_searchSelectedCellIndex] atIndex:0];
        }
        
        searchCellIsSelected = NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新
        [self.tableView reloadData];
    });
}

#pragma mark - UITableView_DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [[self.poiByKeywordDic objectForKey:@"name"] count];
    }
    
    return [[self.poiByLocationDic objectForKey:@"name"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchResultCellIdentify];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchResultCellIdentify];
        }
        
        cell.textLabel.text = [self.poiByKeywordDic objectForKey:@"name"][indexPath.row];
        
        [cell.detailTextLabel setText:[self.poiByKeywordDic objectForKey:@"address"][indexPath.row]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        //if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        //}
        
//        cell.textLabel.text = [self.poiByLocationDic objectForKey:@"name"][indexPath.row];
//        cell.textLabel.font = [UIFont systemFontOfSize:17];
//        
//        [cell.detailTextLabel setText:[self.poiByLocationDic objectForKey:@"address"][indexPath.row]];
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0];
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, SCREEN_WIDTH-12-40, 22)];
        label.font = [UIFont systemFontOfSize:17];
        label.text = [self.poiByLocationDic objectForKey:@"name"][indexPath.row];
        [cell addSubview:label];
        
        UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 35, SCREEN_WIDTH-12-40, 18)];
        detailLabel.font = [UIFont systemFontOfSize:15];
        [detailLabel setText:[self.poiByLocationDic objectForKey:@"address"][indexPath.row]];
        detailLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0];
        [cell addSubview:detailLabel];
        
        if (indexPath.row == _selectedCellIndex)
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }

        if (indexPath.row == 0) {
            
            detailLabel.hidden = YES;
            CGRect _frame = label.frame;
            _frame.origin.y = 0;
            _frame.size.height = 62;
            label.frame = _frame;
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableView_Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        CLLocation *location = [self.poiByKeywordDic objectForKey:@"pt"][indexPath.row];
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        
        [_cancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        _searchSelectedCellIndex = indexPath.row;
        searchCellIsSelected = YES;
    }
    else
    {
        // 如果和上次点击的一样就返回
        if (indexPath.row == _selectedCellIndex) {
            return;
        }
        
        isClickFlag = YES;
        CLLocation *location = [self.poiByLocationDic objectForKey:@"pt"][indexPath.row];
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];
        
        _selectedCellIndex = indexPath.row;
    }
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

#pragma mark - tableView滚动时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == TABLEVIEW_TAG)
    {
        if (scrollView.contentOffset.y > 15 && flag == NO)
        {
            [self adjustTableViewFrameWhenScroll:YES];
        }
        else if (scrollView.contentOffset.y < -15 && flag == YES)
        {
            [self adjustTableViewFrameWhenScroll:NO];
        }
    }
    else if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - 35)
    {
        if (!shouldLoadMoreData)  // scrollViewDidScroll会快速调用很多次，这是为了保证加载完这一次再开始加载下一次
        {
            return;
        }
        
        if ([[self.poiByKeywordDic objectForKey:@"name"] count] == 0) {
            return;
        }
        
        _nearBySearchOption.pageIndex = ++currentPage;     //当前页

        if (currentPage >= pageNum) {
            
            self.searchDisplayController.searchResultsTableView.tableFooterView.hidden = YES;
            if (_searchErrorTip) {
                [_searchErrorTip removeFromSuperview];
                _searchErrorTip = nil;
            }
            return;
        }
        
        _nearBySearchOption.pageCapacity = 12;    //一页几个
        _nearBySearchOption.radius = 35000; //检索范围 m
        BOOL flag = [_poiSearch poiSearchNearBy:_nearBySearchOption];
        if(flag)
        {
            NSLog(@"城市内检索发送成功");
        }
        else
        {
            NSLog(@"城市内检索发送失败");
        }
        
        shouldLoadMoreData = NO;
    }
}

- (void)adjustTableViewFrameWhenScroll:(BOOL)upOrDown
{
//    拖动时什么都不做
    return;
    
    if (upOrDown && flag == NO)
    {
        CGRect rect1 = self.tableView.frame;
        rect1.origin.y -= (KSCREEN_WIDTH/3 - 40);
       
        CGRect rect2 = self.mapView.frame;
        rect2.origin.y -= (KSCREEN_WIDTH/6 + 8);
  
        CGRect rect3 = _locationBtn.frame;
        rect3.origin.y -= (KSCREEN_WIDTH/3 + 16);

        [UIView animateWithDuration:.35f animations:^{
            
            self.tableView.frame = rect1;
            self.mapView.frame = rect2;
            _locationBtn.frame = rect3;
        }];
        
        flag = YES;
    }
    else if (!upOrDown && flag == YES)
    {
        CGRect rect1 = self.tableView.frame;
        rect1.origin.y += (KSCREEN_WIDTH/3 - 40);
       
        CGRect rect2 = self.mapView.frame;
        rect2.origin.y += (KSCREEN_WIDTH/6 + 8);

        CGRect rect3 = _locationBtn.frame;
        rect3.origin.y += (KSCREEN_WIDTH/3 + 16);
 
        [UIView animateWithDuration:.35f animations:^{
            
            self.tableView.frame = rect1;
            self.mapView.frame = rect2;
            _locationBtn.frame = rect3;
        }];
        
        flag = NO;
    }
}

//- (void)resetClick{
//    
//    
//}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // 让tableview下去
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self adjustTableViewFrameWhenScroll:NO];
    
    CGRect _frame = self.mapView.frame;
    CGRect _tableViewFram = self.tableView.frame;
    CGRect _locationBtnFram  = _locationBtn.frame;
    CGRect _redPinFram = _redPin.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = KSCREEN_HEIGHT*0.6;
    _frame.origin.y = 44;
    self.mapView.frame = _frame;

    _redPinFram.origin.x = self.mapView.frame.size.width * 0.5;
    _redPinFram.origin.y = self.mapView.frame.size.height * 0.5;
    _redPin.frame = _redPinFram;
    
    _tableViewFram.origin.y = self.mapView.frame.size.height + self.mapView.frame.origin.y;
    _tableViewFram.size.width = KSCREEN_WIDTH;
    //_tableViewFram.size.height = KSCREEN_HEIGHT - self.mapView.frame.origin.y + 100; //- STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    self.tableView.frame = _tableViewFram;
    [self.tableView reloadData];
    
    _locationBtnFram.origin.x = KSCREEN_WIDTH - 50;
    _locationBtnFram.origin.y = self.mapView.frame.size.height + self.mapView.frame.origin.y - 50;
    _locationBtn.frame = _locationBtnFram;

}
@end
