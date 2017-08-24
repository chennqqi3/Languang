//
//  chooseLanguageViewController.m
//  eCloud
//
//  Created by SH on 14-7-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "chooseLanguageViewController.h"
#import "UIAdapterUtil.h"
#import "LanUtil.h"
#import "StringUtil.h"
#import "eCloudDefine.h"

@interface chooseLanguageViewController ()
{
    NSUserDefaults *userDefaults;
}

@end

@implementation chooseLanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
	[UIAdapterUtil processController:self];

    [UIAdapterUtil setBackGroundColorOfController:self];
//    [UIAdapterUtil setStatusBarColor:self.navigationController];
    self.title = [StringUtil getLocalizableString:@"usual_language"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    chooseLanguageView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:chooseLanguageView];

    chooseLanguageView.delegate = self;
    chooseLanguageView.dataSource = self;
    chooseLanguageView.showsHorizontalScrollIndicator = NO;
    chooseLanguageView.showsVerticalScrollIndicator = NO;
    chooseLanguageView.backgroundView = nil;
    chooseLanguageView.backgroundColor=[UIColor clearColor];
    chooseLanguageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:chooseLanguageView];
    [chooseLanguageView release];
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:chooseLanguageView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
	}
    
    NSArray *languageArray = [NSArray arrayWithObjects:@"简体中文",@"English", nil];
    
    cell.textLabel.text = languageArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [UIAdapterUtil customSelectBackgroundOfCell:cell];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
    
    if ([LanUtil isChinese]) {
        if (indexPath.row ==0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else
    {
        if (indexPath.row ==1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case 0:
            
            [LanUtil setUserlanguage : @"zh-Hans"];
            [chooseLanguageView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:REFREASH_CONACTS_LANGUAGE object:nil];
            break;
            
        case 1:

            [LanUtil setUserlanguage :@"en"];
            [chooseLanguageView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:REFREASH_CONACTS_LANGUAGE object:nil];
            break;
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 32;
}

-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)dealloc
{
    chooseLanguageView = nil;
    [super dealloc];
}

@end
