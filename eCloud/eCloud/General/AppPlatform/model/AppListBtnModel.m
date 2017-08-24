//
//  AppListBtnModel.m
//  AppList
//
//  Created by Pain on 14-6-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "AppListBtnModel.h"
#import "APPListModel.h"

@implementation AppListBtnModel
@synthesize appname;
@synthesize apptype;
@synthesize start_Delete;
@synthesize appicon;
@synthesize appModel;

- (void)dealloc{
    self.appname = nil;
    self.appicon = nil;
    self.appModel = nil;
    
    [super dealloc];
}

@end
