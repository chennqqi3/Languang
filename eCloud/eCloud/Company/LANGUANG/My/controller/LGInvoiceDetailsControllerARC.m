//
//  LGInvoiceDetailsControllerARC.m
//  eCloud
//
//  Created by Ji on 17/7/14.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceDetailsControllerARC.h"
#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"
#import "LGAddInvoiceCellARC.h"
#import "LookOverPhotoViewController.h"
#import "StringUtil.h"
#import "GKImagePicker.h"
#import "LANGUANGShareView.h"
#import "UserDefaults.h"
#import "LGInvoiceUtilARC.h"

@interface LGInvoiceDetailsControllerARC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate,GKImagePickerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,assign) float cellheight;
@property (nonatomic,assign) float cellImageHeight;
@property (nonatomic,strong) NSData *LogoData;
@property (nonatomic,strong) UIImage *tmpImage;
@property (nonatomic,strong) NSString *imagePath;

@end

@implementation LGInvoiceDetailsControllerARC
{
    
    BOOL isChange;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
    
    [UIAdapterUtil setRightButtonItemWithTitle:@"保存" andTarget:self andSelector:@selector(saveButton)];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
#ifdef _LANGUANG_FLAG_
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
#endif
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LGAddInvoiceCellARC *cell = [[LGAddInvoiceCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LGAddInvoiceCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *string = self.dataArray[indexPath.row];
    NSArray *array = [string componentsSeparatedByString:@"="];
    if (array.count == 2) {
        if (indexPath.row == 6) {
            
            cell.valueTextView.hidden = YES;
            cell.invoiceImage.hidden = NO;
            cell.nameLabel.text = array[1] ? array[1] : @"";
            cell.invoiceImage.image =  [UIImage imageWithData:[NSData dataWithContentsOfFile:array[0]]];//[UIImage imageWithContentsOfFile:array[0]];
            if (!cell.invoiceImage.image) {
                _cellImageHeight = 60;
            }
            cell.invoiceImage.frame = CGRectMake(120, 5, 90, 120);
            
            if (_cellImageHeight == 60) {
                
                cell.delImage.hidden = YES;
                cell.invoiceImage.image = [StringUtil getImageByResName:@"xiang_pian.png"];
                cell.invoiceImage.frame = CGRectMake(120, 5, 50, 50);
                UITapGestureRecognizer *addtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addtap:)];
                addtap.numberOfTouchesRequired = 1;
                addtap.delegate = self;
                [cell.invoiceImage addGestureRecognizer:addtap];
                
            }else{
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
                tap.numberOfTouchesRequired = 1;
                tap.delegate = self;
                [cell.invoiceImage addGestureRecognizer:tap];
                cell.delImage.hidden = NO;
                
            }

            UITapGestureRecognizer *delTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delTap:)];
            delTap.numberOfTouchesRequired = 1;
            delTap.delegate = self;
            [cell.delImage addGestureRecognizer:delTap];
            
        }else{
            
            cell.nameLabel.text = array[1] ? array[1] : @"";
            cell.valueTextView.text = array[0] ? array[0] : @"";
            cell.valueTextView.delegate = self;
            cell.valueTextView.tag = indexPath.row;
            
            float height = [self heightForString:cell.valueTextView andWidth:SCREEN_WIDTH - 120];
            
            if (height > 60) {

                _cellheight = height;
                cell.nameLabel.frame = CGRectMake(10, 0, 100, _cellheight);
                cell.valueTextView.frame = CGRectMake(120, 0, SCREEN_WIDTH - 120, _cellheight);
                
            }else{
                
                _cellheight = 60;
                cell.valueTextView = [LGInvoiceUtilARC contentSizeToFit:cell.valueTextView];
            }
            
        }

        cell.nameLabel.textColor = [UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
        cell.valueTextView.textColor = [UIColor blackColor];
    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 6) {
        
        return _cellImageHeight ? _cellImageHeight : 130;
    }
        return _cellheight;
    
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

-(void)actionTap:(UITapGestureRecognizer*)tap{
    
    CGPoint point = [tap locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    LGAddInvoiceCellARC *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    LookOverPhotoViewController *viewCtl = [[LookOverPhotoViewController alloc] initWithImage:cell.invoiceImage.image];
    viewCtl.view.backgroundColor = [UIColor lightGrayColor];
    viewCtl.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:viewCtl animated:YES];
    
}

-(void)delTap:(UITapGestureRecognizer*)tap{
    
    CGPoint point = [tap locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    LGAddInvoiceCellARC *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.invoiceImage.image = [StringUtil getImageByResName:@"xiang_pian.png"];
    _cellImageHeight = 60;
    cell.delImage.hidden = YES;
    
    NSString *string = self.dataArray[6];
    NSArray *array = [string componentsSeparatedByString:@"="];
    NSString *str = [NSString stringWithFormat:@"%@=%@",@"",array[1]];
    [self.dataArray replaceObjectAtIndex:6 withObject:str];
    
    [_tableView reloadData];
    
}

-(void)addtap:(UITapGestureRecognizer*)tap{
    
    [self presentSheet];
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
    [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];

}

//从相册选择图片
- (IBAction) selectExistingPicture {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];

        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"访问图片库错误",@"")
                                                        message: NSLocalizedString(@"设备不支持图片库",@"")
                                                       delegate:nil
                                              cancelButtonTitle: NSLocalizedString(@"确定",@"")
                                              otherButtonTitles:nil];
        [alert show];
    }
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
    
//    NSIndexPath *path=[NSIndexPath indexPathForRow:6 inSection:0];
//    LGAddInvoiceCellARC *cell = (LGAddInvoiceCellARC *)[_tableView cellForRowAtIndexPath:path];
//    cell.imageS.image = image;
    //    cell.imageS.hidden = NO;
    
    _tmpImage = image;
    //内容发生了改变
    isChange = YES;

    NSString *path_document = NSHomeDirectory();
    NSString *string = [NSString stringWithFormat:@"/Documents/%@.png",[StringUtil getRandomString]];
    //设置一个图片的存储路径
    NSString *imagePath = [path_document stringByAppendingString:string];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    
    NSString *strPath = [NSString stringWithFormat:@"%@=开票照片",imagePath];
    [self.dataArray replaceObjectAtIndex:6 withObject:strPath];
    _cellImageHeight = 130;
    
    [_tableView reloadData];
    
}

// 调用系统相机或相册 0819
- (void)callSystemImagePickerControllerWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *pickCtl = [[UIImagePickerController alloc]init];
    pickCtl.sourceType = type;
    pickCtl.delegate = self;
    pickCtl.allowsEditing = NO;
    [UIAdapterUtil presentVC:pickCtl];
    //            [self presentViewController:pickCtl animated:YES completion:nil];
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

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *string = self.dataArray[textView.tag];
    NSArray *array = [string componentsSeparatedByString:@"="];
    NSString *str = [NSString stringWithFormat:@"%@=%@",textView.text,array[1]];
    [self.dataArray replaceObjectAtIndex:textView.tag withObject:str];
    
}

- (void)saveButton{
    
    for (int i = 0 ; i < self.dataArray.count; i++) {
        
        NSString *string = self.dataArray[i];
        NSArray *array = [string componentsSeparatedByString:@"="];
        NSString *str = array[0];
        if (i !=6) {
            if (str.length == 0) {
                
                NSString * msg = [NSString stringWithFormat:@"%@不能为空",array[1]];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
                
            }
        }
    }
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[UserDefaults getLGCommonMsg]];
    [arr replaceObjectAtIndex:self.section withObject:self.dataArray];
    [UserDefaults setLGCommonMsg:arr];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    [self.view endEditing:YES];
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
