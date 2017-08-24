//
//  LCLShareThumbController.m
//  PhotoSea
//
//  Created by  lyong on 13-5-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//

#import "LCLShareThumbController.h"

#import "PictureUtil.h"

#import "ELCAsset.h"
#import "talkSessionViewController.h"
#import "talkSessionUtil.h"
#import "KapokUploadViewController.h"
#import "UIAdapterUtil.h"
#import "LCLLoadingView.h"
#import "StringUtil.h"
#import "ImageUtil.h"

@interface LCLShareThumbController ()

@end

@implementation LCLShareThumbController
@synthesize relation;
@synthesize pre_delegete;
@synthesize receiverName = _receiverName;
@synthesize isForKapokFly;
@synthesize kapok_num;
- (void)dealloc
{
    [relation release];
    [selectedAssetsImages removeAllObjects];
    [selectedAssetsImages release];
    
    [selectedAssetsArray removeAllObjects];
    [selectedAssetsArray release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UploadPicFinished" object:nil];
    
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setToolbarHidden:NO];
    
    [UIAdapterUtil customToolBar:self.navigationController.toolbar];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	maxSelectedCount = 9;
    self.navigationItem.title	=	[StringUtil getLocalizableString:@"chats_talksession_message_photo_title"];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem=nil;
    
    if (!sendbutton) {
        sendbutton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-74, 8.0, 70.0, 30)];
        
        if ([UIAdapterUtil isGOMEApp]) {
            [sendbutton setBackgroundImage:nil forState:UIControlStateNormal];
            [sendbutton setTitleColor:GOME_TRA_BLUE_COLOR forState:UIControlStateDisabled];
            [sendbutton setTitleColor:GOME_BLUE_COLOR forState:UIControlStateNormal];
        }
//        [sendbutton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
//        [sendbutton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
        [sendbutton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_send"] forState:UIControlStateNormal];
        sendbutton.titleLabel.font=[UIFont boldSystemFontOfSize:[UIAdapterUtil isGOMEApp]?16:14];
        [sendbutton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.toolbar setTintColor:[UIColor blackColor]];
//        [self.navigationController.toolbar setTintColor:[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1]];
#ifdef _XIANGYUAN_FLAG_
        
        [sendbutton setBackgroundImage:[StringUtil getImageByResName:@"blue_button.png"] forState:UIControlStateNormal];
#else
        
#ifdef _LANGUANG_FLAG_
        
        [sendbutton setTitleColor: [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        sendbutton.titleLabel.font = [UIFont systemFontOfSize:15];
#else
        [sendbutton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
#endif
        
#endif
        [self.navigationController.toolbar addSubview:sendbutton];
        [sendbutton release];
    }
   
    
    if (!previewbutton) {
        //预览选择的文件
        previewbutton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 8.0, 54.0, 30)];
        [previewbutton setBackgroundImage:[StringUtil getImageByResName:@"blue_button.png"] forState:UIControlStateNormal];
        if ([UIAdapterUtil isGOMEApp]) {
            [previewbutton setBackgroundImage:nil forState:UIControlStateNormal];
            [previewbutton setTitleColor:GOME_BLUE_COLOR forState:UIControlStateSelected];
            [previewbutton setTitleColor:GOME_SUBTITLE_COLOR forState:UIControlStateNormal];
            UIImage *bgImage = [ImageUtil imageWithColor:GOME_BACKGROUND_COLOR];
            [self.navigationController.toolbar setBackgroundImage:bgImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
//        [previewbutton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
//        [previewbutton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
        [previewbutton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"] forState:UIControlStateNormal];
        previewbutton.titleLabel.font=[UIFont boldSystemFontOfSize:[UIAdapterUtil isGOMEApp]?16:14];
        [previewbutton addTarget:self action:@selector(clickOnPreviewbutton:) forControlEvents:UIControlEventTouchUpInside];
#ifdef _LANGUANG_FLAG_
        
        [previewbutton setBackgroundImage:nil forState:UIControlStateNormal];
        [previewbutton setTitleColor: [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0] forState:UIControlStateNormal];
        previewbutton.titleLabel.font = [UIFont systemFontOfSize:15];
        
#endif
        [self.navigationController.toolbar addSubview:previewbutton];
        [previewbutton release];
    }
    
    previewbutton.hidden = NO;
    
    NSInteger selectCount = [self totalSelectedAssets];
    if (selectCount) {
        [sendbutton setTitle:[NSString stringWithFormat:@"%@(%i)",[StringUtil getLocalizableString:@"chats_talksession_message_send"],[self totalSelectedAssets]] forState:UIControlStateNormal];
        previewbutton.enabled = YES;
        sendbutton.enabled = YES;
        if (self.isForKapokFly) {
            sendbutton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
          [sendbutton setTitle:[NSString stringWithFormat:@"确定(%i/%d)",[self totalSelectedAssets],self.kapok_num] forState:UIControlStateNormal];
        }
    }
    else{
      
        [sendbutton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_send"] forState:UIControlStateNormal];
        previewbutton.enabled = NO;
        sendbutton.enabled = NO;
        if (self.isForKapokFly) {
             sendbutton.titleLabel.font=[UIFont boldSystemFontOfSize:12];
            [sendbutton setTitle:[NSString stringWithFormat:@"确定(0/%d)",self.kapok_num] forState:UIControlStateNormal];
        }
    }
    
    //注册发送图片完成的消息中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPicFinished) name:@"UploadPicFinished" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    previewbutton.hidden = YES;
    sendbutton.enabled = YES;
    [super viewWillDisappear:animated];
}

#pragma mark - 注册发送图片完成的消息中心
- (void)uploadPicFinished{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
    
    if ([[[self.navigationController viewControllers] lastObject] isKindOfClass:[ELCImagePreViewViewController class]]) {
        ELCImagePreViewViewController *ctr = [[self.navigationController viewControllers] lastObject];
        [ctr.navigationController popViewControllerAnimated:NO];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 按钮方法实现
- (void)didSelectedAsset:(ELCAsset*)sender{
    if ([UIAdapterUtil isGOMEApp])
    {
        BOOL isSelected = ([self totalSelectedAssets]!=0);
        previewbutton.selected = isSelected;
    }
    NSInteger selectCount = [self totalSelectedAssets];
    if (self.isForKapokFly) {
        if (selectCount > self.kapok_num){
            [sender setSelected:NO];
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"你最多只能选择%i张照片",self.kapok_num] message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alert show];
            [alert release];
            return;
        }
    }
    if (selectCount && selectCount <= maxSelectedCount) {
        [sendbutton setTitle:[NSString stringWithFormat:@"%@(%i)",[StringUtil getLocalizableString:@"chats_talksession_message_send"],[self totalSelectedAssets]] forState:UIControlStateNormal];
        previewbutton.enabled = YES;
        sendbutton.enabled = YES;
        if (self.isForKapokFly) {
            [sendbutton setTitle:[NSString stringWithFormat:@"确定(%i/%d)",[self totalSelectedAssets],self.kapok_num] forState:UIControlStateNormal];
        }
    }
    else if (selectCount > maxSelectedCount){
        [sender setSelected:NO];
        
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"你最多只能选择%i张照片",maxSelectedCount] message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
        NSMutableString *maximum = [NSMutableString stringWithFormat:@"%@",[StringUtil getLocalizableString:@"chats_talksession_message_photo_maximum"]];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[maximum stringByReplacingOccurrencesOfString:@"%i" withString:[NSString stringWithFormat:@"%i",maxSelectedCount]] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"chats_talksession_message_photo_maximum_confirm"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return;
    }
    else{
        if ([self.navigationController.topViewController isKindOfClass:[LCLShareThumbController class]]) {
            eLCSelectedImagePreCtr = nil;
            eLCImagePreCtr = nil;
        }
        if (eLCSelectedImagePreCtr || eLCImagePreCtr) {
            //在预览页面
            [sendbutton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_send"] forState:UIControlStateNormal];
            previewbutton.enabled = NO;
            sendbutton.enabled = YES;
            if (self.isForKapokFly) {
                [sendbutton setTitle:[NSString stringWithFormat:@"确定(0/%d)",self.kapok_num] forState:UIControlStateNormal];
            }
        }
        else{
            //在列表页面
            [sendbutton setTitle:[StringUtil getLocalizableString:@"chats_talksession_message_send"] forState:UIControlStateNormal];
            previewbutton.enabled = NO;
            sendbutton.enabled = NO;
            if (self.isForKapokFly) {
                [sendbutton setTitle:[NSString stringWithFormat:@"确定(0/%d)",self.kapok_num] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 预览所有图片
- (void)didSelectedAssetDetail:(ELCAsset *)sender{
    isPreViewAllPhotoes = YES;
    NSInteger index = [self.elcAssets indexOfObject:sender];
    if (index < 0) {
        index = 0;
    }
    eLCImagePreCtr = [[ELCImagePreViewViewController alloc] initWithIndex:index];
    eLCImagePreCtr.photoSource = self;
    [self.navigationController pushViewController:eLCImagePreCtr animated:YES];
    [eLCImagePreCtr release];
}

#pragma mark - 预览图片
- (void)clickOnPreviewbutton:(id)sender{
    isPreViewAllPhotoes = NO;
    //提取预览图片
    if (!selectedAssetsArray) {
        selectedAssetsArray = [[NSMutableArray alloc] init];
    }
    
    if ([selectedAssetsArray count]) {
        [selectedAssetsArray removeAllObjects];
    }
    
    for(ELCAsset *elcAsset in self.elcAssets)
    {
        if([elcAsset selected])
        {
            [selectedAssetsArray addObject:elcAsset];
        }
    }
    
    eLCSelectedImagePreCtr = [[ELCImagePreViewViewController alloc] initWithIndex:0];
    eLCSelectedImagePreCtr.photoSource = self;
    [self.navigationController pushViewController:eLCSelectedImagePreCtr animated:YES];
    [eLCSelectedImagePreCtr release];
}

#pragma mark - 发送按钮
- (void)next:(id)sender
{
    if (!selectedAssetsImages) {
        selectedAssetsImages = [[NSMutableArray alloc] init];
    }
    
    if ([selectedAssetsImages count]) {
        [selectedAssetsImages removeAllObjects];
    }
    
    for(ELCAsset *elcAsset in self.elcAssets)
    {
        if([elcAsset selected])
        {
            [selectedAssetsImages addObject:[elcAsset asset]];
        }
    }
    
    if ([selectedAssetsImages count]==0) {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您还没选中任何图片" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        [alert release];
//        return;
        
        if (isPreViewAllPhotoes) {
            //预览所有大图
            if (eLCImagePreCtr) {
                [eLCImagePreCtr selectCurrentImage];
                
                for(ELCAsset *elcAsset in self.elcAssets)
                {
                    if([elcAsset selected])
                    {
                        [selectedAssetsImages addObject:[elcAsset asset]];
                    }
                }
            }
        }
        else{
            if (eLCSelectedImagePreCtr) {
                [eLCSelectedImagePreCtr selectCurrentImage];
                
                for(ELCAsset *elcAsset in self.elcAssets)
                {
                    if([elcAsset selected])
                    {
                        [selectedAssetsImages addObject:[elcAsset asset]];
                    }
                }
            }
        }
    }
    
    if ([self.pre_delegete isKindOfClass:[PictureUtil class]]) {
        [((PictureUtil *)self.pre_delegete) showSelectedPic:selectedAssetsImages];
        return;
    }
    
    if (self.isForKapokFly) {
        [((KapokUploadViewController *)self.pre_delegete) showSelectedPic:selectedAssetsImages];
        return;
    }
   [((talkSessionViewController *)self.pre_delegete) uploadManyPics:selectedAssetsImages];
    NSLog(@"-----------count---- %d",[selectedAssetsImages count]);
//    for (int i=0; i<[selectedAssetsImages count]; i++) {
//        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//        CGImageRef imageRef;
//        ALAsset *asset=[[selectedAssetsImages objectAtIndex:i] asset];
//        ALAssetRepresentation* rep = [asset defaultRepresentation];
//        imageRef = [rep fullScreenImage];
//        
//        if(imageRef)
//        {         
//            UIImage *image = [UIImage imageWithCGImage:imageRef];
//            CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
//            if(_size.width > 0 && _size.height > 0)
//            {
//                image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
//            }
//            NSData * data =UIImageJPEGRepresentation(image, 0.5);
//            NSLog(@"-----------------picdata--: %d",data.length);
//            [((talkSessionViewController *)self.pre_delegete) displayAndUploadPic:data];
//            
//        }
//        
//        [pool drain];
//    }
    
    //提示发送
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"chats_talksession_message_photo_sending"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
}

- (void)selectAll:(id)sender
{
	
}

- (void)invertSelect:(id)sender
{
	
}


#pragma mark - ELCImagePreViewViewControllerDelegate协议方法实现
- (NSInteger)numberOfPhotosForELCImagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController{
    if (isPreViewAllPhotoes) {
        return [self.elcAssets count];
    }
    else{
       return [selectedAssetsArray count]; 
    }
}

- (ELCAsset *)imagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController ELCAssetAtIndex:(NSInteger *)index{
    //return [[(ELCAsset*)[selectedAssetsArray objectAtIndex:index] asset] asset];
    if (isPreViewAllPhotoes) {
        ELCAsset *asset = (ELCAsset*)[self.elcAssets objectAtIndex:index];
        return  asset;
    }
    else{
        ELCAsset *asset = (ELCAsset*)[selectedAssetsArray objectAtIndex:index];
        return  asset;
    }
}

- (BOOL)imagePreViewViewController:(ELCImagePreViewViewController*)ELCImagePreViewViewController didSelectAtIndex:(NSInteger)index{
    NSLog(@"didSelectAtIndex---------%i",index);
   // toggleSelection
    if (isPreViewAllPhotoes) {
        ELCAsset *asset = (ELCAsset*)[self.elcAssets objectAtIndex:index];
        [asset initSubview];
        [asset toggleSelection];
        return [asset selected];
    }
    else{
        ELCAsset *asset = (ELCAsset*)[selectedAssetsArray objectAtIndex:index];
        [asset toggleSelection];
        return [asset selected];
    }
}


#pragma mark - ---------------
/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(2 != buttonIndex)
	{
		//**获取被选中的资源文件***
		NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
		
		for(ELCAsset *elcAsset in self.elcAssets)
		{
			if([elcAsset selected])
			{
				[selectedAssetsImages addObject:[elcAsset asset]];
			}
		}
		}
}
*/

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    sendbutton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-64, 8.0, 54.0, 30)];
    
    CGRect _frame;
    _frame = sendbutton.frame;
    if (_frame.origin.x == (SCREEN_WIDTH - 74)) {
        return;
    }
    _frame.origin.x = SCREEN_WIDTH - 74;
    sendbutton.frame = _frame;
    
}
@end
