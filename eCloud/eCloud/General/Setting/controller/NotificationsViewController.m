//
//  NotificationsViewController.m
//  eCloud
//
//  Created by SH on 14-9-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NotificationsViewController.h"

#import "conn.h"

#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "notificationCell.h"
#import "UserInfo.h"
#import "eCloudUser.h"
#import "talkSessionUtil.h"
#import "LanUtil.h"
#import "GYFrame.h"
@interface NotificationsViewController ()
{
    conn *_conn;
}
@property (nonatomic,retain) UserInfo *userinfo;
@end

@implementation NotificationsViewController
@synthesize userinfo;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _conn = [conn getConn];
    self.userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];

    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    self.title=[StringUtil getLocalizableString:@"notification_notification"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"settings_settings"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    notification= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:notification];
    [notification setDelegate:self];
    [notification setDataSource:self];
    notification.backgroundView = nil;
    notification.backgroundColor=[UIColor clearColor];
    [self.view addSubview:notification];
    [notification release];
 
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
#ifdef _LANGUANG_FLAG_
        
            return 2;
        
#else
        
            return 1;
        
#endif
    }else
    {
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSString *str = @"";
    if (section == 0)
    {
        str = [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip"];
    }
    else
    {
        str = [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip_sound_and_vibrator"];
    }
    
//    CGSize _size = [talkSessionUtil getSizeOfTextMsg:str withFont:[UIFont systemFontOfSize:14.0] withMaxWidth:290.0];
    
    CGSize size = CGSizeMake(SCREEN_WIDTH-24, CGFLOAT_MAX);
    CGSize titleSize = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return titleSize.height + 15.0;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section ==0)
    {
        return [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip"];

    }else
    {
        return [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip_sound_and_vibrator"];
    }
}
*/

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *str = @"";
    if (section == 0)
    {
        str = [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip"];
    }
    else
    {
        str = [StringUtil getLocalStringRelatedWithAppNameByKey:@"notification_notification_tip_sound_and_vibrator"];
    }
    CGSize size = CGSizeMake(SCREEN_WIDTH-24, CGFLOAT_MAX);
    CGSize labelSize = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, labelSize.height)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, SCREEN_WIDTH-24, labelSize.height)];
    [titleLabel setTextColor:[UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0]];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    titleLabel.text = str;
    titleLabel.numberOfLines = 0;
    [footerView addSubview:titleLabel];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return [UIAdapterUtil isLANGUANGApp]?12:20;
//    }
//    return 10.0;
    return kGetCurrentValue(32);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [UIAdapterUtil isLANGUANGApp]?40:45;
    CGFloat height = kGetCurrentValue(51);
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    notificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[notificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
	}
    __weak NotificationsViewController *weakSelf = self;
    cell.switchActionCallBack = ^(id sender) {
        [weakSelf switchSoundAction:sender];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section ==0)
    {
#ifdef _LANGUANG_FLAG_
      
        if (indexPath.row ==0) {
            cell.nameLable.text = [StringUtil getLocalizableString:@"notification_bulletins"];
            [cell showSwitch];
            cell.switchBtn.on = YES;
            
        }else if (indexPath.row ==1){

            [cell showIsOpenLabel];
            if ([NotificationsViewController needAlertWhenRcvMsg])
            {
                cell.inOpenLable.text = [StringUtil getLocalizableString:@"notification_enabled"];
            }
            else
            {
                cell.inOpenLable.text = [StringUtil getLocalizableString:@"notification_disabled"];
            }
            
            cell.nameLable.text = [StringUtil getLocalizableString:@"notification_notification"];
            
            [UIAdapterUtil alignHeadIconAndCellSeperateLine:notification withOriginX:cell.nameLable.frame.origin.x];
            return cell;
            
        }
#else
        [cell showIsOpenLabel];
        if ([NotificationsViewController needAlertWhenRcvMsg])
        {
            cell.inOpenLable.text = [StringUtil getLocalizableString:@"notification_enabled"];
        }
        else
        {
            cell.inOpenLable.text = [StringUtil getLocalizableString:@"notification_disabled"];
        }
        
        cell.nameLable.text = [StringUtil getLocalizableString:@"notification_notification"];

        return cell;
        
#endif
        
    }
    if (indexPath.section ==1) {
        [cell showSwitch];
        if (indexPath.row ==0) {
            cell.nameLable.text = [StringUtil getLocalizableString:@"notification_alert_sound"];
            if (self.userinfo.voiceFlag==1) {
                [cell.switchBtn setOn:YES];
            }else
            {
                [cell.switchBtn setOn:NO];
            }
        }
        else
        {
            cell.nameLable.text = [StringUtil getLocalizableString:@"notification_alert_vibrate"];
//            [self positionSwitch:cell.switchBtn ofCell:cell];

            if (self.userinfo.vibrateFlag==1) {
                [cell.switchBtn setOn:YES];
            }else
            {
                [cell.switchBtn setOn:NO];
            }
        }
    }
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:notification withOriginX:cell.nameLable.frame.origin.x];
    return cell;
}

-(void)switchSoundAction:(id)sender
{
    //    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    if (((UISwitch *)sender).on) {
        [((UISwitch *)sender) setOn:YES];
        // [setting setBool:YES forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateVoiceRemindState:1 :[_conn.userId intValue]];//打开
        
    }else
    {
        [((UISwitch *)sender) setOn:NO];
        //[setting setBool:NO forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateVoiceRemindState:0 :[_conn.userId intValue]];//关闭
        
    }
    
}

-(void)switchVirateAction:(id)sender
{
    
    //   NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    if (((UISwitch *)sender).on) {
        [((UISwitch *)sender) setOn:YES];
        [[eCloudUser getDatabase] updateVibrateRemindState:1 :[_conn.userId intValue]];//打开
        
    }else
    {
        [((UISwitch *)sender) setOn:NO];
        [[eCloudUser getDatabase] updateVibrateRemindState:0 :[_conn.userId intValue]];//关闭
    }
}

- (void)positionSwitch:(UISwitch *)_switch ofCell:(UITableViewCell *)cell
{
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];
}

-(void) backButtonPressed:(id) sender{
    
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    self.userinfo = nil;
    [super dealloc];
}

//应用是否关闭了消息提醒
+ (BOOL)needAlertWhenRcvMsg
{
    UIRemoteNotificationType wNotificationType;
    
    if(IOS8_OR_LATER)
    {
        UIUserNotificationSettings *mySet = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        wNotificationType = mySet.types;
    }
    else
    {
        wNotificationType = [[UIApplication sharedApplication]enabledRemoteNotificationTypes];
    }
    
    if(wNotificationType == UIRemoteNotificationTypeNone)
    {
        return NO;
    }
    return YES;
}

//检查本地通知是否需要声音提醒
+ (BOOL)isNotificationNeedSound
{
    UIRemoteNotificationType wNotificationType;
    int _sound = 0;
    
    if(IOS8_OR_LATER)
    {
        UIUserNotificationSettings *mySet = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        wNotificationType = mySet.types;
        _sound = wNotificationType & UIUserNotificationTypeSound;
    }
    else
    {
        wNotificationType = [[UIApplication sharedApplication]enabledRemoteNotificationTypes];
        _sound = UIUserNotificationTypeSound & UIRemoteNotificationTypeSound;
    }
    
    if(wNotificationType > 0 && _sound > 0)
    {
        return YES;
    }
    return NO;
}

-(void)switchAction:(UISwitch *)sender
{
    if (sender.isOn)
    {
        NSLog(@"打开新闻公告消息推送");
    }
    else
    {
        NSLog(@"关闭新闻公告消息推送");
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = notification.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    notification.frame = _frame;
    
    self.userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    
    [notification reloadData];
    
}

@end
