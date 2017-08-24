//
//  CurrentLocationUtil.m
//  eCloud
//
//  Created by Ji on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CurrentLocationUtil.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "JSONKit.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import <BaiduMapAPI_Location/BMKLocationComponent.h>

#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "UserTipsUtil.h"
#import "UIAdapterUtil.h"

@interface CurrentLocation()<CLLocationManagerDelegate,MKMapViewDelegate,BMKLocationServiceDelegate,
BMKGeoCodeSearchDelegate> {
    
    CLLocationManager *_locaManager;
    NSString *_locationStr;
}

@property (nonatomic, strong) BMKLocationService *locService;

@property (nonatomic, strong) BMKGeoCodeSearch *geoCode;        // 地理编码

@property (nonatomic, assign) CGFloat longitude;  // 经度

@property (nonatomic, assign) CGFloat latitude; // 纬度

@end
static CurrentLocation *currentLocation;

@implementation CurrentLocation
@synthesize delegate;

+ (CurrentLocation *)getUtil{
    
    if (currentLocation == nil) {
        
        currentLocation = [[super alloc]init];
        
    }
    return currentLocation;
}

- (void)getUSerLocation
{
    
    BOOL isUpload = [UserTipsUtil checkNetworkAndUserstatus];
    if (isUpload) {
        
        //百度
        [self startLocation];
    }
    
    //原生
//    [self startLocation2];
}
- (void)startLocation2{
    
    //初始化定位管理类
    _locaManager = [[CLLocationManager alloc] init];
    //delegate
    _locaManager.delegate = self;
    //The desired location accuracy.//精确度
    _locaManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //Specifies the minimum update distance in meters.
    //距离
    _locaManager.distanceFilter = 10;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [_locaManager requestWhenInUseAuthorization];
        [_locaManager requestAlwaysAuthorization];
        
    }
    //开始定位
    [_locaManager startUpdatingLocation];

}
- (void)startLocation
{
    // 初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    [self judgeLocationServiceEnabled];
}

#pragma mark - CoreLocation 代理
#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.longitude = userLocation.location.coordinate.longitude;
    self.latitude = userLocation.location.coordinate.latitude;
    [self outputAdd];
    // 当前位置信息：didUpdateUserLocation lat 23.001819,long 113.341650
}

#pragma mark geoCode的Get方法，实现延时加载
- (BMKGeoCodeSearch *)geoCode
{
    if (!_geoCode)
    {
        _geoCode = [[BMKGeoCodeSearch alloc] init];
        _geoCode.delegate = self;
    }
    return _geoCode;
}

//#pragma mark 获取地理位置按钮事件
- (void)outputAdd
{
    // 初始化反地址编码选项（数据模型）
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    // 将数据传到反地址编码模型
    option.reverseGeoPoint = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    // 调用反地址编码方法，让其在代理方法中输出
    [self.geoCode reverseGeoCode:option];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (result) {
        NSString *locationString = [NSString stringWithFormat:@"经度为：%.2f   纬度为：%.2f", result.location.longitude, result.location.latitude];
        NSLog(@"经纬度为：%@ 的位置结果是：%@", locationString, result.address);
//        _locationStr = result.addressDetail.city;
        NSString *retStr = @"";
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:result.location.longitude],@"longitude",[NSNumber numberWithDouble:result.location.latitude],@"latitude",result.address,@"location",nil];
        retStr = [dic JSONString];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetCurrentLocation:)]) {
            [self.delegate didGetCurrentLocation:retStr];
        }
        // 定位一次成功后就关闭定位
        [_locService stopUserLocationService];
        
    }else{
        NSLog(@"%@", @"找不到相对应的位置");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        
        NSString *retStr = @"";
        
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            
//            NSString *locationStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.name];
            NSString *locationStr = [NSString stringWithFormat:@"%@",placemark.name];
            NSLog(@"name===%@",placemark.name);
            _locationStr = [NSString stringWithFormat:@"longitude:%lf,latitude:%lf,%@%@%@%@%@%@",newLocation.coordinate.longitude,newLocation.coordinate.latitude,placemark.country,placemark.administrativeArea,placemark.locality,placemark.subLocality,placemark.thoroughfare,placemark.name];
           
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:newLocation.coordinate.longitude],@"longitude",[NSNumber numberWithDouble:newLocation.coordinate.latitude],@"latitude",locationStr,@"location",nil];
            
            retStr = [dic JSONString];
            NSLog(@"%@",retStr);

                  //            [self initAlertView];

        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGetCurrentLocation:)]) {
            [self.delegate didGetCurrentLocation:retStr];
        }
        
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}
#pragma mark - 检测应用是否开启定位服务
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}

-(void)judgeLocationServiceEnabled
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        //system location enabled
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse||[CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways)
        {
        }
        else
        {
            //定位服务开启  --但是用户没有允许他定位
            [self openGPSTips];
            
        }
        
    }
    
}

-(void)openGPSTips{
    
    if (![UIAdapterUtil isTAIHEApp]) {
        
        UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前定位服务不可用" message:@"请到“设置->隐私->定位服务”中开启定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alet show];
        [alet release];
    }
}
- (void)initAlertView
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:nil message:_locationStr delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    
    [alter show];
    [alter release];
}
@end
