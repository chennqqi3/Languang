//
//  ServerConfigViewController.m
//  eCloud
//
//  Created by robert on 12-12-10.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "ServerConfigViewController.h"
#import "ImageUtil.h"
#import "UIAdapterUtil.h"
#import "AccessConn.h"
#import "eCloudDefine.h"
#import "eCloudUser.h"

#import "eCloudConfig.h"

#define textFieldSpaceingToRight ((IOS7_OR_LATER) ? 70 : 80)

@interface ServerConfigViewController ()

@end

@implementation ServerConfigViewController
@synthesize tableView = _tableView;
@synthesize currentTextField;
@synthesize serverConfig = _serverConfig;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	[self.navigationItem.backBarButtonItem setTarget:self];
//    self.navigationItem.backBarButtonItem.action = @selector(backButtonPressed:);
    
	_db = [eCloudUser getDatabase];
	
	self.title = @"服务器设置";
	
	//设置背景
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"save"] andTarget:self andSelector:@selector(saveConfig:)];
    
	self.tableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped] autorelease];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    self.tableView.backgroundView=nil;
	self.tableView.backgroundColor = [UIColor clearColor];
	
	[self.view addSubview:self.tableView];
	
	UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.numberOfTouchesRequired = 1;
    tapGr.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGr];
    [tapGr release];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar
        shouldPopItem:(UINavigationItem *)item{
    //在此处添加点击back按钮之后的操作代码
    return FALSE;
}
//回到首页
-(void) backButtonPressed:(id) sender
{
	[primaryIPText resignFirstResponder];
	[primaryPortText resignFirstResponder];
	[secondIPText resignFirstResponder];
	[secondPortText resignFirstResponder];
    
    [otherIPText resignFirstResponder];
    [otherPortText resignFirstResponder];
	
	[fileServerText resignFirstResponder];
	[fileServerPortText resignFirstResponder];
	[fileServerUrlText resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];	
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
	[primaryIPText resignFirstResponder];
	[primaryPortText resignFirstResponder];
	[secondIPText resignFirstResponder];
	[secondPortText resignFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.serverConfig = [_db getServerConfig];
	
	[self.tableView reloadData];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
			
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark  tableview data source delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_wanda)
    {
        if(section == 3) return 3;
    }
    else
    {
        if(section == 2) return 3;
    }
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone ;
	
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
			_label.backgroundColor = [UIColor clearColor];
			_label.text = @"地址:";
			_label.font = [UIFont systemFontOfSize:17];
			[cell.contentView addSubview:_label];
			[_label release];
			
			primaryIPText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
			primaryIPText.clearButtonMode = UITextFieldViewModeWhileEditing;
			primaryIPText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			primaryIPText.placeholder=@"主服务器地址";
			primaryIPText.delegate = self;
			primaryIPText.returnKeyType = UIReturnKeyDone;
			primaryIPText.keyboardType =  UIKeyboardTypeNumbersAndPunctuation; 
			primaryIPText.text = self.serverConfig.primaryServer;
			
			[cell.contentView addSubview:primaryIPText];
		}
		else 
		{
			UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
			_label.backgroundColor = [UIColor clearColor];
			_label.text = @"端口:";
			_label.font = [UIFont systemFontOfSize:17];
			[cell.contentView addSubview:_label];
			[_label release];

			primaryPortText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
			primaryPortText.clearButtonMode = UITextFieldViewModeWhileEditing;
			primaryPortText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			primaryPortText.placeholder=@"主服务器端口";
			primaryPortText.delegate = self;
			primaryPortText.returnKeyType = UIReturnKeyDone;
			primaryPortText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			primaryPortText.text = [StringUtil getStringValue:self.serverConfig.primaryPort];
			[cell.contentView addSubview:primaryPortText];
		}
	}
	else if(indexPath.section == 1)
	{
		if(indexPath.row == 0)
		{
			UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
			_label.backgroundColor = [UIColor clearColor];
			_label.text = @"地址:";
			_label.font = [UIFont systemFontOfSize:17];
			[cell.contentView addSubview:_label];
			[_label release];
			
			secondIPText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
			secondIPText.clearButtonMode = UITextFieldViewModeWhileEditing;
			secondIPText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			secondIPText.placeholder=@"备用服务器地址";
			secondIPText.delegate = self;
			secondIPText.returnKeyType = UIReturnKeyDone;
			secondIPText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			secondIPText.tag = 3;
			secondIPText.text = self.serverConfig.secondServer;
          
			[cell.contentView addSubview:secondIPText];
			
		}
		else
		{
			UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
			_label.backgroundColor = [UIColor clearColor];
			_label.text = @"端口:";
			_label.font = [UIFont systemFontOfSize:17];
			[cell.contentView addSubview:_label];
			[_label release];
			
			secondPortText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
			secondPortText.clearButtonMode = UITextFieldViewModeWhileEditing;
			secondPortText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			secondPortText.placeholder=@"备用服务器端口";
			secondPortText.delegate = self;
			secondPortText.returnKeyType = UIReturnKeyDone;
			secondPortText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			secondPortText.text = [StringUtil getStringValue:self.serverConfig.secondPort];
			secondPortText.tag = 4;
			
			[cell.contentView addSubview:secondPortText];
		}
	}
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_wanda)
    {
        if(indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"地址:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                otherIPText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                otherIPText.clearButtonMode = UITextFieldViewModeWhileEditing;
                otherIPText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                otherIPText.placeholder=@"轻应用服务器地址";
                otherIPText.delegate = self;
                otherIPText.returnKeyType = UIReturnKeyDone;
                otherIPText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                otherIPText.tag = 8;
                otherIPText.text = self.serverConfig.otherServer;
                
                [cell.contentView addSubview:otherIPText];
                
            }
            else
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"端口:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                otherPortText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                otherPortText.clearButtonMode = UITextFieldViewModeWhileEditing;
                otherPortText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                otherPortText.placeholder=@"轻应用服务器端口";
                otherPortText.delegate = self;
                otherPortText.returnKeyType = UIReturnKeyDone;
                otherPortText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                otherPortText.text = [StringUtil getStringValue:self.serverConfig.otherPort];
                otherPortText.tag = 9;
                
                [cell.contentView addSubview:otherPortText];
            }
        }
        else if (indexPath.section == 3)
        {
            if(indexPath.row == 0)
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"地址:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerText.placeholder=@"文件服务器地址";
                fileServerText.delegate = self;
                fileServerText.returnKeyType = UIReturnKeyDone;
                fileServerText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerText.tag = 5;
                fileServerText.text = self.serverConfig.fileServer;
                
                [cell.contentView addSubview:fileServerText];
                
            }
            else if(indexPath.row == 1)
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"端口:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerPortText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerPortText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerPortText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerPortText.placeholder=@"备用服务器端口";
                fileServerPortText.delegate = self;
                fileServerPortText.returnKeyType = UIReturnKeyDone;
                fileServerPortText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerPortText.text = [StringUtil getStringValue:self.serverConfig.fileServerPort];
                fileServerPortText.tag = 6;
                
                [cell.contentView addSubview:fileServerPortText];
            }
            else
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"URL:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerUrlText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerUrlText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerUrlText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerUrlText.placeholder=@"文件服务器URL";
                fileServerUrlText.delegate = self;
                fileServerUrlText.returnKeyType = UIReturnKeyDone;
                fileServerUrlText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerUrlText.text = self.serverConfig.fileServerUrl;
                fileServerUrlText.tag = 7;
                
                [cell.contentView addSubview:fileServerUrlText];
            }
        }
    }
	else
	{
        if (indexPath.section == 2) {
            if(indexPath.row == 0)
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"地址:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerText.placeholder=@"文件服务器地址";
                fileServerText.delegate = self;
                fileServerText.returnKeyType = UIReturnKeyDone;
                fileServerText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerText.tag = 5;
                fileServerText.text = self.serverConfig.fileServer;
                
                [cell.contentView addSubview:fileServerText];
                
            }
            else if(indexPath.row == 1)
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"端口:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerPortText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerPortText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerPortText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerPortText.placeholder=@"备用服务器端口";
                fileServerPortText.delegate = self;
                fileServerPortText.returnKeyType = UIReturnKeyDone;
                fileServerPortText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerPortText.text = [StringUtil getStringValue:self.serverConfig.fileServerPort];
                fileServerPortText.tag = 6;
                
                [cell.contentView addSubview:fileServerPortText];
            }
            else
            {
                UILabel *_label  = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 55, 45)];
                _label.backgroundColor = [UIColor clearColor];
                _label.text = @"URL:";
                _label.font = [UIFont systemFontOfSize:17];
                [cell.contentView addSubview:_label];
                [_label release];
                
                fileServerUrlText = [[UITextField alloc]initWithFrame:CGRectMake(65, 0, self.view.frame.size.width-textFieldSpaceingToRight, 45)];
                fileServerUrlText.clearButtonMode = UITextFieldViewModeWhileEditing;
                fileServerUrlText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                fileServerUrlText.placeholder=@"文件服务器URL";
                fileServerUrlText.delegate = self;
                fileServerUrlText.returnKeyType = UIReturnKeyDone;
                fileServerUrlText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                fileServerUrlText.text = self.serverConfig.fileServerUrl;
                fileServerUrlText.tag = 7;
                
                [cell.contentView addSubview:fileServerUrlText];
            }
        }
	}

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_wanda)
    {
        return 4;
    }
	return 3;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

#pragma mark table view delegate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 1;
}

 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 25)]autorelease];
		_temp.backgroundColor = [UIColor clearColor];
		
		UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(15,5, 280, 20)];
		_label.font = [UIFont systemFontOfSize:16];
		_label.text = @"主服务器";
		_label.backgroundColor = [UIColor clearColor];
		[_temp addSubview:_label];
		[_label release];
		
		return _temp;
	}
	else if(section == 1)
	{
		UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 25)]autorelease];
		_temp.backgroundColor = [UIColor clearColor];
		
		UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(15,5, 280, 20)];
		_label.font = [UIFont systemFontOfSize:16];
		_label.text = @"备用服务器";
		_label.backgroundColor = [UIColor clearColor];
		[_temp addSubview:_label];
		[_label release];
		
		return _temp;
	}
    if ([eCloudConfig getConfig].contactListRightBtnClickMode == contact_list_right_btn_click_mode_wanda)
    {
        if(section == 2)
        {
            UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 25)]autorelease];
            _temp.backgroundColor = [UIColor clearColor];
            
            UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(15,5, 280, 20)];
            _label.font = [UIFont systemFontOfSize:16];
            _label.text = @"轻应用服务器";
            _label.backgroundColor = [UIColor clearColor];
            [_temp addSubview:_label];
            [_label release];
            
            return _temp;
        }
        else if (section == 3)
        {
            UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 25)]autorelease];
            _temp.backgroundColor = [UIColor clearColor];
            
            UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(15,5, 280, 20)];
            _label.font = [UIFont systemFontOfSize:16];
            _label.text = @"文件服务器";
            _label.backgroundColor = [UIColor clearColor];
            [_temp addSubview:_label];
            [_label release];
            
            return _temp;
        }
    }
	else
	{
        if (section == 2)
        {
            UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 25)]autorelease];
            _temp.backgroundColor = [UIColor clearColor];
            
            UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(15,5, 280, 20)];
            _label.font = [UIFont systemFontOfSize:16];
            _label.text = @"文件服务器";
            _label.backgroundColor = [UIColor clearColor];
            [_temp addSubview:_label];
            [_label release];
            
            return _temp;
            
        }
	}
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) keyboardWillShow:(NSNotification *)note
{
//	NSLog(@"show keyboard");
}

- (void)keyboardWillHide:(NSNotification*)notification 
{
//	NSLog(@"hide keyboard");
	self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 460);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(textField.tag == 3 || textField.tag == 4)
	{
		self.tableView.frame = CGRectMake(0, -100, self.view.frame.size.width, 460);
	}
	if(textField.tag == 5 || textField.tag == 6 || textField.tag == 7)
	{
		self.tableView.frame = CGRectMake(0, -230, self.view.frame.size.width, 460);
	}
	
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

-(void)saveConfig:(id)sender
{
    AccessConn *conn = [AccessConn getConn];
    [conn removeLastConnectData];

//    update by shisp 使用新的方式保存服务器配置 保存到配置文件
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    mDic[KEY_PRIMARY_SERVER_URL] = primaryIPText.text;
    mDic[KEY_PRIMARY_SERVER_PORT] = [NSNumber numberWithInt:primaryPortText.text.intValue];
    mDic[KEY_SECOND_SERVER_URL] = secondIPText.text;
    mDic[KEY_SECOND_SERVER_PORT] = [NSNumber numberWithInt:secondPortText.text.intValue];
    mDic[KEY_OTHER_SERVER_URL] = otherIPText.text;
    mDic[KEY_OTHER_SERVER_PORT] = [NSNumber numberWithInt:otherPortText.text.intValue];
    mDic[KEY_FILE_SERVER_URL] = fileServerText.text;
    mDic[KEY_FILE_SERVER_PORT] = [NSNumber numberWithInt:fileServerPortText.text.intValue];
    mDic[KEY_FILE_SERVER_PATH] = fileServerUrlText.text;
    [[eCloudConfig getConfig]saveUserConfig:mDic];

    
//	[primaryIPText resignFirstResponder];
//	[primaryPortText resignFirstResponder];
//	[secondIPText resignFirstResponder];
//	[secondPortText resignFirstResponder];
	
//	self.serverConfig.primaryServer = primaryIPText.text;
//	self.serverConfig.primaryPort = primaryPortText.text.intValue;
//	self.serverConfig.secondServer = secondIPText.text;
//	self.serverConfig.secondPort = secondPortText.text.intValue;
//	self.serverConfig.fileServer = fileServerText.text;
//	self.serverConfig.fileServerPort = fileServerPortText.text.intValue;
//	self.serverConfig.fileServerUrl = fileServerUrlText.text;
    
//	[_db saveServerConfig:self.serverConfig];
	
	[self.navigationController popViewControllerAnimated:YES];

}
@end
