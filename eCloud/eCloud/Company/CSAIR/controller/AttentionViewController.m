//
//  AttentionViewController.m
//  eCloud
//
//  Created by shisuping on 16/8/25.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "AttentionViewController.h"
#import "APPListModel.h"
#import "OpenCtxManager.h"
#import "JSONKit.h"
#import "eCloudDAO.h"
#import "StringUtil.h"
#import "conn.h"
#import "eCloudDefine.h"
#import "APPConn.h"

@interface AttentionViewController ()

@end

@implementation AttentionViewController

@synthesize appModel;
- (void)dealloc
{
    self.appModel = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[self class] createTestData];
    
    NSLog(@"%s %@",__FUNCTION__, self.appModel.apphomepage);
    
    [self testGetData];

}

- (void)testGetData
{
    int count = [[eCloudDAO getDatabase]getAppRemindTotalCount];
    
    int offset = 30;
    int limit = 10;
    if (count > 0 && (offset + limit) < count) {
        NSArray *result = [[eCloudDAO getDatabase]getAppRemindsWithLimit:limit andOffset:offset];
    }
}

+ (void)createTestData
{
    [[OpenCtxManager getManager]createTestAppRemindsData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
