//
//  DownloadGuideImage.m
//  eCloud
//
//  Created by yanlei on 15/11/26.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "DownloadGuideImage.h"
#import "ApplicationManager.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "EncryptFileManege.h"
#import "StringUtil.h"
#import "UserDefaults.h"
#import "conn.h"
#import "JSONKit.h"

@implementation DownloadGuideImage{
    /** 广告页图片名称（已没有实际用途，但不要删除  值为nil） */
    NSString *guideImageName;
    /** 存放即将下载的图片名称数组   元素为图片名称(含拓展名) */
    NSMutableArray *imageNameArray;
    /** 以前用作记录新的广告url，现在用作记录广告页的拓展名  如：png */
    NSString *newGuideUrl;
    /** 图片下载url内容  元素内容是字典 */
    NSArray *_arrlist;
    /** 图片信息  advType:广告类型(img 是图片)  intervalTime:有效时长  linkUrl:广告的通用下载路径(要对图片名拼接处理才能找到对应的下载图片) */
    NSMutableDictionary *_dict;
    
}

#pragma mark - 单例
+ (id)shareDownloadGuideImageSingle{
    static dispatch_once_t onceToken;
    static id _s;
    dispatch_once(&onceToken, ^{
        _s = [[[self class]alloc]init];
    });
    return _s;
}
#pragma mark - 封装下载文件方法
-(void)downloadGuideImage:(NSString *)guideUrl{
    
    
    // 判断网络
    if(![ApplicationManager getManager].isNetworkOk)
    {
        return;
    }
    
    imageNameArray = [NSMutableArray array];
    
    _dict = [guideUrl objectFromJSONString];
    if([_dict count] == 0)
    {
        NSDictionary *tempdic = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"downloadFrom",guideUrl,@"imageUrl",nil];
        
        NSMutableArray *arr = [[NSMutableArray alloc]initWithObjects:tempdic, nil];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              arr,@"linkUrl",@"img",@"advType",@(5),@"intervalTime",
                              nil];
        _dict = dict;
    }
    _arrlist = _dict[@"linkUrl"];
    for (NSDictionary *dic in _arrlist) {

        if (dic[@"imageUrl"]) {
            
            NSString *guideUrls = dic[@"imageUrl"];
            newGuideUrl = [guideUrls substringFromIndex:guideUrls.length - 3];
        }
        [LogUtil debug:[NSString stringWithFormat:@"%s,guideUrl is %@",__FUNCTION__,guideUrl]];
        
        
        // 拿取本地存储的上次下载引导页保存的文件名
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSArray *imageArr = [user objectForKey:@"imageNameArray"];
        
        // 拼接新的广告页图片名称   比如：welcome-57.png  - >   welcomeios-57.png
        NSArray *guideImageArray = [dic[@"imageUrl"] componentsSeparatedByString:@"-"];
        NSArray *guideImagePreArray = [guideImageArray[0] componentsSeparatedByString:@"/"];
        NSString *newGuideImageName = [NSString stringWithFormat:@"%@ios-%d",guideImagePreArray[guideImagePreArray.count-1],[guideImageArray[1] intValue]];
 
//        NSString *newGuideImageName = [NSString stringWithFormat:@"%@ios-%d",guideImagePreArray[guideImagePreArray.count-1],[guideImageArray[1] intValue]];
//        [LogUtil debug:[NSString stringWithFormat:@"%s oldGuidName is %@ newGuideName is %@",__FUNCTION__,guideImageName,newGuideImageName]];
        
        if (imageArr) {
            // 本地下载好的文件名称与服务端获取到的文件名称相同时，不需要进行下载操作
            if ([imageArr[0] isEqualToString:[NSString stringWithFormat:@"%@.%@",newGuideImageName,newGuideUrl]]) {
                //        guideImageName = @"welcomeios-1";
                return;
            }
        }
        
        if (!_picNameArray) {
            _picNameArray = [NSMutableArray array];
        }else if (_picNameArray.count){
            [_picNameArray removeAllObjects];
    }
        //        //        增加ipad 横屏 add by shisp
        if (IS_IPHONE) {
            // 根据手机型号拼接下载对应分辨率的图片名称
            if (IS_IPHONE_5) {
                [imageNameArray addObject:[NSString stringWithFormat:@"%@-568h@2x.%@",newGuideImageName,newGuideUrl]];
            }else if (IS_IPHONE_6){
                // 图片名称拼接为welcomeios-57@2x.png
                [imageNameArray addObject:[NSString stringWithFormat:@"%@@2x.%@",newGuideImageName,newGuideUrl]];
            }else if (IS_IPHONE_6P){
                [imageNameArray addObject:[NSString stringWithFormat:@"%@@3x.%@",newGuideImageName,newGuideUrl]];
            }else{
                [imageNameArray addObject:[NSString stringWithFormat:@"%@.%@",newGuideImageName,newGuideUrl]];
            }
        }else{
            [imageNameArray addObject:[NSString stringWithFormat:@"%@_ipad_portrait.%@",newGuideImageName,newGuideUrl]];
            [imageNameArray addObject:[NSString stringWithFormat:@"%@_ipad.%@",newGuideImageName,newGuideUrl]];
        }
//        [imageNameArray addObject:[NSString stringWithFormat:@"%@.%@",newGuideImageName,newGuideUrl]];
    }
    // 拼接下载路径保存到本地
    // 下载，下载完成后，将新的文件名保存到userdefault文件中
    
    // http://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=http%3A%2F%2Fpic.nipic.com%2F2007-11-09%2F200711912453162_2.jpg&thumburl=http%3A%2F%2Fimg3.imgtn.bdimg.com%2Fit%2Fu%3D3841157212%2C2135341815%26fm%3D21%26gp%3D0.jpg
    
    dispatch_queue_t _queue = dispatch_queue_create("download current guide pages", NULL);
    dispatch_async(_queue, ^{
        
        
        for (int i = 0; i < imageNameArray.count; i++) {
            
            //如果下载的文件名和上次保存的一样，就不下载了!
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSArray *imageArr = [user objectForKey:@"imageNameArray"];
            if (imageArr.count > 0) {
                
                if ([imageArr[0] isEqualToString:imageNameArray[i]]) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s,下载的文件名和上次保存的一样，就不下载了",__FUNCTION__]];
                    return ;
                }
            }
            //		准备文件下载url，准备下载
            
            NSURL *producturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://mop.longfor.com:8090/manager/download/",imageNameArray[i]]];
//            NSURL *testurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://114.251.168.252:8090/advertising_test/",imageNameArray[i]]];
//            NSString *serviceStr = testurl;
//            if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
//                serviceStr = producturl;
//            }
//
            
            NSString *fileUrl = @"";
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:producturl];
            [request setDelegate:self];
            
    //        pathStr = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imageNameArray[i]]];
            
            NSString *pathStr = [[StringUtil getHomeDir]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",rcv_file_path,imageNameArray[i]]];
            [LogUtil debug:[NSString stringWithFormat:@"%s,image url is %@ filePath is %@",__FUNCTION__,producturl,pathStr]];

            [StringUtil createFolderForPath:pathStr];
            //设置文件保存路径
            [request setDownloadDestinationPath:pathStr];
            
            [request setDidFinishSelector:@selector(downloadFileComplete:)];
            [request setDidFailSelector:@selector(downloadFileFail:)];
            
            //		传参数，文件传输完成后，根据参数进行不同的处理
            [request setTimeOutSeconds:[self getRequestTimeout]];
            [request setNumberOfTimesToRetryOnTimeout:3];
            request.shouldContinueWhenAppEntersBackground = YES;
            
            [request startAsynchronous];
//            [request release];
        }
    });
    
//    dispatch_release(_queue);
}

/**
 下载完成

 @param request 下载请求对象
 */
- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    [LogUtil debug:[NSString stringWithFormat:@"statuscode====%s,%d",__FUNCTION__,statuscode]];
    
//    [EncryptFileManege encryptExistFile:request.downloadDestinationPath];

    if(statuscode == 404)
    {
        //文件不存在
        [LogUtil debug:[NSString stringWithFormat:@"404引导页不存在：%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
        [self downloadFileFail:request];
    }
    else if(statuscode != 200)
    {
        //下载失败
        [self downloadFileFail:request];
    }
    else if(statuscode == 200)
    {
        
        if (_picNameArray) {
            // 下载完成将图片数组内容设置为1  1:下载成功
            [_picNameArray addObject:@"1"];
            
            if (![guideImageName isEqualToString:[UserDefaults getGuideImageName]] && _picNameArray.count == imageNameArray.count) {
                for (NSString *itemPicName in _picNameArray) {
                    // 是否存在下载失败的图片  2:下载失败的标识
                    // 现在的做法是根据手机型号下载对应的图片，下面的这个判断可以忽略
                    // 以前的做法是会下载多张广告页，若出现下载失败的情况就是标记为2，下次登录要重新下载对应的广告页
                    if ([itemPicName intValue] == 2) {
                        return;
                    }
                }
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:imageNameArray forKey:@"imageNameArray"];
                
                [UserDefaults saveGuideImageName:_dict];
                [UserDefaults saveGuideImagSuffix:newGuideUrl];
                [conn getConn].downLoadImageStatus = download_final;
                [LogUtil debug:@"-------lyan---------引导页下载成功"];
            }else{
                [conn getConn].downLoadImageStatus = download_guide;
            }
        }
         
    }
}

/**
 下载失败

 @param request 下载请求对象
 */
-(void)downloadFileFail:(ASIHTTPRequest*)request{
    if (_picNameArray) {
//        [_picNameArray removeAllObjects];
        [_picNameArray addObject:@"2"];
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"广告页下载失败：%@,%@",request.downloadDestinationPath,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    [[NSFileManager defaultManager]removeItemAtPath:request.downloadDestinationPath error:nil];
    if (_picNameArray && _picNameArray.count != imageNameArray.count) {
        [conn getConn].downLoadImageStatus = download_guide;
    }else{
        [conn getConn].downLoadImageStatus = download_final;
    }
}
#pragma mark - 设置超时时间
-(int)getRequestTimeout
{
    int timeout = 30;
    if([ApplicationManager getManager].netType == type_gprs)
    {
        timeout = 60;
    }
    return timeout;
}
//- (void)dealloc{
//    guideImageName = nil;
//    [super dealloc];
//}
@end
