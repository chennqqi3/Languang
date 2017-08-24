//
//  LANGUANGWorkViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGWorkViewControllerARC.h"
#import "UserDefaults.h"
#import "StringUtil.h"
#import "ServerConfig.h"
#import "LogUtil.h"
#import "LANGUANGWorkModelARC.h"
#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"
#import "APPPlatformDOA.h"
#import "CustomMyCell.h"
#import "APPListModel.h"
#import "NotificationDefine.h"
#import "LANGUANGMeetingListViewControllerARC.h"
#import "LANGUANGAgentViewControllerARC.h"

#define WX_D_APP_BASE_TAG 200

@interface LANGUANGWorkViewControllerARC ()<UIScrollViewDelegate>

@property(nonatomic,retain) NSMutableArray *userDataTextArray;
@property (nonatomic,strong)UIScrollView *scroll;
@property(nonatomic,retain) NSMutableArray *dataArray;

@end

@implementation LANGUANGWorkViewControllerARC
{
    UIButton *_eatButton;
    UIView *buttonView;
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [StringUtil getAppLocalizableString:@"main_works"];
    
    [self.navigationController setNavigationBarHidden:NO];
    [UIAdapterUtil showTabar:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self ButtonAssignment];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
}

#pragma mark - 创建轻应用按钮
- (void)ButtonAssignment
{
    if (!_scroll) {
        
        _scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48)];
        
        _scroll.showsVerticalScrollIndicator = NO;
        //_scroll.showsHorizontalScrollIndicator = NO;
        _scroll.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
//        _scroll.backgroundColor = [UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1] ;
        [self.view addSubview:_scroll];
    }
    
    self.dataArray = [NSMutableArray array];
    if (self.dataArray != nil && [self.dataArray count]) {
        [self.dataArray removeAllObjects];
    }
    
    self.userDataTextArray = [NSMutableArray array];
    if (self.userDataTextArray != nil && [self.userDataTextArray count]) {
        [self.userDataTextArray removeAllObjects];
    }
    self.userDataTextArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    
    int i = 0;

    for (UIView * subview in [_scroll subviews]) {
        [subview removeFromSuperview];
    }

    for (NSArray *modelArr in self.userDataTextArray) {
        
        for (APPListModel *appModel in modelArr) {
            
            CGFloat buttonView_Height = 111;
            
            buttonView = [[UIView alloc]initWithFrame:CGRectMake(i%3*SCREEN_WIDTH/3, i/3*buttonView_Height+12, SCREEN_WIDTH/3-1, buttonView_Height-1)];
            buttonView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:144/255.0 green:144/255.0 blue:144/255.0 alpha:1] ;
            [_scroll addSubview:buttonView];
           
            _eatButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            CGFloat Button_Height = SCREEN_WIDTH/3 - 40;  // 高
//            CGFloat Button_Width  =  SCREEN_WIDTH/3 - 40;    // 宽
            
            _eatButton.frame = CGRectMake(buttonView.frame.size.width/2-22,22 ,45 , 45);
            
            UIImage *image = [CustomMyCell getAppLogo:appModel];
            
            [_eatButton setImage:image forState:UIControlStateNormal];
            [_eatButton addTarget:self action:@selector(singleSelected:) forControlEvents:UIControlEventTouchUpInside];
            _eatButton.tag = i + WX_D_APP_BASE_TAG;
            [buttonView addSubview:_eatButton];
            
            UILabel *eatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _eatButton.frame.size.height + _eatButton.frame.origin.y + 12,buttonView.frame.size.width , 22)];
//            UILabel *eatLabel = [[UILabel alloc] initWithFrame:CGRectMake(_frame.origin.x, _frame.size.height - 22 -22,_frame.size.width , 22)];

            eatLabel.text = appModel.appname;
            
            eatLabel.textColor = [UIColor colorWithRed:0x01/255.0 green:0x01/255.0 blue:0x01/255.0 alpha:1];
            eatLabel.textAlignment = NSTextAlignmentCenter;
            //            eatLabel.backgroundColor = [UIColor redColor];
            eatLabel.font = [UIFont systemFontOfSize:14];
            [buttonView addSubview:eatLabel];
//            if (IS_IPAD) {
//                
//                _eatButton.frame = CGRectMake(10+SCREEN_WIDTH/5*i, 15,SCREEN_WIDTH/5-30 , SCREEN_WIDTH/5-30);
//                
//                CGRect _frame = eatLabel.frame;
//                _frame.size.height = eatLabel.frame.size.height - 30;
//                _frame.size.width = _eatButton.frame.size.width;
//                _frame.origin.x = _eatButton.frame.origin.x;
//                _frame.origin.y = eatLabel.frame.origin.y - 5;
//                eatLabel.frame = _frame;
//                eatLabel.font = [UIFont systemFontOfSize:18];
//                
//            }else{
//                eatLabel.font = [UIFont systemFontOfSize:14];
//            }

            [self.dataArray addObject:appModel];
            
            i++;
        }
    }
    
    [_scroll setContentSize:CGSizeMake(0,buttonView.frame.origin.y + buttonView.frame.size.height +50)];
    
}

#pragma mark - 打开轻应用
- (void)singleSelected:(UIButton *)sender{
    
    UIButton *button = (UIButton *)[self.view viewWithTag:sender.tag];
    [self openAgent:(int)button.tag - WX_D_APP_BASE_TAG];
}
- (void)openAgent:(int)tag
{
    if (self.dataArray) {

        APPListModel *appModel = self.dataArray[tag];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,appModel.apphomepage]];
        
        if (appModel.appid == 10002) {
            
            LANGUANGMeetingListViewControllerARC *meeting = [[LANGUANGMeetingListViewControllerARC alloc]init];
            [self.navigationController pushViewController:meeting animated:YES];
            
        }else{
            
            LANGUANGAgentViewControllerARC *openweb=[[LANGUANGAgentViewControllerARC alloc]init];
            openweb.urlstr= appModel.apphomepage;
            [self.navigationController pushViewController:openweb animated:YES];
        }
        
        [UIAdapterUtil hideTabBar:self];
        
    }
}

- (void)handleCmd:(NSNotification *)notif{
    
    [self ButtonAssignment];
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
