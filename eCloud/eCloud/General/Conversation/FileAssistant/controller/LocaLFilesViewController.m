//
//  LocaLFilesViewController.m
//  QuickLookDemo
//
//  Created by Pain on 14-4-10.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import "LocaLFilesViewController.h"
#import "LCLLoadingView.h"

#import "ApplicationManager.h"
#import "CustomQLPreviewController.h"

#import "StringUtil.h"
#import "LocalFileListCell.h"
#import "LocalFileObject.h"
#import "AppDelegate.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "UserDefaults.h"

@interface LocaLFilesViewController ()

@property(nonatomic,assign)NSMutableArray *dirArray;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@end

@implementation LocaLFilesViewController
@synthesize locaLFilesDelegate = _locaLFilesDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        delectedArr = [[NSMutableArray alloc] init];
        allFileSize = 0;
        //注册发送文件完成的消息中心
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFilesFinished) name:@"UploadFilesFinished" object:nil];
    }
    return self;
}


- (void)dealloc
{
    self.dirArray = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadFilesFinished" object:nil];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    self.title = [StringUtil getLocalizableString:@"chats_talksession_message_file_title"];
    readTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-42.0) style:UITableViewStylePlain];
    readTable.dataSource = self;
    readTable.backgroundColor = [UIColor clearColor];
    readTable.delegate = self;
    [self.view addSubview:readTable];
    [readTable release];
    
    //NSLog(@"self.view.frame.size.height------%f",self.view.frame.size.height);
    
    //底部发送栏
    UIImageView *bottombar=[[UIImageView alloc]init];
    
    if (IOS7_OR_LATER) {
        [bottombar setFrame:CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-42.0-20.0, 320, 42.0)];
    }
    else{
        [bottombar setFrame:CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-42.0, 320, 42.0)];
    }
    
    bottombar.userInteractionEnabled = YES;
    bottombar.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0.6];
    [self.view addSubview:bottombar];
    [bottombar release];
    
    sendLab = [[UILabel alloc]initWithFrame:CGRectMake(10.0,0.0, 236.0, 42.0)];
    sendLab.backgroundColor = [UIColor clearColor];
    sendLab.textColor=[UIColor blackColor];
    sendLab.text = @"";
    sendLab.font=[UIFont systemFontOfSize:14.0];
    sendLab.contentMode = UIViewContentModeTop;
    sendLab.textAlignment = UITextAlignmentLeft;
    sendLab.numberOfLines = 2;
    [bottombar addSubview:sendLab];
    [sendLab release];
    
    sendeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendeBtn.frame = CGRectMake(260, 6.0, 50, 30);
    sendeBtn.enabled = NO;
    [sendeBtn setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sendeBtn setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sendeBtn setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sendeBtn setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
    sendeBtn.titleLabel.font=[UIFont boldSystemFontOfSize:13.0];
    [sendeBtn addTarget:self action:@selector(clickOnSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [bottombar addSubview:sendeBtn];
    
    /*
     //保存一张图片到设备document文件夹中 - by code4app小编
     UIImage *image = [StringUtil getImageByResName:@"code4app.jpg"];
     NSData *jpgData = UIImageJPEGRepresentation(image,0.8);
     
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
     NSString *filePath = [documentsPath stringByAppendingPathComponent:@"code4app.jpg"]; //Add the file name
     [jpgData writeToFile:filePath atomically:YES]; //Write the file
     
     
     //保存一份txt文件到设备document文件夹中 - by code4app小编
     char *saves = "Code4App";
     NSData *data = [[NSData alloc] initWithBytes:saves length:8];
     filePath = [documentsPath stringByAppendingPathComponent:@"code4app.txt"];
     [data writeToFile:filePath atomically:YES];
     
     */
    
    //获取指定目录下的文件
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = [StringUtil newRcvFilePath];
//    NSLog(@"----------%@",documentDir);
	NSError *error = nil;
	NSArray *fileList = [[NSArray alloc] init];
	//fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
	fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
	
	//    以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
	//	NSLog(@"------------------------%@",fileList);
	self.dirArray = [[NSMutableArray alloc] init];
    
	for (NSString *file in fileList)
	{
        //过滤小图，录音文件
//        if (![[file pathExtension] length] || ([file hasPrefix:@"small"] && ([[file pathExtension] isEqualToString:@"png"] || [[file pathExtension] isEqualToString:@"jpg"])) || [[file pathExtension] isEqualToString:@"amr"] || [[file pathExtension] isEqualToString:@"wav"]) {
//            continue;
//        }
//        只显示pc版以文件形式发过来的文件
        NSRange range = [file rangeOfString:@"_"];
        if(range.length == 0)
        {
            continue;
        }
        
        //获取文件属性
        NSString *path = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:file];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
        NSString *fileCreationDateStr = [self stringFromDate:[fileAttributes objectForKey:NSFileCreationDate]];
        
//        NSLog(@"--------%@",fileAttributes);
        //        LocalFileObject *localFile = [[LocalFileObject alloc] init];
        //        localFile.fileName = file;
        //        localFile.fileFullPath = path;
        //        localFile.fileSize = fileSize;
        //        localFile.fileCreateDate = fileCreationDateStr;
        //        localFile.isFileSelect = NO;
        //        [self.dirArray addObject:localFile];
        //        [localFile release];
        
        NSMutableDictionary *pathDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:file,@"fileName",path,@"fileFullPath",[NSNumber numberWithBool:NO],@"isSelected",[NSNumber numberWithInt:fileSize],@"fileSize",fileCreationDateStr,@"fileCreateDate",nil];
        //NSLog(@"%@",[pathDic description]);
        [self.dirArray addObject:pathDic];
        [pathDic release];
        
	}
    
    if ([self.dirArray count]) {
        //数组排序
        //[self.dirArray sortedArrayUsingFunction:sortByFileCreateDate context:NULL];
        [self.dirArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            //按时间降序
            NSMutableDictionary *dic1 =(NSMutableDictionary*) obj1;
            NSMutableDictionary *dic2 =(NSMutableDictionary *) obj2;
            
            NSString *str1 = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"fileCreateDate"]];
            NSString *str2 = [NSString stringWithFormat:@"%@",[dic2 objectForKey:@"fileCreateDate"]];
            
            return [str2 compare:str1];
        }];
    }
    
   // NSLog(@"self.dirArray:%@",self.dirArray);
//    NSLog(@"Every Thing in the dir:%@",fileList);
    
    [readTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getProperFileName:(NSString *)filenane
{
	NSString *file_Ext = nil;
	NSString *originFileName = filenane;
    
    
	NSRange _range = [originFileName rangeOfString:@"." options:NSBackwardsSearch];
    NSRange _range1 = [originFileName rangeOfString:@"_" options:NSBackwardsSearch];
    
//    NSLog(@"_range1-----111%i",_range1.location);
//    NSLog(@"_range-----%i",_range.location);
//    
	if(_range.location > _range1.location )
	{
		//file_Ext = [originFileName substringFromIndex:_range.location+1];
        
        file_Ext = [originFileName stringByReplacingCharactersInRange:NSMakeRange(_range1.location, _range.location-_range1.location) withString:@""];
        return file_Ext;
        
	}
    
    return filenane;
}

#pragma mark - 注册发送文件完成的消息中心
- (void)uploadFilesFinished{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - 按钮方法实现
-(void)backButtonPressed:(id)sender
{
//    if (_photoSource && [_photoSource respondsToSelector:@selector(photoGalleryClickOnBackBtn:)]) {
//        [_photoSource photoGalleryClickOnBackBtn:self];
//    }
    
    [self.navigationController popViewControllerAnimated: YES];
    
}

- (void)clickOnSendBtn{
    
    int netType = [ApplicationManager getManager].netType;
    
    if(netType == type_gprs && allFileSize > 1024*1024)
    {
        NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:allFileSize countStyle:NSByteCountFormatterCountStyleFile];
        
        //2G网络提示用户
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"chats_talksession_message_file_gprs_tips"]  message:@"" delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        alert.tag = 2;
        [alert show];
        [alert release];
    }
    else{
        if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(locaLFilesViewControllerClickOnBackBtn: withSelectFiles:)]) {
            [_locaLFilesDelegate locaLFilesViewControllerClickOnBackBtn:self withSelectFiles:delectedArr];
        }
        
        //提示发送
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"chats_talksession_message_file_sending"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    }
}

#pragma mark - 按照时间逆序排序
NSInteger sortByFileCreateDate(id obj1, id obj2, void *context){
    NSMutableDictionary *dic1 =(NSMutableDictionary*) obj1;
    NSMutableDictionary *dic2 =(NSMutableDictionary *) obj2;
    
    NSString *str1 = [NSString stringWithFormat:@"%@",[dic1 objectForKey:@"fileCreateDate"]];
    NSString *str2 = [NSString stringWithFormat:@"%@",[dic2 objectForKey:@"fileCreateDate"]];
    
    NSLog(@"str1-------%@",str1);
    NSLog(@"str2-------%@",str2);
//    NSLog(@"result----------%@",[str1 compare:str2 options:NSCaseInsensitiveSearch]);
//    return [str1 compare:str2 options:NSCaseInsensitiveSearch];
    
    if (str1 < str2) {
        
        return NSOrderedDescending;
    }
    else if(str1 < str2){
        return NSOrderedSame;
    }
    return NSOrderedAscending;
}

#pragma mark - UIAlertViewDelegate 协议方法实现
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            //确定转发文件
            if (_locaLFilesDelegate && [_locaLFilesDelegate respondsToSelector:@selector(locaLFilesViewControllerClickOnBackBtn: withSelectFiles:)]) {
                [_locaLFilesDelegate locaLFilesViewControllerClickOnBackBtn:self withSelectFiles:delectedArr];
            }
            
            [self.navigationController popViewControllerAnimated: YES];
        }
    }
}

#pragma mark - 长按手势方法实现
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan)
    {
        if (!self.docInteractionController) {
            return;
        }
        
        NSIndexPath *cellIndexPath = [readTable indexPathForRowAtPoint:[longPressGesture locationInView:readTable]];
		
		NSURL *fileURL;
		fileURL = [NSURL fileURLWithPath:[[self.dirArray objectAtIndex:cellIndexPath.row] objectForKey:@"fileFullPath"]];
        self.docInteractionController.URL = fileURL;
		[self.docInteractionController presentOptionsMenuFromRect:longPressGesture.view.frame
                                                           inView:longPressGesture.view
                                                         animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)singleTap{
    if (singleTap.state == UIGestureRecognizerStateEnded)
    {
        NSIndexPath *indexPath = [readTable indexPathForRowAtPoint:[singleTap locationInView:readTable]];
        UIButton *selectButton = (UIButton *)[(LocalFileListCell *)[readTable cellForRowAtIndexPath:indexPath] isSelectBtn];
        [self selectAction:selectButton];
    }
}

#pragma mark - 设置文件浏览器URL
- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate 协议方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dirArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //预览文件
	QLPreviewController *previewController = [[CustomQLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    self.title = [StringUtil getLocalizableString:@"back"];
    previewController.currentPreviewItemIndex = indexPath.row;
    [[self navigationController] pushViewController:previewController animated:YES];
	//[self presentViewController:previewController animated:YES completion:nil];

    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellName = @"CellName";
	LocalFileListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
	if (cell == nil)
	{
        cell = [[LocalFileListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellName];
        
//        UILongPressGestureRecognizer *longPressGesture =
//        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        [cell.fileIconView addGestureRecognizer:longPressGesture];
//        [longPressGesture release];
//        cell.fileIconView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [cell.isSelectBtnView addGestureRecognizer:singleTap];
        [singleTap release];
    }
    
	NSURL *fileURL= nil;
	fileURL = [NSURL fileURLWithPath:[[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"fileFullPath"]];
	[self setupDocumentControllerWithURL:fileURL];
    
    /*
	NSInteger iconCount = [self.docInteractionController.icons count];
    if (iconCount > 0)
    {
        cell.fileIconView.image = [self.docInteractionController.icons objectAtIndex:0];
    }
    else{
        cell.fileIconView.image = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"file_pic_not_exist" andType:@"png"]];
    }
    */
    
    cell.fileIconView.image = [StringUtil getFileDefaultImage:[[self.dirArray objectAtIndex:[indexPath row]] objectForKey:@"fileName"]];
    
    NSInteger fileSize = [[[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"fileSize"] intValue];
    //NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    
//    NSLog(@"fileSizeStr--------%@",fileSizeStr);
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", fileSizeStr, self.docInteractionController.UTI];
    cell.fileNameLabel.text = [[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"fileName"];//[StringUtil getProperFileName:[[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"fileName"]];
    cell.fileSizeLabel.text = [NSString stringWithFormat:@"%@", fileSizeStr];
    cell.fileCreateDateLabel.text = [[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"fileCreateDate"];
    
    UIButton *selectButton = (UIButton *)cell.isSelectBtn;
    selectButton.tag = indexPath.row;
    [selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[[self.dirArray objectAtIndex:indexPath.row] objectForKey:@"isSelected"] boolValue]) {
        //选中
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateHighlighted];
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateSelected];
    }
    else{
        //未选择
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateNormal];
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateHighlighted];
        [selectButton setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateSelected];
        
    }
    
	return cell;
}

#pragma mark - 获取文件扫描路径
- (NSString *)getFilesScaningPath{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:@"receiveFiles"];
    return documentDir;
}

#pragma mark - 时间与NSString互相转化
- (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
}

- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return destDateString;
}

#pragma mark - 复选框
- (void)selectAction:(UIButton *)sender{
    //NSLog(@"sender.tag-----------%i",sender.tag);
    
    NSMutableDictionary *dic = [self.dirArray objectAtIndex:sender.tag];
    
    //NSLog(@"isSelected-----------%@",[dic objectForKey:@"isSelected"]);
    
    float maxSendFileSize = [UserDefaults getMaxSendFileSize];
    float fileSize = [[dic objectForKey:@"fileSize"] integerValue]/(1024.0*1024);
    
    if (fileSize > maxSendFileSize &&  maxSendFileSize > 0) {
        //大于文件最大允许发送时提示
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil  getLocalizableString:@"file_send_max_size"]  delegate:nil cancelButtonTitle:[StringUtil  getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    
    if ([[dic objectForKey:@"isSelected"] boolValue]) {
        //不选中
        [dic setValue:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png.png"] forState:UIControlStateNormal];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateHighlighted];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateSelected];
    }else
    {
        //选中
        [dic setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateHighlighted];
        [sender setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateSelected];
    }
    
    [self reFreshSelectState];
}


- (void)reFreshSelectState{
    allFileSize = 0;
    NSInteger selectedFileCount = 0;
    if ([delectedArr count]) {
        [delectedArr removeAllObjects];
    }
    
    for (NSMutableDictionary *dic in self.dirArray) {
        if ([[dic objectForKey:@"isSelected"] boolValue]) {
            allFileSize += [[dic objectForKey:@"fileSize"] integerValue];
            selectedFileCount++;
            
            [delectedArr addObject:dic];
        }
    }
    
    if (allFileSize) {
        sendeBtn.enabled = YES;
        //NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:allFileSize countStyle:NSByteCountFormatterCountStyleFile];
        NSString *fileSizeStr = [StringUtil getDisplayFileSize:allFileSize];
        sendLab.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"chats_talksession_message_file_selected"],fileSizeStr];
        NSString *str = [NSString stringWithFormat:@"%@(%i)",[StringUtil getLocalizableString:@"send"],selectedFileCount];
        
        [sendeBtn setTitle:str forState:UIControlStateNormal];
    }
    else {
        [sendeBtn setTitle:[StringUtil getLocalizableString:@"send"] forState:UIControlStateNormal];
        sendeBtn.enabled = NO;
        sendLab.text = @"";
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller{
    
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}


#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
	return [self.dirArray count];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    self.title = [StringUtil getLocalizableString:@"chats_talksession_message_file_title"];
    [readTable reloadData];
}

- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)index
{
	//[previewController.navigationController.navigationBar setBackgroundImage:[StringUtil getImageByResName:@"click.png"] forBarMetrics:UIBarMetricsDefault];
	/*
     NSURL *fileURL = nil;
     NSIndexPath *selectedIndexPath = [readTable indexPathForSelectedRow];
     NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentDir = [documentPaths objectAtIndex:0];
     NSString *path = [documentDir stringByAppendingPathComponent:[self.dirArray objectAtIndex:selectedIndexPath.row]];
     fileURL = [NSURL fileURLWithPath:path];
     return fileURL;
     */
    
    /*
     NSURL *fileURL = nil;
     fileURL = [NSURL fileURLWithPath:[[self.dirArray objectAtIndex:idx] objectForKey:@"fileFullPath"]];
     return fileURL;
     */
    
    LocalFileObject *localFileObject = [[LocalFileObject alloc] init];
    localFileObject.fileName = [StringUtil getProperFileName:[[self.dirArray objectAtIndex:index] objectForKey:@"fileName"]];
    localFileObject.fileFullPath = [[self.dirArray objectAtIndex:index] objectForKey:@"fileFullPath"];
    return localFileObject;
}


@end
