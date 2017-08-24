//
//  zoneChooseViewController.m
//  eCloud
//
//  Created by  lyong on 13-12-17.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "zoneChooseViewController.h"
#import "StringUtil.h"
#import "citiesObject.h"
#import "AdvancedSearchViewController.h"
#import "broadcastChooseMemberViewController.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"
#import "countryChooseViewController.h"
#import "provinceChooseViewController.h"
#import "cityChooseViewController.h"

@interface zoneChooseViewController ()

@end

@implementation zoneChooseViewController
@synthesize  countryLabel;
@synthesize  provinceLabel;
@synthesize  cityLabel;
@synthesize delegete;
@synthesize country_id;
@synthesize province_id;
@synthesize area_id_strings;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//返回 按钮
-(void) backButtonPressed:(id) sender{

	[self.navigationController popViewControllerAnimated:YES];
}

-(void)highButtonPressed:(id)sender
{
    citiesObject *citys=[[citiesObject alloc]init];
    citys.some_cityid=area_id_strings;
    citys.some_cities=[NSString stringWithFormat:@"%@/%@/%@",self.countryLabel.text,self.provinceLabel.text,self.cityLabel.text];
    [((broadcastChooseMemberViewController *)self.delegete).zoneArray addObject:citys];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=@"高级搜索";
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"confirm"] andTarget:self andSelector:@selector(highButtonPressed:)];
    
    //	组织架构展示table
	int tableH = SCREEN_HEIGHT - 20 - 45;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
//	if(iPhone5)
//		tableH = tableH + i5_h_diff;
	
    chooseTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) style:UITableViewStylePlain];
    [chooseTable setDelegate:self];
    [chooseTable setDataSource:self];
    chooseTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:chooseTable];
    
    self.countryLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 25, SCREEN_WIDTH-60, 30)];
    self.countryLabel.backgroundColor=[UIColor clearColor];
    self.countryLabel.font=[UIFont systemFontOfSize:14];
    self.countryLabel.textColor=[UIColor grayColor];
    
    self.provinceLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 25, SCREEN_WIDTH-60, 30)];
    self.provinceLabel.backgroundColor=[UIColor clearColor];
    self.provinceLabel.font=[UIFont systemFontOfSize:14];
    self.provinceLabel.textColor=[UIColor grayColor];
    
    self.cityLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 25, SCREEN_WIDTH-60, 30)];
    self.cityLabel.backgroundColor=[UIColor clearColor];
    self.cityLabel.font=[UIFont systemFontOfSize:14];
    self.cityLabel.textColor=[UIColor grayColor];
    
    self.countryLabel.text=@"请选择";
    self.provinceLabel.text=@"请选择";
    self.cityLabel.text=@"请选择";
    
    self.country_id=-1;
    self.province_id=-1;
}
#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
    
    
}
-(void)titleButtonAction:(id)sender
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

   return 60;

    
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
       
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-160, 20)];
        titleLabel.tag=2;
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.font=[UIFont systemFontOfSize:14];
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray ;
    UILabel *titlelabel=(UILabel *)[cell.contentView viewWithTag:2];
  //  UILabel *detaillabel=(UILabel *)[cell.contentView viewWithTag:3];
    if (indexPath.row==0) {
        titlelabel.text=@"国家";
        [cell.contentView addSubview:self.countryLabel];
        
    }else if(indexPath.row==1)
    {
        titlelabel.text=@"省/州";
        
       [cell.contentView addSubview:self.provinceLabel];
    }else if(indexPath.row==2)
    {
      titlelabel.text=@"市";
      [cell.contentView addSubview:self.cityLabel];
    }
   
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0) {
    
        if (countryChoose==nil) {
            countryChoose=[[countryChooseViewController alloc]init];
            countryChoose.delegete=self;
        }
        [self.navigationController pushViewController:countryChoose animated:YES];
    }else if(indexPath.row==1)
    {   if(self.country_id!=-1)
       {//已经选择了国家
        if (provinceChoose==nil) {
            provinceChoose=[[provinceChooseViewController alloc]init];
            provinceChoose.delegete=self;
        }
           if (provinceChoose.country_id!=self.country_id) {
               provinceChoose.country_id=self.country_id;
               [provinceChoose updateShowData];
           }
         
        [self.navigationController pushViewController:provinceChoose animated:YES];
       }else
       {
           UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请先选择国家" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
           [alert show];
           [alert release];
       }
    }else if(indexPath.row==2)
    {
        if(self.province_id!=-1)
        {//已经选择了省／市
        if (cityChoose==nil) {
            cityChoose=[[cityChooseViewController alloc]init];
            cityChoose.delegete=self;
        }
            if (cityChoose.province_id!=self.province_id) {
                cityChoose.province_id=self.province_id;
                [cityChoose updateShowData];
            }
        [self.navigationController pushViewController:cityChoose animated:YES];
        
        }else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请先选择省/州" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
       
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
