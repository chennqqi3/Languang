//
//  GetXYConfig.m
//  eCloud
//
//  Created by shisuping on 17/6/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "GetXYConfigUtil.h"
#import "Emp.h"
#import "conn.h"
#import "UserDefaults.h"
#import "StringUtil.h"
#import "ServerConfig.h"
#import "LogUtil.h"
#import "JSONKit.h"
@interface GetXYConfigUtil () <NSURLConnectionDelegate,NSURLConnectionDataDelegate>


@property (nonatomic,retain) NSMutableData *oaTokenData;
@property (nonatomic,retain) NSMutableData *deptShowConfigData;

@end

static GetXYConfigUtil *getXYConfigUtil;

@implementation GetXYConfigUtil

/** 获取单例 */
+ (GetXYConfigUtil *)getUtil{
    if (!getXYConfigUtil) {
        getXYConfigUtil = [[super alloc]init];
    }
    return getXYConfigUtil;
}

/** 获取祥源OA Token */
- (void)getXYOAToken{
    Emp *emp = [conn getConn].curUser;
    int userId = emp.emp_id;
    NSString *account = [UserDefaults getUserAccount];
    NSString *passWord = [StringUtil getMD5Str:[UserDefaults getUserPassword]];
//    int interval = [[conn getConn]getCurrentTime];
//    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [date timeIntervalSince1970];
    int time = (int )interval;
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%d%d%@",userId,time,md5_password]];
    NSString *urlString = [[ServerConfig shareServerConfig]getXYOATokenUrl];
    
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
//    
//    
//    //    "t": 1496631745,
//    //    "userName": "test",
//    //    "password": "46f94c8de14fb36680850768ff1b7f2a",
//    //    "userid": 490011,
//    //    "mdkey": "4b78739f6ae10b5ba7f164d6d5fbfaf5",
//    //    "terminal": 3
//    
//    NSDictionary *dic = @{@"userName":account,@"password":passWord,@"hasToken":@(1),@"terminal":@(TERMINAL_IOS),@"userid":@(userId),@"t":@(time),@"mdkey":md5Str};
//    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    
//    request.HTTPBody = data;
//    
//    if (self.getOATokenConn) {
//        [self.getOATokenConn cancel];
//        self.getOATokenConn = nil;
//    }
//    
//    self.getOATokenConn = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES];

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
    request.timeoutInterval = [StringUtil getRequestTimeout];
    NSDictionary *dic = @{@"userName":account,@"password":passWord,@"hasToken":@(1),@"terminal":@(TERMINAL_IOS),@"userid":@(userId),@"t":@(time),@"mdkey":md5Str};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    // 将字符串转换成数据
    
    NSHTTPURLResponse * response = nil;
    NSError * error = nil;
    
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    [LogUtil debug:[NSString stringWithFormat:@"%s 获取到了祥源的部门配置 %@ %@",__FUNCTION__,response,error]];
    
    if (response.statusCode == 200) {
        
        NSDictionary *responseDic = [retData objectFromJSONData];
        
        //[LogUtil debug:[NSString stringWithFormat:@"%s 获取到的祥源OAtoken %@",__FUNCTION__,responseDic]];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取到的祥源OAtoken",__FUNCTION__]];
        if ([responseDic[@"status"]intValue] == 0) {
            
            [UserDefaults setXIANGYUANAppToken:responseDic[@"result"]];
            
        }
    }
    
}

/** 获取祥源部门显示配置 */
- (void)getXYDeptShowConfig{
    return;
    //    旧的部门隐藏时间戳
    int oldDeptShowConfigUpdateTime = [conn getConn].oldDeptShowConfigUpdateTime;
    
    //    当前服务器时间
    int interval = [[conn getConn]getCurrentTime];
    
    NSString *tempStr = [NSString stringWithFormat:@"%d%@%@",interval,[conn getConn].userId,md5_password];
    NSString *md5Str = [StringUtil getMD5Str:tempStr];
    
    //    祥源获取部门显示配置的url
    NSString *urlString = [[ServerConfig shareServerConfig]getXYDeptShowConfigUrl];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s oldDeptShowConfigUpdateTime is %d url is %@",__FUNCTION__,oldDeptShowConfigUpdateTime,urlString]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
    request.timeoutInterval = [StringUtil getRequestTimeout];
    
    NSDictionary *dic = @{@"t":@(interval),@"updatetime":@(oldDeptShowConfigUpdateTime),@"userid":[conn getConn].userId,@"mdkey":md5Str,@"terminal":@(TERMINAL_IOS)};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    if (self.getDeptShowConfigConn) {
        [self.getDeptShowConfigConn cancel];
        self.getDeptShowConfigConn = nil;
    }
    
    self.getDeptShowConfigConn = [[[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES]autorelease];

}

#pragma mark ======URLConnection delegate=======

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (connection == self.getOATokenConn) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源OA token发生了error : %@",__FUNCTION__,error]];
        self.getOATokenConn = nil;
    }else if (connection == self.getDeptShowConfigConn){
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源部门显示配置发生了error : %@",__FUNCTION__,error]];
        self.getDeptShowConfigConn = nil;
    }
}

#pragma mark =========NSURLConnection data delegate==========
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse *httpResponse =(NSHTTPURLResponse*)response;
    int statusCode = (int)[httpResponse statusCode];
    long long expectLen = response.expectedContentLength;
    
    if (connection == self.getOATokenConn) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源OA token收到了应答 : %@",__FUNCTION__,response]];
        if (statusCode == 200) {
            self.oaTokenData = [NSMutableData data];
        }else{
            self.getOATokenConn = nil;
        }
    }else if (connection == self.getDeptShowConfigConn){
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源部门显示配置收到了应答 : %@",__FUNCTION__,response]];
        if (statusCode == 200) {
            self.deptShowConfigData = [NSMutableData data];
        }else{
            self.getDeptShowConfigConn = nil;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    if (connection == self.getOATokenConn) {
        [self.oaTokenData appendData:data];
    }else if (connection == self.getDeptShowConfigConn){
        [self.deptShowConfigData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == self.getOATokenConn) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源OA token完成",__FUNCTION__]];
        if (self.oaTokenData.length){
            
            NSDictionary *responseDic = [self.oaTokenData objectFromJSONData];
            
            //[LogUtil debug:[NSString stringWithFormat:@"%s 获取到的祥源OAtoken %@",__FUNCTION__,responseDic]];
            
            if ([responseDic[@"status"]intValue] == 0) {
                
                [UserDefaults setXIANGYUANAppToken:responseDic[@"result"]];
                
            }

        }
        self.getOATokenConn = nil;
    }else if (connection == self.getDeptShowConfigConn){
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源部门显示配置完成 : %@",__FUNCTION__,self.deptShowConfigData]];
        
        self.getDeptShowConfigConn = nil;
    }
    
}


@end
