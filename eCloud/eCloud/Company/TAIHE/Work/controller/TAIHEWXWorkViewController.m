//
//  TAIHEWXWorkViewController.m
//  eCloud
//
//  Created by yanlei on 2017/1/17.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEWXWorkViewController.h"
#import "TAIHEWXWorkView.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "StringUtil.h"
#ifdef _TAIHE_FLAG_
#import "TAIHEAgentLstViewController.h"
#import "TAIHEAppViewController.h"
#endif
#import "UserDefaults.h"
#import "IOSSystemDefine.h"
#import "EmailViewController.h"
#import "UIAdapterUtil.h"
#import "conn.h"
#import "AESCipher.h"
#import "ServerConfig.h"

@interface TAIHEWXWorkViewController ()
/** 第三方应用数据源 */
@property (nonatomic,strong) NSMutableArray *dataArr;

/** 界面控件 */
@property (nonatomic,strong) UIScrollView *backScrollView;
@end

@implementation TAIHEWXWorkViewController
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        // 初始化第三方应用
        NSMutableArray *mArr = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
        for (NSArray *modelArr in mArr) {
            for (APPListModel *appModel in modelArr) {
                [_dataArr addObject:appModel];
            }
        }
    }
    return _dataArr;
}
- (UIScrollView *)backScrollView{
    if(!_backScrollView){
        _backScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    }
    return _backScrollView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil showTabar:self];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [StringUtil getAppLocalizableString:@"main_works"];
    
    // 加载轻应用视图
    [self loadMyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GoOAHome:) name:TAI_HE_WORK_GO_OA_HOME object:nil];
}

#pragma mark 添加
- (void)loadMyView{
    [self.view addSubview:self.backScrollView];
    // 显示的列数
    int cols = 4;
    
    CGFloat spaceW = 20;
    CGFloat workW = (self.view.bounds.size.width - (cols+1)*spaceW)/cols;
    CGFloat workH = 90;

    // 对iphone5进行适配
    if (IS_IPHONE_5) {
        spaceW = 10;
        workW = (self.view.bounds.size.width - (cols+1)*spaceW)/cols;
        workH = 80;
    }
    
    // 每一列之间的间距
    CGFloat colMargin = spaceW;
    // 每一行之间的间距
    CGFloat rowMargin = spaceW;
    
    CGFloat maxWorkViewY = 0;
    
    for (int index = 0; index < self.dataArr.count; index++) {
        TAIHEWXWorkView *workView = [TAIHEWXWorkView workView];
        workView.appModel = self.dataArr[index];
        workView.tag = 100+index;
        
        NSUInteger col = index % cols;
        CGFloat workX = workW * col + (col + 1)*colMargin;
        
        NSUInteger row = index / cols;
        CGFloat workY = workH * row + (row + 1)*rowMargin;
        
        workView.frame = CGRectMake(workX, workY, workW, workH);
        
        if (IS_IPAD) {
            
            CGFloat Button_Height = SCREEN_WIDTH/5 - 30;  // 高
            CGFloat Button_Width  =  SCREEN_WIDTH/5 - 30;    // 宽
            
            workView.frame = CGRectMake(index % 5 * (Button_Width  + 20) + 20, index/5 * (Button_Height - 20 + 70)+ 40 ,Button_Width , Button_Height);
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoAppDetail:)];
        [workView addGestureRecognizer:tap];
        
        if (index == self.dataArr.count-1) {
            maxWorkViewY = CGRectGetMaxY(workView.frame) + rowMargin + 64;
        }
        // 加载到视图上
        [self.backScrollView addSubview:workView];
    }
    self.backScrollView.contentSize = CGSizeMake(self.view.frame.size.width, maxWorkViewY);
}

- (void)gotoAppDetail:(UITapGestureRecognizer *)tap{
    TAIHEWXWorkView *workView = (TAIHEWXWorkView *)tap.view;
    APPListModel *appModel = self.dataArr[workView.tag-100];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,appModel.apphomepage]];
    
#ifdef _TAIHE_FLAG_
    // 使用加密的参数
    NSString *paramStr = [StringUtil encryptStr];
    NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
    NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
    NSString *url = [NSString stringWithFormat:@"%@?username=%@",ssoUrl,paramStr];
    if (appModel.appid == 102) {
        
        EmailViewController *emailVC = [[EmailViewController alloc]init];
        [UIAdapterUtil hideTabBar:self];
        
        emailVC.urlstr = [[NSString stringWithFormat:@"%@&url=%@",url,appModel.apphomepage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [TAIHEAppViewController getTaiHeAppViewController].isReloadHttpUnReadEmail = YES;
        [self.navigationController pushViewController:emailVC animated:YES];
        return;
    }
    
    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    openweb.urlstr= [[NSString stringWithFormat:@"%@&url=%@",url,appModel.apphomepage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (appModel.appid == 101) {
        
        openweb.isWhere = REFRESH_OA;
    }
    openweb.isGoHome = WORK_GO_OA_HOME;
    [self.navigationController pushViewController:openweb animated:YES];
#endif
}

- (void)GoOAHome:(NSNotification *)notification{
    
    NSString *urlStr = notification.userInfo[WORK_GO_OA_HOME];
#ifdef _TAIHE_FLAG_
    TAIHEAgentLstViewController *agent = [[TAIHEAgentLstViewController alloc]init];
    agent.urlstr = urlStr;
    agent.isGoHome = WORK_GO_OA_HOME;
    [self.navigationController pushViewController:agent animated:NO];
#endif
}

@end
