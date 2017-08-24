//
//  FontSizeSettingViewController.m
//  eCloud
//
//  Created by shisuping on 14-7-11.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "FontSizeSettingViewController.h"
#import "GXViewController.h"
#import "FontSizeUtil.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"

#define row_height (45.0)
#define section_footer_height (80.0)

@interface FontSizeSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) UITableView *tableView;
@end

@implementation FontSizeSettingViewController
@synthesize tableView;

- (void)dealloc
{
    self.tableView = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [StringUtil getLocalizableString:@"font_title"];
    
    self.tableView = [[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT) style:UITableViewStyleGrouped]autorelease];
    [UIAdapterUtil setPropertyOfTableView:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    
    self.tableView.rowHeight = row_height;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:self.tableView];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 32;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    ios7可以在通用中设置字体大小，所以可以设置为跟随系统字体进行设置
//    如果参照os系统设置字体，只需要一个section即可
    if ([FontSizeUtil referOsFontSize]) {
        return 1;
    }
    else
    {
        if (IOS7_OR_LATER) {
            return 2;
        }
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([FontSizeUtil referOsFontSize]) {
        return 1;
    }
    else
    {
        if ((IOS7_OR_LATER && section == 0)) {
            return 1;
        }
        else
        {
            return 4;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    
//    是否跟随系统文字大小
    if (IOS7_OR_LATER && indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *blacklabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 14.5, 200, 22)];
        blacklabel.backgroundColor=[UIColor clearColor];
        blacklabel.textColor=[UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        blacklabel.font=[UIFont systemFontOfSize:17];
        blacklabel.text=[StringUtil getLocalizableString:@"font_follow_system"];
        [cell addSubview:blacklabel];
        [blacklabel release];
        
        //同步消息开关
        CGRect switchRect = CGRectMake(220,10,0,0);
        UISwitch *_switch = [[UISwitch alloc] initWithFrame:switchRect];
        [UIAdapterUtil positionSwitch:_switch ofCell:cell];
        
//        _switch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_switch setOn:[FontSizeUtil referOsFontSize]];
        
        [_switch addTarget:self action:@selector(updateReferOsFontSize:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:_switch];
        [_switch release];
    }
//    小，中，大，超大字号选择
//    只有不根据系统调节字体时，才显示字号选择
    else if((IOS7_OR_LATER && indexPath.section == 1 && ![FontSizeUtil referOsFontSize]) || (!IOS7_OR_LATER && indexPath.section == 0))
    {
        int fontSize = [FontSizeUtil getFontSize];
        cell.textColor=[UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
//        label
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = [StringUtil getLocalizableString:@"font_small"];
                cell.textLabel.font = [UIFont systemFontOfSize:font_size_s];
                if (fontSize == font_size_s) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 1:
                cell.textLabel.text = [StringUtil getLocalizableString:@"font_medium"];
                cell.textLabel.font = [UIFont systemFontOfSize:font_size_m];
                if (fontSize == font_size_m) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 2:
                cell.textLabel.text = [StringUtil getLocalizableString:@"font_large"];
                cell.textLabel.font = [UIFont systemFontOfSize:font_size_l];
                if (fontSize == font_size_l) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 3:
                cell.textLabel.text = [StringUtil getLocalizableString:@"font_x_large"];
                cell.textLabel.font = [UIFont systemFontOfSize:font_size_xl];
                if (fontSize == font_size_xl) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (IOS7_OR_LATER && section == 0) {
        return section_footer_height;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (IOS7_OR_LATER && section == 0) {
        UIView *parentView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, section_footer_height)]autorelease];
        
        UIFont *tipFont = [UIFont systemFontOfSize:font_size_s];
        NSString *tipStr = [StringUtil getLocalizableString:@"font_tipstr"];
        
        CGSize tipSize = CGSizeMake(self.view.frame.size.width - 40, section_footer_height);
        tipSize = [tipStr sizeWithFont:tipFont constrainedToSize:tipSize lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect _frame = CGRectMake(12, 12, tipSize.width, tipSize.height);
        UILabel *_label = [[UILabel alloc]initWithFrame:_frame];
        _label.font = tipFont;
        _label.textColor = [UIColor grayColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.text = tipStr;
        _label.textAlignment = NSTextAlignmentLeft;
        [parentView addSubview:_label];
        [_label release];
        return parentView;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ((IOS7_OR_LATER && indexPath.section == 1 && ![FontSizeUtil referOsFontSize]) || (!IOS7_OR_LATER && indexPath.section == 0))
    {
        switch (indexPath.row) {
            case 0:
                [FontSizeUtil setFontSize:font_size_s];
                break;
            case 1:
                [FontSizeUtil setFontSize:font_size_m];
                break;
            case 2:
                [FontSizeUtil setFontSize:font_size_l];
                break;
            case 3:
                [FontSizeUtil setFontSize:font_size_xl];
                break;
            default:
                break;
        }
        [tableView reloadData];
    }
}

- (void)updateReferOsFontSize:(id)sender
{
    UISwitch *_switch = (UISwitch*)sender;
    [FontSizeUtil setReferOsFontSize:_switch.isOn];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.tableView reloadData];
    [GXViewController displaySubViewOfView:self.tableView andLevel:0];
}

@end
