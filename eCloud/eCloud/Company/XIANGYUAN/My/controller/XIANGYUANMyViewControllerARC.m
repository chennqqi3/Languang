//
//  XIANGYUANMyViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANMyViewControllerARC.h"
#import "XIANGYUANMyCell.h"
#import "StringUtil.h"
#import "OpenNotificationDefine.h"
#import "IOSSystemDefine.h"
#import "ImageUtil.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "userInfoViewController.h"
#import "UserDefaults.h"
#import "GXViewController.h"
#import "mainViewController.h"
#import "ServerConfig.h"
#import "TabbarUtil.h"
#import "settingViewController.h"
#import "FileAssistantViewController.h"
#import "personInfoViewController.h"
#import "CollectionController.h"
#import "SettingItem.h"
#import "NewOrgViewController.h"
#import "OfficeMeHeadView.h"
#import "GKImagePicker.h"
#import "UserDisplayUtil.h"
#import "LCLLoadingView.h"
#import "eCloudUser.h"
#import "ASIFormDataRequest.h"
#import "PersonInformationViewController.h"
#import "XIANGYUANAgentViewControllerARC.h"

@interface XIANGYUANMyViewControllerARC ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GKImagePickerDelegate>

@property(nonatomic,strong)UITableView *personalTableView;
@property(nonatomic,strong)OfficeMeHeadView *tableheaderView;
//@property(nonatomic,strong)NSMutableArray *dataSource;
@property(retain,nonatomic) Emp *emp;
@property (nonatomic,retain) GKImagePicker *imagePicker;
@property (nonatomic,retain) NSData *LogoData;
@property (nonatomic,assign) int newLogoTimestamp;

@property(assign)id delegete;
@end

@implementation XIANGYUANMyViewControllerARC
{
    NSMutableArray *_settingArray;
    NSMutableArray *_imageArray;
    conn *_conn;
    eCloudDAO *db;
    
    UIAlertView *tipAlert;
    bool isExit;
    int startTime;
    ASIFormDataRequest *_request;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        _settingArray = [NSMutableArray array];
        _imageArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"我";
    //    self.title = [StringUtil getAppLocalizableString:@"main_settings"];
    
    //    [_personalTableView reloadData];
    // 从个人信息回到"我的"界面tabbar会隐藏
    //[UIAdapterUtil showTabar:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:@"文件",@"收藏",@"设置", nil];
//    NSMutableArray *array1 = [[NSMutableArray alloc] initWithObjects:@"设置", nil];
//    NSMutableArray *imageArray = [[NSMutableArray alloc] initWithObjects:@"icon_file_assistant.png",@"icon_ collection.png",@"icon_setup.png", nil];
//    NSMutableArray *imageArray1 = [[NSMutableArray alloc] initWithObjects:@"icon_setup.png", nil];
//    [_settingArray addObject:array];
//    [_settingArray addObject:array1];
//    [_imageArray addObject:imageArray];
//    [_imageArray addObject:imageArray1];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    

    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    SettingItem *_item = nil;
    
    //NSMutableArray *arr1 = [NSMutableArray array];

    
    NSMutableArray *arr2 = [NSMutableArray array];
    
    _item = [[SettingItem alloc]init];
    [arr2 addObject:_item];
    
    //    登录用户资料
//    _item = [[SettingItem alloc]init];
//    _item.itemName = [StringUtil getLocalizableString:@"111"];
//    _item.clickSelector = @selector(openUserInfo);
//    [arr2 addObject:_item];
    
    //    文件
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"文件"];
    _item.imageName = @"icon_file_assistant.png";
    _item.clickSelector = @selector(openFileAssistant);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [arr2 addObject:_item];

    //    收藏
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"收藏"];
    _item.imageName = @"icon_ collection.png";
    _item.clickSelector = @selector(openCollection);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [arr2 addObject:_item];
    
    //    设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"设置"];
    _item.imageName = @"icon_setup.png";
    _item.clickSelector = @selector(openSetting);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [arr2 addObject:_item];
    

    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"重置密码"];
    _item.imageName = @"icon_pass.png";
    _item.clickSelector = @selector(openPass);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [arr2 addObject:_item];
    
    _item = [[SettingItem alloc]init];
    [arr2 addObject:_item];

    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"退出登录"];
    _item.clickSelector = @selector(exitAction);
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    [arr2 addObject:_item];
    
//    [mArr addObject:arr1];
    [mArr addObject:arr2];
//    [mArr addObject:arr3];

    _settingArray  = [mArr copy];
    
    _personalTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    [self.view addSubview:_personalTableView];
    _personalTableView.delegate=self;
    _personalTableView.dataSource=self;
    _personalTableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    _personalTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.tableheaderView = [OfficeMeHeadView loadFromXib];
    self.tableheaderView.headImageView.image = [self headTangential];
    self.tableheaderView.headImageView.userInteractionEnabled = YES;
    self.emp = [db getEmpInfo:_conn.userId];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(presentSheet)];
    [self.tableheaderView.headImageView addGestureRecognizer:singleTap];
    
    [self.tableheaderView loadViewWithHeadImage:nil name:self.emp.emp_name position:self.emp.titleName apartment:self.emp.deptName loginName:self.emp.empCode];
    
    [UIAdapterUtil setPropertyOfTableView:_personalTableView];
    
    self.tableheaderView.personInfomationBlock = ^(void){
        
        PersonInformationViewController *preson = [[PersonInformationViewController alloc]init];
        [self.navigationController pushViewController:preson animated:YES];
        
    };
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];
    
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    view.tintColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    
}

#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //分组数 也就是section数
    return _settingArray.count;
}
//设置每个分组下tableview的行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _settingArray[section];
    return arr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.tableheaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return self.tableheaderView.frame.size.height;
    
}

//每个分组下边预留的空白高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == (_settingArray.count-2))
//    {
//        return 12;
//    }
//    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 17;
    }else if (indexPath.row ==5){
        
        return 100;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [_personalTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    NSArray *arr = _settingArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if (indexPath.row == 0) {
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.contentView.alpha = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
        
    }
    else if (indexPath.row==5) {

        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.contentView.alpha = 0;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
        
    }else if(indexPath.row ==6){
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = item.itemName;
        return cell;
    }
    else{
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = item.itemName ? item.itemName : @"";
        cell.imageView.image = [StringUtil getImageByResName:item.imageName];
        
        return cell;
    }
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = _settingArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    if (indexPath.row !=5) {
        [UIAdapterUtil hideTabBar:self];
    }
    
    [self performSelector:item.clickSelector withObject:nil];
}

- (void)openUserInfo
{
    [NewOrgViewController openUserInfoById:[conn getConn].userId andCurController:self];
}

- (void)openFileAssistant
{
    FileAssistantViewController *fileVC=[[FileAssistantViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (void)openCollection
{
    CollectionController *collectCtl = [[CollectionController alloc] init];
    [self.navigationController pushViewController:collectCtl animated:YES];
    [UIAdapterUtil hideTabBar:self];
}

- (void)openSetting
{
    settingViewController *settingVC = [[settingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)openPass
{
    XIANGYUANAgentViewControllerARC *agent = [[XIANGYUANAgentViewControllerARC alloc]init];
    NSString *urlStr = [[ServerConfig shareServerConfig]getXYpassWordUrl];
    agent.urlstr = [NSString stringWithFormat:@"%@?usercode=%@",urlStr,[UserDefaults getUserAccount]];
    [self.navigationController pushViewController:agent animated:YES];
    
}
- (void)Picture{
    
    [_personalTableView reloadData];
}
- (UITableViewCell *)getUserInfoCell
{
    
    self.emp = [db getEmpInfo:_conn.userId];
    
    XIANGYUANMyCell *mCell = [[XIANGYUANMyCell alloc] init];
    mCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    mCell.homeDay.text = self.emp.emp_name;
    mCell.homeImageView.image = [self headTangential];
    mCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return mCell;
}

#pragma mark - 获取头像
- (UIImage *)headTangential
{
    self.emp = [db getEmpInfo:_conn.userId];
    UIImage *image = [ImageUtil getOnlineEmpLogo:self.emp];;
    return image;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
    _settingArray = nil;
    //    [_settingArray removeAllObjects];
    
}
-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
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

//从相册选择图片
- (IBAction) selectExistingPicture {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
        if (headerSize.width != headerSize.height)
        {
            self.imagePicker = [[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            self.imagePicker.cropSize = [self getStandardLogoSize];
            self.imagePicker.delegate = self;
            //        [self.view.window.rootViewController presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
            [UIAdapterUtil presentVC:self.imagePicker.imagePickerController];
            //            [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
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
        
        self.LogoData = UIImageJPEGRepresentation(image, 0.5);
        
        
        [self uploadLogo];
        
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    }
    
    
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 退出逻辑
- (void)exitAction{
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
    
    if(temp.length > 0)
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        [tipAlert show];
        tipAlert = nil;
        return;
    }
    
    else {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [tipAlert show];
    }
}

//相机拍摄图片
-(IBAction) getCameraPicture {
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

////确定获得图片（相机拍摄或从相册选择）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //	头像统一成176，缩略图是60
    CGSize _size = [self getStandardLogoSize];
    if (image.size.width > _size.width || image.size.height > _size.height) {
        image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationMedium];
    }
    
    self.LogoData = UIImageJPEGRepresentation(image, 0.5);
    [self uploadLogo];
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
    
    [picker dismissModalViewControllerAnimated:YES];
    
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

-(void)uploadLogo
{
    //    万达 新的头像时间戳
    self.newLogoTimestamp = [_conn getCurrentTime];
    startTime = [_conn getCurrentTime];
    
    NSURL *uploadUrl = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getWandaLogoUploadUrlWithNewTimestamp:self.newLogoTimestamp]];
    
    [LogUtil debug:[NSString stringWithFormat:@"更新用户头像，时间戳%d  新头像大小是%@ \r uploadURL is %@",self.newLogoTimestamp,[StringUtil getDisplayFileSize:self.LogoData.length],[uploadUrl absoluteString]]];
    
    _request = [ASIFormDataRequest requestWithURL:uploadUrl];
    
    //    只需要把头像数据传给服务器端即可
    [_request appendPostData:self.LogoData];

    [_request setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [_request setNumberOfTimesToRetryOnTimeout:3];
    _request.shouldContinueWhenAppEntersBackground = YES;
    
    //    [request setTimeOutSeconds:15];
    [_request setDelegate:self];
    [_request setUploadProgressDelegate:self];
    _request.showAccurateProgress=YES;
    //    [request setDidFinishSelector:@selector(requestCommitDone:)];
    //	[request setDidFailSelector:@selector(requestCommitWrong:)];
    [_request startAsynchronous];
}

- (void)exit{
    [UserDefaults saveUserIsExit:YES];
    
    if (self.delegete && [self.delegete isKindOfClass:[mainViewController class]]) {
        [( (mainViewController*)self.delegete)backRoot];
    }else{
        id tabbarVC = [TabbarUtil getTabbarController];
        if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
            id mainVC = ((GXViewController *)tabbarVC).delegate;
            [((mainViewController*)mainVC) backRoot];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==tipAlert)
    {
        if (buttonIndex==1)
        {
           	if(_conn.connStatus == normal_type)
            {
                isExit = true;
                
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
}

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
    eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
    
    switch (cmd.cmdId)
    {
            
        case modify_userinfo_success:
        {
            NSString *userId = [StringUtil getStringValue:self.emp.emp_id];
            
            NSString *newTimestamp = [StringUtil getStringValue:self.newLogoTimestamp];
            
            [db updateUserAvatar:newTimestamp :self.emp.emp_id];
            
            self.emp.emp_logo = newTimestamp;
            
            [StringUtil deleteUserLogoIfExist:userId];
            
            UIImage *curImage = [UIImage imageWithData:self.LogoData];
            
            [StringUtil createAndSaveMicroLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            [StringUtil createAndSaveSmallLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            //			保存大头像，否则会去下载
            NSString *picpath = [StringUtil getBigLogoFilePathBy:userId andLogo:newTimestamp];
            [self.LogoData writeToFile:picpath atomically:YES];
            
            
            //        保存头像的时间戳
            _conn.newCurUserLogoUpdateTime = self.newLogoTimestamp;
            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
            
            [_personalTableView reloadData];
            
            //            发出通知 把用户id 用户头像 发出去
            [StringUtil sendUserlogoChangeNotification:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"emp_id",newTimestamp,@"emp_logo", nil]];
            
            self.tableheaderView.headImageView.image = [self headTangential];
        }
            break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_upload_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            
        }
            break;
        case cmd_timeout:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"usual_communication_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
}

-(void)setProgress:(float)newProgress
{
    if (newProgress == 1)
    {
        NSNotification * notice = [NSNotification notificationWithName:@"ModifyThePicture" object:nil userInfo:nil];
        //发送消息
        [[NSNotificationCenter defaultCenter]postNotification:notice];
        if(![[conn getConn]modifyUserInfo:15 andNewValue:[StringUtil getStringValue:self.newLogoTimestamp]])
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_request_failed"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            [alert show];
        }
        
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    NSLog(@"progress %f", newProgress);
}

//从网络返回数据成功
- (void)requestCommitDone:(ASIHTTPRequest *)request
{
    int endTime = [_conn getCurrentTime];
    NSString *responseStr = request.responseString;
    [LogUtil debug:[NSString stringWithFormat:@"%s,response is %@ 需要时间%d",__FUNCTION__,responseStr,(endTime - startTime)]];
    
    //    如果应答信息中包含了success字样，则表示设置成功
    if (request.responseStatusCode == 200 && [responseStr rangeOfString:@"success"].length > 0)
    {
        //        [NSThread sleepForTimeInterval:2];
        //        需要告诉服务器头像变了，把新的时间戳告诉服务器
        //        self.newLogoTimestamp = self.newLogoTimestamp - 5;
        //头像上传成功，发送通知，通知办公页面刷新头像
        //创建一个消息对象
        NSNotification * notice = [NSNotification notificationWithName:@"ModifyThePicture" object:nil userInfo:nil];
        //发送消息
        [[NSNotificationCenter defaultCenter]postNotification:notice];
        if(![[conn getConn]modifyUserInfo:15 andNewValue:[StringUtil getStringValue:self.newLogoTimestamp]])
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_request_failed"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        //        代表修改失败了
        [self requestCommitWrong:request];
    }
}

//从网络返回数据失败
- (void)requestCommitWrong:(ASIHTTPRequest *)request {
    
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
    NSError *error = [request error];
    [LogUtil debug:[NSString stringWithFormat:@"%@ 需要时间 %d " , error.localizedDescription,[_conn getCurrentTime] - startTime]];
    
    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_upload_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
    [alertView show];

}

//从网络返回数据成功
- (void)requestCommitDownloadDone:(ASIHTTPRequest *)request {

    UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
//    [selectView setImage:[UIImage createRoundedRectImage:img size:CGSizeMake(user_info_logo_size, user_info_logo_size)] forState:UIControlStateNormal];
    NSString *str = [request responseString];
    NSLog(@"--requestCommitDownloadDone----response－－－ %@   " , str);
    
}

//从网络返回数据失败
- (void)requestCommitDownloadWrong:(ASIHTTPRequest *)request {
    
    NSError *error = [request error];
    NSLog(@"%@" , error.localizedDescription);
    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_download_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
    [alertView show];

}
@end
