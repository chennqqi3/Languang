//
//  clearDataViewController.m
//  eCloud
//
//  Created by SH on 14-8-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "clearDataViewController.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "dataCell.h"
#import "clearData.h"
#import "deleteAllChatRecord.h"
#import "eCloudDAO.h"
#import "UserDefaults.h"
#import "eCloudDefine.h"

#import "UserTipsUtil.h"

@interface clearDataViewController ()
{
    eCloudDAO *db;
    NSArray *fileList;
    long long picSize;
    long long otherFileSize;
    NSMutableArray *picPathArry;
    NSMutableArray *otherPathArry;
}

@end

@implementation clearDataViewController

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
    db = [eCloudDAO getDatabase];
    
	self.title = [StringUtil getLocalStringRelatedWithAppNameByKey:@"usual_clear_data"];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed)];
    
    clearDataView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:clearDataView];
    
//    clearDataView.delegate = self;
    clearDataView.dataSource = self;
    clearDataView.showsHorizontalScrollIndicator = NO;
    clearDataView.showsVerticalScrollIndicator = NO;
    clearDataView.delegate = self;
    clearDataView.backgroundView = nil;
    clearDataView.backgroundColor=[UIColor clearColor];

    [self.view addSubview:clearDataView];
    [clearDataView release];
    
    //获取指定目录下的文件
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = [StringUtil newRcvFilePath];
    NSLog(@"----------%@",documentDir);
	NSError *error = nil;
 //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
	fileList =[fileManager contentsOfDirectoryAtPath:documentDir error:&error];

    picPathArry = [[NSMutableArray alloc] init];
    otherPathArry = [[NSMutableArray alloc] init];
    
    NSMutableString *fullPath;
    //  所有子文件夹名
	for (NSString *file in fileList)
    {
        fullPath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:file];
        
        long long fileSize = [self fileSizeAtPath:fullPath];
        NSLog(@"fileSize == %lld",fileSize);
         
        if (([[file pathExtension] length] && ([[file pathExtension] isEqualToString:@"png"] || [[file pathExtension] isEqualToString:@"jpg"])) ||([[file pathExtension ]isEqualToString:@"gif"]||([[file pathExtension ]isEqualToString:@"bmp"]) || ([[file pathExtension ]isEqualToString:@"tiff"])))
        {
//            picSize += fileSize;
           [picPathArry addObject:fullPath];
        }else
        {
//            otherFileSize += fileSize;
            [otherPathArry addObject:fullPath];

        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellName = @"CellName";

    dataCell *cell = nil;// [tableView dequeueReusableCellWithIdentifier:CellName];
	if (cell == nil)
	{
        cell = [[[dataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName] autorelease];
        cell.sizeLable.tag = 100;
    }

//    NSArray *data = [NSArray arrayWithObjects:[StringUtil getLocalizableString:@"clearData_chat_records"],[StringUtil getLocalizableString:@"clearData_pictures"],[StringUtil getLocalizableString:@"clearData_files"], nil];
    
     NSArray *data = [NSArray arrayWithObjects:[StringUtil getLocalizableString:@"clearData_pictures"],[StringUtil getLocalizableString:@"clearData_files"], nil];
    
    cell.typeLable.text = data[indexPath.row];
    
//    CGRect rect = cell.sizeLable.frame;
//    
//    if (indexPath.row == 0) {
//        rect.origin.x = 145;
//        cell.sizeLable.frame = rect;
//    }
    
    switch (indexPath.row)
    {
//        case 0:
//            cell.sizeLable.text = [StringUtil getDisplayFileSize:(picSize+otherFileSize)];
//            if ((picSize+otherFileSize) == 0) {
//                cell.clearButton.enabled = NO;
//                [cell.clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            }
//            break;
            
        case 0:
            picSize = [[UserDefaults getPicStorage]longLongValue];
            cell.sizeLable.text = [StringUtil getDisplayFileSize:picSize];
            if (picSize == 0) {
                cell.clearButton.enabled = NO;
                [cell.clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            break;
            
        case 1:
            otherFileSize = [[UserDefaults getFileStorage]longLongValue];
            cell.sizeLable.text = [StringUtil getDisplayFileSize:otherFileSize];
            if (otherFileSize == 0) {
                cell.clearButton.enabled = NO;
                [cell.clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            break;
    }
    cell.clearButton.tag = indexPath.row;
    [cell.clearButton addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:clearDataView withOriginX:cell.typeLable.frame.origin.x];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12;
}

- (void)clear:(UIButton *)sender
{
//    UIButton *btn = (UIButton *)[self.view viewWithTag:sender.tag];
//    UITableViewCell * cell = (UITableViewCell *)[btn superview];
//    NSIndexPath *indexPath = [clearDataView indexPathForCell:cell];
    int btnTag = sender.tag;
//    NSLog(@"%@-------------%@",picPathArry,otherPathArry);
//    NSLog(@"%i",btnTag);
    switch (btnTag) {
//        case 0:
//            
//            [self clearAction:[StringUtil getLocalizableString:@"clearData_clear_all_records"] andTag:btnTag];
//            break;
            
        case 0:
            
            [self clearAction:[StringUtil getLocalizableString:@"clearData_clear_pictures"] andTag:btnTag];
            break;
            
        case 1:
            
            [self clearAction:[StringUtil getLocalizableString:@"clearData_clear_files"] andTag:btnTag];
            break;
    }

}

- (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//清除文件
- (void)clearFile
{
    clearData *clear = [[[clearData alloc] init]autorelease];
    [clear clearData:otherPathArry];
    
    [UserTipsUtil hideLoadingView];
    
    [UserDefaults setFileStorage:@0];
    [clearDataView reloadData];
}

//清除图片
- (void)clearPic
{
    clearData *clear = [[[clearData alloc] init]autorelease];
    [clear clearData:picPathArry];
    
    [UserTipsUtil hideLoadingView];
    
    [UserDefaults setPicStorage:@0];
    [clearDataView reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    if(tag == 0 && buttonIndex == 1)
    {
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];

        // 清除图片文件
        [self performSelector:@selector(clearPic) withObject:nil afterDelay:1];
    }
    else if(tag == 1 && buttonIndex == 1)
    {   // 清除其他文件
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];

        [self performSelector:@selector(clearFile) withObject:nil afterDelay:1];
    }
}

-(void)clearAction:(NSString *)message andTag:(int) btntag
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    alert.tag = btntag;
	[alert show];
	[alert release];
}

-(void) backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc
{
    fileList = nil;
    picSize = nil;
    otherFileSize =nil;
    picPathArry = nil;
    otherPathArry = nil;
    [super dealloc];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = clearDataView.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    clearDataView.frame = _frame;
    
    [clearDataView reloadData];
}

@end
