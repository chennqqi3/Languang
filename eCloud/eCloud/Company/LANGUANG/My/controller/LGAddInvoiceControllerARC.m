//
//  LGAddInvoiceControllerARC.m
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGAddInvoiceControllerARC.h"
#import "SettingItem.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "LGAddInvoiceCellARC.h"
#import "eCloudConfig.h"
#import "ImageUtil.h"
#import "GKImagePicker.h"
#import "LCLLoadingView.h"
#import "UserDisplayUtil.h"
#import "FGalleryViewController.h"
#import "LookOverPhotoViewController.h"
#import "UserDefaults.h"
#import "LANGUANGMyViewControllerARC.h"
#import "LGInvoiceControllerARC.h"
#import "LANGUANGShareView.h"
#import "LGInvoiceUtilARC.h"

@interface LGAddInvoiceControllerARC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate,GKImagePickerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,FGalleryViewControllerDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) GKImagePicker *imagePicker;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic,strong) NSData *LogoData;
@property (nonatomic,strong) UIImage *tmpImage;
@property (nonatomic,strong) NSString *imagePath;
@property (nonatomic,assign) float cellheight;
@end

@implementation LGAddInvoiceControllerARC
{
    
    BOOL isChange;
}

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        SettingItem *_item = nil;
        
        
        NSMutableArray *arr1 = [NSMutableArray array];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"名称";
        _item.itemValue = @"公司名称";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"纳税人识别号";
        _item.itemValue = @"仅增值税专用发票需填写";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"公司地址";
        _item.itemValue = @"";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"公司电话";
        _item.itemValue = @"";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"开户银行名称";
        _item.itemValue = @"如“中国银行”";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"开户银行账号";
        _item.itemValue = @"";
        [arr1 addObject:_item];
        
        _item = [[SettingItem alloc]init];
        _item.itemName = @"开票照片";
        _item.imageName = @"xiang_pian.png";
        [arr1 addObject:_item];
        
        [mArr addObject:arr1];
        
        _dataArray = [mArr copy];
    }
    
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新增开票信息";
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.tableView];
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [UIAdapterUtil setRightButtonItemWithTitle:@"保存" andTarget:self andSelector:@selector(saveButton)];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:@"取消" andTarget:self andSelector:@selector(cancelButton) andDisplayLeftButtonImage:NO];

#ifdef _LANGUANG_FLAG_
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

#endif

    
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LGAddInvoiceCellARC *cell = [[LGAddInvoiceCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LGAddInvoiceCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    if (indexPath.row == 6) {
        
        cell.valueTextView.hidden = YES;
        cell.invoiceImage.hidden = NO;
        cell.nameLabel.text = item.itemName ? item.itemName : @"";
        if (_cellheight == 130) {
            
            cell.invoiceImage.image =  [UIImage imageWithData:[NSData dataWithContentsOfFile:item.itemValue]];
            cell.invoiceImage.frame = CGRectMake(120, 5, 90, 120);
            cell.delImage.hidden = NO;
            UITapGestureRecognizer *delTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delTap:)];
            delTap.numberOfTouchesRequired = 1;
            delTap.delegate = self;
            [cell.delImage addGestureRecognizer:delTap];
        }else{
            
            cell.invoiceImage.image = [StringUtil getImageByResName:item.imageName];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        tap.numberOfTouchesRequired = 1;
        tap.delegate = self;
        [cell.invoiceImage addGestureRecognizer:tap];
//        cell.imageS.image = _tmpImage;
        
    }else{
        
        cell.nameLabel.text = item.itemName ? item.itemName : @"";
        cell.valueTextView.text = item.itemValue ? item.itemValue : @"";
        cell.valueTextView = [LGInvoiceUtilARC contentSizeToFit:cell.valueTextView];
        cell.valueTextView.tag = indexPath.row;
        cell.valueTextView.delegate = self;
    }

    if (indexPath.row == 3) {
        
        cell.valueTextView.keyboardType = UIKeyboardAppearanceLight;
    }
    if (indexPath.row == 5) {
        
        cell.valueTextView.keyboardType = UIKeyboardTypePhonePad;
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSArray *arr = self.dataArray[indexPath.section];
//    SettingItem *item = arr[indexPath.row];
//    [self performSelector:item.clickSelector withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 6) {
        
        return _cellheight ? _cellheight : 60;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableViewController* tvc=[[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:tvc];
        [tvc.view setFrame:self.view.frame];
        _tableView=tvc.tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    [self.view endEditing:YES];
}

-(void)actionTap:(UITapGestureRecognizer*)tap{
    
    [self presentSheet];
}

- (void)ReviewImages:(UITapGestureRecognizer*)tap{
    
    LookOverPhotoViewController *viewCtl = [[LookOverPhotoViewController alloc] initWithImage:_tmpImage];
    viewCtl.view.backgroundColor = [UIColor lightGrayColor];
    viewCtl.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
//    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtl animated:YES];

}

- (void)presentSheet
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
        
//        CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
//        if (headerSize.width != headerSize.height)
//        {
//            self.imagePicker = [[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//        CGSize size;
//        size.height = SCREEN_HEIGHT;
//        size.width = SCREEN_WIDTH;
//            self.imagePicker.cropSize = size;
//            self.imagePicker.delegate = self;
//            //        [self.view.window.rootViewController presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
//            [UIAdapterUtil presentVC:self.imagePicker.imagePickerController];
            //            [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
//        }else
//        {
//            //             使用系统的方式选择照片
            [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
       // }
    
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
    if (image)
    {
//        CGSize _size = [self getStandardLogoSize];
//        if (image.size.width > _size.width || image.size.height > _size.height) {
//            image= [ImageUtil scaledImage:image toSize:_size withQuality:kCGInterpolationMedium];
//            //            image = [ImageUtil OriginImage:image scaleToSize:_size];
//        }
//        NSLog(@"%s,after croppend image size is %@",__FUNCTION__,NSStringFromCGSize(image.size));
        
    
//        NSIndexPath *path=[NSIndexPath indexPathForRow:6 inSection:0];
//        LGAddInvoiceCellARC *cell = (LGAddInvoiceCellARC *)[_tableView cellForRowAtIndexPath:path];
//        cell.imageS.image = image;
//        cell.imageS.hidden = NO;
//        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ReviewImages:)];
//        tap.numberOfTouchesRequired = 1;
//        tap.delegate = self;
//        [cell.imageS addGestureRecognizer:tap];
        self.LogoData = UIImageJPEGRepresentation(image, 0.5);
        _tmpImage = image;
        //内容发生了改变
        isChange = YES;
        NSArray *arr = self.dataArray[0];
        SettingItem *item = arr[6];
//        NSString *path_document = NSHomeDirectory();
//        NSString *string = [NSString stringWithFormat:@"/Documents/%@.png",[StringUtil getRandomString]];
//        //设置一个图片的存储路径
//        NSString *imagePath = [path_document stringByAppendingString:string];
//        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
//        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
//        item.itemValue = imagePath;
//        [self uploadLogo];
//        
//        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"userInfo_upload_picture"]];
//        [[LCLLoadingView currentIndicator]showSpinner];
//        [[LCLLoadingView currentIndicator]show];
        
        
        NSString *path_document = NSHomeDirectory();
        NSString *string = [NSString stringWithFormat:@"/Documents/%@.png",[StringUtil getRandomString]];
        //设置一个图片的存储路径
        NSString *imagePath = [path_document stringByAppendingString:string];
        //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
        
        item.itemValue = imagePath;
        _cellheight = 130;

    }
    
    
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
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
//    CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
//    
//    if (headerSize.width != headerSize.height)
//    {
//        self.imagePicker = [[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera];
//        self.imagePicker.cropSize = [self getCropSize];
//        self.imagePicker.delegate = self;
//        [UIAdapterUtil presentVC:self.imagePicker.imagePickerController];
        //    [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
//    }else
//    {
//        // 使用系统的调用相机 0819
        [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
//    }
}

////确定获得图片（相机拍摄或从相册选择）
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage* image;
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation=image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp)
        {
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
//    self.LogoData = [self imageData:image];
//    image = [UIImage imageWithData:self.LogoData];
    
    image = [[LANGUANGShareView getShareView]compressedImageFiles:image imageKB:1000];
    _tmpImage = image;
    //内容发生了改变
    isChange = YES;
//
    NSArray *arr = self.dataArray[0];
    SettingItem *item = arr[6];
    NSString *path_document = NSHomeDirectory();
    NSString *string = [NSString stringWithFormat:@"/Documents/%@.png",[StringUtil getRandomString]];
    //设置一个图片的存储路径
    NSString *imagePath = [path_document stringByAppendingString:string];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    item.itemValue = imagePath;
    _cellheight = 130;
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:6 inSection:0];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

// 调用系统相机或相册 0819
- (void)callSystemImagePickerControllerWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *pickCtl = [[UIImagePickerController alloc]init];
    pickCtl.sourceType = type;
    pickCtl.delegate = self;
    pickCtl.allowsEditing = NO;
    pickCtl.navigationBar.tintColor =  [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
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
#pragma mark - 获取头像
//- (UIImage *)headTangential
//{
//    self.emp = [db getEmpInfo:_conn.userId];
//    UIImage *image = [ImageUtil getOnlineEmpLogo:self.emp];;
//    return image;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView.tag == 1) {
        
        if ([LGInvoiceUtilARC isChinese:text]) {
            
            return NO;
        }
    }else if (textView.tag ==3){
        
        if ([LGInvoiceUtilARC isChinese:text] || [LGInvoiceUtilARC isLowerLetter:text]) {
            
            return NO;
        }
        
    }
    
    return YES;
    
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"公司名称"] || [textView.text isEqualToString:@"仅增值税专用发票需填写"] || [textView.text isEqualToString:@"如“中国银行”"]){
        textView.text=@"";
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{

    NSArray *arr = self.dataArray[0];
    SettingItem *item = arr[textView.tag];
    item.itemValue = textView.text;
    
    //内容发生了改变
    isChange = YES;
    
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length < 1){
        
        if (textView.tag == 0) {
            
            textView.text = @"公司名称";
        }else if (textView.tag == 1){
            
            textView.text = @"仅增值税专用发票需填写";
        }else if (textView.tag == 4){
            textView.text = @"如“中国银行”";
            
        }
    }
    
    NSArray *arr = self.dataArray[0];
    SettingItem *item = arr[textView.tag];
    item.itemValue = textView.text;
    
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    //    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];

}

- (void)saveButton{
    
    NSArray *arr = self.dataArray[0];

    NSMutableArray *array = [NSMutableArray arrayWithArray:[UserDefaults getLGCommonMsg]];
    NSMutableArray *tempArray = [NSMutableArray array];
    if (array.count == 0) {
        
        array = [NSMutableArray array];
        
    }
    
    for (int i = 0; i < arr.count; i++) {

        SettingItem *item = arr[i];
        if ([item.itemValue isEqualToString:@"公司名称"]) {
            
            item.itemValue = @"";
        }else if ([item.itemValue isEqualToString:@"仅增值税专用发票需填写"]){
            
            item.itemValue = @"";
        }else if ([item.itemValue isEqualToString:@"如“中国银行”"]){
            
            item.itemValue = @"";
        }
        if (i !=6) {
            
            if (item.itemValue.length == 0) {
                
                NSString * msg = [NSString stringWithFormat:@"%@不能为空",item.itemName];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        }
        
        NSString *str = [NSString stringWithFormat:@"%@=%@",item.itemValue,item.itemName];
//        [tempDict setValue:item.itemValue forKey:item.itemName];
        [tempArray addObject:str];
    }
    if (array.count>0) {
        
        [array insertObject:tempArray atIndex:0];

    }else if (array.count == 0){
        
        [array addObject:tempArray];
    }

    [UserDefaults setLGCommonMsg:array];

    
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[LGInvoiceControllerARC class]]){
            target = controller;
        }
    }
    if (target) {
    
        [self.navigationController popToViewController:target animated:NO];
        self.delegate = target;
        [self.delegate returnString:@"save"];

    }

}

- (void)cancelButton{
    
    if (isChange == YES) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"是否保存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alert show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        NSLog(@"保存");
        [self saveButton];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)delTap:(UITapGestureRecognizer*)tap{
    
    CGPoint point = [tap locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    LGAddInvoiceCellARC *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //    cell.invoiceImage.image = [StringUtil getImageByResName:@"xiang_pian.png"];
    _cellheight = 60;
    cell.delImage.hidden = YES;
    [_tableView reloadData];
    
}

-(NSData *)imageData:(UIImage *)myimage{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {
            //1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {
            //0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }else if (data.length>200*1024) {
            //0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    return data;
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
