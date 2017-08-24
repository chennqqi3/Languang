//
//  MonthHelperViewController.m
//  eCloud
//
//  Created by  lyong on 13-11-14.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "MonthHelperViewController.h"
#import "Emp.h"
#import "JBCalendarLogic.h"

#import "JBUnitView.h"
#import "JBUnitGridView.h"

#import "JBSXRCUnitTileView.h"
#import "eCloudDAO.h"
#import "helperObject.h"
#import "DetailScheduleViewController.h"
#import "conn.h"
#import "talkSessionViewController.h"
#import "addScheduleViewController.h"

@interface MonthHelperViewController () <JBUnitGridViewDelegate, JBUnitGridViewDataSource, JBUnitViewDelegate, JBUnitViewDataSource>

@property (nonatomic, retain) JBUnitView *unitView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UILabel *yearMonthLabel;
@property (nonatomic, retain) UIView *showView;
@property (nonatomic, retain) NSString *nowhelper_id;
@property (nonatomic, retain) talkSessionViewController *talkSession;
@property (nonatomic, retain) UIButton *monthbutton;
@property (nonatomic, retain) UIButton *todaybutton;
@property (nonatomic, retain) NSDate *now_date;
// 增加日期视图的数组
@property (nonatomic, retain) NSMutableArray *weekViewArrays;
- (void)selectorForButton;

@end

@implementation MonthHelperViewController
@synthesize dataArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

-(void)updateYearMonth:(NSNotification *)notification
{
    NSDate *date=notification.object;
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        fmt.dateFormat = @"dd/MM/yyyy EEEE";
    }else
    {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
    }
    NSString* dateString = [fmt stringFromDate:date];
    NSLog(@"%@ ---selectorForSwipeRightGR", dateString);
    self.yearMonthLabel.text=dateString;
    
    [fmt release];
}
-(void)dayDoAction:(NSNotification *)notification
{
    
    NSLog(@"----dayDoAction");
    NSDate *date=(NSDate *)notification.object;
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        fmt.dateFormat = @"dd/MM/yyyy EEEE";
    }else
    {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
    }
    NSString* dateString = [fmt stringFromDate:date];
    NSLog(@"%@ ---selectorForSwipeRightGR", dateString);
    
    [fmt release];
    NSDateFormatter* newfmt = [[NSDateFormatter alloc] init];
    newfmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    newfmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [newfmt stringFromDate:date];
     [newfmt release];
    if (self.todaybutton.tag==0) {
        self.yearMonthLabel.text=dateString;
        
    }
    eCloudDAO*   db = [eCloudDAO getDatabase];
    BOOL ishas=[db isTheDateHasSchedule:startdate];
    if (ishas) {
        if (self.todaybutton.tag==1) {
            self.todaybutton.tag=0;
            [db setNewestBeUnread];
            self.yearMonthLabel.text=dateString;
          
        }
        self.dataArray=[db getTheDateAndFollowingSchedule:startdate];
        [self.tableView reloadData];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A1.png"] forState:UIControlStateNormal];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateSelected];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateHighlighted];
        self.monthbutton.tag=1;
        self.showView.hidden=YES;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.weekViewArrays = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateYearMonth:) name:@"YearMonthNotice" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dayDoAction:) name:@"DayActionNotice" object:nil];
    if (self.unitView!=nil) {
        [self.unitView reloadEvents];
        
        eCloudDAO*   db = [eCloudDAO getDatabase];
        self.dataArray=[db getNewestGetSchedule];
        if ([self.dataArray count]==0) {//没有最新收到
            self.todaybutton.tag=0;
            NSDateFormatter* newfmt = [[NSDateFormatter alloc] init];
            newfmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            NSDate*destDate;
            if(![self.yearMonthLabel.text isEqualToString:@"新日程"]||![self.yearMonthLabel.text isEqualToString:@"New Schedule"]){
                NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
                NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
                if ([from isEqualToString:@"From"]) {
                    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    dateFormatter.dateFormat = @"dd/MM/yyyy";
                    NSString *tempdatestr=[self.yearMonthLabel.text substringToIndex:10];
                    destDate= [dateFormatter dateFromString:tempdatestr];
                }else
                {
                    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                    dateFormatter.dateFormat = @"yyyy年MM月dd日";
                    NSString *tempdatestr=[self.yearMonthLabel.text substringToIndex:11];
                    
                    destDate= [dateFormatter dateFromString:tempdatestr];
                }
               
                
                [dateFormatter release];
            }else
            {
                destDate=[NSDate date];
               
                NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
               
                NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
                if ([from isEqualToString:@"From"]) {
                    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                    fmt.dateFormat = @"dd/MM/yyyy EEEE";
                }else
                {
                    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                    fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
                }
                NSString* dateString = [fmt stringFromDate:destDate];
                NSLog(@"%@", dateString);
                self.yearMonthLabel.text=dateString;
                [fmt release];
            }
            
            newfmt.dateFormat = @"yyyyMMdd";
            NSString *startdate= [newfmt stringFromDate:destDate];
            self.dataArray=[db getTheDateAndFollowingSchedule:startdate];
           
            [newfmt release];
        }else
        {
            self.yearMonthLabel.text=@"新日程";
            self.todaybutton.tag=1;
        }
         [self.tableView reloadData];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"YearMonthNotice" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DayActionNotice" object:nil];
    // 释放掉创建的星期label
    if (self.weekViewArrays != nil && self.weekViewArrays.count > 0) {
        for (UIView *weekView in self.weekViewArrays) {
            [weekView removeFromSuperview];
            weekView = nil;
        }
        // 将星期视图数组释放
        self.weekViewArrays = nil;
    }
}
//-(void)dealloc
//{
//    [super dealloc];
//}
-(void)addAction:(id)sender
{
    NSLog(@"-----addAction");
    addScheduleViewController *addSchedule=[[addScheduleViewController alloc]init];
    addSchedule.title=[StringUtil getLocalizableString:@"schedule_new_schedule"];
    NSDate*destDate;
    if(![self.yearMonthLabel.text isEqualToString:@"新日程"]||![self.yearMonthLabel.text isEqualToString:@"New Schedule"]){
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
        if ([from isEqualToString:@"From"]) {
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.dateFormat = @"dd/MM/yyyy";
            NSString *tempdatestr=[self.yearMonthLabel.text substringToIndex:10];
            destDate= [dateFormatter dateFromString:tempdatestr];
        }else
        {
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            dateFormatter.dateFormat = @"yyyy年MM月dd日";
            NSString *tempdatestr=[self.yearMonthLabel.text substringToIndex:11];
            
            destDate= [dateFormatter dateFromString:tempdatestr];
        }

    [dateFormatter release];
        
    }else
    {
        destDate=[NSDate date];
    }
    addSchedule.startDate=destDate;
    addSchedule.endDate=[destDate dateByAddingTimeInterval:2*60*60];
    //addSchedule.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addSchedule animated:YES];
    [addSchedule release];
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIAdapterUtil processController:self];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setUserInteractionEnabled:YES];
    self.now_date=[NSDate date];
    if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    // 隐藏添加按钮
//    UIButton*rightButton = [[UIButton  alloc]initWithFrame:CGRectMake(0,0,50,30)];
//    [rightButton addTarget:self action:@selector(addAction:)forControlEvents:UIControlEventTouchUpInside];
//    [rightButton setTitle:@"＋" forState:UIControlStateNormal];
//    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
//    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
//    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
//    rightButton.titleLabel.font=[UIFont boldSystemFontOfSize:28];
//    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem= rightItem;
   
    UIImageView *headerBackgroup=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 60)];
    headerBackgroup.image=[StringUtil getImageByResName:@"title_bj.png"];
    [self.view addSubview:headerBackgroup];
    [headerBackgroup release];
    //  Example 1.1:

    
    self.yearMonthLabel=[[UILabel alloc]initWithFrame: CGRectMake(15, 10.0f, SCREEN_WIDTH-30, 40.0f)];
    self.yearMonthLabel.font=[UIFont systemFontOfSize:18];
    self.yearMonthLabel.textAlignment = NSTextAlignmentCenter;
    self.yearMonthLabel.backgroundColor=[UIColor clearColor];
    NSDate* now = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        fmt.dateFormat = @"dd/MM/yyyy EEEE";
    }else
    {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
    }
    NSString* dateString = [fmt stringFromDate:now];
    NSLog(@"%@", dateString);
    self.yearMonthLabel.text=dateString;
    self.yearMonthLabel.textColor=[UIColor redColor];
    [self.view addSubview:self.yearMonthLabel];
   
    
    self.todaybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.todaybutton.frame = CGRectMake(0, 0, SCREEN_WIDTH-50, 40);
    [self.todaybutton addTarget:self action:@selector(selectorForButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.todaybutton];
    //self.todaybutton.hidden=YES;
    
    self.monthbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.monthbutton.frame = CGRectMake(SCREEN_WIDTH-50, 10.0f, 34, 36);
    self.monthbutton.tag=0;
    
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A1.png"] forState:UIControlStateNormal];
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateSelected];
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateHighlighted];
//    [self.monthbutton addTarget:self action:@selector(doHiddenMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.monthbutton];
   
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,58, SCREEN_WIDTH, self.view.frame.size.height-60-20-20) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView .dataSource=self;
   // self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor=[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
    self.unitView = [[JBUnitView alloc] initWithFrame:self.view.bounds UnitType:UnitTypeMonth SelectedDate:[NSDate date] AlignmentRule:JBAlignmentRuleTop Delegate:self DataSource:self];
 
    self.showView=[[UIView alloc]initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, self.view.bounds.size.height-55)];
    [self.showView addSubview:self.unitView];
    [self.view addSubview:self.showView];
    //self.showView.backgroundColor=[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    self.showView.backgroundColor=[UIColor whiteColor];
    self.showView.hidden=YES;
    
    eCloudDAO*   db = [eCloudDAO getDatabase];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [fmt stringFromDate:[NSDate date]];
    
    self.dataArray=[db getNewestGetSchedule];
    if ([self.dataArray count]==0) {//没有最新收到
        self.dataArray=[db getTheDateAndFollowingSchedule:startdate];
        self.todaybutton.tag=0;
        self.monthbutton.tag=1;
        self.monthbutton.enabled = NO;
        if ([self.dataArray count]==0) {
             self.showView.hidden=NO;
            [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B1.png"] forState:UIControlStateNormal];
//            [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B2.png"] forState:UIControlStateSelected];
//            [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B2.png"] forState:UIControlStateHighlighted];
        }
    }else
    {
     self.yearMonthLabel.text=@"新日程";
     self.todaybutton.tag=1;
    
    }
     [fmt release];
    //  Example 1.2:
    //    self.unitView = [[JBUnitView alloc] initWithFrame:self.view.bounds UnitType:UnitTypeWeek SelectedDate:[NSDate date] AlignmentRule:JBAlignmentRuleTop Delegate:self DataSource:self];
    //    [self.view addSubview:self.unitView];
    //
    //    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.unitView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.unitView.bounds.size.height) style:UITableViewStylePlain];
    //    [self.view addSubview:self.tableView];
    
    
    //  Example 2.1:
    //    JBUnitGridView *gridView = [[JBUnitGridView alloc] initWithFrame:self.view.bounds UnitType:UnitTypeMonth];
    //    gridView.delegate = self;
    //    gridView.dataSource = self;
    //    [self.view addSubview:gridView];
    //    [gridView setSelectedDate:[JBCalendarDate dateFromNSDate:[NSDate date]]];
    
    //  Example 2.2
    //    JBUnitGridView *gridView = [[JBUnitGridView alloc] initWithFrame:self.view.bounds UnitType:UnitTypeWeek];
    //    gridView.delegate = self;
    //    gridView.dataSource = self;
    //   // [self.view addSubview:gridView];
    //    [showView addSubview:gridView];
    //    [gridView setSelectedDate:[JBCalendarDate dateFromNSDate:[NSDate date]]];
}
-(void)doHiddenMonthAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if (button.tag==1) {
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B1.png"] forState:UIControlStateNormal];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B2.png"] forState:UIControlStateSelected];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_B2.png"] forState:UIControlStateHighlighted];
        button.tag=0;
        self.showView.hidden=NO;
    }else
    {
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A1.png"] forState:UIControlStateNormal];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateSelected];
        [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateHighlighted];
        button.tag=1;
        self.showView.hidden=YES;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Class Extensions
- (void)selectorForButton
{

    eCloudDAO*   db = [eCloudDAO getDatabase];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        fmt.dateFormat = @"dd/MM/yyyy EEEE";
    }else
    {
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
    }
    NSString* dateString = [fmt stringFromDate:[NSDate date]];
    NSLog(@"%@", dateString);
    self.yearMonthLabel.text=dateString;
   
    [self.unitView selectDate:[NSDate date]];
    [fmt release];
    
    NSDateFormatter* newfmt = [[NSDateFormatter alloc] init];
    newfmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    newfmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [newfmt stringFromDate:[NSDate date]];
    self.dataArray=[db getTheDateAndFollowingSchedule:startdate];
    [self.tableView reloadData];
    [newfmt release];
}
-(void)selecteddDateAction:(id)sender
{   UIButton *button=(UIButton *)sender;
    NSLog(@"--text--%@",button.titleLabel.text);
    NSString *datestr=button.titleLabel.text;
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    NSDate*destDate= [dateFormatter dateFromString:datestr];
    
    [self.unitView selectDate:destDate];
    
    dateFormatter.dateFormat = @"yyyy年MM月dd日 EEEE";
    NSString* dateString = [dateFormatter stringFromDate:destDate];
    self.yearMonthLabel.text=dateString;
    
    [dateFormatter release];
}
//------日程列表-------
//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    return [self.dataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     helperObject *hobject=[self.dataArray objectAtIndex:indexPath.row];
    if (hobject.show_week) {
         return 100;
    }else
    {
    return 80;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  
        UILabel *startlabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 25, 40, 20)];
        startlabel.backgroundColor=[UIColor clearColor];
        startlabel.tag=1;
        startlabel.textAlignment=NSTextAlignmentLeft;
        startlabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:startlabel];
        [startlabel release];
        
        
        UILabel *endlabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 75, 50, 20)];
        endlabel.backgroundColor=[UIColor clearColor];
        endlabel.font=[UIFont systemFontOfSize:10];
        endlabel.textAlignment=NSTextAlignmentLeft;
        endlabel.tag=2;
        endlabel.textColor=[UIColor grayColor];
        [cell.contentView addSubview:endlabel];
        [endlabel release];
        
        UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(45, 25, 230, 20)];
        titlelabel.tag=3;
        titlelabel.backgroundColor=[UIColor clearColor];
        titlelabel.textColor=[UIColor blackColor];
        titlelabel.font=[UIFont systemFontOfSize:14];
        [cell.contentView addSubview:titlelabel];
        [titlelabel release];
        
        UILabel *detaillabel=[[UILabel alloc]initWithFrame:CGRectMake(45, 45, 230, 30)];
        detaillabel.tag=4;
        detaillabel.backgroundColor=[UIColor clearColor];
        detaillabel.textColor=[UIColor grayColor];
        detaillabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:detaillabel];
        [detaillabel release];

        UIButton *ringButton=[[UIButton alloc]initWithFrame:CGRectMake(40, 75, 275, 30)];
        ringButton.userInteractionEnabled=NO;
        ringButton.tag=5;
        [cell.contentView addSubview:ringButton];
       
        UIImageView *isReadImage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 60,7, 7)];
       // isReadImage.image=[StringUtil getImageByResName:@"schedule_bluepoint.png"];
        isReadImage.tag=6;
        [cell.contentView addSubview:isReadImage];
        [isReadImage release];
        
        UILabel *weeklabel=[[UILabel alloc]initWithFrame:CGRectMake(-5, 0, 330, 20)];
       // weeklabel.backgroundColor=[UIColor colorWithRed:246/255.0 green:246/255.0 blue:244/255.0 alpha:1];
        weeklabel.backgroundColor=[UIColor whiteColor];
        weeklabel.font=[UIFont systemFontOfSize:14];
//        weeklabel.layer.borderColor=[UIColor lightGrayColor].CGColor;
//        weeklabel.layer.borderWidth=0.5;
        weeklabel.textAlignment=NSTextAlignmentCenter;
        weeklabel.tag=7;
        weeklabel.textColor=[UIColor grayColor];
        [cell.contentView addSubview:weeklabel];
        [weeklabel release];
        
        UIImageView *lineimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 20,320, 1)];
        lineimage.image=[StringUtil getImageByResName:@"line_s.png"];
        lineimage.tag=8;
        [cell.contentView addSubview:lineimage];
        [lineimage release];
        
        UIButton *groupButton=[[UIButton alloc]initWithFrame:CGRectMake(320-45, 40, 41, 41)];
        [groupButton setImage:[StringUtil getImageByResName:@"Group_ios.png"] forState:UIControlStateNormal];
        [groupButton addTarget:self action:@selector(talkAction:) forControlEvents:UIControlEventTouchUpInside];
        groupButton.tag=9;
        [cell.contentView addSubview:groupButton];
        [groupButton release];
        
        
        UILabel *headtiplabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 30)];
        headtiplabel.backgroundColor=[UIColor clearColor];
        headtiplabel.font=[UIFont systemFontOfSize:10];
        headtiplabel.textColor=[UIColor lightGrayColor];
        headtiplabel.tag=52;
        [ringButton addSubview:headtiplabel];
        [headtiplabel release];
        
        UILabel *tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(150, 0, 80, 30)];
        tiplabel.backgroundColor=[UIColor clearColor];
        tiplabel.font=[UIFont systemFontOfSize:10];
        tiplabel.textAlignment=NSTextAlignmentRight;
        tiplabel.textColor=[UIColor lightGrayColor];
        tiplabel.tag=51;
        [ringButton addSubview:tiplabel];
        [tiplabel release];
         [ringButton release];
        
    }
    helperObject *hobject=[self.dataArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    UILabel *startlabel=(UILabel *)[cell.contentView viewWithTag:1];
    
    NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    
    fmt.dateFormat = @"HH:mm";
    NSString *starthourmm= [fmt stringFromDate:tempdate];
    startlabel.text=starthourmm;
    
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    
    
    UILabel *weeklabel=(UILabel *)[cell.contentView viewWithTag:7];
   
    if ([from isEqualToString:@"From"]) {
     fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
      fmt.dateFormat = @"dd/MM/yyyy EEEE";   
    }else
    {
     fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
     fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
    }
    NSString *weekstr=[fmt stringFromDate:tempdate];
    UIImageView *lineimage=(UIImageView *)[cell.contentView viewWithTag:8];
    weeklabel.text=weekstr;

    UIImageView *isreadimage=(UIImageView *)[cell.contentView viewWithTag:6];
    if (hobject.is_read>0) {//未读
        isreadimage.image=[StringUtil getImageByResName:@"schedule_redpoint.png"];
    }else
    {   if(hobject.is_now)
        {
        isreadimage.image=[StringUtil getImageByResName:@"schedule_bluepoint.png"];
        }else
        {
        isreadimage.image=nil;
        }
    }
    fmt.dateFormat = @"HH:mm";
    UILabel *endlabel=(UILabel *)[cell.contentView viewWithTag:2];
    tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.end_time intValue]];
    NSString *endhourmm= [fmt stringFromDate:tempdate];
    endlabel.text=endhourmm;
    [fmt release];
    
    UILabel *titlelabel=(UILabel *)[cell.contentView viewWithTag:3];
    titlelabel.text=hobject.helper_name;
    
    UILabel *detaillabel=(UILabel *)[cell.contentView viewWithTag:4];
    detaillabel.text=hobject.helper_detail;
    
    UIButton *ringButton=(UIButton *)[cell.contentView viewWithTag:5];
    UILabel *headtiplabel=(UILabel *)[ringButton viewWithTag:52];
    headtiplabel.text=hobject.ring_str;
    
    UILabel *tiplabel=(UILabel *)[ringButton viewWithTag:51];
    tiplabel.text=[NSString stringWithFormat:@"%@ %@",[StringUtil getLocalizableString:@"schedule_from"],hobject.create_emp_name];
    
    UIButton *groupbutton=(UIButton *)[cell.contentView viewWithTag:9];
    groupbutton.tag=indexPath.row;
     groupbutton.hidden=YES;
    if (hobject.is_group) {
        groupbutton.hidden=NO;
    }
    if (hobject.show_week) {
        weeklabel.hidden=NO;
        lineimage.hidden=NO;
        
        startlabel.frame=CGRectMake(5, 25, 40, 20);
        endlabel.frame=CGRectMake(5, 75, 50, 20);
        titlelabel.frame=CGRectMake(45, 25, 230, 20);
        detaillabel.frame=CGRectMake(45, 45, 230, 30);
        ringButton.frame=CGRectMake(40, 70, 275, 30);
        isreadimage.frame=CGRectMake(10, 60,7, 7);
         groupbutton.frame=CGRectMake(275, 40, 41, 41);
       
    }else
    {
        weeklabel.hidden=YES;
        lineimage.hidden=YES;
        
        startlabel.frame=CGRectMake(5, 5, 40, 20);
        endlabel.frame=CGRectMake(5, 55, 50, 20);
        titlelabel.frame=CGRectMake(45, 5, 230, 20);
        detaillabel.frame=CGRectMake(45, 25, 230, 30);
        ringButton.frame=CGRectMake(40, 50, 275, 30);
        isreadimage.frame=CGRectMake(10, 40,7, 7);
         groupbutton.frame=CGRectMake(275,20, 41, 41);
       
    }
    return cell;
    
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
    UIView *lastview=[preview superview];
    UIButton *ringbutton=(UIButton *)[lastview viewWithTag:5];
    UILabel *headerlabel=( UILabel *)[ringbutton viewWithTag:52];
    headerlabel.text=contextlabel.text;
    headerlabel.hidden=NO;
    NSLog(@"--contextlabel.text-- %@",contextlabel.text);
}

-(void)fobitActon:(id)sender
{
    NSLog(@"---- fobitActon");
    
}

-(void)ringSetAction:(id)sender
{   NSString *str=((UIButton *)sender).titleLabel.text;
    NSLog(@"---- ringSetAction -- %@",str);
    if (ringIndex==str.intValue) {
        ringIndex=-1;
        UILabel *label=(UILabel *)[((UIButton *)sender) viewWithTag:51];
        label.hidden=YES;
    }else
    {
        ringIndex=str.intValue;
        UILabel *label=(UILabel *)[((UIButton *)sender) viewWithTag:51];
        label.hidden=NO;
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A1.png"] forState:UIControlStateNormal];
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateSelected];
    [self.monthbutton setImage:[StringUtil getImageByResName:@"icon_month_A2.png"] forState:UIControlStateHighlighted];
    self.monthbutton.tag=1;
    self.showView.hidden=YES;
    
    NSLog(@"--here indexPath --row  %d ",indexPath.row);
    helperObject *hobject=[self.dataArray objectAtIndex:indexPath.row];
    self.nowhelper_id=hobject.helper_id;
    
   
    DetailScheduleViewController *detailschedule=[[DetailScheduleViewController alloc]init];
    detailschedule.helper_id=self.nowhelper_id;
    detailschedule.title=@"日程明细";
    
    eCloudDAO*   db = [eCloudDAO getDatabase];
    [db setHadReadedByHelperID:self.nowhelper_id];
    [self.navigationController pushViewController:detailschedule animated:YES];

}
-(void)talkAction:(id)sender
{
    NSLog(@"---talkAction--here");
    UIButton *button=(UIButton *)sender;
    helperObject *hobject=[self.dataArray objectAtIndex:button.tag];
    self.nowhelper_id=hobject.helper_id;
  
    eCloudDAO*   db = [eCloudDAO getDatabase];
    NSString *groupid=[db getGroupIdByHelperID:self.nowhelper_id];
    
    NSDictionary *dic=[db searchConversationBy:groupid];
    helperObject *nowHelper=[db getTheDateScheduleByID:self.nowhelper_id];
    NSString *create_emp_id=[NSString stringWithFormat:@"%d",nowHelper.create_emp_id];
    NSArray *emps=[db getEmpByhelperid:self.nowhelper_id];
    
    
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
-(void)detailAction:(id)sender
{  
    DetailScheduleViewController *detailschedule=[[DetailScheduleViewController alloc]init];
    detailschedule.helper_id=self.nowhelper_id;
    detailschedule.title=@"日程明细";
    
     eCloudDAO*   db = [eCloudDAO getDatabase];
    [db setHadReadedByHelperID:self.nowhelper_id];
    [self.navigationController pushViewController:detailschedule animated:YES];
    NSLog(@"---detailAction--here");
    
}

#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {//顶部下拉
    //offset为0，表示已经没有历史记录，那么不处理;
//    	NSLog(@"%s,offset is %d",__FUNCTION__,scrollView.contentOffset.y);
//	if(offset == 0) {
//		return;
//	}
//    //	NSLog(@"%.0f",scrollView.contentOffset.y);
//	if (scrollView.contentOffset.y<0 && !isLoading ) {
//		isLoading = true;
//		loadingIndic.hidden = NO;
//		[loadingIndic startAnimating];
//		[self performSelector:@selector(getHistoryRecord) withObject:nil afterDelay:0.5];
//	}
}

-(void)hideLoadingCell
{
//	loadingIndic.hidden = YES;
//	[loadingIndic stopAnimating];
//	isLoading = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{//底部上拖
	//pageControl.currentPage=scrollView.contentOffset.x/320;
    
}

- (void)getHistoryRecord
{
//    //	总数量
//	totalCount = [_ecloud getConvRecordCountBy:self.convId];
//    //已经加载数量
//	loadCount = self.convRecordArray.count;
//	
//	if(totalCount > (loadCount + num_convrecord))
//	{
//		limit = num_convrecord;
//		offset = totalCount - (loadCount + num_convrecord);
//	}
//	else
//	{
//		limit =totalCount - loadCount;
//		offset = 0;
//	}
//    //	NSLog(@"%s,totalCount is %d,loadCount is %d",__FUNCTION__,totalCount,loadCount);
//    //	NSLog(@"get history record limit is %d,offset is %d",limit,offset);
//	
//	NSArray *recordList = [_ecloud getConvRecordBy:self.convId andLimit:limit andOffset:offset];
//	
//    
//	
//	int count=[recordList count];
//    
//	for (int i=count-1; i>=0; i--)
//	{
//        ConvRecord *record =[recordList objectAtIndex:i];
//		[self.convRecordArray insertObject:record atIndex:0];
//	}
//	for(int i = 0;i<recordList.count;i++)
//	{
//		ConvRecord *_convRecord = [recordList objectAtIndex:i];
//		[self setTimeDisplay:_convRecord andIndex:i];
//		[talkSessionUtil setPropertyOfConvRecord:_convRecord];
//	}
//	
//    float oldh=self.chatTableView.contentSize.height;
//	[self.chatTableView reloadData];
//	
//	[self hideLoadingCell];
//    float newh=self.chatTableView.contentSize.height;
//	self.chatTableView.contentOffset=CGPointMake(0, newh-oldh-20);
}

#pragma mark -
#pragma mark - JBUnitGridViewDelegate
/**************************************************************
 *@Description:获取当前UnitGridView中UnitTileView的高度
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:当前unitGridView中UnitTileView的高度
 **************************************************************/
- (CGFloat)heightOfUnitTileViewsInUnitGridView:(JBUnitGridView *)unitGridView
{
    return SCREEN_WIDTH/7;
}


/**************************************************************
 *@Description:获取当前UnitGridView中UnitTileView的宽度
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:当前UnitGridView中UnitTileView的宽度
 **************************************************************/
- (CGFloat)widthOfUnitTileViewsInUnitGridView:(JBUnitGridView *)unitGridView
{
    return SCREEN_WIDTH/7;//46.0f;
}


//  ------------选中了当前月份或周之外的时间--------------
/**************************************************************
 *@Description:选中了当前Unit的上一个Unit中的时间点
 *@Params:
 *  unitGridView:当前unitGridView
 *  date:选中的时间点
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedOnPreviousUnitWithDate:(JBCalendarDate *)date
{
    NSLog(@"----selectedOnPreviousUnitWithDate");
    
}

/**************************************************************
 *@Description:选中了当前Unit的下一个Unit中的时间点
 *@Params:
 *  unitGridView:当前unitGridView
 *  date:选中的时间点
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedOnNextUnitWithDate:(JBCalendarDate *)date
{
    NSLog(@"----selectedOnNextUnitWithDate");
}
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedDate:(JBCalendarDate *)date
{
    NSLog(@"----date--- %@",[date nsDate]);
    NSLog(@"----当前时间－－－－－");
}
#pragma mark -
#pragma mark - JBUnitGridViewDataSource
/**************************************************************
 *@Description:获得unitTileView
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:unitTileView
 **************************************************************/
- (JBUnitTileView *)unitTileViewInUnitGridView:(JBUnitGridView *)unitGridView
{
    return [[JBSXRCUnitTileView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH/7, SCREEN_WIDTH/7)];
}

/**************************************************************
 *@Description:设置unitGridView中的weekdaysBarView
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:weekdaysBarView
 **************************************************************/
- (UIView *)weekdaysBarViewInUnitGridView:(JBUnitGridView *)unitGridView
{
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[StringUtil getImageByResName:@"weekdaysBarView"]];
//    return imageView;
    UILabel *weeklabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 18)];
    weeklabel.font=[UIFont systemFontOfSize:12];
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        weeklabel.text=[NSString stringWithFormat:@"    Sun      Mon      Tues      Wed      Thur      Frid      Sat"];
        
    }else
    {
        weeklabel.text=[NSString stringWithFormat:@"       周日         周一         周二         周三      周四      周五      周六"];
        
    }
    return weeklabel;
}


/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件的数量
 *@Params:
 *  unitGridView:当前unitGridView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView NumberOfEventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSInteger eventCount))completedBlock
{
    completedBlock(calendarDate.day);
}

/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件
 *@Params:
 *  unitGridView:当前unitGridView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView EventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSArray *events))completedBlock
{
    completedBlock(nil);
}


#pragma mark -
#pragma mark - JBUnitViewDelegate
/**************************************************************
 *@Description:获取当前UnitView中UnitTileView的高度
 *@Params:
 *  unitView:当前unitView
 *@Return:当前UnitView中UnitTileView的高度
 **************************************************************/
- (CGFloat)heightOfUnitTileViewsInUnitView:(JBUnitView *)unitView
{
    return SCREEN_WIDTH/7;
}

/**************************************************************
 *@Description:获取当前UnitView中UnitTileView的宽度
 *@Params:
 *  unitView:当前unitView
 *@Return:当前UnitView中UnitTileView的宽度
 **************************************************************/
- (CGFloat)widthOfUnitTileViewsInUnitView:(JBUnitView *)unitView
{
    return SCREEN_WIDTH/7;// 46.0f;
}


/**************************************************************
 *@Description:更新unitView的frame
 *@Params:
 *  unitView:当前unitView
 *  newFrame:新的frame
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView UpdatingFrameTo:(CGRect)newFrame
{
    // self.tableView.frame = CGRectMake(0.0f, newFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - newFrame.size.height);
}

/**************************************************************
 *@Description:重新设置unitView的frame
 *@Params:
 *  unitView:当前unitView
 *  newFrame:新的frame
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView UpdatedFrameTo:(CGRect)newFrame
{
    //NSLog(@"OK");
}

#pragma mark -
#pragma mark - JBUnitViewDataSource
/**************************************************************
 *@Description:获得unitTileView
 *@Params:
 *  unitView:当前unitView
 *@Return:unitTileView
 **************************************************************/
- (JBUnitTileView *)unitTileViewInUnitView:(JBUnitView *)unitView
{
    return [[JBSXRCUnitTileView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH/7, SCREEN_WIDTH/7)];
}

/**************************************************************
 *@Description:设置unitView中的weekdayView
 *@Params:
 *  unitView:当前unitView
 *@Return:weekdayView
 **************************************************************/
- (UIView *)weekdaysBarViewInUnitView:(JBUnitView *)unitView
{
    
//    UILabel *weeklabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 18)];
//    weeklabel.font=[UIFont systemFontOfSize:12];
//    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
//    if ([from isEqualToString:@"From"]) {
//    weeklabel.text=[NSString stringWithFormat:@"    Sun      Mon      Tues      Wed      Thur      Frid      Sat"];
//  
//    }else
//    {
//    weeklabel.text=[NSString stringWithFormat:@"       周日         周一         周二         周三         周四      周五      周六"];
// 
//    }
//      return weeklabel;
    
    
    UIView *weekView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 18)];
    NSArray *weekArray = nil;
    NSString *from=[StringUtil getLocalizableString:@"schedule_from"];
    if ([from isEqualToString:@"From"]) {
        weekArray = @[@"Sun",@"Mon",@"Tues",@"Wed",@"Thur",@"Frid",@"Sat"];
    }else{
        weekArray = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    }
    for (int i = 0;i < weekArray.count;i++) {
        UILabel *weekLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/7)*i, 0, SCREEN_WIDTH/7, 18)];
        weekLabel.text = weekArray[i];
        weekLabel.font=[UIFont systemFontOfSize:12];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [weekView addSubview:weekLabel];
        [weekLabel release];
    }
    // 将星期视图加入到星期视图数组中
    [self.weekViewArrays addObject:weekView];
    
    return weekView;
}

/**************************************************************
 *@Description:选择某一天
 *@Params:
 *  unitView:当前unitView
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView SelectedDate:(NSDate *)date
{
    //NSLog(@"selected date:%@", date);
}

/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件的数量
 *@Params:
 *  unitView:当前unitView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView NumberOfEventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSInteger eventCount))completedBlock
{
    completedBlock(calendarDate.day);
}

/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件
 *@Params:
 *  unitView:当前unitView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView EventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSArray *events))completedBlock
{
    completedBlock(nil);
}

@end

