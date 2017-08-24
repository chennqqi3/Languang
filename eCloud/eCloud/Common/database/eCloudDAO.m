//
//  eCloudDAO.m
//  eCloud
//
//  Created by Richard on 13-9-27.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "eCloudDAO.h"
#import "APPPlatformDOA.h"

static eCloudDAO *_eCloud;
@implementation eCloudDAO
//获取数据库的实例
+(eCloudDAO *)getDatabase
{
	if(_eCloud == nil)
	{
		_eCloud = [[eCloudDAO alloc]init];
	}
	return _eCloud;
}
//释放数据库
+(void)releaseDatabase
{
	if(_eCloud)
	{
		[_eCloud release];
		_eCloud = nil;
	}
}

- (void)closeSqliteDatabase
{
//    [[APPPlatformDOA getDatabase]closeSqliteDatabase];
    [super closeSqliteDatabase];
}

//closeSqliteDatabase
@end
