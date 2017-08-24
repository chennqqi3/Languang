//
//  aboutViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "aboutViewController.h"

#import "VerticallyAlignedLabel.h"

#import "ServerConfig.h"
#import "UserDefaults.h"

#import "openWebViewController.h"
#import "MessageView.h"
#import "UIAdapterUtil.h"
#import "eCloudDAO.h"
#import "GYFrame.h"
#define row_height (50.0)

#define LG_SECRETARY_ID @"13774"
@interface aboutViewController ()
{
    CGFloat screenW;
    UITableView *infoTable;
    
    UIImageView *logoView;
    float logoWidth;
    UILabel *versionLabel;
}

@end

@implementation aboutViewController
//update by shisp 不从xib文件中读取
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	_conn = [conn getConn];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
//	self.title = [NSString stringWithFormat:@"关于%@",[StringUtil getAppName]];
    self.title = [NSString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"settings_about"]];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    [self addTableView];
}
- (void)addTableView
{
    // add by toxicanty 0803 适配
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
    
    infoTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0 , screenW, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:infoTable];
    [infoTable setDelegate:self];
    [infoTable setDataSource:self];
    infoTable.backgroundView = nil;
    infoTable.backgroundColor=[UIColor clearColor];
    infoTable.scrollEnabled=YES;
    [self.view addSubview:infoTable];
    [infoTable release];

    //    header view
    UIView *parentView = [[UIView alloc]init];
    
    UIImage *logoImage  = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"logo_about" andType:@"png"]];
    logoWidth = 80;
    float logoHeight = 80;
    float logoX = (screenW - logoWidth)/2;
    float logoY = kGetCurrentValue(40);;
    
    logoView = [[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, logoWidth, logoHeight)];
//    logoView.backgroundColor = [UIColor redColor];
    logoView.image = logoImage;
    [parentView addSubview:logoView];
    [logoView release];
    
    float labelHeight = 18.5;
    CGRect labelRect = CGRectMake(0, 138, SCREEN_WIDTH, labelHeight);
    versionLabel = [[UILabel alloc]init];
    versionLabel.frame = [GYFrame myRect:labelRect];
    versionLabel.text = [NSString stringWithFormat:@"%@ Version %@",[StringUtil getAppName],[[eCloudUser getDatabase]getVersion:app_version_type]];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.font = [UIFont systemFontOfSize:15];
    versionLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1/1.0];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [parentView addSubview:versionLabel];
    [versionLabel release];
    
    CGRect parentRect = CGRectMake(0, 0, 375,270.5 - 58);
    parentView.frame = [GYFrame myRect:parentRect];
    
    infoTable.tableHeaderView = parentView;
    
    [parentView release];
    
//    VerticallyAlignedLabel *copyRightLabel=[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, 0, screenW, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - parentView.frame.size.height - 2 * row_height - 30)];
////    NSLog(@"%@,%@,%@",parentView,infoTable,copyRightLabel);
//    copyRightLabel.backgroundColor= [UIColor clearColor];
//    copyRightLabel.textAlignment=UITextAlignmentCenter;
//    copyRightLabel.contentMode = UIViewContentModeBottom;
//    copyRightLabel.numberOfLines=0;
//    copyRightLabel.textColor=[UIColor colorWithRed:82/255.0 green:142/255.0 blue:211/255.0 alpha:1];
//    copyRightLabel.text= [StringUtil getAppLocalizableString:@"about_ctx"];
//    copyRightLabel.verticalAlignment = VerticalAlignmentBottom;
//    infoTable.tableFooterView = copyRightLabel;
//    [copyRightLabel release];
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [UIAdapterUtil isLANGUANGApp]?3:2;
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [UIAdapterUtil isLANGUANGApp]?40:row_height;
    CGFloat height = kGetCurrentValue(51);
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 18;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        
        float tipX = [UIAdapterUtil isLANGUANGApp]?12:15;
        float tipY = 14.5;
        float tipW = (self.view.frame.size.width - 40) * 0.67;
        float tipH = 22;
        CGRect tipLabelRect = CGRectMake(tipX, tipY, tipW, tipH);
        UILabel *tipLabel=[[UILabel alloc]initWithFrame:[GYFrame myRect:tipLabelRect]];

        tipLabel.tag=1;
        tipLabel.textColor=UIColorFromRGB(0xA3A3A3);
        tipLabel.backgroundColor=[UIColor clearColor];
        tipLabel.contentMode = UIViewContentModeCenter;
        tipLabel.font = [UIFont systemFontOfSize:kGetCurrentValue(17)];
        [cell.contentView addSubview:tipLabel];
        [tipLabel release];
        
        float valueW = (self.view.frame.size.width - 40) * 0.33;
    
        CGRect tipDetailLabelRect = CGRectMake(tipX + tipW, 14.5, valueW, 22);
        UILabel *tipDetailLabel=[[UILabel alloc]initWithFrame:[GYFrame myRect:tipDetailLabelRect]];

        tipDetailLabel.tag=2;
        tipDetailLabel.textAlignment=NSTextAlignmentRight;
        tipDetailLabel.textColor=[UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : UIColorFromRGB(0xA3A3A3);
        tipDetailLabel.backgroundColor=[UIColor clearColor];
        tipDetailLabel.contentMode = UIViewContentModeCenter;
        tipDetailLabel.font = [UIFont systemFontOfSize:kGetCurrentValue(17)];
        [cell.contentView addSubview:tipDetailLabel];
        [tipDetailLabel release];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
   }
    
    float nameW = 0.0;
    float valueW = 0.0;
     
    UILabel *namelabel=(UILabel *)[cell viewWithTag:1];
//    UITextView *namelabel = (UITextView *)[cell viewWithTag:1];
    UILabel *valuelabel=(UILabel *)[cell viewWithTag:2];

    
    if(indexPath.row == 0)
    {
        //        name 和 value 宽度相同
        nameW = (self.view.frame.size.width - 40) * 0.5;
        valueW = nameW;
    }
//    else if(indexPath.row == 1)
//    {
//        //        name 占 1/3 value占2/3
//        nameW = (self.view.frame.size.width - 40) * 0.33;
//        valueW = nameW * 2;
//     }
    else if(indexPath.row == 1)
    {
        //        name 占 2/3 value占1/3
        nameW = (self.view.frame.size.width - 40) * 0.67;
        valueW = nameW / 2;
    }
#ifdef _LANGUANG_FLAG_
    else if (indexPath.row == 2){
        
        nameW = (self.view.frame.size.width - 40) * 0.67;
        valueW = nameW / 2;
    }
    
#endif
    
    CGRect nameFrame = namelabel.frame;
    nameFrame.size.width = nameW;
    namelabel.frame = nameFrame;
    
    CGRect valueFrame = valuelabel.frame;
    valueFrame.size.width = valueW - 10;
    valueFrame.origin.x = SCREEN_WIDTH-valueFrame.size.width-15;
    valuelabel.frame = valueFrame;
    
    
    if (indexPath.row == 0)
    {
        namelabel.text = [StringUtil getLocalizableString:@"about_publish_date"];
        
        valuelabel.text = [StringUtil getAppReleaseDate];
//        valuelabel.text = @"2015-5-22";
    }
//    else if(indexPath.row == 1)
//    {
//        namelabel.text=@"网址";
//        valuelabel.text = @"http://qyfile.csair.com";
//        valuelabel.textColor = [UIColor blueColor];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     else if(indexPath.row == 1)
    {
       if(_conn.hasNewVersion)
        {
            namelabel.text=[StringUtil getLocalizableString:@"about_version_hint"];
            valuelabel.text = _conn.updateVersion;
            
            UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
            MessageView *messageView = [MessageView getMessageView];
            UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
            newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
            
            float newLabelW = 40;
            float newLabelH = 20;
            
            CGSize _size = [namelabel.text sizeWithFont:namelabel.font];
            
            float newLabelX = namelabel.frame.origin.x + _size.width + 10;
            float newLabelY = (row_height - newLabelH) / 2;
            
            UIButton *newLabel=[[UIButton alloc]initWithFrame:CGRectMake(newLabelX, newLabelY, newLabelW, newLabelH)];
            [newLabel addTarget:self action:@selector(dolineAction:) forControlEvents:UIControlEventTouchUpInside];
            [newLabel setBackgroundImage:newMsgImage forState:UIControlStateNormal];
            newLabel.backgroundColor=[UIColor clearColor];
            [newLabel setTitle:@"new" forState:UIControlStateNormal];
            newLabel.font=[UIFont boldSystemFontOfSize:12];
            [cell.contentView addSubview:newLabel];
            [newLabel release];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            namelabel.text=[StringUtil getLocalizableString:@"about_new_version"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
#ifdef _LANGUANG_FLAG_
    
//    else if (indexPath.row == 2){
//        
//        namelabel.text = @"意见反馈";
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
#endif
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:infoTable withOriginX:namelabel.frame.origin.x];
     return cell;
}
-(void)dolineAction:(id)sender
{
    NSString *updateUrl = _conn.updateUrl;
    if (updateUrl.length == 0) {
        updateUrl = [UserDefaults getNewVersionUrl];
    }
    
    //    测试数据
    //    updateUrl = @"http://mop.longfor.com:8090/";
    //    updateUrl = @"itms-services://?action=download-manifest&url=https://mop.longfor.com/plist/lhdc_27.plist";
    
    if (updateUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:updateUrl];
        
        [[UIApplication sharedApplication]openURL:url];
        if ([updateUrl hasPrefix:@"itms-services://"]) {
//            ios8下 用户选择安装新版本后，系统不会自动退出，所以
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(indexPath.row == 1)
//    {
//        [self dolineAction:nil];
//    }
	if(indexPath.row == 1)
	{
        if(_conn.hasNewVersion)
        {
            [self dolineAction:nil];
        }
    }
#ifdef _LANGUANG_FLAG_
    
//    else if (indexPath.row == 2){
//
//        Emp *_emp = [[eCloudDAO getDatabase] getEmployeeById:LG_SECRETARY_ID];
//        [UIAdapterUtil openConversation:self andEmp:_emp];
//    }
    
#endif
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = infoTable.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    infoTable.frame = _frame;
    
    [infoTable reloadData];
    
    _frame = logoView.frame;
    _frame.origin.x = (SCREEN_WIDTH - logoWidth) * 0.5;
    logoView.frame = _frame;
    
    _frame = versionLabel.frame;
    _frame.size.width = SCREEN_WIDTH;
    versionLabel.frame = _frame;
    
}

@end
