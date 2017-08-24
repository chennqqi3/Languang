//
//  GOMEAppMsgListViewController.m
//  eCloud
//
//  Created by shisuping on 16/12/12.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "GOMEAppMsgListViewController.h"
#import "GOMENotiDetailViewController.h"
#import "RemindModel.h"
#import "APPPlatformDOA.h"
#import "Conversation.h"
#import "QueryResultCell.h"
#import "eCloudDAO.h"
#import "PSBackButtonUtil.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"
#import "APPListModel.h"
#import "ConvNotification.h"
#import "GOMEWebViewControllerArc.h"
#import "GOMEMailDefine.h"

//把原来的 owa.corp.gome.com.cn 换成 https://10.122.1.247/owa
//#define GOME_EMAIL_WEBSITE @"https://owa.corp.gome.com.cn"
#define GOME_EMAIL_WEBSITE @"https://10.122.1.247/owa"
//#define GOME_EMAIL_WEBSITE @"https://pushdan.cn/owa"



@interface GOMEAppMsgListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSMutableArray *itemArray;
@end

@implementation GOMEAppMsgListViewController
{
    UITableView *tableView;
}

@synthesize itemArray;

- (void)dealloc
{
    self.itemArray = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewRemind:) name:NEW_REMIND_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];
    
 
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStylePlain];
    
    [UIAdapterUtil setPropertyOfTableView:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = conv_row_height;
    
    [self.view addSubview:tableView];
    [tableView release];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:tableView];
    [UIAdapterUtil setExtraCellLineHidden:tableView];
    
    [self setLeftBtn];
    
    self.title = [StringUtil getLocalizableString:@"app_msg"];
    
    NSArray *tempArray = [[APPPlatformDOA getDatabase]  getGOMEAppMsgList];
    [self sortDataArray:tempArray];

    [tableView reloadData];
    
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    UIButton *backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    [tableView setEditing:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
        [cell initSubView];
    }
    cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
    
    Conversation *_conv = [self.itemArray objectAtIndex:indexPath.row];
    _conv.displayTime = YES;
    _conv.displayRcvMsgFlag = NO;
//    [cell configSearchResultCell:_conv];
    [cell configCell:_conv];
    [cell configAppLogo:_conv];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
        
        
        // 如果是邮件代收服务
        if (conv.appModel.appid == GOME_EMAIL_APP_ID)
        {
            GOMEWebViewControllerArc *webVC = [[[GOMEWebViewControllerArc alloc] init] autorelease];
            webVC.urlStr = GOME_EMAIL_WEBSITE;
            [self.navigationController pushViewController:webVC animated:YES];
        }
        else
        {
            GOMENotiDetailViewController *vc = [[[GOMENotiDetailViewController alloc]init]autorelease];
            vc.appModel = conv.appModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Conversation *_conv = [self.itemArray objectAtIndex:indexPath.row];
        [[APPPlatformDOA getDatabase]deleteAllMsgOfApp:_conv.conv_id];
        
        [self.itemArray removeObject:_conv];
        [tableView reloadData];
    }
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = tableView.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    tableView.frame = _frame;
    
    [tableView reloadData];
    
}

#pragma mark ======处理新提醒通知=======

- (void)processNewRemind:(NSNotification *)_notification
{
    NSDictionary *userInfo =  _notification.userInfo;
    if (userInfo) {
        RemindModel *newRemind = userInfo[NEW_REMIND_KEY];
        
        Conversation *newConv = [[APPPlatformDOA getDatabase]getLastAppMsg:newRemind.fromSystem];
        
        if (newConv) {
            //        如果已经包含了，那么需要重新获取
            //        如果不包含，那么需要获取后添加
            //        然后内存里排序，刷新界面
            
            int convIndex = -1;
            for (int i = 0;i < self.itemArray.count;i++) {
                Conversation *conv = self.itemArray[i];
                if ([conv.conv_id isEqualToString:newConv.conv_id]) {
                    convIndex = i;
                    break;
                }
            }
            if (convIndex < 0) {
                [self.itemArray insertObject:newConv atIndex:0];
            }else{
                [self.itemArray replaceObjectAtIndex:convIndex withObject:newConv];
                [self sortDataArray:self.itemArray];
            }
            
            [tableView reloadData];
        }
    }
}

- (void)sortDataArray:(NSArray *)dataArray
{
    NSArray *sortedArray = [dataArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)];
    self.itemArray = [NSMutableArray arrayWithArray:sortedArray];
}

#pragma mark =========
-(void)processNewConvNotification:(NSNotification *)notification
{
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case read_app_msg:
            case remove_app_msg:
            {
                NSDictionary *dic = _notification.info;
                NSString *appId = dic[@"app_id"];
                if (appId) {
                    Conversation *curConv = [[APPPlatformDOA getDatabase]getLastAppMsg:appId];
                    
                    int convIndex = -1;
                    for (int i = 0;i < self.itemArray.count;i++) {
                        Conversation *conv = self.itemArray[i];
                        if ([conv.conv_id isEqualToString:curConv.conv_id]) {
                            convIndex = i;
                            break;
                        }
                    }
                    if (convIndex >= 0) {
                        if (curConv.last_record == nil) {
                            [self.itemArray removeObjectAtIndex:convIndex];
                        }else{
                            [self.itemArray replaceObjectAtIndex:convIndex withObject:curConv];
                        }
                        [tableView reloadData];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
