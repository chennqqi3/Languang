//
//  XINHUAUserInfoViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/5/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAUserInfoViewControllerArc.h"

#import "XINHUAUserInfoCellArc.h"
#import "XINHUAEmpInfoCellArc.h"

#import "OpenCtxManager.h"
#import "AppDelegate.h"

#import "UserDefaults.h"

#import "eCloudDAO.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "UserDefaults.h"
#import "conn.h"
#import "ServerConfig.h"
#import "UserDisplayUtil.h"

#import "GKImagePicker.h"
#import "eCloudUser.h"

#import "UserDataDAO.h"

#import "mainViewController.h"
#import "GXViewController.h"

#import "PermissionModel.h"

#import "TabbarUtil.h"
#import "UserTipsUtil.h"
#import "LCLLoadingView.h"

#import "talkSessionViewController.h"

static  NSString *userInfoCellIdentifier = @"userInfoCellIdentifier";
static  NSString *userInfoLogoCellIdentifier = @"userInfoLogoCellIdentifier";
static NSString *XINHUAEmpInfoCellArcID = @"XINHUAEmpInfoCellArcID";
@interface XINHUAUserInfoViewControllerArc ()<UserInfoCellDelegate ,FGalleryViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,GKImagePickerDelegate>
{
    int startTime;
    
    ASIFormDataRequest *_request;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) GKImagePicker* imagePicker;

@property (nonatomic, strong) NSString *preImageFullPath;

@property (nonatomic,strong) NSData *logoData;
@property (nonatomic,assign) int newLogoTimestamp;

/** 是不是当前用户 */
@property (nonatomic, assign) BOOL isCurUser;

@end

@implementation XINHUAUserInfoViewControllerArc

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (NSArray *)dataArray
{
    if (nil == _dataArray)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        NSMutableArray *mArr3 = [NSMutableArray array];
        UIImage *logo = [ImageUtil getEmpLogo:self.emp];
        NSDictionary *dic7 = @{@"title" : [StringUtil getAppLocalizableString:@"head"], @"value" : logo};
        
        [mArr3 addObject:self.isCurUser ? dic7 : self.emp];
        
        NSMutableArray *mArr1 = [NSMutableArray array];
        NSDictionary *dic1 = @{@"title" : [StringUtil getAppLocalizableString:@"name"], @"value" : self.emp.emp_name ? self.emp.emp_name:@""};
        [mArr1 addObject:dic1];
        NSDictionary *dic2 = @{@"title" : [StringUtil getAppLocalizableString:@"sex"], @"value" : (self.emp.emp_sex ? [StringUtil getAppLocalizableString:@"male"]:[StringUtil getAppLocalizableString:@"female"])};
        [mArr1 addObject:dic2];
        NSString *account = self.isCurUser ? [UserDefaults getUserAccount] : @"";
        NSDictionary *dic3 = @{@"title" : [StringUtil getAppLocalizableString:@"phone_number"], @"value" : (self.emp.empCode ? :account)};
        [mArr1 addObject:dic3];
        
        NSMutableArray *mArr2 = [NSMutableArray array];
        NSDictionary *di4 = @{@"title"  : [StringUtil getAppLocalizableString:@"city"], @"value" : (self.emp.empNameEng ? self.emp.empNameEng:@"")};
        [mArr2 addObject:di4];
        NSDictionary *dic5 = @{@"title" : [StringUtil getAppLocalizableString:@"teaching_place"], @"value" : (self.emp.empAddress ? self.emp.empAddress:@"")};
        [mArr2 addObject:dic5];
        NSDictionary *dic6 = @{@"title" : [StringUtil getAppLocalizableString:@"class"], @"value" : (self.emp.deptName ? self.emp.deptName:@"")};
        [mArr2 addObject:dic6];
        
        [mArr addObject:mArr3];
        [mArr addObject:mArr1];
        [mArr addObject:mArr2];
        
        _dataArray = [NSArray arrayWithArray:mArr];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = self.isCurUser ? [StringUtil getAppLocalizableString:@"personal_information"] : [StringUtil getAppLocalizableString:@"contacts_information"];
    
    int id1 = self.emp.emp_id;
    int id2 = [conn getConn].curUser.emp_id;
    self.isCurUser = (id1 == id2);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 注册cell
    [self.tableView registerClass:[XINHUAUserInfoCellArc class] forCellReuseIdentifier:userInfoCellIdentifier];
    [self.tableView registerClass:[XINHUAUserInfoCellArc class] forCellReuseIdentifier:userInfoLogoCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"XINHUAEmpInfoCellArc" bundle:nil] forCellReuseIdentifier:XINHUAEmpInfoCellArcID];
    
    [self.view addSubview:self.tableView];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getEmpInfo];
}

#pragma mark - <UserInfoCellDelegate>
- (void)showBigLogo
{
    [self showbigimage];
}

-(void)showbigimage
{
    NSString *empLogo = self.emp.emp_logo;
    if(empLogo && empLogo.length > 0)
    {
        //	预览图片
        
        NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
        //        NSLog(@"%@",bigLogoPath);
        if([[NSFileManager defaultManager]fileExistsAtPath:bigLogoPath])
        {//大图存在
            
            self.preImageFullPath=bigLogoPath;
            [self displayBigImage];
        }
        else
        {
            //            查看是否有小图，如果有小图，那么可以下载大图，否则不下载
            NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
            if([[NSFileManager defaultManager]fileExistsAtPath:logoPath])
            {
                [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
                
                
                dispatch_queue_t queue = dispatch_queue_create("download.bigpic", NULL);
                dispatch_async(queue, ^{
                    NSURL *bigurl = [NSURL URLWithString:[[ServerConfig shareServerConfig]getBigLogoUrlByEmpId:[StringUtil getStringValue:self.emp.emp_id]]];
                    NSData *bigImageData = [NSData dataWithContentsOfURL:bigurl];
                    if (bigImageData.length > 0) {
                        [bigImageData writeToFile:bigLogoPath atomically:YES];
                        
                        //                        生成并保存小头像
                        UIImage *curImage = [UIImage imageWithData:bigImageData];
                        //
                        [StringUtil createAndSaveMicroLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                        
                        [StringUtil createAndSaveSmallLogo:curImage andEmpId:[StringUtil getStringValue:self.emp.emp_id] andLogo:empLogo];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UserTipsUtil hideLoadingView];
                        if (bigImageData.length > 0)
                        {
                            self.preImageFullPath = bigLogoPath;
                            [self displayBigImage];
                            
                        }
                        else
                        {
                            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"userInfo_download_fail"]];
                        }
                    });
                });
                
            }
        }
    }
}

- (void)displayBigImage
{
    FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [self.navigationController pushViewController:localGallery animated:YES];
}

#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return self.preImageFullPath;
}
- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}

- (void) presentSheet
{
    if (IOS8_OR_LATER && IS_IPHONE) {
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"chatBackground_take_photo"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            拍照
            [self getCameraPicture];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"chatBackground_choose_photos"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //            选择照片
            [self selectExistingPicture];
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alertCtl dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertCtl addAction:takePhotoAction];
        [alertCtl addAction:choosePhotoAction];
        [alertCtl addAction:cancelAction];
        
        [UIAdapterUtil presentVC:alertCtl];
        //        [self presentViewController:alertCtl animated:YES completion:nil];
    }else{
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"chatBackground_take_photo"], [StringUtil getLocalizableString:@"chatBackground_choose_photos"], nil];
        [menu showInView:self.view];
    }
}

////确定获得图片（相机拍摄或从相册选择）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //	头像统一成176，缩略图是60
    CGSize _size = [self getStandardLogoSize];
    if (image.size.width > _size.width || image.size.height > _size.height) {
        image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationMedium];
    }
    
    self.logoData = UIImageJPEGRepresentation(image, 0.5);
    [self uploadLogo];
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
    
    [picker dismissModalViewControllerAnimated:YES];
    
}

//从相册选择图片
- (void) selectExistingPicture {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
        if (headerSize.width != headerSize.height)
        {
            self.imagePicker = [[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            self.imagePicker.cropSize = [self getStandardLogoSize];
            self.imagePicker.delegate = self;
            
            [UIAdapterUtil presentVC:self.imagePicker.imagePickerController];
            
        }else
        {
            //             使用系统的方式选择照片
            [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"访问图片库错误",@"")
                                                        message: NSLocalizedString(@"设备不支持图片库",@"")
                                                       delegate:nil
                                              cancelButtonTitle: NSLocalizedString(@"确定",@"")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (CGSize)getStandardLogoSize
{
    return CGSizeMake([eCloudConfig getConfig].uploadUserLogoWidth.intValue, [eCloudConfig getConfig].uploadUserLogoHeight.intValue);
}

//相机拍摄图片
-(void) getCameraPicture {
    //判断是否支持摄像头
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chatBackground_warning"]
                                                        message: [StringUtil getLocalizableString:@"chatBackground_warning_message"]
                                                       delegate:nil
                                              cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
        
    }
    CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
    
    if (headerSize.width != headerSize.height)
    {
        self.imagePicker = [[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imagePicker.cropSize = [self getCropSize];
        self.imagePicker.delegate = self;
        [UIAdapterUtil presentVC:self.imagePicker.imagePickerController];
        //    [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
    }else
    {
        // 使用系统的调用相机 0819
        [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
    }
}

// 调用系统相机或相册 0819
- (void)callSystemImagePickerControllerWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *pickCtl = [[UIImagePickerController alloc]init];
    pickCtl.sourceType = type;
    pickCtl.delegate = self;
    pickCtl.allowsEditing = YES;
    [UIAdapterUtil presentVC:pickCtl];
    //            [self presentViewController:pickCtl animated:YES completion:nil];
}

- (CGSize)getCropSize
{
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    float width = SCREEN_WIDTH;
    float height = (width * _size.height) / _size.width;
    return CGSizeMake(width, height);
}


- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [[actionSheet layer] setBackgroundColor:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1].CGColor];
}

# pragma mark GKImagePicker Delegate Methods
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    
    NSLog(@"%s,before croppend image size is %@",__FUNCTION__,NSStringFromCGSize(image.size));
    
    if (image)
    {
        CGSize _size = [self getStandardLogoSize];
        if (image.size.width > _size.width || image.size.height > _size.height) {
            image= [ImageUtil scaledImage:image toSize:_size withQuality:kCGInterpolationMedium];
            //            image = [ImageUtil OriginImage:image scaleToSize:_size];
        }
        NSLog(@"%s,after croppend image size is %@",__FUNCTION__,NSStringFromCGSize(image.size));
        
        self.logoData = UIImageJPEGRepresentation(image, 0.5);
        
        
        [self uploadLogo];
        
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    }
    
    
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadLogo
{
    [[OpenCtxManager getManager] setPortrait:[UIImage imageWithData:self.logoData] completionHandler:^(int resultCode, NSString *resultMsg) {
        
        NSLog(@" %@", resultMsg);
        
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        
        _dataArray = nil;
        [self.tableView reloadData];
    }];
}

- (void)getEmpInfo
{
    //    如果还没有获取用户资料，又要求显示全部资料，那么先去获取资料
    PermissionModel *permission = self.emp.permission;
    NSLog(@"%d - %d",!self.emp.info_flag,!permission.isHidePartInfo);
    if (!self.emp.info_flag && !permission.isHidePartInfo)
    {
        NSLog(@"用户资料还没有获取，并且要求显示全部资料，所以需要从服务器端取数据");
        conn *_conn = [conn getConn];
        bool ret = [_conn getUserInfo:self.emp.emp_id];
        if(ret)
        {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"loading"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
        }
    }
}

-(void)handleCmd:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case get_user_info_success_new:
            {
                NSLog(@"get user info success new");
                
                NSString* empId = [_notification.info objectForKey:@"EMP_ID"];
                if (empId.intValue == self.emp.emp_id)
                {
                    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                    Emp *emp1 = [_ecloud getEmpInfo:empId];
                    self.emp = emp1;
                    self.dataArray = nil;
                    [self refreshData];
                }
            }
                break;
            case get_user_info_timeout_new:
            {
                NSLog(@"get user info timeout new ");
                
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_timeout"]];
            }
                break;
                
            case get_user_info_failure_new:
            {
                NSLog(@"get user info failure new ");
                [self showAlert:[StringUtil getLocalizableString:@"personinfo_get_user_info_fail"]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)showAlert:(NSString *)message
{
    [UserTipsUtil showAlert:message];
}

- (void)showAlert:(NSString *)message autoDimiss:(BOOL)autoDimiss
{
    [UserTipsUtil showAlert:message autoDimiss:autoDimiss];
}

- (void)refreshData
{
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count ; //+ (self.isCurUser?1:0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==self.dataArray.count) {
        return 1;
    }
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.isCurUser)
        {
            XINHUAUserInfoCellArc *cell = [tableView dequeueReusableCellWithIdentifier:userInfoLogoCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.logoDelegate = self;
            
            NSArray *arr = self.dataArray[0];
            cell.dic = arr[indexPath.row];
            
            return cell;
        }
        else
        {
            XINHUAEmpInfoCellArc *cell = [tableView dequeueReusableCellWithIdentifier:XINHUAEmpInfoCellArcID];
            
            NSArray *arr = self.dataArray[0];
            Emp *emp = arr[indexPath.row];
            cell.emp = emp;
            
            return cell;
        }
    }
    else if (indexPath.section < self.dataArray.count)
    {
        XINHUAUserInfoCellArc *cell = [tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
        
        NSArray *arr = self.dataArray[indexPath.section];
        cell.dic = arr[indexPath.row];
        
        return cell;
    }
    else
    {
        
        static NSString *logoutCellIdentifier = @"logoutCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:logoutCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logoutCellIdentifier];
            if (_isCurUser)
            {
                UILabel *logoutLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-120)/2, 12, 120, 26)];
                logoutLabel.textColor = [UIColor redColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                logoutLabel.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:logoutLabel];
                
                logoutLabel.text = [StringUtil getAppLocalizableString:@"logout"];
            }
        }
        
        return cell;
        
    }
    
    
    return nil;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isCurUser && indexPath.section == 0)
    {
        return 76;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!self.isCurUser && section == self.dataArray.count-1)
    {
        return 45;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    
    if (!self.isCurUser && section == self.dataArray.count-1)
    {
        UIButton *sendMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendMessageBtn setTitle:[StringUtil getAppLocalizableString:@"send_message"] forState:UIControlStateNormal];
        sendMessageBtn.layer.cornerRadius = 5;
        sendMessageBtn.clipsToBounds = YES;
        [sendMessageBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        sendMessageBtn.backgroundColor = [UIColor colorWithRed:29/255.0 green:113/255.0 blue:183/255.0 alpha:1];
        sendMessageBtn.frame =  CGRectMake(SCREEN_WIDTH/8.0, 18, SCREEN_WIDTH*(3.0/4.0), 45);
        [view addSubview:sendMessageBtn];
    }
    
    return view;
}

- (void)sendMessage
{
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = singleType;
    talkSession.titleStr = self.emp.emp_name;
    talkSession.needUpdateTag = 1;
    talkSession.convId = [NSString stringWithFormat:@"%d",self.emp.emp_id];
    talkSession.convEmps = [NSArray arrayWithObject:self.emp];
    
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWORG object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.isCurUser)
        {
            [self presentSheet];
        }
        else
        {
            [self showbigimage];
        }
    }
    else if (indexPath.section == self.dataArray.count)
    {
        [self logoutIfPermission];
    }
}

- (void)logoutIfPermission
{
    conn *_conn = [conn getConn];
    
    NSString *temp = @"";
    if(_conn.connStatus == linking_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_connecting_server"];
    }
    else if(_conn.connStatus == rcv_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_receiving_messages"];
    }
    else if(_conn.connStatus == download_org)
    {
        temp = [StringUtil getLocalizableString:@"settings_loading_organizational_structure"];
    }
    else if(_conn.downLoadImageStatus == download_guide)
    {
        temp = [StringUtil getLocalizableString:@"settings_download_guide"];
    }
    
    UIAlertView *tipAlert;
    if(temp.length > 0)
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        [tipAlert show];
        tipAlert = nil;
        return;
    }
    else
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [tipAlert show];
    }
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"退出登录");
        conn *_conn = [conn getConn];
        
        if(_conn.connStatus == normal_type)
        {
            [_conn logout:1];
            
            NSString *str =  [[ServerConfig shareServerConfig]getShareName];
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
            [sharedDefaults removeObjectForKey:@"isLogin"];
            
            [self exit];
        }
        else if(_conn.connStatus == not_connect_type)
        {
            [self exit];
        }
    }
}

-(void)exit
{
    [UserDefaults saveUserIsExit:YES];
    
    id tabbarVC = [TabbarUtil getTabbarController];
    if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
        id mainVC = ((GXViewController *)tabbarVC).delegate;
        [((mainViewController*)mainVC) backRoot];
    }
}

@end
