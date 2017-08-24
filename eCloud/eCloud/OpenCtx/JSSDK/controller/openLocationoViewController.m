//
//  openLocationoViewController.m
//  eCloud
//
//  Created by Ji on 16/8/17.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "openLocationoViewController.h"
#import "LocationModel.h"
#import "LocationMsgUtil.h"
#import "eCloudDefine.h"

#import "UIAdapterUtil.h"

#import "StringUtil.h"
#import "UserTipsUtil.h"
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

static NSString *cellIdentify = @"cellIdentify";
static NSString *searchResultCellIdentify = @"searchResultCellIdentify";

@interface openLocationoViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKPoiSearchDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geocodesearch;
    BMKPoiSearch *_poiSearch;    //poi搜索
    BMKNearbySearchOption *_nearBySearchOption;
    BMKPointAnnotation *_annotation;
    NSString *_cityName;   // 检索城市名
    NSString *_keyWord;    // 检索关键字
    int currentPage;       // 当前页
    int pageNum;
    
    BOOL isClickFlag;
    BOOL flag;
    BOOL shouldAdjustSearchBarFrame;
    
    BOOL shouldLoadMoreData;
    
    
    UIButton *_locationBtn;

    
    NSInteger _selectedCellIndex;
    BMKLocationViewDisplayParam *_displayParam;
    UIImageView *_redPin;
}

@property (nonatomic, strong) BMKMapView *mapView;



@end

@implementation openLocationoViewController

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

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.edgesForExtendedLayout = UIRectEdgeLeft;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = [StringUtil getLocalizableString:@"location"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [self loadMapView];
    [self addLocationButton];
}

- (void)addLocationButton
{
    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationBtn.frame = CGRectMake(KSCREEN_WIDTH - 55, self.mapView.frame.size.height - 55 , 45, 45);
    //[_locationBtn setTitle:@"定位" forState:UIControlStateNormal];
    //[_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_locationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [_locationBtn setImage:[StringUtil getImageByResName:@"Button_positioning_icon.png"] forState:UIControlStateNormal];
    [_locationBtn setImage:[StringUtil getImageByResName:@"Button_positioning_icon_hl.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:_locationBtn];
}

- (void)startLocation
{
    [_mapView removeAnnotations:_mapView.annotations];
    [_locService startUserLocationService];
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL];
    
}

- (void)loadMapView
{
    self.mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    //    self.mapView.showMapScaleBar = YES;
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUserLocation"];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([arr[0] floatValue], [arr[1] floatValue]);
    self.mapView.logoPosition = BMKLogoPositionLeftTop;

//    _redPin = [LocationMsgUtil getRedPinImageView];
//    _redPin.center = self.mapView.center;
//    [self.mapView addSubview:_redPin];
    
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
    [self.view addSubview:self.mapView];
}

// 地图显示的区域改变时调用
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    
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
//    _displayParam = [[BMKLocationViewDisplayParam alloc]init];
//    _displayParam.isRotateAngleValid = YES;//跟随态旋转角度是否生效
//    _displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
//    _displayParam.locationViewImgName= @"icon_center_point";//定位图标名称
//    _displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
//    _displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
//    [_mapView updateLocationViewWithParam:_displayParam];
    
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
    
    _mapView.showsUserLocation = YES;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
//    _mapView.showsUserLocation = YES;//显示定位图层
    //    _mapView.showsUserLocation = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时置为nil
    
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
    
    if (error == 0) {
        
            BMKPoiInfo *poiInfo = result.poiList[0];
            _annotation = [[BMKPointAnnotation alloc]init];
            _annotation.coordinate = result.location;
            NSString *titleStr = [NSString stringWithFormat:@"%@%@",poiInfo.address,poiInfo.name];
            _annotation.title = titleStr;
            _mapView.centerCoordinate = result.location;
            [self.mapView addAnnotation:_annotation];
            [self.mapView selectAnnotation:_annotation animated:YES];//这样就可以在初始化的时候将 气泡信息弹出
       
    }else{
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"定位失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [myAlertView show];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
   
}

@end
