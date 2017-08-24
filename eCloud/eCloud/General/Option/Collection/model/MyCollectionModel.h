//
//  MyCollectionModel.h
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eCloudDefine.h"

@class RobotResponseModel;
@class Emp;

@interface MyCollectionModel : NSObject

@property (nonatomic, copy) NSString *originID;
@property (nonatomic, copy) NSString* body;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* imgtextURL;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* msgTime;
@property (nonatomic, copy) NSString* time;
@property (nonatomic, copy) NSString* timeText;
@property (nonatomic, copy) NSString* logo;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, strong) UIImage* icon;
@property (nonatomic, strong) UIImage* picture;
@property (nonatomic, assign) BOOL emp_sex;
@property (nonatomic, assign) msgType type;
@property (nonatomic, assign) msgType realType;

@property (nonatomic,retain) RobotResponseModel *robotModel;

@property (nonatomic,strong) Emp *emp;

@end
