//
//  CloudFileUtil.m
//  eCloud
//
//  Created by Ji on 16/12/12.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CloudFileUtil.h"

#ifdef _LONGHU_FLAG_
#import "AFNetworking.h"
#endif

#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "CloudFileDOA.h"
#import "ConvRecord.h"
#import "conn.h"
#import <CommonCrypto/CommonDigest.h>
#import "LCLLoadingView.h"
#import "AgentListViewController.h"
#import "JSONKit.h"
#import "UserDefaults.h"
#import "talkSessionUtil.h"
#import "talkSessionViewController.h"


@implementation CloudFileUtil

// 更换服务器后，后台给出的认证地址和对应的key
//#define CLOUD_FILE_INTERFACE_URL @"http://114.251.168.252:9010/cloud/oauth"
#define CLOUD_FILE_INTERFACE_URL @"http://mop.longfor.com:18080/cloud/oauth"    // 后台给出  授权、上传步骤都需要
#define KEY @"20c69203a493d3b9e37d161b08e9c136"                                 // 后台给出  授权、上传步骤都需要
#define CALLBACK_URL @"http://mop.longfor.com:18080/cloud/callback"             // 后台给出  鉴权使用

/*
 功能描述
    文件预览(暂未对龙湖开放)
 参数
    convRecord:会话实体
 */
+ (void)clounFilePreView:(ConvRecord *)convRecord
{
    [UserTipsUtil showLoadingView:@"请稍后"];
    conn *_conn = [conn getConn];
    
    NSDate *senddate = [NSDate date];
    NSString *date = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *date1 = [dateformatter stringFromDate:senddate];
    //随机字符串
    NSString *randomStr = [StringUtil getRandomString];
    
    NSString *file_id =  [[CloudFileDOA getDatabase] isCloudFile:convRecord.msg_body];
    //预览
    NSString *sign = [NSString stringWithFormat:@"action=preview&file_id=%@&nonce_str=%@&timestamp=%@&user_id=%@&key=%@",file_id,randomStr,date1,_conn.userId,KEY];
    NSString *signMD5 = [self md5:sign];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:date1,@"timestamp", @"preview",@"action",_conn.userId,@"user_id",randomStr,@"nonce_str",signMD5,@"sign",file_id,@"file_id", nil];
    
    NSString *base64Str = [self jsonTurnBase64:dict];
    //    NSString *urlStr = [NSString stringWithFormat:CLOUD_FILE_INTERFACE_URL];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?state=%@",CLOUD_FILE_INTERFACE_URL,base64Str];
    //    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:base64Str,@"state", nil];
    
#ifdef _LONGHU_FLAG_
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    [manager POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        [LogUtil debug:[NSString stringWithFormat:@"%s 预览文件 == %@",__FUNCTION__,responseObject]];
        id dict = responseObject;
        NSString *errcode = [NSString stringWithFormat:@"%@",dict[@"errcode"]];
        if ([errcode isEqualToString:@"0"]) {
            
            [[talkSessionViewController getTalkSession]previewTheCloudFile:dict[@"url"]];
            
            //});
        }else{
            
            [UserTipsUtil showAlert:@"预览失败，请重试"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        NSLog(@"Error: %@", error);
        [UserTipsUtil showAlert:@"预览失败，请重试"];
    }];
#endif

}

/*
 功能描述
    文件上传到云盘
 参数
    convRecord:会话实体
 */
+ (void)savedTocloud:(ConvRecord *)convRecord
{

    dispatch_queue_t queue = dispatch_queue_create("Logic", NULL);
    
    dispatch_async(queue, ^{
        
        conn *_conn = [conn getConn];
        //时间
        NSDate *senddate = [NSDate date];
        NSString *date = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
        NSString *date1 = [dateformatter stringFromDate:senddate];
        //随机字符串
        NSString *randomStr = [StringUtil getRandomString];
        
        // action取值:
        //       gettoken       取用户token，看是否存在，如果不存在，就需要弹出授权页
        //       saveas         内部文件上传
        //       uploadfile     外部文件上传
        //       preview        预览
        //       download       下载文件
        //       previewinweb   嵌入web页面预览
        //       fileinfo       根据file_id、file_name取文件信息
        //       code           获取code值
        //       oauth          授权
        
        NSString *sign = [NSString stringWithFormat:@"action=gettoken&custom_token=%@&nonce_str=%@&timestamp=%@&user_id=%@&key=%@",[UserDefaults getLoginToken],randomStr,date1,_conn.userId,KEY];
        NSString *signMD5 = [self md5:sign];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:date1,@"timestamp", @"gettoken",@"action",_conn.userId,@"user_id",randomStr,@"nonce_str",signMD5,@"sign",[UserDefaults getLoginToken],@"custom_token", nil];
        NSString *base64Str = [self jsonTurnBase64:dict];
        NSString *urlStr = [NSString stringWithFormat:@"%@?state=%@",CLOUD_FILE_INTERFACE_URL,base64Str];
        // 请求服务器当前用户是否已经过授权
        NSDictionary *dic = [self getHtmlText:urlStr];
        NSString *errcode = [NSString stringWithFormat:@"%@",dic[@"errcode"]];
        [LogUtil debug:[NSString stringWithFormat:@"%s 查询token返回== %@",__FUNCTION__,dic]];
        // errcode为0为正常，非0为错误
        if ([errcode isEqualToString:@"0"]) {
            NSString *token = dic[@"token"];
            // 请求返回的token为null时，代表当前用户未经过授权，此时打开webview用户进行绑定授权
            if ([token isEqualToString:@"null"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //鉴权
                    NSString *sign = [NSString stringWithFormat:@"action=oauth&backurl=%@&custom_token=%@&nonce_str=%@&timestamp=%@&user_id=%@&key=%@",CALLBACK_URL,[UserDefaults getLoginToken],randomStr,date1,_conn.userId,KEY];
                    NSString *signMD5 = [self md5:sign];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:date1,@"timestamp", @"oauth",@"action",_conn.userId,@"user_id",randomStr,@"nonce_str",signMD5,@"sign",[UserDefaults getLoginToken],@"custom_token",CALLBACK_URL,@"backurl", nil];
                    NSString *base64Str = [self jsonTurnBase64:dict];
                    NSString *urlStr = [NSString stringWithFormat:@"%@?state=%@",CLOUD_FILE_INTERFACE_URL,base64Str];
                                        
                    [[talkSessionViewController getTalkSession]previewTheCloudFile:urlStr];
                    
                });
                
                
            }else{// 用户已授权，进行文件上传操作
                //保存token
                //                    [UserDefaults setCloudFileToken:token];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"msg_body=====%@",convRecord.msg_body);
                    if ([convRecord.msg_body isEqualToString:@"FromOtherApp"]) {
                        //外部文件上传
                        [UserTipsUtil showLoadingView:@"上传中"];
                        [self cloudFileUpload:convRecord];
                    }else{
                        
                        //内部文件上传
                        [UserTipsUtil showLoadingView:@"上传中"];
                        [self internalCloudFileUpload:convRecord];
                    }
                });
            }
        }
        
    });
    

}


/*
 功能描述
    内部云文件上传
 参数
    convRecord:会话实体
 */
+ (void)internalCloudFileUpload:(ConvRecord *)convRecord
{
    
    conn *_conn = [conn getConn];
    NSDate *senddate = [NSDate date];
    NSString *date = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *date1 = [dateformatter stringFromDate:senddate];
    //随机字符串
    NSString *randomStr = [StringUtil getRandomString];
    
    if (convRecord) {
        
        NSString *sign = [NSString stringWithFormat:@"action=saveas&filename=%@&nonce_str=%@&timestamp=%@&token=%@&user_id=%@&key=%@",convRecord.file_name, randomStr,date1,convRecord.msg_body,_conn.userId,KEY];
        NSString *signMD5 = [self md5:sign];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:date1,@"timestamp", @"saveas",@"action",_conn.userId,@"user_id",randomStr,@"nonce_str",signMD5,@"sign",convRecord.file_name,@"filename",convRecord.msg_body,@"token", nil];
        
        NSString *base64Str = [self jsonTurnBase64:dict];
        
        NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:base64Str,@"state", nil];
        
        NSString *urlStr2 = [NSString stringWithFormat:@"%@?state=%@",CLOUD_FILE_INTERFACE_URL,base64Str];
        
        NSString *urlStr = [NSString stringWithFormat:CLOUD_FILE_INTERFACE_URL];
        
        [self startUpFileRequestWithUrl:urlStr parameters:paramers fileName:@"" filePath:@"" fileToken:convRecord.msg_body convRecord:convRecord];
    }else{
        
        [UserTipsUtil hideLoadingView];
        [UserTipsUtil showAlert:@"上传失败，请重试"];
    }
}
/*
 功能描述
    外部云文件上传
 参数
    convRecord:会话实体
*/
+ (void)cloudFileUpload:(ConvRecord *)convRecord{
    
    conn *_conn = [conn getConn];
    NSDate *senddate = [NSDate date];
    NSString *date = [NSString stringWithFormat:@"%ld", (long)[senddate timeIntervalSince1970]];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *date1 = [dateformatter stringFromDate:senddate];
    //随机字符串
    NSString *randomStr = [StringUtil getRandomString];
    
    if (convRecord) {
        
        NSString *sign = [NSString stringWithFormat:@"action=uploadfile&method=%d&nonce_str=%@&timestamp=%@&user_id=%@&key=%@",upload_method_new,randomStr,date1,_conn.userId,KEY];
        NSString *signMD5 = [self md5:sign];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:date1,@"timestamp", @"uploadfile",@"action",_conn.userId,@"user_id",randomStr,@"nonce_str",signMD5,@"sign",@2,@"method", nil];
        
        NSString *base64Str = [self jsonTurnBase64:dict];
        
        NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:convRecord]];
        NSString *fileName = convRecord.file_name;
        NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:base64Str,@"state", nil];
        
        NSString *urlStr = [NSString stringWithFormat:CLOUD_FILE_INTERFACE_URL];
        NSString *urlStr2 = [NSString stringWithFormat:@"%@?state=%@",CLOUD_FILE_INTERFACE_URL,base64Str];
        NSLog(@"urlStr2=======%@",urlStr2);
        [self startUpFileRequestWithUrl:urlStr parameters:paramers fileName:fileName filePath:filePath fileToken:convRecord.msg_body convRecord:convRecord];
    }else{
        [UserTipsUtil hideLoadingView];
        [UserTipsUtil showAlert:@"上传失败，请重试"];
    }
    
}
/*
 功能描述
    文件开始上传
 参数
    url:上传请求url
    parameters:上传需要的参数
    fileName:上传的文件路径
    fileToken:文件token
    convRecord:会话实体
 */
+ (void)startUpFileRequestWithUrl:(NSString *)url parameters:(NSDictionary *)parameters fileName:(NSString *)fileName filePath:(NSString *)filePath fileToken:(NSString *)fileToken convRecord:(ConvRecord *)convRecord
{
#ifdef _LONGHU_FLAG_
    //创建请求管理类
    AFHTTPRequestOperationManager* mgr = [AFHTTPRequestOperationManager manager];
    mgr.requestSerializer.timeoutInterval = 30;
    if (![fileToken isEqualToString:@"FromOtherApp"]) {
        
        [mgr POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"responseObject====%@",responseObject);
            [LogUtil debug:[NSString stringWithFormat:@"%s 上传云盘返回 == %@",__FUNCTION__,responseObject]];
            id dict = responseObject;
            NSString *errcode = [NSString stringWithFormat:@"%@",dict[@"errcode"]];
            if ([errcode isEqualToString:@"0"]) {
                
                NSString *status = [NSString stringWithFormat:@"%@",dict[@"status"]];
                if ([status isEqualToString:@"finished"]) {
                    
                    NSArray *fileinfo = dict[@"fileinfo"];
                    //保存到数据库
                    if (fileinfo.count > 0) {
                        [UserTipsUtil hideLoadingView];
                        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"上传成功"]];
                        [[LCLLoadingView currentIndicator]showTickView];
                        [[LCLLoadingView currentIndicator]show];
                        [[LCLLoadingView currentIndicator]hideWithDuration:1.5];
                        
                        NSString *file_id;
                        for (NSDictionary *dic in fileinfo) {
                            
                            file_id = [NSString stringWithFormat:@"%@",dic[@"file_id"]];
                        }
                        NSMutableDictionary *uploadCloudFile = [[NSMutableDictionary alloc] init];
                        [uploadCloudFile setObject:fileToken forKey:@"file_token"];
                        [uploadCloudFile setObject:file_id forKey:@"file_id"];
                        [[CloudFileDOA getDatabase] addOneCloudFileUploadRecord:uploadCloudFile];
                        [uploadCloudFile release];
                    }else{
                        
                        [UserTipsUtil hideLoadingView];
                        [UserTipsUtil showAlert:@"上传失败，请重试"];
                        
                    }
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                                   
                                   dispatch_get_main_queue(), ^{
                                       
                                       [self internalCloudFileUpload :convRecord];
                                       
                                   });
                }
            }else{
                [UserTipsUtil hideLoadingView];
                [UserTipsUtil showAlert:@"上传失败，请重试"];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [UserTipsUtil hideLoadingView];
            NSLog(@"Error: %@", error);
            [UserTipsUtil showAlert:@"上传失败，请重试"];
        }];
    }else{
        //发送请求
        [mgr POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> totalformData) {
            
            NSData *_data = [NSData dataWithContentsOfFile:filePath];
            
            [totalformData appendPartWithFileData:_data name:@"userFile" fileName:fileName mimeType:@"multipart/form-data"];
            
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *dict = responseObject;
            NSLog(@"responseObject====%@",responseObject);
            [LogUtil debug:[NSString stringWithFormat:@"%s 上传云盘返回== %@",__FUNCTION__,dict]];
            NSString *errcode = [NSString stringWithFormat:@"%@",dict[@"errcode"]];
            if ([errcode isEqualToString:@"0"]) {
                //往数据添加上传记录
                
                NSArray *fileinfo = dict[@"fileinfo"];
                //保存到数据库
                if (fileinfo.count > 0) {
                    [UserTipsUtil hideLoadingView];
                    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"上传成功"]];
                    [[LCLLoadingView currentIndicator]showTickView];
                    [[LCLLoadingView currentIndicator]show];
                    [[LCLLoadingView currentIndicator]hideWithDuration:1.5];
                    
                    //                    NSURL *url  = [NSURL URLWithString:@"mqq://"];
                    //                    [[UIApplication sharedApplication] openURL:url];
                    
                    NSString *file_id;
                    for (NSDictionary *dic in fileinfo) {
                        
                        file_id = [NSString stringWithFormat:@"%@",dic[@"file_id"]];
                    }
                    NSMutableDictionary *uploadCloudFile = [[NSMutableDictionary alloc] init];
                    [uploadCloudFile setObject:fileToken forKey:@"file_token"];
                    [uploadCloudFile setObject:file_id forKey:@"file_id"];
                    [[CloudFileDOA getDatabase] addOneCloudFileUploadRecord:uploadCloudFile];
                    [uploadCloudFile release];
                    
                }else{
                    NSLog(@"responseObject====%@",responseObject);
                    [UserTipsUtil hideLoadingView];
                    [UserTipsUtil showAlert:@"上传失败，请重试"];
                }
                
            }else{
                
                [UserTipsUtil hideLoadingView];
                [UserTipsUtil showAlert:@"上传失败，请重试"];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 上传云盘失败== %@",__FUNCTION__,error]];
            [UserTipsUtil hideLoadingView];
            [UserTipsUtil showAlert:@"上传失败，请重试"];
            
        } ];
    }
#endif
 
}

//json转base64
+ (NSString *)jsonTurnBase64:(NSDictionary *)dict
{
    NSString *jsonStr = [dict JSONString];
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str= [data base64Encoding];
    return base64Str;
}
//根据url获取网页内容
+ (NSDictionary *)getHtmlText:(NSString *)str
{
    NSURL *_url = [NSURL URLWithString:str];
    NSData *_data = [NSData dataWithContentsOfURL:_url];
    NSString *urlContentStr = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSData* jsonData = [urlContentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [jsonData objectFromJSONData];
    return dic;
}
//字符串md5加密
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
