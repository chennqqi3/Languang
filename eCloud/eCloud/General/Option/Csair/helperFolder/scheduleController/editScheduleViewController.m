//
//  addScheduleViewController.m
//  JBCalendar
//
//  Created by  lyong on 13-10-18.
//  Copyright (c) 2013年 JustBen. All rights reserved.
//
static int helper_recyle = 0;
#import "editScheduleViewController.h"
#import "eCloudDefine.h"

#import "Emp.h"
#import <QuartzCore/QuartzCore.h>
#import "talkRecordDetailViewController.h"
#import "talkSessionViewController.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"
#import "ImageSet.h"
#import "userInfoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "helperObject.h"
#import "ImageUtil.h"

#import "MWViewController.h"
#import "conn.h"
#import "chooseMemberViewController.h"
#import "textInputViewController.h"
#import "specialChooseMemberViewController.h"
#import "ScheduleConn.h"

@interface editScheduleViewController ()
@property (nonatomic, retain) UITableView *tableView;
@property(nonatomic,retain)UIButton *expandButton;
@property(nonatomic,retain)UIAlertView *tipAlert;
@end

@implementation editScheduleViewController
@synthesize titleField;
@synthesize detailField;
@synthesize selectLabel;
@synthesize memberScroll;
@synthesize start_Delete;
@synthesize deleteIndex;
@synthesize dataArray;
@synthesize chooseMember;
@synthesize startDate;
@synthesize endDate;
@synthesize getRingStr;
@synthesize getRingtype;
@synthesize placeholderlabel;
@synthesize ringLabel;
@synthesize detailView;
@synthesize detailLineImage;
@synthesize helper_id;
@synthesize specialchooseMember = _specialchooseMember;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)saveAction:(id)sender
{
    if (self.titleField.text.length==0||[self.dataArray count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_empty"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    if(_conn.userStatus == status_offline)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_check_network"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([self.startDate compare:[NSDate date]]==NSOrderedAscending) {
        if (self.tipAlert==nil) {
            self.tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_check_date"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        }
        [self.tipAlert show];
        return;
    }
    


//    NSString *temp = [NSString stringWithFormat:@"00000000%@",_conn.userId];
//    temp = [temp substringFromIndex:([temp length] - 8)];
    NSString *nowTime =[_conn getSCurrentTime];
//    NSString *helperid = [NSString stringWithFormat:@"%@%@%d",nowTime,temp,helper_recyle];
//    helper_recyle++;
//    if(helper_recyle == 10) helper_recyle = 0;
    
    NSString *startstr=[NSString stringWithFormat:@"%0.0f",[self.startDate timeIntervalSince1970]];
    NSString *endstr=[NSString stringWithFormat:@"%0.0f",[self.endDate timeIntervalSince1970]];
    NSLog(@"---startstr -- %@  -endstr-%@",startstr,endstr);
    helperObject *hobject=[[helperObject alloc]init];
    hobject.helper_name=self.titleField.text;
    hobject.helper_detail=self.detailField.text;
    hobject.empArray=self.dataArray;
    hobject.ring_type=self.getRingtype;
    hobject.ring_str=self.getRingStr;
    hobject.create_time=nowTime;
    hobject.start_time=startstr;
    hobject.end_time=endstr;
    hobject.create_emp_id=_conn.userId.intValue;
    hobject.helper_id=self.helper_id;
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [fmt stringFromDate:self.startDate];
    hobject.start_date=startdate;
    
    int state= [[ScheduleConn getScheduleConn] modifyHelperSchedule:hobject];
    if (state==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_modify_success"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"schedule_modify_fail"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    
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
    //    UIView *lastview=[preview superview];
    //    UIButton *ringbutton=(UIButton *)[lastview viewWithTag:5];
    //    UILabel *headerlabel=( UILabel *)[ringbutton viewWithTag:52];
    //    headerlabel.text=contextlabel.text;
    //    headerlabel.hidden=NO;
    
    NSString *typestr=[ringdic objectForKey:contextlabel.text];
    self.getRingtype=typestr.intValue;
    self.getRingStr=contextlabel.text;
    self.ringLabel.text=contextlabel.text;
    NSLog(@"--contextlabel.text-- %@  type %d",contextlabel.text, self.getRingtype);
}
-(void)chooseDateNotice:(NSNotification *)notification
{
    NSDate *date=(NSDate *)notification.object;
    NSLog(@"----chooseDateNotice--  %@",date);
    if (showdate==2) {//start
        self.startDate=date;
        if ([self.startDate compare:self.endDate]!=NSOrderedAscending) {
            self.endDate=[self.startDate dateByAddingTimeInterval:2*60*60];
        }
    }else if(showdate==3)
    {
        self.endDate=date;
        if ([self.startDate compare:self.endDate]==NSOrderedDescending) {
            self.endDate=self.startDate;
        }
    }
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"chooseDateNotice" object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.detailField.text.length == 0) {
        self.placeholderlabel.text =[StringUtil getLocalizableString:@"schedule_detail"];
    }else{
        self.placeholderlabel.text = @"";
        [self.tableView reloadData];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(chooseDateNotice:) name:@"chooseDateNotice" object:nil];
    
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger strLength = textField.text.length - range.length + string.length;
    return (strLength <= 20);
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger strLength = textView.text.length - range.length + text.length;
    return (strLength <= 100);
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
         self.placeholderlabel.text =[StringUtil getLocalizableString:@"schedule_detail"];
    }else{
        self.placeholderlabel.text = @"";
    }
}
-(void)externDoAction:(id)sender
{
    
    if (self.expandButton.tag==0) {
        self.expandButton.tag=1;
        [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_1.png"] forState:UIControlStateNormal];
    }else{
        self.expandButton.tag=0;
        [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_2.png"] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
     [super viewDidLoad];
    self.title=[StringUtil getLocalizableString:@"schedule_edit"];
    
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
    self.getRingtype=0;
    self.getRingStr=[StringUtil getLocalizableString:@"schedule_no_remind"];
    
    
    _conn = [conn getConn];
    eCloudDAO* db=[eCloudDAO getDatabase];
    nowUser=[db getEmployeeById:_conn.userId];
    
    self.dataArray=[db getEmpByhelperid:self.helper_id];
    helperObject *hobject=[db getTheDateScheduleByID:self.helper_id];
    self.getRingtype=hobject.ring_type;
    self.getRingStr=hobject.ring_str;
    
    self.startDate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
    self.endDate=[NSDate dateWithTimeIntervalSince1970:[hobject.end_time intValue]];
    
    isFresh = false;
    showdate=-1;
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    UIButton*rightButton = [[UIButton  alloc]initWithFrame:CGRectMake(0,0,50,30)];
    [rightButton addTarget:self action:@selector(saveAction:)forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"√" forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    rightButton.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    [rightItem release];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    if (IOS7_OR_LATER) {
        self.tableView.frame=CGRectMake(0.0f,0, self.view.bounds.size.width, self.view.frame.size.height);
    }
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView .dataSource=self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    self.titleField=[[UITextField alloc]initWithFrame:CGRectMake(5, 0, 313, 45)];
    self.titleField.placeholder=[StringUtil getLocalizableString:@"schedule_title"];
    self.titleField.delegate=self;
    self.titleField.text=hobject.helper_name;
    self.titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.titleField.font=[UIFont boldSystemFontOfSize:14];
    //    self.titleField.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    //    self.titleField.layer.borderWidth= 0.5f;
    self.titleField.backgroundColor=[UIColor whiteColor];
    
    UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 40, 313, 1)];
    lineimage.image=[StringUtil getImageByResName:@"line_s.png"];
    [self.titleField  addSubview:lineimage];
    [lineimage release];
    
    self.detailView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    
    
    self.detailField=[[UITextView alloc]initWithFrame:CGRectMake(0, 0, 320, 55)];
    //self.detailField.placeholder=@"请输入...";
    self.detailField.delegate=self;
    self.detailField.userInteractionEnabled=NO;
    self.detailField.textColor=[UIColor grayColor];
    self.detailField.font=[UIFont systemFontOfSize:14];
    self.detailField.backgroundColor=[UIColor whiteColor];
    self.detailField.text=hobject.helper_detail;
	// Do any additional setup after loading the view.
    
    self.placeholderlabel=[[UILabel alloc]initWithFrame:CGRectMake(7,10,100, 20)];
    self.placeholderlabel.text = [StringUtil getLocalizableString:@"schedule_detail"];
    self.placeholderlabel.font=[UIFont systemFontOfSize:14];
    self.placeholderlabel.textColor=[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1].CGColor;
    self.placeholderlabel.enabled = NO;//lable必须设置为不可用
    self.placeholderlabel.backgroundColor = [UIColor clearColor];
    [self.detailField addSubview:self.placeholderlabel];
    self.detailLineImage=[[UIImageView alloc]initWithFrame:CGRectMake(5, 65, 313, 1)];
    self.detailLineImage.image=[StringUtil getImageByResName:@"line_s.png"];
    [self.detailView  addSubview:self.detailLineImage];
    [self.detailView  addSubview:self.detailField];
    
    self.expandButton= [[UIButton  alloc]initWithFrame:CGRectMake(280,0,40,30)];
    self.expandButton.tag=0;
    [self.expandButton addTarget:self action:@selector(externDoAction:)forControlEvents:UIControlEventTouchUpInside];
    [self.expandButton setImage:[StringUtil getImageByResName:@"arrow_2.png"] forState:UIControlStateNormal];
    [self.detailView  addSubview:self.expandButton];
    
    self.ringLabel=[[UILabel alloc]initWithFrame:CGRectMake(210, 10, 100, 30)];
    self.ringLabel.textColor=[UIColor grayColor];
    self.ringLabel.font=[UIFont systemFontOfSize:14];
    self.ringLabel.textAlignment=NSTextAlignmentRight;
    self.ringLabel.text=hobject.ring_str;
    self.ringLabel.backgroundColor=[UIColor clearColor];
    
    
    
    self.selectLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 47, 320, 60)];
    self.selectLabel.tag=6;
    self.selectLabel.layer.borderColor=[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1].CGColor;
    self.selectLabel.layer.borderWidth=0.5;
    //self.selectLabel.hidden=YES;
    
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
    
    datepicker=[[MWViewController alloc]init];
    datepicker.selectedDate=self.startDate;
    datepicker.view.frame=CGRectMake(0, 47, 320, 120);
    
    
    //	显示群组成员头像的视图
    self.memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, 320, 80)];
    self.memberScroll.backgroundColor=[UIColor whiteColor];
    
    //  self.memberScroll.layer.cornerRadius = 10;//设置那个圆角的有多圆
    // memberScroll.layer.borderWidth = 10;//设置边框的宽度，当然可以不要
    //  self.memberScroll.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
    //  self.memberScroll.layer.masksToBounds = YES;//设为NO去试试
	NSLog(@"--memberScroll--here--showMemberScrollow");
    //	[NSThread detachNewThreadSelector:@selector(showMemberScrollow) toTarget:self withObject:nil];
    [self showMemberScrollow];
    [self performSelector:@selector(updateTableContent) withObject:nil afterDelay:0.2];
}
-(void)updateTableContent
{
    [self.tableView reloadData];
}
-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [self.memberScroll subviews])
    {
        [eachView removeFromSuperview];
        //[eachView release];
    }
    
}
-(void)displayTabBar
{
    /*
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
     */
    [UIAdapterUtil showTabar:self];
	self.navigationController.navigationBarHidden = NO;
}
-(void)hideTabBar
{
	/*
	//	add by shisp 2013.6.16
	//	如果tabbar是显示的状态那么
	if(self.tabBarController && 	!self.tabBarController.tabBar.hidden)
	{
		//		contentView frame在原来的基础上加上tabbar高度
		UITabBar *_tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
		
		UIView *contentView = [self.tabBarController.view.subviews objectAtIndex:0];
		
		CGRect _frame = contentView.frame;
		_frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
		
		contentView.frame = _frame;
		
		//NSLog(@"height is %.0f",contentView.frame.size.height);
		
		//		隐藏UITabBar
		self.tabBarController.tabBar.hidden = YES;
		
	}
     */
    [UIAdapterUtil hideTabBar:self];
}

-(void)iconbuttonAction:(id)sender
{
    
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    
    NSLog(@"----index-- %d",index);
    if (index==-1) {
        showdate=-1;
        datepicker.view.hidden=YES;
        [self.tableView reloadData];
		if(self.specialchooseMember == nil)
		{
			self.specialchooseMember = [[specialChooseMemberViewController alloc]init];
			self.specialchooseMember.typeTag=2;
			self.specialchooseMember.delegete=self;
		}
        [self hideTabBar];
		[self.navigationController pushViewController:self.specialchooseMember animated:YES];
    }
    else if(index==-2)
    {
        NSLog(@"start delete group member .....");
        self.start_Delete=YES;
        [self showMemberScrollow];
    }
    else
    {
        //        Emp *emp=[self.dataArray objectAtIndex:index];
        //
        //        emp=[db getEmpInfo:[StringUtil getStringValue:emp.emp_id]];
        //
        //        if(emp.emp_id == [_conn.userId intValue])
        //        {
        //            //		打开用户自己的资料
        //            userInfoViewController *userInfo = [[userInfoViewController alloc]init];
        //            userInfo.tagType=1;
        //            userInfo.emp=emp;
        //            userInfo.titleStr=emp.emp_name;
        //			[self.navigationController pushViewController:userInfo animated:YES];
        //            [userInfo release];
        //            return;
        //        }
        //        personInfo.titleStr=emp.emp_name;
        //        personInfo.sexType=emp.emp_sex;
        //        personInfo.emp=emp;
        //
        //        if(emp.info_flag)
        //        {
        //			[self.navigationController pushViewController:personInfo animated:YES];
        //        }
        //        else
        //        {
        //            NSLog(@"需要从服务器端取数据");
        //            [[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
        //            [[LCLLoadingView currentIndicator]showSpinner];
        //            [[LCLLoadingView currentIndicator]show];
        //            bool ret = [_conn getUserInfo:emp.emp_id];
        //            if(!ret)
        //            {
        //                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        //				[self.navigationController pushViewController:personInfo animated:YES];
        //            }
        //        }
    }
}

-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    int showiconNum=4;
    
	int sumnum=[self.dataArray count]+1;
    BOOL is_owner=NO;
    if (sumnum>1) {
        sumnum=[self.dataArray count]+2;
        is_owner=YES;
        NSLog(@"----HERE---create_emp_id");
    }
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
    [pageview addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
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
		if (is_owner) {//群组创建人
            if (nowindex==sumnum-2) {
                
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
                
                row=j/4;
                
                iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
                iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
                //  iconbutton.layer.borderWidth = 3;//设置边框的宽度，当然可以不要
                //   iconbutton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
                iconbutton.layer.masksToBounds = YES;//设为NO去试试
                
                UIImage *image=[StringUtil getImageByResName:@"addmember.png"];
                [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
                iconbutton.tag=-1;
                
                iconbutton.backgroundColor=[UIColor clearColor];
                [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
                // backView.image=[StringUtil getImageByResName:@"setting.png"];
                //[pageview addSubview:backView];
                [itemview addSubview:iconbutton];
                [pageview addSubview:itemview];
                [iconbutton release];
                [itemview release];
                
                if (self.start_Delete) {
                    break;
                }
                continue;
            }
            
            if (nowindex==sumnum-1) {
                
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
                
                row=j/4;
                
                iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
                iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
                //  iconbutton.layer.borderWidth = 3;//设置边框的宽度，当然可以不要
                //   iconbutton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
                iconbutton.layer.masksToBounds = YES;//设为NO去试试
                
                UIImage *image=[StringUtil getImageByResName:@"deleteGroupMember.png"];
                [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
                iconbutton.tag=-2;
                
                iconbutton.backgroundColor=[UIColor clearColor];
                [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
                // backView.image=[StringUtil getImageByResName:@"setting.png"];
                //[pageview addSubview:backView];
                [itemview addSubview:iconbutton];
                [pageview addSubview:itemview];
                [iconbutton release];
                [itemview release];
                
                break;
            }
            
            
        }else{//其他情况
            if (nowindex==sumnum-1) {
                
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
                
                row=j/4;
                
                iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
                iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
                //  iconbutton.layer.borderWidth = 3;//设置边框的宽度，当然可以不要
                //   iconbutton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
                iconbutton.layer.masksToBounds = YES;//设为NO去试试
                
                UIImage *image=[StringUtil getImageByResName:@"addmember.png"];
                [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
                iconbutton.tag=-1;
                
                iconbutton.backgroundColor=[UIColor clearColor];
                [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
                // backView.image=[StringUtil getImageByResName:@"setting.png"];
                //[pageview addSubview:backView];
                [itemview addSubview:iconbutton];
                [pageview addSubview:itemview];
                [iconbutton release];
                [itemview release];
                
                break;
            }
        }
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
	self.memberScroll.frame=CGRectMake(0, 40, 320, y+cy+115);
    //    if (self.talkType==singleType) {
    //        titleLabel.text=@"聊天信息";
    //    }else
    //    {
    //        titleLabel.text=[NSString stringWithFormat:@"聊天信息(%d)",[self.dataArray count]];
    //    }
    
	[pageview release];
    [self.tableView reloadData];
    // actionTable.tableHeaderView=memberScroll;
    //    if (sumnum>8) {
    //        CGPoint bottomOffset = CGPointMake(0, memberScroll.contentSize.height - memberScroll.bounds.size.height);
    //        [memberScroll setContentOffset:bottomOffset animated:YES];
    //    }
    
}
-(void)onClickForDeleteStatus{
    //点击操作内容
    if ( self.start_Delete) {
        self.start_Delete=NO;
        [self showMemberScrollow];
    }
    
}
-(void)deleteGroupMemberAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    NSMutableArray *temparray=[[NSMutableArray alloc]initWithArray:self.dataArray];
    [temparray removeObjectAtIndex:index];
    self.dataArray=temparray;
    [self showMemberScrollow];
    NSLog(@"-------------deleteGroupMemberAction");
}
//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 45;
    }else if(indexPath.row==1) {
        NSLog(@"-detailField--heigh-- %f",self.detailField.contentSize.height);
        self.expandButton.hidden=YES;
        if(self.detailField.contentSize.height>70)
        {
            float cellheight=self.detailField.contentSize.height;
            if (self.detailField.contentSize.height>=160) {
                self.expandButton.hidden=NO;
                if (self.expandButton.tag==0) {
                    cellheight=155;
                }
                
            }
            self.detailField.frame=CGRectMake(0, 0, 320, cellheight);
            self.detailLineImage.frame=CGRectMake(5, cellheight+1, 313, 1);
            self.detailView.frame=CGRectMake(0, 0, 320, cellheight+5);
            self.expandButton.frame=CGRectMake(280, cellheight-30, 40, 30);
            return cellheight;
        }else
        {
            self.detailField.frame=CGRectMake(0, 0, 320, 60);
            self.detailLineImage.frame=CGRectMake(5, 69, 313, 1);
            self.detailView.frame=CGRectMake(0, 0, 320, 70);
        }
        
        return 70;
    }
    else if(indexPath.row==2||indexPath.row==3) {
        if (showdate==indexPath.row) {
            return 170;
        }
        return 48;
    }
    else if(indexPath.row==4) {
        return 110;
    }
    else {
        return self.memberScroll.frame.size.height+30;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.titleField resignFirstResponder];
    [self.detailField resignFirstResponder];
    NSLog(@"------indexPath-   %d",indexPath.row);
    if (indexPath.row==1) {
        if (showdate!=-1) {
            showdate=-1;
            datepicker.view.hidden=YES;
            [self.tableView reloadData];
            return;
        }
        if (textInput==nil) {
            textInput=[[textInputViewController alloc]init];
            textInput.predelegete=self;
            
        }
        
        [self.navigationController pushViewController:textInput animated:YES];
        textInput.detailField.text=self.detailField.text;
        
    }
    if (indexPath.row==2||indexPath.row==3) {
        
        if (showdate==indexPath.row) {
            showdate=-1;
            datepicker.view.hidden=YES;
        }else
        {
            showdate=indexPath.row;
            datepicker.view.hidden=NO;
        }
        [self.tableView reloadData];
    }
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        //        UITextField *inputField=[[UITextField alloc]initWithFrame:CGRectMake(10+50, 10, 280-50, 40)];
        //        inputField.backgroundColor=[UIColor clearColor];
        //        inputField.tag=1;
        //        inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //        [cell.contentView addSubview:inputField];
        //        [inputField release];
        
        UIImageView *iconimage=[[UIImageView alloc]initWithFrame:CGRectMake(5, 17, 15, 15)];
        iconimage.tag=3;
        [cell.contentView addSubview:iconimage];
        [iconimage release];
        
        UILabel *titlegraylabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 285, 30)];
        titlegraylabel.tag=1;
        titlegraylabel.textAlignment=NSTextAlignmentLeft;
        titlegraylabel.font=[UIFont systemFontOfSize:14];
        [cell.contentView addSubview:titlegraylabel];
        [titlegraylabel release];
        
        
        UILabel *detaillabel=[[UILabel alloc]initWithFrame:CGRectMake(160, 10, 150, 30)];
        detaillabel.tag=2;
        detaillabel.backgroundColor=[UIColor clearColor];
        detaillabel.textAlignment=NSTextAlignmentRight;
        [cell.contentView addSubview:detaillabel];
        detaillabel.font=[UIFont systemFontOfSize:14];
        [detaillabel release];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    //    cell.textLabel.text=@"test";
    UILabel *titlegraylabel=(UILabel *)[cell viewWithTag:1];
    UILabel *detaillabel=(UILabel *)[cell viewWithTag:2];
    UIImageView *iconimage=(UIImageView*)[cell viewWithTag:3];
    if (indexPath.row==0) {
        titlegraylabel.text=@" 日程标题";
        titlegraylabel.hidden=YES;
        detaillabel.text=@"20字";
        detaillabel.hidden=YES;
        detaillabel.textColor=[UIColor grayColor];
        [cell.contentView addSubview:self.titleField];
    }else if(indexPath.row==1) {
        titlegraylabel.text=@" 日程描述";
        detaillabel.text=@"140字";
        detaillabel.textColor=[UIColor grayColor];
        [cell.contentView addSubview:self.detailView];
    }
    else if(indexPath.row==2) {
           titlegraylabel.text=[NSString stringWithFormat:@" %@",[StringUtil getLocalizableString:@"schedule_start"]];
        iconimage.image=[StringUtil getImageByResName:@"start.png"];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
        if ([from isEqualToString:@"From"]) {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            fmt.dateFormat = @"dd/MM/yyyy HH:mm";
        }else
        {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"yyyy年MM月dd日 HH:mm";
        }
        NSString* dateString = [fmt stringFromDate:self.startDate];
        NSLog(@"%@ ---selectorForSwipeRightGR", dateString);
        detaillabel.text=dateString;
        detaillabel.textColor=[UIColor blackColor];
        
        UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(5, 47, 313, 1)];
        lineimage.image=[StringUtil getImageByResName:@"line_s.png"];
        [cell.contentView  addSubview:lineimage];
        [lineimage release];
        
        if (showdate==indexPath.row) {
            [cell.contentView addSubview:datepicker.view];
        }
        
    }
    else if(indexPath.row==3) {
        titlegraylabel.text=[NSString stringWithFormat:@" %@",[StringUtil getLocalizableString:@"schedule_end"]];
        
        iconimage.image=[StringUtil getImageByResName:@"stop.png"];
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
        if ([from isEqualToString:@"From"]) {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            fmt.dateFormat = @"dd/MM/yyyy HH:mm";
        }else
        {
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"yyyy年MM月dd日 HH:mm";
        }
        NSString* dateString = [fmt stringFromDate:self.endDate];
        NSLog(@"%@ ---selectorForSwipeRightGR", dateString);
        detaillabel.text=dateString;
        detaillabel.textColor=[UIColor blackColor];
        
        UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(5, 47, 313, 1)];
        lineimage.image=[StringUtil getImageByResName:@"line_s.png"];
        [cell.contentView  addSubview:lineimage];
        [lineimage release];
        
        if (showdate==indexPath.row) {
            [cell.contentView addSubview:datepicker.view];
        }
    }
    else if(indexPath.row==4) {
     
        titlegraylabel.text=[NSString stringWithFormat:@" %@",[StringUtil getLocalizableString:@"schedule_remind"]];
        
        iconimage.image=[StringUtil getImageByResName:@"clock.png"];
        [cell.contentView addSubview:self.selectLabel];
        [cell.contentView addSubview:self.ringLabel];
    }
    else if(indexPath.row==5) {
        titlegraylabel.text=[NSString stringWithFormat:@" %@",[StringUtil getLocalizableString:@"schedule_participants"]];
        
        iconimage.image=[StringUtil getImageByResName:@"user.png"];
        [cell.contentView addSubview:self.memberScroll];
        
        UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(5, 40, 313, 1)];
        lineimage.image=[StringUtil getImageByResName:@"line_s.png"];
        [cell.contentView  addSubview:lineimage];
        [lineimage release];
    }
    
    return cell;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
