//
//  DetailScheduleViewController.m
//  eCloud
//
//  Created by  lyong on 13-10-23.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "DetailScheduleViewController.h"
#import "eCloudDefine.h"

#import "Emp.h"
#import "eCloudUser.h"
#import <QuartzCore/QuartzCore.h>
#import "talkRecordDetailViewController.h"
#import "talkSessionViewController.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "ImageSet.h"
#import "userInfoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "helperObject.h"
#import "conn.h"
#import "ImageUtil.h"

#import "conn.h"
#import "editScheduleViewController.h"
#import "personInfoViewController.h"
#import "helperObject.h"
#import "ScheduleConn.h"
@interface DetailScheduleViewController ()
@property (nonatomic, retain) talkSessionViewController *talkSession;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *titleview;
@property (nonatomic, retain) UIView *detailview;
@property (nonatomic, retain) UIView *warningview;
@property (nonatomic, retain) UIView *memberview;
@property (nonatomic, retain) UITextView *detailField;
@property(nonatomic,retain)UIButton *expandButton;
@property(nonatomic,retain)UIImageView *expandimageview;
@property(nonatomic,retain)UIAlertView *deleteAlert;

@end

@implementation DetailScheduleViewController
@synthesize helper_id;
@synthesize memberScroll;
@synthesize dataArray;
@synthesize deleteIndex;
@synthesize start_Delete;
@synthesize selectLabel;

-(void)dealloc
{
    [self.memberScroll release];
	[self.dataArray release];
	[self.talkSession release];
    
    self.memberScroll = nil;
	self.dataArray = nil;
	self.talkSession = nil;
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
-(void)displayTabBar
{
	//	add by shisp 2013.6.16
	//	在隐藏的情况下，显示出来，并且
	if(self.tabBarController && self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上减去tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		//NSLog(@"tabbar height is %.0f",_tabBar.frame.size.height);
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height - _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		self.tabBarController.tabBar.hidden = NO;
		
	}
	self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
   
    if (self.titleview!=nil) {//刷新
        eCloudDAO*   db = [eCloudDAO getDatabase];
        
        hobject=[db getTheDateScheduleByID:self.helper_id];
        self.dataArray=[db getEmpByhelperid:self.helper_id];

        UILabel *titleLabel=(UILabel *)[self.titleview viewWithTag:1];
        titleLabel.text=hobject.helper_name;
        
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        
        NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
        if ([from isEqualToString:@"From"]) {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            fmt.dateFormat = @"dd/MM HH:mm";
        }else
        {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"MM月dd日 HH:mm";
        }
        NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
        NSString *starttime= [fmt stringFromDate:tempdate];
        tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.end_time intValue]];
        
        NSString *endtime= [fmt stringFromDate:tempdate];
        [fmt release];
        
        UILabel *dateLabel=(UILabel *)[self.titleview viewWithTag:3];
        dateLabel.text=[NSString stringWithFormat:@"%@ - %@",starttime,endtime];
        
        UILabel *publishLable=(UILabel *)[self.titleview viewWithTag:4];
        publishLable.text=[NSString stringWithFormat:@"%@ %@",hobject.create_emp_name,[StringUtil getLocalizableString:@"schedule_launch"]];

        self.detailField.text=hobject.helper_detail;
        ringLable.text=hobject.ring_str;
        [self showMemberScrollow];
        [self performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.2];
        
    }
}

-(void)updateTableContent
{
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
   
}
-(void)addAction:(id)sender
{
    NSLog(@"---talkAction--here");
    eCloudDAO*   db = [eCloudDAO getDatabase];
    NSString *groupid=[db getGroupIdByHelperID:self.helper_id];
    
    NSDictionary *dic=[db searchConversationBy:groupid];
    helperObject *nowHelper=[db getTheDateScheduleByID:self.helper_id];
    NSString *create_emp_id=[NSString stringWithFormat:@"%d",nowHelper.create_emp_id];
    NSArray *emps=[db getEmpByhelperid:self.helper_id];
    
    
    if ([emps count]>0) {
        
        if (dic==nil) {//没有会话
            conn* _conn = [conn getConn];
             [_conn getGroupInfo:groupid];
            
            
            NSString *nowTime =[_conn getSCurrentTime];
            
            //			首先创建分组成功后，保存到本地
			//				多人会话
			NSString *convType = [StringUtil getStringValue:mutiableType];
			//				不屏蔽
			NSString *recvFlag = [StringUtil getStringValue:open_msg];
            
			NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:groupid,@"conv_id",convType,@"conv_type",nowHelper.helper_name,@"conv_title",recvFlag,@"recv_flag",create_emp_id,@"create_emp_id",nowTime, @"create_time",@"-1",@"last_msg_id", nil];
			
			[db addConversation:[NSArray arrayWithObject:dic]];
			
			//				增加会话成员
			NSMutableArray *tempArray = [NSMutableArray array];
			for(Emp *_emp in emps)
			{
				dic = [NSDictionary dictionaryWithObjectsAndKeys:groupid,@"conv_id",[StringUtil getStringValue:_emp.emp_id ],@"emp_id", nil];
				[tempArray addObject:dic];
			}
			[db addConvEmp:tempArray];
			
            //			在这里增加一个群组创建消息 你邀请谁加入群聊
            //			//群聊中除自己以外的人员的名称
			NSMutableString *otherNames = [NSMutableString stringWithString:@""];
			
			for(Emp *_emp in emps)
			{
				if(_emp.emp_id != _conn.userId.intValue)
				{
					[otherNames appendString:[_emp getEmpName]];
					[otherNames appendString:@","];
				}
			}
			
			if(otherNames.length > 1)
			{
				[otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
				
				
				NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_invite_x_join_group"],otherNames];
				//	保存到数据库中
				//				 新增文本消息，并通知
				[_conn saveGroupNotifyMsg:groupid andMsg:msgBody andMsgTime:[_conn getSCurrentTime]];
			}
            self.talkSession.talkType = mutiableType;
            self.talkSession.titleStr = nowHelper.helper_name;
            self.talkSession.convId = groupid;
            self.talkSession.needUpdateTag=1;
            self.talkSession.convEmps =emps;
            self.talkSession.last_msg_id=-1;
            [db updateLastInputMsgByConvId:groupid LastInputMsg:nowHelper.helper_name];
            
            // [self hideTabBar];
            [self.navigationController pushViewController:self.talkSession animated:YES];
            
            return;
        }
        
        self.talkSession.talkType = mutiableType;
        self.talkSession.titleStr = [dic objectForKey:@"conv_title"];
        self.talkSession.convId = groupid;
		self.talkSession.needUpdateTag=1;
        self.talkSession.convEmps =emps;
        self.talkSession.last_msg_id=[[dic objectForKey:@"last_emp_id"]intValue];
        // [self hideTabBar];
        [self.navigationController pushViewController:self.talkSession animated:YES];
        
        
    }
    else
    {
        NSLog(@"－－－没有会话");
        
    }
    
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)ringAction:(id)sender
{
 NSLog(@"---ringAction --here");
    if (self.selectLabel.hidden) {
        UIButton *button=(UIButton *)sender;
        self.selectLabel.hidden=NO;
        self.selectLabel.frame=CGRectMake(10, button.frame.origin.y+40, 300, 60);
      
    }else
    {
     self.selectLabel.hidden=YES;
    }
    [self.tableView reloadData];
  
}
-(void)selectActionForSelect:(id)sender
{
    
    NSLog(@"------selectActionForOne");
    UIButton *button=(UIButton *)sender;
    UIView *preview=[button superview];
    
    for( UIView * view in preview.subviews )
    {
        if( [view isKindOfClass:[UIButton class]] )
        {
            UIImageView *imageview=(UIImageView *)[view viewWithTag:110];
            imageview.image=[StringUtil getImageByResName:@"noselected.png"];
        }
        
    }
    
    UIImageView *imageview=(UIImageView *)[button viewWithTag:110];
    imageview.image=[StringUtil getImageByResName:@"selected.png"];
    UILabel *contextlabel=(UILabel *)[button viewWithTag:111];
   
    ringLable.text=contextlabel.text;
     self.selectLabel.hidden=YES;
     [self.tableView reloadData];
    NSString *typestr=[ringdic objectForKey:contextlabel.text];
     NSLog(@"--contextlabel.text-- %@  typestr %@",contextlabel.text ,typestr);
    eCloudDAO*   db = [eCloudDAO getDatabase];
    [db updateHelperRingTypeByID:self.helper_id Type:typestr TypeName:ringLable.text];
    
    //修改 提醒
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArr = [app scheduledLocalNotifications];
    
    //声明本地通知对象
    UILocalNotification *localNoti=nil;
    
    if (localArr) {
        for (UILocalNotification *noti in localArr) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:@"localNoticeId"];
                if ([inKey isEqualToString:self.helper_id]) {
                    if (localNoti){
                        [localNoti release];
                        localNoti = nil;
                    }
                    localNoti = [noti retain];
                    [app cancelLocalNotification:localNoti];
                    [localNoti release];
                    break;
                }
            }
        }
        
         //新建 通知
            if (typestr.intValue>0) {
                NSDateFormatter* locfmt = [[NSDateFormatter alloc] init];
                locfmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                locfmt.dateFormat = @"yyyy-MM-dd HH:mm";
                NSDate *locstartdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
                NSString *locstartstr= [locfmt stringFromDate:locstartdate];
                
                NSDate *tempdate=nil;
                
                if (typestr.intValue==1) {//正点
                    tempdate=locstartdate;
                }else if(typestr.intValue==2) {//10分钟
                    tempdate= [locstartdate dateByAddingTimeInterval:-10*60];
                }
                else if(typestr.intValue==3) {//30分钟
                    tempdate= [locstartdate dateByAddingTimeInterval:-30*60];
                }
                else if(typestr.intValue==4) {//1小时
                    tempdate= [locstartdate dateByAddingTimeInterval:-60*60];
                }
                else if(typestr.intValue==5) {//1天前
                    tempdate= [locstartdate dateByAddingTimeInterval:-24*60*60];
                }
                
             //   NSString *starttime= [fmt stringFromDate:tempdate];
             //   NSLog(@"--localNotif-starttime  --  %@  startstr %@  ringtype %d",starttime,locstartstr,typestr.intValue);
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil)
                    return;
                localNotif.fireDate = tempdate;
                localNotif.timeZone = [NSTimeZone defaultTimeZone];
                
                // Notification details
                localNotif.alertBody =  [NSString stringWithFormat:@"%@:%@ \n%@",[StringUtil getLocalizableString:@"schedule_show"],locstartstr,hobject.helper_name];
               
                // Set the action button
                localNotif.alertAction = @"打开";
                
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                // localNotif.applicationIconBadgeNumber = 1;
                
                // Specify custom data for the notification
                  NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:hobject.helper_id,@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
                localNotif.userInfo = infoDict;
                
                // Schedule the notification
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                [localNotif release];
            }
       }
}
- (IBAction)doActionForAdimi:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    switch (seg.selectedSegmentIndex) {
        case 0:
            NSLog(@"-here-edit");
            editSchedule=[[editScheduleViewController alloc]init];
            editSchedule.helper_id=self.helper_id;
            [self.navigationController pushViewController:editSchedule animated:YES];
            [editSchedule release];
            break;
            
        case 1:
           NSLog(@"-here-delete");
            if(self.deleteAlert==nil)
            {
                self.deleteAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_delete"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"schedule_yes"] otherButtonTitles:[StringUtil getLocalizableString:@"schedule_no"], nil];
                
            }
            [self.deleteAlert show];
            break;
            
        default:
            break;
    }
    
  
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        NSLog(@"---删除该日程");
  
        int state= [[ScheduleConn getScheduleConn] deleteHelperSchedule:hobject.helper_id GroupID:hobject.group_id CreateID:hobject.create_emp_id];
        if (state==0) {

            
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_delete_fail"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    ringdic=[[NSMutableDictionary alloc] init];
    [ringdic setObject:@"1" forKey:@"正点"];
    [ringdic setObject:@"2" forKey:@"10分钟"];
    [ringdic setObject:@"3" forKey:@"30分钟"];
    [ringdic setObject:@"4" forKey:@"1小时"];
    [ringdic setObject:@"5" forKey:@"1天前"];
    [ringdic setObject:@"0" forKey:@"不提醒"];
    [ringdic setObject:@"1" forKey:@"On Time"];
    [ringdic setObject:@"2" forKey:@"10 min"];
    [ringdic setObject:@"3" forKey:@"30 min"];
    [ringdic setObject:@"4" forKey:@"1 hour"];
    [ringdic setObject:@"5" forKey:@"1 day"];
    [ringdic setObject:@"0" forKey:@"No Remind"];
    personInfo=[[personInfoViewController alloc]init];
    //-----------------------修改提醒----------------------------
    self.selectLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 35, 300, 60)];
    self.selectLabel.tag=6;
    self.selectLabel.layer.borderColor=[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1].CGColor;
    self.selectLabel.layer.borderWidth=0.5;
    self.selectLabel.hidden=YES;
    
    self.selectLabel.userInteractionEnabled=YES;
    
    UIButton *selectButton11=[[UIButton alloc]initWithFrame:CGRectMake(5, 0, 80, 30)];
    [selectButton11 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton11=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton11.tag=110;
    imagebutton11.image=[StringUtil getImageByResName:@"noselected.png"];
    UILabel *button11Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 65, 30)];
    button11Title.backgroundColor=[UIColor clearColor];
    button11Title.font=[UIFont systemFontOfSize:12];
    button11Title.text=[StringUtil getLocalizableString:@"schedule_no_remind"];
    button11Title.tag=111;
    button11Title.textColor=[UIColor grayColor];
    [selectButton11 addSubview:imagebutton11];
    [selectButton11 addSubview:button11Title];
    [self.selectLabel addSubview:selectButton11];
    [button11Title release];
    [imagebutton11 release];
    [selectButton11 release];
    
    UIButton *selectButton12=[[UIButton alloc]initWithFrame:CGRectMake(5, 30, 80, 30)];
    [selectButton12 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton12=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton12.image=[StringUtil getImageByResName:@"noselected.png"];
    imagebutton12.tag=110;
    UILabel *button12Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 55, 30)];
    button12Title.backgroundColor=[UIColor clearColor];
    button12Title.font=[UIFont systemFontOfSize:12];
    button12Title.text=[StringUtil getLocalizableString:@"schedule_30_min"];
    button12Title.tag=111;
    button12Title.textColor=[UIColor grayColor];
    [selectButton12 addSubview:imagebutton12];
    [selectButton12 addSubview:button12Title];
    [self.selectLabel addSubview:selectButton12];
    [button12Title release];
    [imagebutton12 release];
    [selectButton12 release];
    
    UIButton *selectButton21=[[UIButton alloc]initWithFrame:CGRectMake(115, 0, 80, 30)];
    [selectButton21 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton21=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton21.image=[StringUtil getImageByResName:@"noselected.png"];
    imagebutton21.tag=110;
    UILabel *button21Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 55, 30)];
    button21Title.backgroundColor=[UIColor clearColor];
    button21Title.font=[UIFont systemFontOfSize:12];
    button21Title.text=[StringUtil getLocalizableString:@"schedule_on_time"];
    button21Title.tag=111;
    button21Title.textColor=[UIColor grayColor];
    [selectButton21 addSubview:imagebutton21];
    [selectButton21 addSubview:button21Title];
    [self.selectLabel addSubview:selectButton21];
    [button21Title release];
    [imagebutton21 release];
    [selectButton21 release];
    
    UIButton *selectButton22=[[UIButton alloc]initWithFrame:CGRectMake(115, 30, 80, 30)];
    [selectButton22 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton22=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton22.image=[StringUtil getImageByResName:@"noselected.png"];
    imagebutton22.tag=110;
    UILabel *button22Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 55, 30)];
    button22Title.backgroundColor=[UIColor clearColor];
    button22Title.font=[UIFont systemFontOfSize:12];
    button22Title.text=[StringUtil getLocalizableString:@"schedule_1_hour"];
    button22Title.tag=111;
    button22Title.textColor=[UIColor grayColor];
    [selectButton22 addSubview:imagebutton22];
    [selectButton22 addSubview:button22Title];
    [self.selectLabel addSubview:selectButton22];
    [button22Title release];
    [imagebutton22 release];
    [selectButton22 release];
    
    UIButton *selectButton31=[[UIButton alloc]initWithFrame:CGRectMake(225, 0, 80, 30)];
    [selectButton31 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton31=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton31.tag=110;
    imagebutton31.image=[StringUtil getImageByResName:@"noselected.png"];
    UILabel *button31Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 55, 30)];
    button31Title.backgroundColor=[UIColor clearColor];
    button31Title.font=[UIFont systemFontOfSize:12];
    button31Title.text=[StringUtil getLocalizableString:@"schedule_10_min"];
    button31Title.tag=111;
    button31Title.textColor=[UIColor grayColor];
    [selectButton31 addSubview:imagebutton31];
    [selectButton31 addSubview:button31Title];
    [self.selectLabel addSubview:selectButton31];
    [button31Title release];
    [imagebutton31 release];
    [selectButton31 release];
    
    UIButton *selectButton32=[[UIButton alloc]initWithFrame:CGRectMake(225, 30, 80, 30)];
    [selectButton32 addTarget:self action:@selector(selectActionForSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imagebutton32=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 20, 20)];
    imagebutton32.image=[StringUtil getImageByResName:@"noselected.png"];
    imagebutton32.tag=110;
    UILabel *button32Title=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 55, 30)];
    button32Title.backgroundColor=[UIColor clearColor];
    button32Title.font=[UIFont systemFontOfSize:12];
    button32Title.text=[StringUtil getLocalizableString:@"schedule_1_day"];
    button32Title.tag=111;
    button32Title.textColor=[UIColor grayColor];
    [selectButton32 addSubview:imagebutton32];
    [selectButton32 addSubview:button32Title];
    [self.selectLabel addSubview:selectButton32];
    [button32Title release];
    [imagebutton32 release];
    [selectButton32 release];

    //---------------------------------------------------－－－－
    
    if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=[StringUtil getLocalizableString:@"schedule_details"];
    
   
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

    _conn = [conn getConn];
    isFresh = false;
    eCloudDAO*   db = [eCloudDAO getDatabase];
   
    hobject=[db getTheDateScheduleByID:self.helper_id];
    self.dataArray=[db getEmpByhelperid:self.helper_id];
    
    if(hobject.create_emp_id==_conn.userId.intValue)//创建人 才可以修改，删除
    {

        UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(80.0f, 7.0f, 83, 30.0f) ];
        if (IOS7_OR_LATER) {
        [segmentedControl insertSegmentWithImage:[[StringUtil getImageByResName:@"modify_ios.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:0 animated:YES];
        [segmentedControl insertSegmentWithImage:[[StringUtil getImageByResName:@"delete_ios.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:1 animated:YES];
        }else
        {
            [segmentedControl insertSegmentWithImage:[StringUtil getImageByResName:@"modify_ios.png"] atIndex:0 animated:YES];
            [segmentedControl insertSegmentWithImage:[StringUtil getImageByResName:@"delete_ios.png"] atIndex:1 animated:YES];
        }
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
//         [segmentedControl setTintColor:[UIColor colorWithRed:19/255.0 green:130/255.0 blue:210/255.0 alpha:1]];
        segmentedControl.momentary = YES;
        segmentedControl.multipleTouchEnabled=NO;
        [segmentedControl addTarget:self action:@selector(doActionForAdimi:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *segButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        [segmentedControl release];
        self.navigationItem.rightBarButtonItem = segButton;
        [segButton release];
    
    }
    //----title---
    self.titleview=[[UIView alloc]initWithFrame:CGRectMake(0, 00, 320, 60)];
    
    UIImageView *backgroupLable=[[UIImageView alloc]initWithFrame:CGRectMake(0, 00, 320, 60)];
    backgroupLable.image=[StringUtil getImageByResName:@"title_bj.png"];
   // backgroupLable.backgroundColor=[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    [self.titleview addSubview:backgroupLable];
    [backgroupLable release];
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 270, 20)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.tag=1;
    titleLabel.font=[UIFont boldSystemFontOfSize:16];
    titleLabel.text=hobject.helper_name;
    [self.titleview addSubview:titleLabel];
    [titleLabel release];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        fmt.dateFormat = @"dd/MM HH:mm";
    }else
    {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"MM月dd日 HH:mm";
    }
    NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
    NSString *starttime= [fmt stringFromDate:tempdate];
    tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.end_time intValue]];
    
    NSString *endtime= [fmt stringFromDate:tempdate];
    [fmt release];
    
    UILabel *dateLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 30, 220, 20)];
    dateLabel.backgroundColor=[UIColor clearColor];
    dateLabel.font=[UIFont systemFontOfSize:12];
    dateLabel.textColor=[UIColor blackColor];
    dateLabel.tag=3;
    dateLabel.text=[NSString stringWithFormat:@"%@ - %@",starttime,endtime];
    [self.titleview addSubview:dateLabel];
    [dateLabel release];
    
    UILabel *publishLable=[[UILabel alloc]initWithFrame:CGRectMake(200, 30, 100, 20)];
    publishLable.backgroundColor=[UIColor clearColor];
    publishLable.tag=4;
    publishLable.font=[UIFont systemFontOfSize:12];
    publishLable.textColor=[UIColor grayColor];
    publishLable.text=[NSString stringWithFormat:@"%@ %@",hobject.create_emp_name,[StringUtil getLocalizableString:@"schedule_launch"]];
    publishLable.textAlignment=NSTextAlignmentLeft;
    [self.titleview addSubview:publishLable];
    [publishLable release];
    
    UIButton *groupButton = [[UIButton  alloc]initWithFrame:CGRectMake(320-45,10,41,41)];
    [groupButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [groupButton setBackgroundImage:[StringUtil getImageByResName:@"Group_ios.png"] forState:UIControlStateNormal];
    [self.titleview addSubview:groupButton];
    [groupButton release];
    
    if ([self.dataArray count]==1) {
      groupButton.hidden=YES;
    }
     //----detail---
    self.detailview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    
    self.detailField=[[UITextView alloc]initWithFrame:CGRectMake(15, 0, 300, 70)];
    self.detailField.textColor=[UIColor lightGrayColor];
    self.detailField.backgroundColor=[UIColor clearColor];
    self.detailField.tag=2;
    self.detailField.font=[UIFont systemFontOfSize:14];
    self.detailField.userInteractionEnabled=NO;
    self.detailField.text=hobject.helper_detail;
    [self.detailview addSubview:self.detailField];
   
    
    self.expandButton= [[UIButton  alloc]initWithFrame:CGRectMake(280,0,40,30)];
    self.expandButton.tag=0;
    [self.expandButton addTarget:self action:@selector(externDoAction:)forControlEvents:UIControlEventTouchDown];
   // [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_2.png"] forState:UIControlStateNormal];
    [self.detailview  addSubview:self.expandButton];
    
    self.expandimageview=[[UIImageView alloc]initWithFrame:CGRectMake(280,0,40,30)];
    [self.expandimageview setContentMode:UIViewContentModeScaleAspectFit];
    self.expandimageview.image=[StringUtil getImageByResName:@"arrow_2.png"];
     [self.detailview  addSubview:self.expandimageview];
    //--warning--
     self.warningview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    lineimage.image=[StringUtil getImageByResName:@"title_bj.png"];
    [self.warningview  addSubview:lineimage];
    [lineimage release];
    
    ringLable=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 295, 30)];
    ringLable.backgroundColor=[UIColor clearColor];
    ringLable.font=[UIFont systemFontOfSize:12];
    ringLable.text=hobject.ring_str;
    ringLable.textAlignment=NSTextAlignmentLeft;
    ringLable.textColor=[UIColor grayColor];
    [self.warningview addSubview:ringLable];
   // [ringLable release];
    
    UIImageView *ringimage=[[UIImageView  alloc]initWithFrame:CGRectMake(295-20,5,20,20)];
    ringimage.image=[StringUtil getImageByResName:@"clock_ico.png"];
    [ringLable addSubview:ringimage];
    [ringimage release];
    
    UIButton*ringbutton = [[UIButton  alloc]initWithFrame:CGRectMake(10, 0, 295, 30)];
    [ringbutton addTarget:self action:@selector(ringAction:)forControlEvents:UIControlEventTouchUpInside];
    [self.warningview addSubview:ringbutton];
    [ringbutton release];
    
    [self.warningview addSubview:self.selectLabel];

    //--member--
    self.memberview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    
    UILabel *membertipLable=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 295, 30)];
    membertipLable.backgroundColor=[UIColor clearColor];
    membertipLable.font=[UIFont systemFontOfSize:12];
    membertipLable.text=[StringUtil getLocalizableString:@"schedule_participants"];
    membertipLable.textColor=[UIColor blackColor];
    membertipLable.textAlignment=NSTextAlignmentLeft;
    [self.memberview addSubview:membertipLable];
    [membertipLable release];
    

//
//    //	显示群组成员头像的视图
    self.memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(10, 21, 300, 80)];
//    self.memberScroll.layer.borderColor=[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1].CGColor;
//    self.memberScroll.layer.borderWidth=0.5;
    self.memberScroll.backgroundColor=[UIColor whiteColor];
    [self.memberview addSubview:self.memberScroll];
    [self showMemberScrollow];
    
//    UIImageView *lineimage1=[[UIImageView alloc]initWithFrame:CGRectMake(10, 30, 300, 1)];
//    lineimage1.image=[StringUtil getImageByResName:@"line_s.png"];
//    [self.memberview  addSubview:lineimage1];
//    [lineimage1 release];
//
//    //是否有编辑
//    NSArray *emps=[db getEmpByhelperid:self.helper_id];
//    if ([emps count]==1) {
//        Emp *emp=[emps objectAtIndex:0];
//        if (emp.emp_id==_conn.userId.intValue) {//只对本人可以编辑
//          editbuton.hidden=NO;
//        }
//    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,0, self.view.bounds.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView .dataSource=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    if (IOS7_OR_LATER) {
        self.tableView.frame=CGRectMake(0.0f,0, self.view.bounds.size.width, self.view.frame.size.height);
    }
    else
    {
    
    }

}

-(void)externDoAction:(id)sender
{    
    if (self.expandButton.tag==0) {
        self.expandButton.tag=1;
        self.expandimageview.image=[StringUtil getImageByResName:@"arrow_1.png"];
        //  [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_1.png"] forState:UIControlStateNormal];
    }else{
        self.expandButton.tag=0;
        // [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_2.png"] forState:UIControlStateNormal];
        self.expandimageview.image=[StringUtil getImageByResName:@"arrow_2.png"];
    }
    [self.tableView reloadData];
}
//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height=80;
    if (indexPath.row==0) {
        height=60;
    }
    else if(indexPath.row==1) {
        NSLog(@"-detailField--heigh-- %f",self.detailField.contentSize.height);
        self.expandButton.hidden=YES;
        self.expandimageview.hidden=YES;
        if(self.detailField.contentSize.height>70)
        {
            float cellheight=self.detailField.contentSize.height;
            if (self.detailField.contentSize.height>=160) {
                self.expandButton.hidden=NO;
                self.expandimageview.hidden=NO;
                if (self.expandButton.tag==0) {
                    cellheight=155;
                }
                
            }
            self.detailField.frame=CGRectMake(10, 0, 300, cellheight);
           
             self.detailview.frame=CGRectMake(0, 0, 320, cellheight+5);
             self.expandButton.frame=CGRectMake(0,0, 320, cellheight);
             self.expandimageview.frame=CGRectMake(280, cellheight-20, 40, 20);
            return cellheight;
        }else
        {
            self.detailField.frame=CGRectMake(10, 0, 300, 60);
           
             self.detailview.frame=CGRectMake(0, 0, 320, 70);
        }
        
        return 70;
    } else if(indexPath.row==2) {
        if (self.selectLabel.hidden) {
            height=40;
        }else
        {
            height=100;
        }
        
    }else if(indexPath.row==3)
    {
       height=self.memberview.frame.size.height+10;
    }
    return height;

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        [cell addSubview:self.titleview];
    }else if(indexPath.row==1) {
        [cell addSubview:self.detailview];
    }else if (indexPath.row==2)
    {
        [cell addSubview:self.warningview];
    }else if (indexPath.row==3)
    {
         [cell addSubview:self.memberview];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [self.memberScroll subviews])
    {
        [eachView removeFromSuperview];
        //[eachView release];
    }
    
}
-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    int showiconNum=4;
    
	int sumnum=[self.dataArray count];
    BOOL is_owner=NO;
//    if (sumnum>1) {
//        sumnum=[self.dataArray count]+2;
//        is_owner=YES;
//        NSLog(@"----HERE---create_emp_id");
//    }
  	//int sumnum=4;
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
	
	//scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(70, 630, showpageSize-70, 75)];//320
	self.memberScroll.pagingEnabled = NO;
    self.memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width , self.memberScroll.frame.size.height* pagenum);
    self.memberScroll.showsHorizontalScrollIndicator = YES;
    self.memberScroll.showsVerticalScrollIndicator = YES;
    self.memberScroll.scrollsToTop = NO;
    //  musicFirstSrollview.delegate = self;
    
    
	UIButton *pageview;
	
	int nowindex=0;
	
	
    UIView *itemview;
	UIButton *iconbutton;
    UIButton *deletebutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
	//UIImageView *backView;
	//	for (int i=0; i<pagenum; i++) {
	//float origin_x=5;
	
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, memberScroll.frame.size.width, memberScroll.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    //[pageview addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
	/*
	 CGRect frame = scrollView.frame;
	 frame.origin.x = 0;
	 frame.origin.y = frame.size.height * i;
	 pageview.frame=frame;
	 */
	x=15;
	y=0;
	cx=5;
	cy=0;
	
    int row=0;
	for (int j=0; j<sumnum; j++) {
		
		
		nowindex=j;
        
		//item=[dataArray objectAtIndex:nowindex];
        Emp *emp=[self.dataArray objectAtIndex:j];
		if (j/4==row) {
            
            cx=cx+67;
			if (j==0) {
                cx=7;
            }
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+9+5,60,60)];
            
			
		}else if (j/4!=row) {
        	
            cx=7;
            cy=cy+80;
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+9+5,60,60)];
            
		}
        
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
        //        iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
        // iconbutton.layer.borderWidth = 3;//设置边框的宽度，当然可以不要
        //iconbutton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
        //        iconbutton.layer.masksToBounds = YES;//设为NO去试试
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, 60, 20)];
        nameLabel.text=emp.emp_name;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textAlignment=UITextAlignmentCenter;
        if (emp.emp_status==status_online||emp.emp_status==status_leave)
        {
            nameLabel.textColor=[UIColor blueColor];
        }
        else
        {
            nameLabel.textColor=[UIColor blackColor];
        }
        [itemview addSubview:iconbutton];
        [itemview addSubview:nameLabel];
        [nameLabel release];
        
        if (is_owner&&self.start_Delete) {
            
            deletebutton=[[UIButton alloc]initWithFrame:CGRectMake(-7,-7,30,30)];
            deletebutton.tag=nowindex;
            [deletebutton setImage:[StringUtil getImageByResName:@"red_delete.png"] forState:UIControlStateNormal];
            [deletebutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];
            [itemview addSubview:deletebutton];
            [deletebutton release];
        }
        
        
		row=j/4;
		
       	UIImage *image;
        NSString *empLogo = emp.emp_logo;
		if(empLogo && empLogo.length > 0)
		{
            image = [ImageUtil getLogo:emp];
			if(image == nil)
			{
				image = [ImageUtil getDefaultLogo:emp];
				dispatch_queue_t queue = dispatch_queue_create("download_userlogo", NULL);
				dispatch_async(queue, ^{
					NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],empLogo]];
					NSData *imageData = [NSData dataWithContentsOfURL:url];
					UIImage *downloadImage = [UIImage imageWithData:imageData];
					if(downloadImage)
					{
                        //						保存头像之前，先删除原来的头像
						[StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:emp.emp_id]];
						
						NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id ] andLogo:empLogo];
						BOOL success= [imageData writeToFile:logoPath atomically:YES];
						if(!success)
						{
							NSLog(@"save user logo fail");
						}
						
						UIImage *offlineimage=[ImageSet setGrayWhiteToImage:downloadImage];
						NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
						NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
						BOOL offlinesuccess= [dataObj writeToFile:offlinepicPath atomically:YES];
						if(!offlinesuccess)
						{
							NSLog(@"save user offline logo fail");
						}
						
						if(!isFresh)
						{
							isFresh = true;
						}
						dispatch_async(dispatch_get_main_queue(), ^{
							if(_conn.userStatus == status_online)
							{
								if (emp.emp_status==status_online||emp.emp_status==status_leave)
								{
									[iconbutton setBackgroundImage:downloadImage forState:UIControlStateNormal];
								}
								else
								{
									
                                    [iconbutton setBackgroundImage:offlineimage forState:UIControlStateNormal];
								}
							}
							else
							{
								[iconbutton setBackgroundImage:offlineimage forState:UIControlStateNormal];
								
							}
						});
					}
				});
			}
		}
		else
		{
			image = [ImageUtil getDefaultLogo:emp];
		}
        
		[iconbutton setBackgroundImage:image forState:UIControlStateNormal];
		iconbutton.tag=nowindex;
		
		iconbutton.backgroundColor=[UIColor clearColor];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
		[pageview addSubview:itemview];
		[iconbutton release];
        
	}
	pageview.frame=CGRectMake(0, 0,self.memberScroll.frame.size.width,y+cy+115);
	//pageview.backgroundColor=[UIColor clearColor];
	[self.memberScroll addSubview:pageview];
	self.memberScroll.contentSize = CGSizeMake(self.memberScroll.frame.size.width, y+cy+115);
	self.memberScroll.frame=CGRectMake(10, 25, 300, y+cy+115);
    self.memberview.frame=CGRectMake(0,0,320, y+cy+115);
     //    if (self.talkType==singleType) {
    //        titleLabel.text=@"聊天信息";
    //    }else
    //    {
    //        titleLabel.text=[NSString stringWithFormat:@"聊天信息(%d)",[self.dataArray count]];
    //    }
    
	[pageview release];
  
    // actionTable.tableHeaderView=memberScroll;
    //    if (sumnum>8) {
    //        CGPoint bottomOffset = CGPointMake(0, memberScroll.contentSize.height - memberScroll.bounds.size.height);
    //        [memberScroll setContentOffset:bottomOffset animated:YES];
    //    }
    
}

-(void)iconbuttonAction:(id)sender
{
    
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    
    NSLog(@"----index-- %d",index);
       eCloudDAO*   db = [eCloudDAO getDatabase];
        Emp *emp=[self.dataArray objectAtIndex:index];
        
        emp=[db getEmpInfo:[StringUtil getStringValue:emp.emp_id]];
        
        if(emp.emp_id == [_conn.userId intValue])
        {
            //		打开用户自己的资料
            userInfoViewController *userInfo = [[userInfoViewController alloc]init];
            userInfo.tagType=1;
            userInfo.emp=emp;
            userInfo.titleStr=emp.emp_name;
			[self.navigationController pushViewController:userInfo animated:YES];
            [userInfo release];
            return;
        }
    personInfo.emp=emp;
    [self.navigationController pushViewController:personInfo animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
