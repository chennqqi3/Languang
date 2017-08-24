//
//  JWURLProtocol.m
//  NSURLProtocolExample
//
//  Created by yangjw on 16/8/19.
//  Copyright © 2016年 lujb. All rights reserved.
//

#import "JWURLProtocol.h"
#import "JSONKit.h"
#import "NotificationUtil.h"
#import "LogUtil.h"

//终止url：http://dev.brc.com.cn:9998/xt/workflowAction!abort.ajax
//暂缓url：http://dev.brc.com.cn:9998/xt/workflowAction!sleep.ajax
//回退中打回url：http://dev.brc.com.cn:9998/xt/workflowAction!replenish.ajax
//回退中会退url：http://dev.brc.com.cn:9998/xt/workflowAction!back.ajax
//交办url：http://dev.brc.com.cn:9998/xt/workflowAction!transmit.ajax
//提交url：http://dev.brc.com.cn:9998/xt/workflowAction!advance.ajax
//提交在打回状态下的url：http://dev.brc.com.cn:9998/xt/expenseAccountAction!completeReplenishTask.ajax
//另外一个提交URL:http://xt.brc.com.cn:8098/xt/workflowAction!queryAdvance.ajax
//workflowAction!completeReplenishTask.ajax

#define check_url_array [NSArray arrayWithObjects:@"workflowAction!abort.ajax",@"workflowAction!sleep.ajax",@"workflowAction!replenish.ajax",@"workflowAction!back.ajax",@"workflowAction!transmit.ajax",@"workflowAction!advance.ajax",@"expenseAccountAction!completeReplenishTask.ajax",@"workflowAction!queryAdvance.ajax",@"workflowAction!completeReplenishTask.ajax",nil]

static NSString * const JWURLProtocolHandledKey = @"JWURLProtocolHandledKey";

@interface JWURLProtocol ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *mData;

@end

@implementation JWURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:JWURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    /** 可以在此处添加头等信息  */
    //    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    //    return mutableReqeust;
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    self.mData = [NSMutableData data];
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //打标签，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:JWURLProtocolHandledKey inRequest:mutableReqeust];
    
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
    //异步
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    
//    [NSURLConnection sendAsynchronousRequest:mutableReqeust queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//               [self mockRequest:mutableReqeust data:data];
//    }];
//    
    //    同步
    //    NSHTTPURLResponse* urlResponse = nil;
    //    NSError *error = [[NSError alloc] init];
    //    NSData *data =[NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&urlResponse error:&error];
    //    [self mockRequest:mutableRequest data:data];
    
}

#pragma mark - Mock responses

-(void) mockRequest:(NSURLRequest*)request data:(NSData*)data {
    id client = [self client];
    
    //    问题来自于webkit块因为起源于跨域请求的响应。因为我们我们必须迫使Access-Control-Allow-Origin模拟响应，然后我们还需要强迫响应的内容类型。
    //    设置为*则所域可以用ajax跨域获取数据，设置为指定的域名只能指定的域名用ajax跨域获取到数据。
    NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Content-Type"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.0" headerFields:headers];
    
    [client URLProtocol:self didReceiveResponse:response
     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
}
- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate
/// 网络请求返回数据
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
    if([httpresponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *di  = [httpresponse allHeaderFields];
        NSArray *keys = [di allKeys];
        for(int i=0; i<di.count;i++){
            NSString *key = [keys objectAtIndex:i];
            NSString *value=[di objectForKey:key];
            if([key rangeOfString:@"Set-Cookie"].location != NSNotFound)
            {
                NSLog(@"response_header_value -- %@",value);
                // 获取Session
            }
        }
    }
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.mData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    BOOL needCheck = NO;
    NSString *url = [self.request.URL absoluteString];
    for (NSString *tempStr in check_url_array) {
        if ([url rangeOfString:tempStr].length) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 需要检查结果 url:%@",__FUNCTION__,url]];

            needCheck = YES;
            break;
        }
    }
    if (needCheck) {
        NSString *result = [[NSString alloc]initWithData:self.mData encoding:NSUTF8StringEncoding];
        
        if (result.length) {
            //        {"status":1,"brcfid":"c4ca4238a0b923820dcc509a6f75849b","data":{"bizData":null}}
            
//            if (result.length <= 100) {
                [LogUtil debug:[NSString stringWithFormat:@"%s result is %@",__FUNCTION__,result]];
//            }
            
            id _id = [result objectFromJSONString];
            if ([_id isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary *)_id;
                id statusId = dic[@"status"];
                if ([statusId isKindOfClass:[NSNumber class]]) {
                    int status = ((NSNumber *)statusId).intValue;
                    if (status == 1){
                        id brcfid = dic[@"brcfid"];
                        if ([brcfid isKindOfClass:[NSString class]]) {
                            NSString *sBrcfid = (NSString *)brcfid;
                            if (sBrcfid.length) {
                                
                                BOOL needSend = NO;
                                
                                id dataId = dic[@"data"];
                                if (dataId == nil || [dataId isKindOfClass:[NSNull class]]) {
                                    needSend = YES;
                                }else{
                                    if ([dataId isKindOfClass:[NSString class]]) {
                                        NSString *tempStr = (NSString *)dataId;
                                        if (!tempStr || tempStr.length == 0 || [tempStr compare:@"ok" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                                            needSend = YES;
                                        }
                                    }else if ([dataId isKindOfClass:[NSDictionary class]]){
                                        NSDictionary *dic = (NSDictionary *)dataId;
                                        if (dic.count == 0) {
                                            needSend = YES;
                                        }else if (dic.count == 1){
                                            id valueId = dic.allValues[0];
                                            if (valueId == nil || [valueId isKindOfClass:[NSNull class]] ) {
                                                needSend = YES;
                                            }
                                            if ([valueId isKindOfClass:[NSString class]]) {
                                                NSString *str = (NSString *)valueId;
                                                if (str.length == 0 || [str compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                                                    needSend = YES;
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                                if (needSend) {
                                    [[NotificationUtil getUtil]sendNotificationWithName:LG_CLOSE_WEBVIEW_NOTIFICATION andObject:nil andUserInfo:nil];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
