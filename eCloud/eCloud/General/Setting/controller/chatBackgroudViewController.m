//
//  chatBackgroudViewController.m
//  eCloud
//
//  Created by  lyong on 14-6-25.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "chatBackgroudViewController.h"
#import "ChatBackgroundUtil.h"

#import "StringUtil.h"
#import "talkSessionViewController.h"
#import "talkSessionUtil.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIAdapterUtil.h"
#import "ImageUtil.h"

#import "UserDefaults.h"

#import "chooseChatBackGroudViewController.h"

@interface chatBackgroudViewController ()
{
    UITableView *settingTable;
    UIImagePickerController *imagePicker;
    chooseChatBackGroudViewController *chooseChatBackGroud;
    NSString *one_chat_imagename;
    //预览图片
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
}

@property(nonatomic,retain)NSString *preImageFullPath;

@end

@implementation chatBackgroudViewController
@synthesize one_chat_imagename;
@synthesize preImageFullPath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
 }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIAdapterUtil setStatusBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    self.title=[StringUtil getLocalizableString:@"chatBackground_title"];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    settingTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44 - 48) style:UITableViewStyleGrouped];
    [settingTable setDelegate:self];
    [settingTable setDataSource:self];
    settingTable.showsHorizontalScrollIndicator = NO;
    settingTable.showsVerticalScrollIndicator = NO;
    settingTable.backgroundView = nil;
    settingTable.backgroundColor=[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
    settingTable.backgroundColor=[UIColor clearColor];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:settingTable];
    settingTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:settingTable];
    [settingTable release];
    
    [UIAdapterUtil setPropertyOfTableView:settingTable];
}
//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section ==0) {
        
        return 1;
    }else{
        
        return 2;
    }
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	   
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        UILabel *blacklabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 0, 200, 51)];
        blacklabel.tag=1;
        blacklabel.backgroundColor=[UIColor clearColor];
        blacklabel.textColor=[UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        blacklabel.font=[UIFont systemFontOfSize:17];
        [cell.contentView addSubview:blacklabel];
        [blacklabel release];
	}
    UILabel *blacklabel=(UILabel *)[cell.contentView viewWithTag:1];
    if (indexPath.section==0) {
         blacklabel.text=[StringUtil getLocalizableString:@"chatBackground_choose"];
    }else if (indexPath.section==1 && indexPath.row ==0) {
        blacklabel.text=[StringUtil getLocalizableString:@"chatBackground_choose_photos"];
    }else if (indexPath.section==1 && indexPath.row ==1) {
        blacklabel.text=[StringUtil getLocalizableString:@"chatBackground_take_photo"];
    }
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:settingTable withOriginX:blacklabel.frame.origin.x];
    cell.accessoryType	=	UITableViewCellAccessoryDisclosureIndicator;
    [UIAdapterUtil customSelectBackgroundOfCell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        
        chooseChatBackGroud=[[chooseChatBackGroudViewController alloc]init];
       
        chooseChatBackGroud.title=[StringUtil getLocalizableString:@"chatBackground_choose"];
        chooseChatBackGroud.one_chat_imagename=self.one_chat_imagename;
        [self.navigationController pushViewController:chooseChatBackGroud animated:YES];
        [chooseChatBackGroud release];
        
    }else if(indexPath.section==1 && indexPath.row ==0)
    {
        [self selectExistingPicture];
    }else if(indexPath.section==1 && indexPath.row ==1)
    {
        [self getCameraPicture];
      
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
		[alert release];
		
		return;
		
	}
	
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    //imagePicker.allowsEditing = YES;

	imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [UIAdapterUtil presentVC:imagePicker];
//	[self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        [UIAdapterUtil setStatusBar];
    }
}

//从相册选择图片
- (IBAction) selectExistingPicture {
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
       
		//启动相册界面
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //imagePicker.allowsEditing= YES;
       
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
        [UIAdapterUtil presentVC:imagePicker];
        imagePicker.navigationBar.tintColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
//		[self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
        
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
        if(_size.width > 0 && _size.height > 0)
        {
            image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
        }
//        
//        float rate=image.size.height/image.size.width;
//        float height=320*rate;
//        CGSize size = CGSizeMake(320, height);
//        image= [ImageUtil scaledImage:image  toSize:size withQuality:kCGInterpolationMedium];
        
        NSData* data =UIImageJPEGRepresentation(image, 0.5);
        
        ////存入本地
        NSString *picpath = [ChatBackgroundUtil getCommonBackgroundPath];
        if (self.one_chat_imagename.length>0) {
            picpath = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:self.one_chat_imagename];
        }
        if (data!=nil)
        {
            BOOL success= [data writeToFile:picpath atomically:YES];
            if (!success) {
                [pool release];
                return;
            }
            [pool release];
            
            NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
            [accountDefaults setBool:YES forKey:@"is_chat_backgroud_change"];
        }
        
        if (self.one_chat_imagename.length>0) {
            
            //从拍照中选择聊天背景时，把和会话对应的背景对应的value设置为-1 否则还是显示为某一个被选中
            [UserDefaults setConvBackgroundSelected:[[talkSessionViewController getTalkSession] getConvid] andSelectTag:-1];

            for(UIViewController *controller in self.navigationController.viewControllers)
            {
                if([controller isKindOfClass:[talkSessionViewController class]])
                {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
        else
        {
            //从拍照中选择聊天背景时，把和默认背景对应的value设置为-1 否则还是显示为某一个被选中
            [UserDefaults setBackgroundSelected:-1];
        }
        
        [picker dismissModalViewControllerAnimated:YES];
        
    }else//相册选择
    {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
        UIImage *newimage=nil;
        if(_size.width > 0 && _size.height > 0)
        {
            newimage= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
        }
        if (newimage==nil) {
            newimage=image;
        }
        NSData* data =UIImageJPEGRepresentation(newimage, 0.5);
        
        //存入本地
        NSString *picpath = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:@"TempChatBackground.jpg"];
        if (self.one_chat_imagename.length>0) {
            NSString *tempName=[NSString stringWithFormat:@"Temp%@",self.one_chat_imagename];
            picpath = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:tempName];
        }
        self.preImageFullPath=picpath;
        NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
        if (data!=nil) {
            
            BOOL success= [data writeToFile:picpath atomically:YES];
            if (!success) {
                [pool release];
                return;
            }
            
            [pool release];
            
            
        }
        localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        localGallery.one_chat_imagename=self.one_chat_imagename;
        localGallery.is_from_chatbackgroud=YES;
        localGallery.imagePath=self.preImageFullPath;
        localGallery.predelegete=self;
        [picker pushViewController:localGallery animated:YES];
        [localGallery release];
    }
        
}


-(void)backToTalkSession
{
    if (self.one_chat_imagename.length>0) {
        for(UIViewController *controller in self.navigationController.viewControllers)
        {
            if([controller isKindOfClass:[talkSessionViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}
#pragma mark –
#pragma mark Camera View Delegate Methods

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // Was there an error?
    if (error) {
		// Show error message
		
    } else { // No errors
		// Show message image successfully saved
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)preview_selected_image:(NSString *)picpath
{
    self.navigationController.view.backgroundColor=[UIColor blackColor];
    localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
  //  self.preImageFullPath=picpath;
    
    
    localGallery.imagePath=self.preImageFullPath;
    [self.navigationController pushViewController:localGallery animated:YES];
    [localGallery release];
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

-(void)dealloc
{
    self.one_chat_imagename = nil;
    self.preImageFullPath = nil;
    settingTable = nil;
    [super dealloc];
}

@end
