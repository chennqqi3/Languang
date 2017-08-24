//
//  RemainViewController.m
//  eCloud
//
//  Created by shisuping on 16/8/23.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RemindViewController.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "OpenNotificationDefine.h"
#import "RemindModel.h"
#import "OpenCtxManager.h"

@interface RemindViewController ()

@end

@implementation RemindViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super dealloc];
}

- (void)processNewRemind:(NSNotification *)_notification
{
   NSDictionary *userInfo =  _notification.userInfo;
    if (userInfo) {
         RemindModel *newRemind = userInfo[NEW_REMIND_KEY];
//        显示
        NSLog(@"%@",newRemind.remindMsgId);
        
        [[OpenCtxManager getManager]setRemindToReadWithMsgId:newRemind.remindMsgId];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewRemind:) name:NEW_REMIND_NOTIFICATION object:nil];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    self.title = @"南航提醒";
    
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
