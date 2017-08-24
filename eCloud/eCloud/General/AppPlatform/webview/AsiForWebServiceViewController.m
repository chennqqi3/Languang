//
//  AsiForWebServiceViewController.m
//  eCloud
//
//  Created by yanlei on 15/9/1.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "AsiForWebServiceViewController.h"

@interface AsiForWebServiceViewController ()

@end

@implementation AsiForWebServiceViewController

/*
 //Mark: 生成SOAP1.1版本的ASIHttp请求
 参数 webURL：                远程WebService的地址，不含*.asmx
 参数 webServiceFile：        远程WebService的访问文件名，如service.asmx
 参数 xmlNS：                    远程WebService的命名空间
 参数 webServiceName：        远程WebService的名称
 参数 wsParameters：            调用参数数组，形式为[参数1名称，参数1值，参数2名称，参数2值⋯⋯]，如果没有调用参数，此参数为nil
 */
+ (ASIHTTPRequest *)getASISOAP11Request:(NSString *) WebURL
                         webServiceFile:(NSString *) wsFile
                           xmlNameSpace:(NSString *) xmlNS
                         webServiceName:(NSString *) wsName
                           wsParameters:(NSMutableArray *) wsParas
{
    //1、初始化SOAP消息体
    NSString * soapMsgBody1 = [[NSString alloc] initWithFormat:
                               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
                               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" \n"
                               "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "<%@ xmlns=\"%@\">\n", wsName, xmlNS];
    NSString * soapMsgBody2 = [[NSString alloc] initWithFormat:
                               @"</%@>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>", wsName];
    
    //2、生成SOAP调用参数
    NSString * soapParas = [[NSString alloc] init];
    soapParas = @"";
    if (![wsParas isEqual:nil]) {
        int i = 0;
        for (i = 0; i < [wsParas count]; i = i + 2) {
            soapParas = [soapParas stringByAppendingFormat:@"<%@>%@</%@>\n",
                         [wsParas objectAtIndex:i],
                         [wsParas objectAtIndex:i+1],
                         [wsParas objectAtIndex:i]];
        }
    }
    
    //3、生成SOAP消息
    NSString * soapMsg = [soapMsgBody1 stringByAppendingFormat:@"%@%@", soapParas, soapMsgBody2];
    
    //请求发送到的路径
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", WebURL, wsFile]];
    
    //NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    ASIHTTPRequest * theRequest = [ASIHTTPRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
    [theRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [theRequest addRequestHeader:@"SOAPAction" value:[NSString stringWithFormat:@"%@%@", xmlNS, wsName]];
    
    [theRequest addRequestHeader:@"Content-Length" value:msgLength];
    [theRequest setRequestMethod:@"POST"];
    [theRequest appendPostData:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    [theRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    return theRequest;
}

#pragma mark -
/*
 //Mark: 使用SOAP1.1同步调用WebService请求
 参数 webURL：                远程WebService的地址，不含*.asmx
 参数 webServiceFile：        远程WebService的访问文件名，如service.asmx
 参数 xmlNS：                    远程WebService的命名空间
 参数 webServiceName：        远程WebService的名称
 参数 wsParameters：            调用参数数组，形式为[参数1名称，参数1值，参数2名称，参数2值⋯⋯]，如果没有调用参数，此参数为nil
 */
+ (NSString *)getSOAP11WebServiceResponse:(NSString *) WebURL
                           webServiceFile:(NSString *) wsFile
                             xmlNameSpace:(NSString *) xmlNS
                           webServiceName:(NSString *) wsName
                             wsParameters:(NSMutableArray *) wsParas
{
    //创建请求
    ASIHTTPRequest * theRequest = [self getASISOAP11Request:WebURL
                                             webServiceFile:wsFile
                                               xmlNameSpace:xmlNS
                                             webServiceName:wsName
                                               wsParameters:wsParas];
    
    //显示网络请求信息在status bar上
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    
    //同步调用
    [theRequest startSynchronous];
    NSError *error = [theRequest error];
    if (!error) {
        return [theRequest responseString];
    }
    else {
        //出现调用错误，则使用错误前缀+错误描述
        return [NSString stringWithFormat:@"%@",[error localizedDescription]];
    }
}

#pragma mark -
/*
 //Mark: 使用SOAP1.1同步调用WebService请求，需提供Windows集成验证的用户名、密码和域
 参数 webURL：                远程WebService的地址，不含*.asmx
 参数 webServiceFile：        远程WebService的访问文件名，如service.asmx
 参数 xmlNS：                    远程WebService的命名空间
 参数 webServiceName：        远程WebService的名称
 参数 wsParameters：            调用参数数组，形式为[参数1名称，参数1值，参数2名称，参数2值⋯⋯]，如果没有调用参数，此参数为nil
 参数 userName                用户名--目前来看，不需要输入域信息
 参数 passWord                密码
 */
+ (NSString *)getSOAP11WebServiceResponseWithNTLM:(NSString *) WebURL
                                   webServiceFile:(NSString *) wsFile
                                     xmlNameSpace:(NSString *) xmlNS
                                   webServiceName:(NSString *) wsName
                                     wsParameters:(NSMutableArray *) wsParas
                                         userName:(NSString *) userName
                                         passWord:(NSString *) passWord
{
    //创建请求
    ASIHTTPRequest * theRequest = [self getASISOAP11Request:WebURL
                                             webServiceFile:wsFile
                                               xmlNameSpace:xmlNS
                                             webServiceName:wsName
                                               wsParameters:wsParas];
    
    //集成验证NTLM用户名，密码和域设置
    [theRequest setUsername:userName];
    [theRequest setPassword:passWord];
    //[theRequest setDomain:doMain];
    
    //显示网络请求信息在status bar上
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
    
    //同步调用
    [theRequest startSynchronous];
    NSError *error = [theRequest error];
    if (!error) {
        return [theRequest responseString];
    }
    else {
        //出现调用错误，则使用错误前缀+错误描述
        return [NSString stringWithFormat:@"%@", [error localizedDescription]];
    }
}

#pragma mark -
/*
 //Mark: 检查WebService的Response是否包含错误信息
 如果未包含错误，则返回零长度字符串
 否则返回错误描述
 错误信息格式：错误前缀\n错误描述
 */
+ (NSString *)checkResponseError:(NSString *) theResponse
{
    //检查消息是否包含错误前缀
//    if (![theResponse hasPrefix:[Constant sharedConstant].G_WEBSERVICE_ERROR]) {
//        return @"";
//    }
//    else {
//        NSMutableString *sTemp = [[NSMutableString alloc] initWithString:theResponse];
//        //获取错误前缀的范围
//        NSRange range=[sTemp rangeOfString:[Constant sharedConstant].G_WEBSERVICE_ERROR];
//        //剔除错误前缀
//        [sTemp replaceCharactersInRange:range withString:@""];
//        
//        NSString * errMsg = sTemp;
//        //Authentication needed
//        if ([sTemp isEqualToString:@"Authentication needed"]) {
//            errMsg = @"用户登录失败！";
//        }
//        //The request timed out
//        if ([sTemp isEqualToString:@"The request timed out"]) {
//            errMsg = @"访问超时，请检查远程地址等基本设置！";
//        }
//        //The request was cancelled
//        if ([sTemp isEqualToString:@"The request was cancelled"]) {
//            errMsg = @"请求被撤销！";
//        }
//        //Unable to create request (bad url?)
//        if ([sTemp isEqualToString:@"Unable to create request (bad url?)"]) {
//            errMsg = @"无法创建请求，错误的URL地址！";
//        }
//        //The request failed because it redirected too many times
//        if ([sTemp isEqualToString:@"The request failed because it redirected too many times"]) {
//            errMsg = @"请求失败，可能是因为被重定向次数过多！";
//        }
//        //A connection failure occurred
//        if ([sTemp isEqualToString:@"A connection failure occurred"]) {
//            errMsg = @"网络连接错误，请检查无线或3G网络设置！";
//        }
//        
//        return errMsg;
//    }
    return @"";
}

@end
