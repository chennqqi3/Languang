//
//  userInfoViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "userInfoViewController.h"
#import "NotificationDefine.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "eCloudDefine.h"
#import "LogUtil.h"
#import "eCloudNotification.h"

#import "modifySignatureViewController.h"
#import "modifyPositionViewController.h"
#import "Emp.h"
#import "UserInfo.h"
#import "UIRoundedRectImage.h"
#import "conn.h"
#import "FGalleryViewController.h"

#import "GKImagePicker.h"
#import "SettingItem.h"
#import "settingViewController.h"
#import "conn.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"
#import "ASIFormDataRequest.h"
#import "LCLLoadingView.h"
#import "ImageUtil.h"
#import "UIAdapterUtil.h"
#import "myCell.h"
#import "modifyTelephoneViewController.h"
#import "modifyMailViewController.h"
#import "VerticallyAlignedLabel.h"
#import "modifySexViewController.h"

#ifdef _TAIHE_FLAG_
#import "modifyAddressViewController.h"
#endif

#import "UserDefaults.h"

#import "UserDisplayUtil.h"

#import "eCloudConfig.h"
#import "NewMyViewControllerOfCustomTableview.h"

#ifdef _XIANGYUAN_FLAG_
#import "WaterMarkViewARC.h"
#endif

#define row_height 45.0

#define TITLE_LABEL_X (12)
#define TITLE_LABEL_WIDTH (63)
#define VALUE_LABEL_WIDTH (SCREEN_WIDTH - TITLE_LABEL_X - TITLE_LABEL_WIDTH - 12)


@interface userInfoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,FGalleryViewControllerDelegate,GKImagePickerDelegate>
{
    ASIFormDataRequest *_request;
    
    UITableView*   personTable;
    
    int tagType;
    Emp *emp;
    
    NSString *response;
    UIButton *selectView;
    UIImageView *bigImageView;
    NSString *filePath;
    //    UIImagePickerController *imagePicker;
    
    conn *_conn;
    //预览图片
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
    NSString *preImageFullPath;
}

@property(nonatomic,retain)  NSString *preImageFullPath;
@property (nonatomic,retain) NSData *newLogoData;
@property (nonatomic,assign) int newLogoTimestamp;
@property (nonatomic,retain) GKImagePicker *imagePicker;
@end

@implementation userInfoViewController
{
	eCloudDAO *db;
    
    CGSize tempCellSize;
    CGSize deptCellSize;
    CGSize postCellSize;
    CGSize homeNumCellSize;
    CGSize addcellSize;
    CGSize emailCellSize;
    
    
    //    数据项数组
    NSMutableArray *settingItemArray;
    
    int startTime;
    UIButton *footButton;

}
@synthesize imagePicker;
@synthesize newLogoTimestamp;
@synthesize newLogoData;
@synthesize tagType;
@synthesize emp;
@synthesize userInfo;

@synthesize preImageFullPath;

-(void)dealloc
{
    [settingItemArray release];
    settingItemArray = nil;

    self.imagePicker = nil;
    self.newLogoData = nil;
    personTable =nil;
	self.userInfo = nil;
	self.preImageFullPath = nil;
	self.emp = nil;
	[super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

-(void)viewWillAppear:(BOOL)animated
{
//    因为通过拍照上传头像后，状态栏被隐藏了，所以在这里增加了显示状态栏
    [[UIApplication sharedApplication]setStatusBarHidden:NO];

    [UIAdapterUtil setStatusBar];
    
	if (self.tagType==1)
	{
        //		self.navigationController.navigationBarHidden = YES;
        [self hideTabBar];
	}
	else
	{
		self.navigationController.navigationBarHidden = NO;
        [self hideTabBar];
	}
    //   self.navigationController.view.backgroundColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
    
    NSString* userid=_conn.userId;
    self.userInfo= [[eCloudUser getDatabase] searchUserObjectByUserid:userid];
    self.emp= [db getEmpInfo:userid];
   
    if (self.emp)
    {
//        self.emp.titleName = @"xcode编程中iphone的文件读写 - 怕羊的老虎的日志 - 网易博客xcode编程中iphone的文件读写 - 怕羊的老虎的日志 - 网易博客";
//        self.emp.deptName = self.emp.titleName;
//        self.emp.emp_tel = self.emp.titleName;
//        self.emp.emp_mail = self.emp.titleName;
//        self.emp.empAddress = self.emp.titleName;
        
        
        postCellSize = [self configCellHeight:self.emp.titleName];
        
//        NSLog(@"postCellSize is %@",NSStringFromCGSize(postCellSize));
//        self.emp.deptName
        deptCellSize = [self configCellHeight:self.emp.deptName];
//        NSLog(@"deptCellSize is %@",NSStringFromCGSize(deptCellSize));
        
        homeNumCellSize = [self configCellHeight:self.emp.emp_tel];
//        NSLog(@"homeNumCellSize is %@",NSStringFromCGSize(homeNumCellSize));

        emailCellSize = [self configCellHeight:self.emp.emp_mail];
//        NSLog(@"emailCellSize is %@",NSStringFromCGSize(emailCellSize));

        addcellSize = [self configCellHeight:self.emp.empAddress];
//        NSLog(@"addcellSize is %@",NSStringFromCGSize(addcellSize));

    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        
        [self prepareSettingTAIHEItems];
    }else{
        [self prepareSettingItems];
    }
    [personTable reloadData];
    
 	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    
    [footButton setTitle:[StringUtil getLocalizableString:@"personal_settings"] forState:UIControlStateNormal];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
    self.navigationItem.title = [StringUtil getLocalizableString:@"userInfo_userInfo"];
    
    if ([UIAdapterUtil isHongHuApp]) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

-(CGSize)configCellHeight:(NSString *)cellStr
{
    CGFloat tempFloat;
    if(cellStr.length>0)
    {

        tempCellSize = [cellStr sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(VALUE_LABEL_WIDTH, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
      
   
        if (tempCellSize.height < DEFAULT_ROW_HEIGHT) {
            
            if (tempCellSize.height > 30) {
                
                tempCellSize.height = tempCellSize.height +30;
            }else{
                
                tempCellSize.height = DEFAULT_ROW_HEIGHT;
            }
            
        }else
        {
            tempCellSize.height = tempCellSize.height +30;
        }
    }
    else
    {
        tempCellSize.height = DEFAULT_ROW_HEIGHT;
    }
    
    return tempCellSize;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
}

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
  	eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
    
	switch (cmd.cmdId)
	{
            
        case modify_userinfo_success:
        {
            NSString *userId = [StringUtil getStringValue:self.emp.emp_id];
            
            NSString *newTimestamp = [StringUtil getStringValue:self.newLogoTimestamp];
            
            [db updateUserAvatar:newTimestamp :self.emp.emp_id];
            
            self.emp.emp_logo = newTimestamp;
            
            [StringUtil deleteUserLogoIfExist:userId];
             
            UIImage *curImage = [UIImage imageWithData:self.newLogoData];
            
            [StringUtil createAndSaveMicroLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            [StringUtil createAndSaveSmallLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            //			保存大头像，否则会去下载
            NSString *picpath = [StringUtil getBigLogoFilePathBy:userId andLogo:newTimestamp];
            [self.newLogoData writeToFile:picpath atomically:YES];
            
            
            //        保存头像的时间戳
            _conn.newCurUserLogoUpdateTime = self.newLogoTimestamp;
            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];

            [personTable reloadData];
            
//            发出通知 把用户id 用户头像 发出去
            [StringUtil sendUserlogoChangeNotification:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"emp_id",newTimestamp,@"emp_logo", nil]];
        }
            break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_upload_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
            break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"usual_communication_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;
		default:
			break;
	}
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	db = [eCloudDAO getDatabase];
	
    // Do any additional setup after loading the view from its nib.
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
	int tableH = SCREEN_HEIGHT - 20 - 44;
	
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:personTable];
//    personTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundView = nil;
    personTable.backgroundColor=[UIColor clearColor];
    personTable.showsHorizontalScrollIndicator = NO;
    personTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:personTable];
    
    [personTable setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    
    [personTable release];

    
    _conn = [conn getConn];
  
    
}
//-(void)onClickImage{
//    if (self.tagType==1) {
//        bigImageView.frame=CGRectMake(230, 95, 0, 0);
//    }else
//    {
//        bigImageView.frame=CGRectMake(230, 50,0, 0);
//    }
//    //点击操作内容
//    bigImageView.hidden=YES;
//    
//    
//}
//-(void)modifySignature:(id)sender
//{
//    if (modifySignature==nil) {
//       modifySignature=[[modifySignatureViewController alloc]init];
//    }
//    modifySignature.emp_id=[NSString stringWithFormat:@"%d",self.userInfo.userId];
//    modifySignature.oldSignature = self.emp.signature;
//    modifySignature.modifyType=0;
//	[self.navigationController pushViewController:modifySignature animated:YES];
//    [self presentModalViewController:modifySignature animated:YES];
//}
/*
-(void)modifyAction:(id)sender
{
    
    
    if (modifyPassword==nil) {
        modifyPassword=[[modifyPasswordViewController alloc]init];
    }
    modifyPassword.oldPasswordRecord=self.userInfo.userPasswd;
    modifyPassword.userEmail=self.userInfo.userEmail;
	[self.navigationController pushViewController:modifyPassword animated:YES];
    //    [self presentModalViewController:modifyPassword animated:YES];
}
 */
-(void)editInfoAction:(id)sender
{
    NSLog(@"-------editInfoAction");
    
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//add by lyong  2012-6-19
#pragma  table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingItemArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSArray *_array = [settingItemArray objectAtIndex:section];
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row == 0) {
        return myCellHeight;
    }
//    else if((indexPath.section == 2 && indexPath.row ==1) || indexPath.section ==3)
//    {
//        return 55;
//    }
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    CGSize detailValueSize = _item.detailValueSize;
    if (detailValueSize.height) {
        return detailValueSize.height;
    }
    return DEFAULT_ROW_HEIGHT;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section= indexPath.section;
    
    if (section ==0 && indexPath.row == 0)
    {
        return [self getUserInfoCell];
    }
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];

        UILabel *tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(TITLE_LABEL_X, 0, TITLE_LABEL_WIDTH, DEFAULT_ROW_HEIGHT)];
        tipLabel.tag=1;
        tipLabel.backgroundColor=[UIColor clearColor];
        tipLabel.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1/1.0];
        tipLabel.font = [UIFont systemFontOfSize:17];
        [cell addSubview:tipLabel];
        [tipLabel release];
//        tipLabel.backgroundColor = [UIColor redColor];
        
        UILabel *tipDetailLabel=[[UILabel alloc]initWithFrame:CGRectMake(TITLE_LABEL_X + TITLE_LABEL_WIDTH, 0, VALUE_LABEL_WIDTH, DEFAULT_ROW_HEIGHT)];
//        tipDetailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipDetailLabel.tag=2;
//        tipDetailLabel.backgroundColor = [UIColor redColor];
//                tipDetailLabel.textColor=[UIColor grayColor];
        tipDetailLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        tipDetailLabel.font = [UIFont systemFontOfSize:17];
        tipDetailLabel.numberOfLines = 0;
        [cell addSubview:tipDetailLabel];
        [tipDetailLabel release];
//        tipDetailLabel.backgroundColor = [UIColor blueColor];
        
    }

    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    
    UILabel *tipLabel=(UILabel *)[cell viewWithTag:1];
    UILabel *tipDetailLabel=(UILabel *)[cell viewWithTag:2];
    
    tipLabel.text=_item.itemName;
    
    tipDetailLabel.text = _item.itemValue;

    if (indexPath.section == 2) {
        
        tipDetailLabel.textColor = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];

    }
    if (_item.detailValueSize.height) {
        CGRect _frame = tipDetailLabel.frame;
        
        if (_item.detailValueSize.width > VALUE_LABEL_WIDTH) {
            
            _frame.size.width = _item.detailValueSize.width + 30;
        }
        
        _frame.size.height = _item.detailValueSize.height;
        
        NSLog(@"%@ %@",_item.itemValue,NSStringFromCGSize(_item.detailValueSize));
        _frame.origin.y = 0;
        tipDetailLabel.frame = _frame;
     
    }

    if (_item.customCellSelector) {
        [self performSelector:_item.customCellSelector withObject:cell];
    }

    return cell;
}

//如果可以编辑 那么点击效果为灰色，并且有指示符
- (void)setEditStatusOfCell:(UITableViewCell *)cell
{
    if ([eCloudConfig getConfig].canModifyUserInfo && ![UIAdapterUtil isTAIHEApp]) {
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}


-(UITableViewCell *)getUserInfoCell
{
    myCell *mCell = [[myCell alloc] init];
    
    mCell.nameLable.text = self.emp.emp_name;
    
    mCell.deptLable.text = self.emp.empCode;
    
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:self.emp];
    mCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectAction:)];
    mCell.iconView.userInteractionEnabled =YES;
    [mCell.iconView addGestureRecognizer:recognizer];
    [recognizer release];
    
    CGSize size = [mCell.nameLable.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(VALUE_LABEL_WIDTH, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    mCell.nameLable.frame = CGRectMake(SCREEN_WIDTH /2 - size.width/2, 98, size.width, 22);
    
    NSString *imageStr = @"ic_contact_datum_ woman.png";
    if (self.emp.emp_sex == 1) {
        imageStr = @"ic_contact_datum_man.png";
    }
    mCell.sexView.image = [StringUtil getImageByResName:imageStr];
    mCell.sexView.frame = CGRectMake(mCell.nameLable.frame.origin.x + mCell.nameLable.frame.size.width + 8, mCell.nameLable.frame.origin.y +3, 16, 16);
    
    mCell.accessoryType = UITableViewCellAccessoryNone;
    
    return [mCell autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section == 0) return 0.01;
	
    return 12;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//	if(section == 2) return 18;
    return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0 && indexPath.row ==0)
    {
        
#ifdef _LANGUANG_FLAG_
      
        if ([UserDefaults getLanGuangModifyHead]) {
            
            [self presentSheet];
        }
#else
        
        [self presentSheet];
#endif
        
        return;
    }
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
}
    

-(void)selectAction:(id)sender
{
    
    [self presentSheet];
    return;
    
    NSString * picpath=[StringUtil getLogoFilePathBy:_conn.userId andLogo:self.emp.emp_logo];
    UIImage *img = [UIImage imageWithContentsOfFile:picpath];
    if (img==nil)
	{
		return;
	}
    self.navigationController.view.backgroundColor=[UIColor blackColor];
    localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    self.preImageFullPath=picpath;
    
    NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:_conn.userId andLogo:self.emp.emp_logo];
    NSLog(@"%@",bigLogoPath);
    if([[NSFileManager defaultManager]fileExistsAtPath:bigLogoPath])
    {
        self.preImageFullPath=bigLogoPath;
    }
    
    localGallery.imagePath=self.preImageFullPath;
    [self.navigationController pushViewController:localGallery animated:YES];
    [localGallery release];
    
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    printf("User Pressed Button %d\n", buttonIndex);
    if (buttonIndex==0) {//拍照
        [self getCameraPicture];
    }else if(buttonIndex==1)
    {
        [self selectExistingPicture];
    }
    
    [actionSheet release];
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

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [[actionSheet layer] setBackgroundColor:[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1].CGColor];
}

//update by shisp 因为万达的头像不是正方形，所以设置头像后裁剪框也要长方形，系统默认的是正方形，所以进行修改
////相机拍摄图片
//-(IBAction) getCameraPicture {
//	//判断是否支持摄像头
//	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chatBackground_warning"]
//														message: [StringUtil getLocalizableString:@"chatBackground_warning_message"]
//													   delegate:nil
//											  cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
//											  otherButtonTitles:nil];
//		[alert show];
//		[alert release];
//		
//		return;
//		
//	}
//	
//    imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    imagePicker.allowsEditing = YES;
//    
//	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//	[self presentModalViewController:imagePicker animated:YES];
//    [imagePicker release];
//}
//
//- (void)navigationController:(UINavigationController *)navigationController
//      willShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated
//{
//    if ([navigationController isKindOfClass:[UIImagePickerController class]])
//    {
//        [UIAdapterUtil setStatusBar];
//    }
//}
////从相册选择图片
//- (IBAction) selectExistingPicture {
//	
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        
//        imagePicker = [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.allowsEditing= YES;
//		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//		[self presentModalViewController:imagePicker animated:YES];
//        [imagePicker release];
//		
//	} else {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"访问图片库错误",@"")
//														message: NSLocalizedString(@"设备不支持图片库",@"")
//													   delegate:nil
//											  cancelButtonTitle: NSLocalizedString(@"确定",@"")
//											  otherButtonTitles:nil];
//		[alert show];
//		[alert release];
//	}
//}

#pragma mark -

-(void)uploadLogo
{
//    万达 新的头像时间戳
    self.newLogoTimestamp = [_conn getCurrentTime];
    startTime = [_conn getCurrentTime];
    
    NSURL *uploadUrl = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getWandaLogoUploadUrlWithNewTimestamp:self.newLogoTimestamp]];
    
    [LogUtil debug:[NSString stringWithFormat:@"更新用户头像，时间戳%d  新头像大小是%@ \r uploadURL is %@",self.newLogoTimestamp,[StringUtil getDisplayFileSize:self.newLogoData.length],[uploadUrl absoluteString]]];
    
    _request = [ASIFormDataRequest requestWithURL:uploadUrl];
    
//    只需要把头像数据传给服务器端即可
    [_request appendPostData:self.newLogoData];
//    [request setData:<#(NSData *)#> forKey:<#(NSString *)#>];
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
            [alert release];
        }
        
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    NSLog(@"progress %f", newProgress);
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

    self.newLogoData = UIImageJPEGRepresentation(image, 0.5);
    [self uploadLogo];
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
	
	[picker dismissModalViewControllerAnimated:YES];

}

#pragma mark –
#pragma mark Camera View Delegate Methods
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    // Was there an error?
//    if (error) {
//		// Show error message
//		
//    } else { // No errors
//		// Show message image successfully saved
//    }
//}
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissModalViewControllerAnimated:YES];
//}

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
            [alert release];
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
    [alertView release];
}

//从网络返回数据成功
- (void)requestCommitDownloadDone:(ASIHTTPRequest *)request {
    [response release];
    UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
    bigImageView.image=img;
    [selectView setImage:[UIImage createRoundedRectImage:img size:CGSizeMake(user_info_logo_size, user_info_logo_size)] forState:UIControlStateNormal];
    NSString *str = [request responseString];
    NSLog(@"--requestCommitDownloadDone----response－－－ %@   " , str);
    
}

//从网络返回数据失败
- (void)requestCommitDownloadWrong:(ASIHTTPRequest *)request {
    
    NSError *error = [request error];
	NSLog(@"%@" , error.localizedDescription);
    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"userInfo_download_fail"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
    [alertView show];
    [alertView release];
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

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    if( gallery == localGallery ) {
        caption = @"112 ";
    }
    else if( gallery == networkGallery ) {
        caption =@"343";
    }
	return @" ";
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return self.preImageFullPath;
}
- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return nil;
}
- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}
- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

#pragma mark ========裁剪图片 长方形===========

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
		[alert release];
		
		return;
		
	}
    CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
    
    if (headerSize.width != headerSize.height)
    {
    self.imagePicker = [[[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera]autorelease];
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
            [pickCtl release];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[GKImagePicker class]])
    {
        [UIAdapterUtil setStatusBar];
    }
}
//从相册选择图片
- (IBAction) selectExistingPicture {
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
       CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
        if (headerSize.width != headerSize.height)
        {
            self.imagePicker = [[[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary]autorelease];
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
		[alert release];
	}
}


# pragma mark -
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
        
        self.newLogoData = UIImageJPEGRepresentation(image, 0.5);
        
        
        [self uploadLogo];
        
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
    }

	
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)getStandardLogoSize
{
    return CGSizeMake([eCloudConfig getConfig].uploadUserLogoWidth.intValue, [eCloudConfig getConfig].uploadUserLogoHeight.intValue);
}

- (CGSize)getCropSize
{
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    float width = SCREEN_WIDTH;
    float height = (width * _size.height) / _size.width;
    return CGSizeMake(width, height);
}

#pragma mark ========准备设置项泰禾数组=========
- (void)prepareSettingTAIHEItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    //    性别
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"personInfo_sex"];
    NSString *sexStr = [StringUtil getLocalizableString:@"sex_female"];
    if (self.emp.emp_sex == 1) {
        sexStr = [StringUtil getLocalizableString:@"sex_male"];
    }
    _item.itemValue = sexStr;
    _item.customCellSelector = @selector(setEditStatusOfCell:);
    if ([eCloudConfig getConfig].canModifyUserInfo) {
        _item.clickSelector = @selector(modifySex);
    }
    
    [settingItemArray addObject:_item];
    [_item release];
    
    //    座机
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_tel"];
    _item.itemValue = self.emp.emp_tel;
    _item.detailValueSize = homeNumCellSize;
    _item.customCellSelector = @selector(setEditStatusOfCell:);
    if ([eCloudConfig getConfig].canModifyUserInfo) {
        _item.clickSelector = @selector(modifyTel);
    }
    [settingItemArray addObject:_item];
    [_item release];
    
    //    手机
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_mobile"];
    _item.itemValue = self.emp.emp_mobile;
    _item.customCellSelector = @selector(setEditStatusOfCell:);
    if ([eCloudConfig getConfig].canModifyUserInfo) {
        _item.clickSelector = @selector(modifyMobile);
    }
    [settingItemArray addObject:_item];
    [_item release];
    
    //    邮箱
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_email"];
    _item.itemValue = self.emp.emp_mail;
    _item.detailValueSize = emailCellSize;
    _item.customCellSelector = @selector(setEditStatusOfCell:);
    if ([eCloudConfig getConfig].canModifyUserInfo) {
        _item.clickSelector = @selector(modifyMail);
    }
    
    [settingItemArray addObject:_item];
    [_item release];
    
    //    职务
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_post"];
    _item.itemValue = self.emp.titleName;
    _item.detailValueSize = postCellSize;
    _item.customCellSelector = @selector(setEditStatusOfCell:);
    
    if ([eCloudConfig getConfig].canModifyUserInfo && ![UIAdapterUtil isTAIHEApp]) {
        _item.clickSelector = @selector(modifyPosition);
    }
    
    [settingItemArray addObject:_item];
    [_item release];

    //    部门
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_dept"];
    _item.itemValue = self.emp.deptName;
    _item.detailValueSize = deptCellSize;
    [settingItemArray addObject:_item];
    [_item release];
    
    //   职责
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_work_duty"];
    _item.itemValue = self.emp.signature;
    
    if ([eCloudConfig getConfig].canModifyUserInfo && [UIAdapterUtil isTAIHEApp]) {
        _item.clickSelector = @selector(modifySignature);
    }
    
    [settingItemArray addObject:_item];
    [_item release];
    
    //    地址及邮编
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_address_and_zip_code"];
    _item.itemValue = self.emp.empAddress;
    _item.detailValueSize = addcellSize;
    if ([eCloudConfig getConfig].canModifyUserInfo) {
        _item.clickSelector = @selector(modifyAddress);
    }
    
    [settingItemArray addObject:_item];
    [_item release];
    
}
#pragma mark ========准备设置项数组=========
- (void)prepareSettingItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    

//    性别
//    _item = [[SettingItem alloc]init];
//    _item.itemName = [StringUtil getLocalizableString:@"personInfo_sex"];
//    NSString *sexStr = [StringUtil getLocalizableString:@"sex_female"];
//    if (self.emp.emp_sex == 1) {
//        sexStr = [StringUtil getLocalizableString:@"sex_male"];
//    }
//    _item.itemValue = sexStr;
//    _item.customCellSelector = @selector(setEditStatusOfCell:);
//    if ([eCloudConfig getConfig].canModifyUserInfo) {
//        _item.clickSelector = @selector(modifySex);
//    }
//    
//    [settingItemArray addObject:_item];
//    [_item release];
    
    NSMutableArray *arr1 = [NSMutableArray array];
    //    登录用户资料
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@""];
//    _item.clickSelector = @selector(openUserInfo);
    [arr1 addObject:_item];
    
    NSMutableArray *arr2 = [NSMutableArray array];
//    职务
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_post"];
    _item.itemValue = self.emp.titleName;
    _item.detailValueSize = postCellSize;
    if ([eCloudConfig getConfig].canModifyUserInfo && ![UIAdapterUtil isTAIHEApp]) {
        _item.clickSelector = @selector(modifyPosition);
    }

    [arr2 addObject:_item];
    [_item release];
    
    
    //    部门
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_dept"];
    _item.itemValue = self.emp.deptName;
    _item.detailValueSize = deptCellSize;
    [arr2 addObject:_item];
    [_item release];
    
    
    NSMutableArray *arr3 = [NSMutableArray array];
    
    
    //    手机
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_mobile"];
    _item.itemValue = self.emp.emp_mobile;
    _item.clickSelector = @selector(modifyMobile);
    
    [arr3 addObject:_item];
    [_item release];
    
    
    
    //    座机
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_tel"];
    _item.itemValue = self.emp.emp_tel;
    _item.detailValueSize = homeNumCellSize;
    _item.clickSelector = @selector(modifyTel);
    [arr3 addObject:_item];
    [_item release];
    
    
    //    传真
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_fax"];
    _item.itemValue = self.emp.empFax;
    _item.clickSelector = @selector(modifyFax);
    [arr3 addObject:_item];
    [_item release];
    
    
    //    邮箱
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"userInfo_email"];
    _item.itemValue = self.emp.emp_mail;
    _item.detailValueSize = emailCellSize;
    _item.clickSelector = @selector(modifyMail);
    [arr3 addObject:_item];
    [_item release];
    
    [settingItemArray addObject:arr1];
    [settingItemArray addObject:arr2];
    [settingItemArray addObject:arr3];
}

//修改性别
- (void)modifySex
{
    modifySexViewController *viewController=[[modifySexViewController alloc]init];
    viewController.emp_id = [StringUtil getStringValue:self.emp.emp_id];
    viewController.sextype = self.emp.emp_sex;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

//修改办公电话
- (void)modifyTel
{
//    modifyTelephoneViewController *modifyTelephone=[[modifyTelephoneViewController alloc]init];
//    
//    modifyTelephone.emp_id=[NSString stringWithFormat:@"%d",self.userInfo.userId];
//    modifyTelephone.oldMobile = self.emp.emp_tel;
//    modifyTelephone.modifyType = 1;
//    [self.navigationController pushViewController:modifyTelephone animated:YES];
//    [modifyTelephone release];
    
    [self callPhone:self.emp.emp_tel];

}
//修改手机
- (void)modifyMobile
{
//    modifyTelephoneViewController *modifyTelephone=[[modifyTelephoneViewController alloc]init];
//    
//    modifyTelephone.emp_id=[NSString stringWithFormat:@"%d",self.userInfo.userId];
//    modifyTelephone.oldMobile = self.emp.emp_mobile;
//    modifyTelephone.modifyType = 0;
//    [self.navigationController pushViewController:modifyTelephone animated:YES];
//    [modifyTelephone release];
    
    [self callPhone:self.emp.emp_mobile];
    
}

- (void)modifyFax{
    
    [self callPhone:self.emp.empFax];
}

//修改邮箱
- (void)modifyMail
{
//    modifyMailViewController *modifyMail=[[modifyMailViewController alloc]init];
//    
//    modifyMail.emp_id=[NSString stringWithFormat:@"%d",self.userInfo.userId];
//    modifyMail.oldMail = self.emp.emp_mail;
//    modifyMail.title=[StringUtil getLocalizableString:@"email_title"];
//    
//    [self.navigationController pushViewController:modifyMail animated:YES];
//    [modifyMail release];
    
    if (self.emp.emp_mail.length) {
        
        [self sendEmail:self.emp.emp_mail];
    }
    
}

//修改地址
- (void)modifyAddress
{
#ifdef _TAIHE_FLAG_
    
    modifyAddressViewController *modifyAddress=[[modifyAddressViewController alloc]init];
    
    modifyAddress.emp_id=[NSString stringWithFormat:@"%d",self.userInfo.userId];
    modifyAddress.oldAddress = self.emp.empAddress;
    modifyAddress.title=[StringUtil getLocalizableString:@"address_title"];
    
    [self.navigationController pushViewController:modifyAddress animated:YES];
    [modifyAddress release];
#endif
}



//修改签名//泰禾为修改职责
- (void)modifySignature
{
    modifySignatureViewController *modifySignature=[[[modifySignatureViewController alloc]init]autorelease];
    modifySignature.emp_id=[NSString stringWithFormat:@"%d",self.emp.emp_id];
    modifySignature.oldSignature = self.emp.signature;
    modifySignature.modifyType=0;
    [self.navigationController pushViewController:modifySignature animated:YES];
}

//修改职务
- (void)modifyPosition
{
    modifyPositionViewController *vc = [[[modifyPositionViewController alloc]init]autorelease];
    vc.emp_id=[NSString stringWithFormat:@"%d",self.emp.emp_id];
    vc.oldPosition = self.emp.titleName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (SettingItem *)getSettingItemByIndexPath:(NSIndexPath *)indexPath
{
    int section=[indexPath section];
    int row = [indexPath row];
    
    NSArray *_array = [settingItemArray objectAtIndex:section];
    SettingItem *_item = [_array objectAtIndex:row];
    return _item;
}

- (void)EnterSettings{
    
    settingViewController *setting = [[settingViewController alloc]init];
    [self.navigationController pushViewController:setting animated:YES];
    [setting release];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = personTable.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    personTable.frame = _frame;
    
    [personTable reloadData];
}


- (void)callPhone:(NSString *)string{
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",string]]];
}

- (void)sendEmail:(NSString *)string{
    
    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    NSArray *toRecipients = @[string];
    [mailUrl appendFormat:@"mailto:%@", toRecipients[0]];
    
    NSString *emailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath]];
}
@end;

@implementation UIImagePickerController (LandScapeImagePicker)
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
     if ([UIAdapterUtil isLandscap])
         return UIInterfaceOrientationMaskLandscape;
    return UIInterfaceOrientationPortrait;
}
@end
