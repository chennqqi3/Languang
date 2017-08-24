//
//  GMRequest.h
//  GMNetworkService
//
//  Created by 岳潇洋 on 2017/5/16.
//  Copyright © 2017年 岳潇洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMRequestTask.h"
#import "GMRequestFile.h"

typedef NS_ENUM(NSInteger,GMRequestMethod) {
    GMRequestMethodGet,
    GMRequestMethodPost,
    GMRequestMethodHead,
    GMRequestMethodPut,
    GMRequestMethodDelete,
    GMRequestMethodPatch
};

typedef NS_ENUM(NSInteger,GMRequestContentType) {
    GMRequestContentTypeDefault,//application/x-www-form-urlencoded
    GMRequestContentTypeJson,//application/json
    GMRequestContentTypeXplist//application/x-plist
};

#define kTimeOut @"timeOut"  // Key for request options parameter
#define kAllowInvalidCertificates @"allowInvalidCertificates" // Key for request options parameter
#define kContentType @"contentType" // Descript the HTTP request header field `Content-Type`,`GMRequestContentType` type value.


/**
 The response block for a request,called when a response recieved or the request go wrong.

 @param resHeader Response header,allways a dictionary
 @param resData Response body
 @param error An error throwed if the request go wrong
 */
typedef void(^GMRequestFinishWithHeaderBlock)(id resHeader,id resData,NSError * error);


/**
 The response block for a request,called when a response recieved or the request go wrong.

 @param resData Response body
 @param error An error throwed if the request go wrong
 */
typedef void(^GMRequestFinishBlock)(id resData,NSError * error);


/**
 If you will be downloading or uploading a file,this block can be setted to recieve the progress.

 @param progress A `NSProgress` object
 */
typedef void(^GMRequestProgressBlock)(NSProgress * progress);

/**
 `GMRequest` is a convience class for HTTP requests,you can refer a `GMRequest` object to send one or mutiple requests.
 */

@interface GMRequest : NSObject
@property(assign,nonatomic) NSTimeInterval timeOut;

/**
 Whether a invalid certificate is allowed when send a request to a server.
 */
@property(assign,nonatomic) BOOL allowInvalidCertificates;

#pragma -mark Get method request
- (GMRequestTask *)getWithUrl:(NSString *) url finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)getWithUrl:(NSString *) url parameters:(NSDictionary *) params finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)getWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params finish:(GMRequestFinishBlock) finish;

#pragma -mark Post method request
- (GMRequestTask *)postWithUrl:(NSString *) url parameters:(NSDictionary *) params finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)postWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params finish:(GMRequestFinishBlock) finish;

#pragma -mark upload a file to server
- (GMRequestTask *)uploadWithUrl:(NSString *) url parameters:(NSDictionary *) params fileName:(NSString *) fileName fileData:(id) data miniType:(NSString * ) mini finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)uploadWithUrl:(NSString *) url parameters:(NSDictionary *) params fileName:(NSString *) fileName keyName:(NSString *) keyName fileData:(id) data miniType:(NSString * ) mini progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)uploadWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params fileName:(NSString *) fileName keyName:(NSString *) keyName fileData:(id) data miniType:(NSString * ) mini progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;

- (GMRequestTask *)uploadWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params files:(NSArray<GMRequestFile *> *) files progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;


#pragma -mark download a file from server
- (GMRequestTask *)downloadWithUrl:(NSString *) url parameters:(NSDictionary *) params finish:(GMRequestFinishBlock) finish;
- (GMRequestTask *)downloadWithUrl:(NSString *) url parameters:(NSDictionary *) params progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;
- (GMRequestTask *)downloadWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;

#pragma -mark Head method request
- (GMRequestTask *)headWithUrl:(NSString *) url parameters:(NSDictionary *) params finishWithHeader:(GMRequestFinishWithHeaderBlock) finish;
- (GMRequestTask *)headWithUrl:(NSString *) url headers:(NSDictionary *) heads parameters:(NSDictionary *) params finishWithHeader:(GMRequestFinishWithHeaderBlock) finish;

#pragma -mark final request methods
- (GMRequestTask *)requestWithUrl:(NSString *) url method:(GMRequestMethod) method headers:(NSDictionary *) heads parameters:(NSDictionary *) params progress:(GMRequestProgressBlock) progress finish:(GMRequestFinishBlock) finish;
- (GMRequestTask *)requestWithUrl:(NSString *) url method:(GMRequestMethod) method headers:(NSDictionary *) heads parameters:(NSDictionary *) params progress:(GMRequestProgressBlock) progress finishWithHeader:(GMRequestFinishWithHeaderBlock) finish;


/**
 A convience method for creating `GMRequest` object with default application/x-www-form-urlencoded content type,it`s not a singleton method.

 @return A `GMRequest` object.
 */
+ (instancetype)request;

/**
 A convience method for creating `GMRequest` object with default application/json content type
 */
+ (instancetype)jsonRequest;

/**
 A convience method for creating `GMRequest` object with default application/x-plist content type
 */
+ (instancetype)xmlRequest;

/**
 A convience method for creating `GMRequest` object,it`s not a singleton method.

 @param options A dictionary for request setting,it can contains both kTimeOut key and kAllowInvalidCertificates key
 @return A `GMRequest` object
 */
+ (instancetype)requestWithOptions:(NSDictionary *) options;
@end
