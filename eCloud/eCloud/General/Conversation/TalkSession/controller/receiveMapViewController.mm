//
//  receiveMapViewController.m
//  eCloud
//
//  Created by Alex L on 16/4/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "receiveMapViewController.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "eCloudDefine.h"

#import "LocationMsgUtil.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>  //引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>   //引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
//#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#import <MapKit/MapKit.h>
#import "ForwardingRecentViewController.h"
#import "UserTipsUtil.h"

//ios8及以后
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0 )

#define KSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define KSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define DEVIATION_LATITUDE 0.0062
#define DEVIATION_LONGITUDE 0.0065
#define RECEIVE_MAP_VIEW_CONTROLLER @"receiveMapViewController"
@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface receiveMapViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate, UIActionSheetDelegate,ForwardingDelegate>
{
    BMKLocationService *_locService;
    BMKRouteSearch* _routesearch;
    
    CLLocationCoordinate2D _endCoords;   // 目的地的经纬度
    
    BOOL polylineFlag;   // 显示还是隐藏路线
    BOOL mapCenterFlag;  // 保证第一次进入时以接收到的位置为地图的中心
    UIView *_navigationView;
    UIButton *_navigationBtn;
    UIButton *_shareButton;
}

@property (nonatomic, strong) BMKMapView *mapView;


@end

@implementation receiveMapViewController

- (void)dealloc
{
    if (_mapView) {
        _mapView = nil;
    }
    if (_locService) {
        _locService = nil;
    }
    if (_routesearch) {
        _routesearch = nil;
    }
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO];

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    self.title = [StringUtil getLocalizableString:@"location"];

    [self loadMapView];
    
    NSLog(@"%f-%f", self.latitude, self.longitude);
}

- (void)addAnnotation {
    
//    BMKPointAnnotation *annotation1=[[BMKPointAnnotation alloc]init];
//    annotation1.image= [StringUtil getImageByResName:@""];
//    
//    [self.mapView addAnnotation:annotation1];
//    
}

- (void)loadMapView
{
    _endCoords = CLLocationCoordinate2DMake(self.latitude, self.longitude);//纬度，经度
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 82)];
    self.mapView.centerCoordinate = _endCoords;
    self.mapView.showMapScaleBar = NO;
    _mapView.rotateEnabled = NO;
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
    
    [self.view addSubview:self.mapView];
    
    // 添加大头针
    BMKPointAnnotation *item = [[BMKPointAnnotation alloc]init];
    item.coordinate = _endCoords;
    [_mapView addAnnotation:item];
    
    // 添加定位按钮
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[locationBtn setTitle:@"定位" forState:UIControlStateNormal];
    //[locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn setImage:[StringUtil getImageByResName:@"btn_map_gps_normal"] forState:UIControlStateNormal];
    [locationBtn setImage:[StringUtil getImageByResName:@"btn_map_gps_pressed"] forState:UIControlStateHighlighted];
    locationBtn.frame = CGRectMake(KSCREEN_WIDTH - 56, KSCREEN_HEIGHT - 82-56, 44, 44);
    
    // 添加显示地名和导航按钮的view
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, KSCREEN_HEIGHT - 82, KSCREEN_WIDTH, 82)];
    _navigationView.backgroundColor = [UIColor whiteColor];
    UILabel *buildingName = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, KSCREEN_WIDTH-68-12, 25)];
    buildingName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    [buildingName setText:self.buildingName];
    
    UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(12, 45, KSCREEN_WIDTH-68-12, 18)];
    address.font = [UIFont fontWithName:@"PingFangHK-Regular" size:15];
    address.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0];
    address.text = self.address;
    
    _navigationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navigationBtn.frame = CGRectMake(KSCREEN_WIDTH-56, 19, 44, 44);
    [_navigationBtn setImage:[StringUtil getImageByResName:@"btn_map_guidance_normal"] forState:UIControlStateNormal];
    [_navigationBtn setImage:[StringUtil getImageByResName:@"btn_map_guidance_pressed"] forState:UIControlStateHighlighted];
    [_navigationBtn addTarget:self action:@selector(beginNavigation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:locationBtn];
    [_navigationView addSubview:buildingName];
    [_navigationView addSubview:address];
    [_navigationView addSubview:_navigationBtn];
    [self.view addSubview:_navigationView];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 12 - 28,25,28,28)];
    [shareButton addTarget:self action:@selector(ShareWithFriends) forControlEvents:(UIControlEventTouchUpInside)];
    [shareButton setImage:[StringUtil getImageByResName:@"ic_actbar_gps_more"] forState:UIControlStateNormal];
//    [shareButton setImage:[StringUtil getImageByResName:@"ic_actbar_gps_more"] forState:UIControlStateHighlighted];
    [self.view addSubview:shareButton];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(12,25,28,28)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:(UIControlEventTouchUpInside)];
    [backButton setImage:[StringUtil getImageByResName:@"ic_actbar_map_gps_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
}

- (void)startLocation
{
    [_locService startUserLocationService];
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL];
    
    NSLog(@"startLocation");
}

- (void)beginNavigation
{
    if (IOS8_OR_LATER)
    {
        UIAlertController *alertCtl = [[UIAlertController alloc] init];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *showAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"According_to_route"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf showNavigationOverlayView];
            polylineFlag = YES;
        }];
        
        UIAlertAction *HideAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"hide_the_route"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf hideNavigationOverlayView];
            polylineFlag = NO;
        }];
        
        UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"Baidu_map"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf openBaiduMap];
        }];
        
        UIAlertAction *gaodeAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"Scott_map"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf openGaodeMap];
        }];
        
        UIAlertAction *appleAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"Apple_map"]  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [weakSelf openAppleMap];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [weakSelf popoverPresentationController];
        }];
        
        
        [alertCtl addAction:polylineFlag ? HideAction : showAction];
        [alertCtl addAction:baiduAction];
        [alertCtl addAction:gaodeAction];
        [alertCtl addAction:appleAction];
        [alertCtl addAction:cancelAction];
        if (IS_IPAD) {
            
            UIPopoverPresentationController *popPresenter = [alertCtl popoverPresentationController];popPresenter.sourceView = _navigationBtn;
            popPresenter.sourceRect = _navigationBtn.bounds;
            [self presentViewController:alertCtl animated:YES completion:nil];

        }else{
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
    }
    else
    {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString: polylineFlag ? @"hide_the_route" : @"According_to_route"], [StringUtil getLocalizableString:@"Baidu_map"], [StringUtil getLocalizableString:@"Scott_map"],[StringUtil getLocalizableString:@"Apple_map"], nil];
        menu.tag = 100;
        [menu showInView:self.view];
    }
    
    NSLog(@"beginNavigation");
}

// 隐藏路线
- (void)hideNavigationOverlayView
{
    NSArray *array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
}

// 显示路线
- (void)showNavigationOverlayView
{
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = _locService.userLocation.location.coordinate;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = _endCoords;
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
}

// 打开百度地图
- (void)openBaiduMap
{
    // coord_type允许的值为bd09ll、gcj02、wgs84 如果你APP的地图SDK用的是百度地图SDK 请填bd09ll
    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",self.latitude-DEVIATION_LATITUDE, self.longitude-DEVIATION_LONGITUDE] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else
    {
        NSLog(@"你还没有安装百度地图");
    }
}

// 打开高德地图
- (void)openGaodeMap
{
    //            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"MapNavigation",@"com.csair.eCloud",self.latitude, self.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // 废弃、过时的方法
    NSString *urlStr = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"MapNavigation",@"com.csair.eCloud",self.latitude-DEVIATION_LATITUDE, self.longitude-DEVIATION_LONGITUDE] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    BOOL isSuccess = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    if (!isSuccess)
    {
        NSLog(@"你还没有安装高德地图");
    }
}


// 打开苹果地图
- (void)openAppleMap
{
    //当前的位置 // 起点
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    //目的地的位置
    CLLocationCoordinate2D endCoords = CLLocationCoordinate2DMake(self.latitude-DEVIATION_LATITUDE, self.longitude-DEVIATION_LONGITUDE);
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoords addressDictionary:nil]];
    toLocation.name = self.buildingName;
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    NSDictionary *options = @{
                              MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                              MKLaunchOptionsMapTypeKey:[NSNumber numberWithInteger:MKMapTypeStandard],
                              MKLaunchOptionsShowsTrafficKey:@YES
                              };
    //打开苹果自身地图应用，并呈现特定的item
    BOOL isSuccess = [MKMapItem openMapsWithItems:items launchOptions:options];
    if (!isSuccess)
    {
        NSLog(@"打开失败");
    }
}

#pragma mark - BMKMapViewDelegate   划导航线的代理方法
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
        polylineView.lineWidth = 4.0;
        return polylineView;
    }
    return nil;
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        
    switch (buttonIndex) {
        case 0:
        {
            if (polylineFlag)
            {
                [self hideNavigationOverlayView];
            }
            else
            {
                [self showNavigationOverlayView];
            }
            polylineFlag = !polylineFlag;
        }
            break;
            
        case 1:
        {
            [self openBaiduMap];
        }
            break;
            
        case 2:
        {
            [self openGaodeMap];
        }
            break;
            
        case 3:
        {
            [self openAppleMap];
        }
            break;
            
        case 4:
        {
            //[self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
    }else{
        
        switch (buttonIndex) {
            case 0:
            {
                [self openRecentContacts];
            }
                break;
            case 1:
            {
                //[self.navigationController popViewControllerAnimated:YES];
            }
                break;
    }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(dismissSelf:) name:@"dismiss" object:nil];
    
    [_mapView viewWillAppear];
    
    //     去掉范围圈
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = true;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewImgName= @"ic_map_gps_location@2x.png";//定位图标名称
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 10;//定位偏移量（纬度）
    [_mapView updateLocationViewWithParam:displayParam];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放

    _routesearch = [[BMKRouteSearch alloc] init];
    _routesearch.delegate = self;
    
    // 定位
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self addAnnotation];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.mapView setZoomLevel:MAP_ZOOM_LEVEL]; // 缩放大小
    
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态为跟随态
    _mapView.showsUserLocation = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _routesearch.delegate = nil;

}

#pragma mark - 定位成功后调用的代理方法
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    if (mapCenterFlag == NO)
    {
        self.mapView.centerCoordinate = _endCoords;
        
        mapCenterFlag = YES;
    }
    else
    {
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    }
    
    [_locService stopUserLocationService];
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    //    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
    }
}
- (void)ShareWithFriends
{
    if (IOS8_OR_LATER)
    {
        UIAlertController *alertCtl = [[UIAlertController alloc] init];
        
        UIAlertAction *SendFriends = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"send_to_someone"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [self openRecentContacts];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [self popoverPresentationController];
        }];
        
        [alertCtl addAction:SendFriends];
        [alertCtl addAction:cancelAction];
        if (IS_IPAD) {
            
            UIPopoverPresentationController *popPresenter = [alertCtl popoverPresentationController];popPresenter.sourceView = _shareButton;
            if (popPresenter) {
                
                popPresenter.barButtonItem = self.navigationItem.rightBarButtonItem;
            }
            [self presentViewController:alertCtl animated:YES completion:nil];
            
        }else{
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
    }
    else
    {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"send_to_someone"], nil];
        menu.tag = 200;
        [menu showInView:self.view];
    }
    
}

#pragma mark - 发送给朋友（借用转发功能）
//打开最近的联系人，用来转发
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc] initWithConvRecord:self.forwardRecord];
    forwarding.fromType = transfer_from_image_preview;
    forwarding.forwardingDelegate = self;
    
    forwarding.fromWhere = RECEIVE_MAP_VIEW_CONTROLLER;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor = [UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
    //    [self presentModalViewController:nav animated:YES];
}

#pragma mark =======转发提示=========
- (void)showTransferTips
{
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
- (void)dismissSelf:(NSNotificationCenter *)notification
{
    [self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismiss" object:nil];
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = self.mapView.frame;
    CGRect _navigationViewFrame = _navigationView.frame;
    CGRect _navigationBtnFrame = _navigationBtn.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    _navigationViewFrame.size.width = SCREEN_WIDTH;
    _navigationViewFrame.origin.y = KSCREEN_HEIGHT - 70 - 64;
    _navigationBtnFrame.origin.x = KSCREEN_WIDTH - 55;
    self.mapView.frame = _frame;
    _navigationView.frame = _navigationViewFrame;
    _navigationBtn.frame = _navigationBtnFrame;
    
   
}
@end
