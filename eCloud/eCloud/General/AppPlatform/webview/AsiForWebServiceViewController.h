//
//  AsiForWebServiceViewController.h
//  eCloud
//
//  Created by yanlei on 15/9/1.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface AsiForWebServiceViewController : UIViewController

/**
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
                           wsParameters:(NSMutableArray *) wsParas;

/**
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
                             wsParameters:(NSMutableArray *) wsParas;

/**
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
                                         passWord:(NSString *) passWord;

/**
 //Mark: 检查WebService的Response是否包含错误信息
 如果未包含错误，则返回零长度字符串
 否则返回错误描述
 错误信息格式：错误前缀\n错误描述
 */
+ (NSString *)checkResponseError:(NSString *) theResponse;
@end
