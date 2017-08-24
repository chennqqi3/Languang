//
//  broadcastContentViewController.m
//  eCloud
//
//  Created by SH on 14-7-29.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "broadcastContentViewController.h"
#import "eCloudDAO.h"
#import "VerticallyAlignedLabel.h"
#import "eCloudDAO.h"
#import "broadcastListViewController.h"
#import "openWebViewController.h"
#import "TextLinkView.h"

@interface broadcastContentViewController ()

@end

@implementation broadcastContentViewController
{
    float cellHeight;
    float titleHeight;
    eCloudDAO *db;
}
@synthesize messageString;
@synthesize titleString;

- (void)dealloc
{
    self.messageString = nil;
    self.titleString = nil;
    self.msgId = nil;
    self.convId = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"%s,%@",__FUNCTION__,NSStringFromCGRect(self.view.frame));
    broadcastContentView.frame = CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height);
    if(IOS7_OR_LATER)
    {
        // 计算title的高度  ios7及以上使用
        titleHeight = [self.titleString boundingRectWithSize:CGSizeMake(self.view.frame.size.width-40,4000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} context:nil].size.height;
    }
    else
    {
        // 计算title的高度  ios6及以上使用
        titleHeight = [self.titleString sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(209,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height;
    }
    
    // 动态匹配广播内容的高度(普通字符串使用)
    //    cellHeight = [self.messageString boundingRectWithSize:CGSizeMake(self.view.frame.size.width-20,4000)options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} context:nil].size.height+70;
    // 动态匹配广播内容的高度(普通字符串/带链接的字符串使用)
    TextLinkView *linkView = [[TextLinkView alloc]initWithFrame:CGRectMake(10, 0, 0, 0)];
    linkView.textWidth = self.view.frame.size.width-10;
    linkView.textstr = self.messageString;
    cellHeight = [linkView getViewSize].height+50+titleHeight;
    [linkView release];

    
    if (self.broadcastType == normal_broadcast)
    {
        self.title=[StringUtil getLocalizableString:@"settings_broadcast_message"];
    }
    else
    {
        self.title=[StringUtil getLocalizableString:@"im_notice"];
    }
    
    // 添加打开url网页通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWebUrl:) name:OPEN_WEB_NOTIFICATION object:nil];
    
    if ([db needUpdateBroadcastReadFlag:self.msgId])
    {
        [db updateBroadcastReadFlagToRead:self.msgId andUpdateConvId:self.convId andBroadcastType:self.broadcastType];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //if ([db needUpdateBroadcastReadFlag:self.msgId])
    //{
        //[db updateBroadcastReadFlagToRead:self.msgId andUpdateConvId:self.convId andBroadcastType:self.broadcastType];
    //}
}
// 页面失去焦点后,取消通知
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:OPEN_WEB_NOTIFICATION object:nil];
}

// 广播消息链接的通知事件
-(void)openWebUrl:(NSNotification *)notification
{
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.urlstr=notification.object;
    [self.navigationController pushViewController:openweb animated:YES];
    [openweb release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    db = [eCloudDAO getDatabase];
    
//    NSLog(@"%s,%@",__FUNCTION__,NSStringFromCGRect(self.view.frame));
    broadcastContentView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    
//    self.title = [StringUtil getLocalizableString:@"settings_broadcast_message"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    broadcastContentView.dataSource = self;
    broadcastContentView.delegate = self;
    
    broadcastContentView.showsHorizontalScrollIndicator = NO;
    broadcastContentView.showsVerticalScrollIndicator = NO;
    broadcastContentView.backgroundView = nil;
    broadcastContentView.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview:broadcastContentView];
    [broadcastContentView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width -40, titleHeight+20)];
        titleLable.font=[UIFont boldSystemFontOfSize:18];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.backgroundColor=[UIColor clearColor];
        titleLable.text= self.titleString;
        titleLable.numberOfLines = 0;
        if (titleHeight > 22) {
            titleLable.textAlignment = NSTextAlignmentLeft;
        }
        
        [cell.contentView addSubview:titleLable];
        [titleLable release];
        
        //        VerticallyAlignedLabel *contentLabel = [[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(10,50, 300,cellHeight - 50)];
        //        contentLabel.verticalAlignment = VerticalAlignmentTop;
        //        contentLabel.text= self.messageString;
        //        contentLabel.font=[UIFont systemFontOfSize:16];
        //        contentLabel.backgroundColor=[UIColor clearColor];
        //        contentLabel.numberOfLines = 0;
        //        [cell addSubview:contentLabel];
        //        NSLog(@"height = %f",contentLabel.frame.size.height);
        //        [contentLabel release];
        
        TextLinkView *linkView = [[TextLinkView alloc]initWithFrame:CGRectZero];
        linkView.textWidth = self.view.frame.size.width - 10;
        linkView.textstr = self.messageString;
        [linkView getViewSize];
        
        [linkView updateShowContent];
        CGRect frame = linkView.frame;
        frame.origin.x = 5;
        frame.origin.y = titleHeight+20;
        linkView.frame = frame;
        [cell.contentView addSubview:linkView];
        [linkView release];
	}
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
