//
//  KapokUploadViewController.m
//  eCloud
//
//  Created by  lyong on 14-5-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "KapokUploadViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUtil.h"
#import "LCLLoadingView.h"
#import "LCLShareThumbController.h"
#import "KapokDAO.h"
#import "StringUtil.h"
#import "talkSessionUtil.h"
#import "kapokImageObject.h"
#import "IOSSystemDefine.h"
#import "FlatDatePicker.h"
#import "PictureManager.h"
#import "FGalleryViewController.h"
#import "conn.h"
#import "kapokUploadEventObject.h"
#import "LogUtil.h"

#define max_upload_pic_count (5)

//一个button ，包含了 多个item，每一个item 包含了 一个iconbutton，如果是删除状态，那么还包括了一个deletebutton

//图标 高度 和 宽度
#define iconViewWidth 60
#define iconViewHeight (iconViewWidth)

//删除按钮的大小
#define deleteGroupMemberButtonSize (30.0)

//把icon加到item里的x和y
#define iconViewX (5.0)
#define iconViewY (iconViewX)

//    每个item的宽度和高度
#define perItemWidth (iconViewWidth + 2 * iconViewX)
//头像(60) nameLabel(20) 10 头像上面留空 10
#define perItemHeight (perItemWidth)

//    第一行，第一列的item的x值和y值
#define item0X (10)
#define item0Y (item0X)

//    每行 之间 每列之间 item的间隔
//间隔需要根据宽度 根据显示的个数计算出来
//#define itemSpaceX (10)
#define itemSpaceY (10)

//图片按钮的tag 基数
#define iconbutton_tag_0 (100)
//删除按钮的tag 基数
#define deletebutton_tag_0 (1000)

@interface KapokUploadViewController ()<UITextFieldDelegate,FlatDatePickerDelegate,photosLibraryManagerDelegate,ELCImagePickerControllerDelegate,FGalleryViewControllerDelegate,UIAlertViewDelegate>

@end
@interface KapokUploadViewController ()
{
    int showiconNum;
    
//    每一行显示的图标数量
    int perRowCount;
    
//    如果是上传失败了，那么点击进来可以重新上传，但是图片还可以再选择吗
    BOOL canEditPic;
}

@end

@implementation KapokUploadViewController
@synthesize start_Delete;
@synthesize modify_type_upload_id;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
//-(void)viewWillAppear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(boxValueChanged:)
//     name:UITextFieldTextDidChangeNotification
//     object:nil];
//}
//-(void)viewWillDisappear:(BOOL)animated
//{
//   [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//}
- (void)dealloc {
    [tip_textView release];
    [backgroudButton release];
}
-(void)boxValueChanged:(id)sender
{   UITextField *temp=(UITextField *)sender;
    NSString *text=temp.text;
    NSLog(@"--text-- %@  -- %d",text,text.length);
    NSString*case_str =[text uppercaseString];
    temp.text=case_str;
 
}
-(void)dismissDateView:(id)sender
{
    [self.flatDatePicker dismiss];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _conn = [conn getConn];
    
    if(IS_IPHONE_6P){
        
        showiconNum = 5;
    }else{
        
        showiconNum = 4;
    }
    
    perRowCount = 4;
    if (IS_IPHONE_6P) {
        perRowCount = 5;
    }
    
    
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    self.title=@"上传照片";
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    [UIAdapterUtil setRightButtonItemWithTitle:@"上传" andTarget:self andSelector:@selector(uploadButtonPressed:)];
    
    tip_textView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 235)];
    [self.view addSubview:tip_textView];
    
    UIImageView *imageicon1=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    imageicon1.image=[StringUtil getImageByResName:@"fly_1.png"];
    [tip_textView addSubview:imageicon1];
    [imageicon1 release];
    
    UIImageView *imageicon2=[[UIImageView alloc]initWithFrame:CGRectMake(10, 55, 30, 30)];
    imageicon2.image=[StringUtil getImageByResName:@"fly_2.png"];
    [tip_textView addSubview:imageicon2];
    [imageicon2 release];
    
    UIImageView *imageicon3=[[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 30, 30)];
    imageicon3.image=[StringUtil getImageByResName:@"fly_3.png"];
    [tip_textView addSubview:imageicon3];
    [imageicon3 release];
     
    UIImageView *imageicon4=[[UIImageView alloc]initWithFrame:CGRectMake(10, 145, 30, 30)];
    imageicon4.image=[StringUtil getImageByResName:@"fly_4.png"];
    [tip_textView addSubview:imageicon4];
    [imageicon4 release];
    
     
    UIImageView *imageicon5=[[UIImageView alloc]initWithFrame:CGRectMake(10, 190, 30, 30)];
    imageicon5.image=[StringUtil getImageByResName:@"fly_5.png"];
    [tip_textView addSubview:imageicon5];
    [imageicon5 release];
    

    //[backgroudButton release];
   
    dateChoose=[[UIButton alloc]initWithFrame:CGRectMake(50, 10,self.view.frame.size.width - 50 - 15, 30)];
    dateChoose.layer.borderWidth=1;
    dateChoose.layer.borderColor=[UIColor grayColor].CGColor;
    dateChoose.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    dateChoose.contentEdgeInsets = UIEdgeInsetsMake(0,5, 0, 0);
    dateChoose.titleLabel.font=[UIFont systemFontOfSize:14];
    [dateChoose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [dateChoose addTarget:self action:@selector(actionOpen:) forControlEvents:UIControlEventTouchUpInside];
    [tip_textView addSubview:dateChoose];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *value = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateChoose setTitle:value forState:UIControlStateNormal];
    
   
    FlightField=[[UITextField alloc]initWithFrame:CGRectMake(50, 55, self.view.frame.size.width - 50 - 15, 30)];
    [tip_textView addSubview:FlightField];
    FlightField.layer.borderWidth=1;
    FlightField.layer.borderColor=[UIColor grayColor].CGColor;
    FlightField.textAlignment=NSTextAlignmentLeft;
    FlightField.placeholder=@"航班号,如CZ8888";
  //  FlightField.clearButtonMode = UITextFieldViewModeWhileEditing;
    FlightField.delegate=self;
    FlightField.keyboardType=UIKeyboardTypeASCIICapable;
    FlightField.returnKeyType= UIReturnKeyNext;
    FlightField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    FlightField.font=[UIFont systemFontOfSize:14];
    [FlightField addTarget:self action:@selector(boxValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [FlightField addTarget:self action:@selector(dismissDateView:) forControlEvents:UIControlEventEditingDidBegin];
    UIView *FlightFieldview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    FlightFieldview.userInteractionEnabled=NO;
    FlightField.leftView = FlightFieldview;
    FlightField.leftViewMode = UITextFieldViewModeAlways;
    [FlightFieldview release];
    
    [FlightField release];
    
    AirportField=[[UITextField alloc]initWithFrame:CGRectMake(50,100, self.view.frame.size.width - 50 - 15, 30)];
    [tip_textView addSubview:AirportField];
    AirportField.layer.borderWidth=1;
    AirportField.layer.borderColor=[UIColor grayColor].CGColor;
    AirportField.textAlignment=NSTextAlignmentLeft;
    AirportField.placeholder=@"起飞机场";
  //  AirportField.clearButtonMode = UITextFieldViewModeWhileEditing;
    AirportField.delegate=self;
    AirportField.returnKeyType= UIReturnKeyNext;
     AirportField.keyboardType=UIKeyboardTypeASCIICapable;
    AirportField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    AirportField.font=[UIFont systemFontOfSize:14];

    [AirportField addTarget:self action:@selector(boxValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [AirportField addTarget:self action:@selector(dismissDateView:) forControlEvents:UIControlEventEditingDidBegin];
    UIView *AirportFieldview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    AirportFieldview.userInteractionEnabled=NO;
    AirportField.leftView = AirportFieldview;
    AirportField.leftViewMode = UITextFieldViewModeAlways;
    [AirportFieldview release];
    
    [AirportField release];
    
    AirportField.text= [[KapokDAO getDatabase] getBoarding_NumLast];

    
    NoBoardingField=[[UITextField alloc]initWithFrame:CGRectMake(50, 145, self.view.frame.size.width - 50 - 15, 30)];
    NoBoardingField.layer.borderWidth=1;
    NoBoardingField.layer.borderColor=[UIColor grayColor].CGColor;
    [tip_textView addSubview:NoBoardingField];
    NoBoardingField.delegate=self;
    NoBoardingField.textAlignment=NSTextAlignmentLeft;
    NoBoardingField.placeholder=@"登机牌序号,如BN001";
  //  NoBoardingField.clearButtonMode = UITextFieldViewModeWhileEditing;
    NoBoardingField.returnKeyType= UIReturnKeyNext;
     NoBoardingField.keyboardType=UIKeyboardTypeASCIICapable;
    NoBoardingField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    NoBoardingField.font=[UIFont systemFontOfSize:14];
    [NoBoardingField addTarget:self action:@selector(boxValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [NoBoardingField addTarget:self action:@selector(dismissDateView:) forControlEvents:UIControlEventEditingDidBegin];
    UIView *NoBoardingFieldview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    NoBoardingFieldview.userInteractionEnabled=NO;
    NoBoardingField.leftView = NoBoardingFieldview;
    NoBoardingField.leftViewMode = UITextFieldViewModeAlways;
    [NoBoardingFieldview release];
    [NoBoardingField release];
    

    lastField=[[UITextField alloc]initWithFrame:CGRectMake(50, 190, self.view.frame.size.width - 50 - 15, 30)];
    lastField.delegate=self;
    lastField.layer.borderWidth=1;
    lastField.layer.borderColor=[UIColor grayColor].CGColor;
    [tip_textView addSubview:lastField];
    lastField.textAlignment=NSTextAlignmentLeft;
    lastField.placeholder=@"工号";
  //  lastField.clearButtonMode = UITextFieldViewModeWhileEditing;
    lastField.returnKeyType= UIReturnKeyDefault;
     lastField.keyboardType=UIKeyboardTypeASCIICapable;
    lastField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    lastField.font=[UIFont systemFontOfSize:14];
    UIView *lastFieldview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    lastFieldview.userInteractionEnabled=NO;
    lastField.leftView = lastFieldview;
    lastField.leftViewMode = UITextFieldViewModeAlways;
    [lastFieldview release];
     lastField.text=_conn.user_code;
    [lastField release];
   
    CGFloat scrollViewW = self.view.frame.size.width - 10 * 2;
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
    memberScroll=[[UIButton alloc]initWithFrame:CGRectMake(10,235, scrollViewW, 210)];
//    memberScroll.scrollEnabled=NO;
    [self.view addSubview:memberScroll];
    memberScroll.layer.cornerRadius = 10;//设置那个圆角的有多圆
    memberScroll.layer.borderWidth = 1;//设置边框的宽度，当然可以不要
    memberScroll.layer.borderColor = [[UIColor grayColor] CGColor];//设置边框的颜色
    memberScroll.layer.masksToBounds = YES;//设为NO去试试
    
    memberScroll.backgroundColor = [UIColor clearColor];
    
    [memberScroll addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit;
    NSDateComponents *comps  = [calendar components:unitFlags fromDate:[NSDate date]];
    [comps setYear:[comps year]+5];
    NSDate *maxDate = [calendar dateFromComponents:comps];
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:self.view];
    self.flatDatePicker.delegate = self;
    self.flatDatePicker.title = @"选择航班日期";
    self.flatDatePicker.maximumDate=maxDate;
    self.flatDatePicker.datePickerMode = FlatDatePickerModeDate;
    
    manyPicArray=[[NSMutableArray alloc]init];
    
    canEditPic = YES;
    
    if (self.modify_type_upload_id.length>0) {
        canEditPic = NO;
        
       NSLog(@"---modify_type_upload_id:  %@",self.modify_type_upload_id);
        
       kapokUploadEventObject*kapok_obj=[[KapokDAO getDatabase]getKapokUploadEventById:self.modify_type_upload_id];
        NSString *selected_date=kapok_obj.selected_date;
        selected_date = [selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
       [dateChoose setTitle:selected_date forState:UIControlStateNormal];
        FlightField.text=kapok_obj.flight_num;
        AirportField.text=kapok_obj.start_airport;
        NoBoardingField.text=kapok_obj.boarding_num;
        lastField.text=kapok_obj.emp_code;
        NSArray *pic_array= [[KapokDAO getDatabase]getKapokUploadImageListPathBy:self.modify_type_upload_id];
        [manyPicArray addObjectsFromArray:pic_array];
    }

    [self showMemberScrollow];

    backgroudButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    backgroudButton.backgroundColor=[UIColor clearColor];
    backgroudButton.hidden=YES;
    [self.view addSubview:backgroudButton];
    [backgroudButton addTarget:self action:@selector(dismissKeyView) forControlEvents:UIControlEventTouchUpInside];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    backgroudButton.hidden=NO;
    if (textField==FlightField) {
     FlightField.layer.borderColor=[UIColor blueColor].CGColor;
     tip_textView.frame=CGRectMake(0, 0, self.view.frame.size.width, 235);
       
    }else if(textField==AirportField)
    {
     AirportField.layer.borderColor=[UIColor blueColor].CGColor;
     tip_textView.frame=CGRectMake(0, 0, self.view.frame.size.width, 235);
    }
    else if(textField==NoBoardingField)
    {
      NoBoardingField.layer.borderColor=[UIColor blueColor].CGColor;
        if (self.view.frame.size.height<=480) {
            tip_textView.frame=CGRectMake(0, -30, self.view.frame.size.width, 235);
        }
     
    }else
    {
        if (self.view.frame.size.height<=480) {
            tip_textView.frame=CGRectMake(0, -30, self.view.frame.size.width, 235);
        }
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor=[UIColor grayColor].CGColor;
    if (textField==lastField) {
        tip_textView.frame=CGRectMake(0, 0, self.view.frame.size.width, 235);
    }
}

//数字
#define NUM @"0123456789"
//字母
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
//数字和字母
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL is_ok= [string isEqualToString:filtered];
    
    NSInteger strLength = textField.text.length - range.length + string.length;
    if (textField==FlightField) {
        return (is_ok&&(strLength <8));
    }else if(textField==AirportField)
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        is_ok= [string isEqualToString:filtered];
        
        return (is_ok&&(strLength <4));
    }
    else if(textField==NoBoardingField)
    {
        return (is_ok&&(strLength <=5));
    } else if(textField==lastField)
    {
        return (is_ok&&(strLength <=15));
        
    }else
    {
        return YES;
    }
    
    
}
-(void)showSelectedPic:(NSMutableArray*)selectedArray
{

    [manyPicArray addObjectsFromArray:selectedArray];
    
    if (self.start_Delete) {
        self.start_Delete = NO;
    }
    
    [self showMemberScrollow];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPicFinished" object:nil];
}

- (IBAction)actionOpen:(id)sender {
    [self dismissKeyView];
    [self.flatDatePicker show];
}

-(void)dismissKeyView
{
    backgroudButton.hidden=YES;
    tip_textView.frame=CGRectMake(0, 0, self.view.frame.size.width, 235);
    [FlightField resignFirstResponder];
    [AirportField resignFirstResponder];
    [NoBoardingField resignFirstResponder];
    [lastField resignFirstResponder];
     [self.flatDatePicker dismiss];

}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {

    if (FlightField==theTextField) {
      [AirportField becomeFirstResponder];
    }
    else if(AirportField==theTextField)
    {
     [NoBoardingField becomeFirstResponder];
    }else if(NoBoardingField==theTextField)
    {
        [lastField becomeFirstResponder];
    }
    else if(lastField==theTextField)
    {
        [lastField resignFirstResponder];
    }
     [self.flatDatePicker dismiss];
    return YES;
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1) {
        [FlightField becomeFirstResponder];
    }
    else if(alertView.tag==2)
    {
        [AirportField becomeFirstResponder];
    }else if(alertView.tag==3)
    {
        [NoBoardingField becomeFirstResponder];
    }
    else if(alertView.tag==4)
    {
        [lastField becomeFirstResponder];
    }
    else if(alertView.tag==5)
    {
        [self dismissKeyView];
    }
}

-(NSString *)makeFilghtNum:(NSString *)string
{
    NSString *return_str=string;
    
    if (string.length>2) {
         NSString *index_str=[string substringToIndex:2];
        if ([index_str isEqualToString:@"CZ"]) {
            string=[string substringFromIndex:2];
        }
    }
    
    NSString *is_add_A_str=@"";
    NSString *last_str;
    if (string.length>1) {
        last_str=[string substringWithRange:NSMakeRange(string.length-1, 1)];
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
        NSString *filtered = [[last_str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL is_not_num= [last_str isEqualToString:filtered];
        
        if (is_not_num) {
            is_add_A_str=last_str;
            int len=string.length-1;
            string=[string substringToIndex:len];
            NSLog(@"--string-A- %@",string);
        }
    }
    
    if (string.length<=4) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL is_ok= [string isEqualToString:filtered];
        if (is_ok) {
           
            if (string.length==1) {
              return_str=[NSString stringWithFormat:@"CZ000%@%@",string,is_add_A_str];
            }else if(string.length==2) {
              return_str=[NSString stringWithFormat:@"CZ00%@%@",string,is_add_A_str];  
            }else if(string.length==3) {
              return_str=[NSString stringWithFormat:@"CZ0%@%@",string,is_add_A_str];   
            }
            else if(string.length==4) {
              return_str=[NSString stringWithFormat:@"CZ%@%@",string,is_add_A_str];   
            }
           
        }
    }
    FlightField.text = return_str;
  
    return return_str;
}
-(BOOL)CheckFilghtNum:(NSString *)string
{
    BOOL is_ok=NO;
    NSCharacterSet *num_cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
    NSString *num_filtered = [[string componentsSeparatedByCharactersInSet:num_cs] componentsJoinedByString:@""];
    if (num_filtered.length>4) {
        UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号数字不能超过4位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tip_alert show];
        [tip_alert release];
        return is_ok;
    }
    
    if (string.length>=6) {
      
        NSString *index_str=[string substringToIndex:2];
        NSString *num_str=[string substringWithRange:NSMakeRange(2, 4)];
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[num_str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        is_ok= [num_str isEqualToString:filtered];
        if ([index_str isEqualToString:@"CZ"]&&is_ok) {
         is_ok=YES;
        }else
        {
            is_ok=NO;
            UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [tip_alert show];
            [tip_alert release];
            return is_ok;
        }
        
        if (string.length==7) {
            NSString *last_str=[string substringWithRange:NSMakeRange(6, 1)];
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
            NSString *filtered = [[last_str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            BOOL is_not_num= [last_str isEqualToString:filtered];
            if (is_not_num) {
              is_ok=YES;   
            }else
            {
                is_ok=NO;
                UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [tip_alert show];
                [tip_alert release];
                return is_ok;
            }
        }
    }else
    {
        UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tip_alert show];
        [tip_alert release];
    }
    return is_ok;
}
-(BOOL)CheckBoardinNum:(NSString *)string
{
   BOOL is_ok=NO;
    
    NSCharacterSet *num_cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
    NSString *num_filtered = [[string componentsSeparatedByCharactersInSet:num_cs] componentsJoinedByString:@""];
    if (num_filtered.length>3) {
        UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"登机牌序号数字不能超过3位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tip_alert show];
        [tip_alert release];
        return is_ok;
    }
    if (string.length==5) {
        
        NSString *index_str=[string substringToIndex:2];
        NSString *num_str=[string substringWithRange:NSMakeRange(2, 3)];
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[num_str componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        is_ok= [num_str isEqualToString:filtered];
        if ([index_str isEqualToString:@"BN"]&&is_ok) {
            is_ok=YES;
        }else
        {
            is_ok=NO;
            UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"登机牌序号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [tip_alert show];
            [tip_alert release];
        }
    }else
    {
        UIAlertView *tip_alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"登机牌序号格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [tip_alert show];
        [tip_alert release];
    }
    return is_ok;
}

-(NSString *)makeBoardinNum:(NSString *)string
{
    NSString *return_str=string;
    
    if (string.length>2) {
        NSString *index_str=[string substringToIndex:2];
        if ([index_str isEqualToString:@"BN"]) {
            string=[string substringFromIndex:2];
        }
    }

    if (string.length<=3) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL is_ok= [string isEqualToString:filtered];
        if (is_ok) {
            
            if (string.length==1) {
                return_str=[NSString stringWithFormat:@"BN00%@",string];
            }else if(string.length==2) {
                return_str=[NSString stringWithFormat:@"BN0%@",string];
            }else if(string.length==3) {
                return_str=[NSString stringWithFormat:@"BN%@",string];
            }
           
            
        }
    }
    NoBoardingField.text = return_str;
    return return_str;
}

-(void)uploadButtonPressed:(id)sender
{
    if (self.modify_type_upload_id.length>0) {
        
        NSString *selected_date=dateChoose.titleLabel.text;
        selected_date = [selected_date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSLog(@"---selected_date-- %@",selected_date);
        NSString *flight_num=FlightField.text;
        NSString *airport_num=AirportField.text;
        NSString *boardin_num=NoBoardingField.text;
        NSString *emp_code=lastField.text;
        
        if (flight_num.length==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            alert.tag=1;
            [alert show];
            [alert release];
            return;
        }else if(airport_num.length==0||airport_num.length<3) {
            if (airport_num.length==0) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"起飞机场不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=2;
                [alert show];
                [alert release];
            }else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"起飞机场长度是3个字母" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=2;
                [alert show];
                [alert release];
                
            }

            return;
        }
        else if(boardin_num.length==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"登机牌序号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
             alert.tag=3;
            [alert show];
            [alert release];
            return;
        }
        else if(emp_code.length==0) {
            
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"工号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=4;
                [alert show];
                [alert release];
                        
            return;
        }
        
        flight_num=[self makeFilghtNum:flight_num];
        boardin_num=[self makeBoardinNum:boardin_num];
        
        if (FlightField.isFirstResponder) {
            FlightField.layer.borderColor=[UIColor blueColor].CGColor;
        }else
        {
            FlightField.layer.borderColor=[UIColor grayColor].CGColor;
        }
        
        if (NoBoardingField.isFirstResponder) {
            NoBoardingField.layer.borderColor=[UIColor blueColor].CGColor;
        }else
        {
            NoBoardingField.layer.borderColor=[UIColor grayColor].CGColor;
        }
        
        if (![self CheckFilghtNum:flight_num]) {
            FlightField.layer.borderColor=[UIColor redColor].CGColor;
            return;
        }
        if (![self CheckBoardinNum:boardin_num]) {
            NoBoardingField.layer.borderColor=[UIColor redColor].CGColor;
            return;
        }
   
        kapokUploadEventObject*kapok_obj=[[KapokDAO getDatabase]getKapokUploadEventById:self.modify_type_upload_id];
        NSString *old_selected_date=kapok_obj.selected_date;
       // old_selected_date = [old_selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        
        
        is_modify=NO;
        if (![selected_date isEqualToString:old_selected_date]||![flight_num isEqualToString:kapok_obj.flight_num]||![airport_num isEqualToString:kapok_obj.start_airport]||![boardin_num isEqualToString:kapok_obj.boarding_num]||![emp_code isEqualToString:kapok_obj.emp_code]) {
            is_modify=YES;
        }
        
        
        int nowtimeInt= [_conn getCurrentTime];
        NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
        
        BOOL is_uploading=[[KapokDAO getDatabase] getKapokUploadingEventState];
        NSDictionary *tempdic=nil;
        if (is_uploading) { //等待上传
            tempdic=[NSDictionary dictionaryWithObjectsAndKeys:self.modify_type_upload_id,@"upload_id",selected_date,@"selected_date",nowTime,@"create_time",flight_num,@"flight_num",airport_num,@"start_airport",boardin_num,@"boarding_num",emp_code,@"emp_code",@"1",@"upload_state", nil];
        }else
        { //正在上传
            tempdic=[NSDictionary dictionaryWithObjectsAndKeys:self.modify_type_upload_id,@"upload_id",selected_date,@"selected_date",nowTime,@"create_time",flight_num,@"flight_num",airport_num,@"start_airport",boardin_num,@"boarding_num",emp_code,@"emp_code",@"2",@"upload_state", nil];
        }
        
        [[KapokDAO getDatabase] addUploadRecord:tempdic];
        [[LCLLoadingView currentIndicator]setCenterMessage:@"照片压缩中..."];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
        [self performSelector:@selector(doPicAction:) withObject:nil afterDelay:0.5];
        return;
    }
    
        
        NSString *selected_date=dateChoose.titleLabel.text;
        selected_date = [selected_date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSLog(@"---selected_date-- %@",selected_date);
        NSString *flight_num=FlightField.text;
        NSString *airport_num=AirportField.text;
        NSString *boardin_num=NoBoardingField.text;
        NSString *emp_code=lastField.text;
     
        if (flight_num.length==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"航班号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            alert.tag=1;
            [alert show];
            [alert release];
            return;
        }else if(airport_num.length==0||airport_num.length<3) {
            if (airport_num.length==0) {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"起飞机场不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=2;
                [alert show];
                [alert release];
            }else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"起飞机场长度是3个字母" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=2;
                [alert show];
                [alert release];
            
            }
          
            return;
        }
        else if(boardin_num.length==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"登机牌序号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            alert.tag=3;
            [alert show];
            [alert release];
            return;
        }else if(emp_code.length==0) {
            
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"工号不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag=4;
                [alert show];
                [alert release];
                return;
        }
    
    
        flight_num=[self makeFilghtNum:flight_num];
        boardin_num=[self makeBoardinNum:boardin_num];
    
    if (FlightField.isFirstResponder) {
        FlightField.layer.borderColor=[UIColor blueColor].CGColor;
    }else
    {
        FlightField.layer.borderColor=[UIColor grayColor].CGColor;
    }
    
    if (NoBoardingField.isFirstResponder) {
        NoBoardingField.layer.borderColor=[UIColor blueColor].CGColor;
    }else
    {
        NoBoardingField.layer.borderColor=[UIColor grayColor].CGColor;
    }

    
    if (![self CheckFilghtNum:flight_num]) {
        FlightField.layer.borderColor=[UIColor redColor].CGColor;
        return;
    }
    if (![self CheckBoardinNum:boardin_num]) {
        NoBoardingField.layer.borderColor=[UIColor redColor].CGColor;
        return;
    }

//          
//    NSString *tip_str=[NSString stringWithFormat:@"航班号:%@ \n 起飞机场:%@ \n 登机牌序号:%@ \n",flight_num,airport_num,boardin_num];
//    UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:@" " message:tip_str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [tipAlert show];
//    [tipAlert release];
//    return;
    
    if([manyPicArray count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有选择照片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag=5;
        [alert show];
        [alert release];
        return;
    }
        int nowtimeInt= [_conn getCurrentTime];
        NSString *nowTime =[StringUtil getStringValue:nowtimeInt];

        BOOL is_uploading=[[KapokDAO getDatabase] getKapokUploadingEventState];
        NSDictionary *tempdic=nil;
        if (is_uploading) { //等待上传
         tempdic=[NSDictionary dictionaryWithObjectsAndKeys:nowTime,@"upload_id",selected_date,@"selected_date",nowTime,@"create_time",flight_num,@"flight_num",airport_num,@"start_airport",boardin_num,@"boarding_num",emp_code,@"emp_code",@"1",@"upload_state", nil];   
        }else
        { //正在上传
        tempdic=[NSDictionary dictionaryWithObjectsAndKeys:nowTime,@"upload_id",selected_date,@"selected_date",nowTime,@"create_time",flight_num,@"flight_num",airport_num,@"start_airport",boardin_num,@"boarding_num",emp_code,@"emp_code",@"2",@"upload_state", nil];
        }
        
        [[KapokDAO getDatabase] addUploadRecord:tempdic];
        [[KapokDAO getDatabase] addUploadRecord:tempdic];
        [[LCLLoadingView currentIndicator]setCenterMessage:@"照片压缩中"];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];
        [self performSelector:@selector(doPicAction:) withObject:nowTime afterDelay:0.5];
   
}

-(void)doPicAction:(NSString *)nowTime
{
   if (self.modify_type_upload_id.length>0) {

 
        if (is_modify) {
               NSString *selected_date=dateChoose.titleLabel.text;
               NSString *flight_num=FlightField.text;
               NSString *airport_num=AirportField.text;
               NSString *boardin_num=NoBoardingField.text;
               NSString *emp_code=lastField.text;
               for (int i=0; i<[manyPicArray count]; i++) {
                   
                   NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                   NSData * data=nil;
            
                   //存入本地
                   NSString *picpath = [manyPicArray objectAtIndex:i];
                   
                   data=[NSData dataWithContentsOfFile:picpath];
                   
                   NSString *picname=[picpath lastPathComponent];
                   //-----获取token--------
                   NSString *imageHash=[StringUtil getFileMD5WithPath:picpath];
                   NSString * upload_picname=[NSString stringWithFormat:@"%@_%d.jpg",emp_code,i];
                   NSString *json_str=[NSString stringWithFormat:@"{\"flightdate\":\"%@\",\"flightno\":\"%@\",\"boardingno\":\"%@\",\"filelength\":%d,\"filemd5\":\"%@\",\"filename\":\"%@\"}",selected_date,flight_num,boardin_num,data.length,imageHash,upload_picname];
                   
                   [LogUtil debug:[NSString stringWithFormat:@"%s json1: %@",__FUNCTION__,json_str]];
 //
                   //    NSString *file_len=[NSString stringWithFormat:@"%d",data.length];
                   //使用post方法请求http
                   
                   NSString *token_url=[NSString stringWithFormat:@"%@/token",kapod_file_server];
                   NSURL *url = [NSURL URLWithString:token_url];
                 
                   NSError *error;
                   
                   NSData *testData = [json_str dataUsingEncoding: NSUTF8StringEncoding];
                   // Byte *testByte = (Byte *)[testData bytes];
                   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                   //    [request setDelegate:self];
                   [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
                   [request addRequestHeader:@"Accept" value:@"application/json"];
                   [request setRequestMethod:@"POST"];
                   [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
                   [request setPostBody:testData];
                   [request startSynchronous];
                   
                   NSError *error1 = [request error];
                   NSString *response=nil;
                   
                   if (!error1) {
                       
                       int statuscode=[request responseStatusCode];
                      
                       if (statuscode==200) {
                           NSString* temp_response = [request responseString];
                           NSDictionary *dic=[temp_response objectFromJSONString];
                           response=[dic objectForKey:@"result"];
                           
                           [LogUtil debug:[NSString stringWithFormat:@"%s token1 is %@",__FUNCTION__,response]];
                           if (response!=nil) {
                           NSDictionary *picdic=[NSDictionary dictionaryWithObjectsAndKeys:self.modify_type_upload_id,@"upload_id",picname,@"image_name",picname,@"image_code",@"1",@"upload_state",response,@"image_token",@"0",@"upload_start_index", nil];
                           [[KapokDAO getDatabase] addUploadImage:picdic];
                           }
                       }
                    
                       
                       // [[KapokDAO getDatabase]updateKapodUploadToken:nowTime andPicName:picname andToken:response];//设置图片token
                   }
                   if (response==nil) {
                       NSLog(@"-token----error1：%@",error1);
                       [[KapokDAO getDatabase]updateKapodUploadState:nowTime andState:3];//设置上传失败
                       NSDictionary *picdic=[NSDictionary dictionaryWithObjectsAndKeys:self.modify_type_upload_id,@"upload_id",picname,@"image_name",picname,@"image_code",@"1",@"upload_state",@"0",@"upload_start_index", nil];
                       [[KapokDAO getDatabase] addUploadImage:picdic];
                   }
                  [pool release];
  
           }
           }else//获取长度
           {   NSString *selected_date=dateChoose.titleLabel.text;
               NSString *flight_num=FlightField.text;
               NSString *airport_num=AirportField.text;
               NSString *boardin_num=NoBoardingField.text;
               NSString *emp_code=lastField.text;
               NSArray *pic_array= [[KapokDAO getDatabase]getKapokNoUploadImageInfoBy:self.modify_type_upload_id];
               for (int i=0; i<[pic_array count]; i++) {
                   kapokImageObject *kapok_object=[pic_array objectAtIndex:i];
                   
                   //-------获取长度
                   int start_upload_index=0;
                   if(kapok_object.image_token.length>0)//需要续传
                   {
                       NSString *url_str=[NSString stringWithFormat:@"%@/resume?token=%@",kapod_file_server,kapok_object.image_token];
                       //   NSString *url_str=[NSString stringWithFormat:@"http://10.10.2.179:8080/mmdf/resume?token=%@",kapok_object.image_token];
                       NSURL *url = [NSURL URLWithString:url_str];
                       ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                       [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
                       [request startSynchronous];
                       NSError *error1 = [request error];
                       NSString *response=nil;
                       if (!error1) {
                           int statuscode=[request responseStatusCode];
                           if (statuscode==200) {
                               NSString* temp_response = [request responseString];
                               NSDictionary *dic=[temp_response objectFromJSONString];
                               response=[dic objectForKey:@"result"];
                               NSLog(@"---upload--start_upload_index：%@",response);
                               start_upload_index=response.intValue;
                               [[KapokDAO getDatabase]updateKapodUploadStartIndex:self.modify_type_upload_id andPicName:kapok_object.image_name andIndex:start_upload_index];
                           }
                       }
                       
                   }
                     
                   //没有token的要获取token
                   NSString *picpath = kapok_object.image_path;
                   NSData *data=[NSData dataWithContentsOfFile:picpath];
                   NSString*  exestr = [picpath lastPathComponent];
                   
                   [LogUtil debug:[NSString stringWithFormat:@"%s imageToken is %@",__FUNCTION__,kapok_object.image_token]];
                   if (kapok_object.image_token.length==0) {//需要获取token
                       
                       NSString *imageHash=[StringUtil getFileMD5WithPath:picpath];
                       NSString * upload_picname=[NSString stringWithFormat:@"%@_%d.jpg",emp_code,i];
                       NSString *json_str=[NSString stringWithFormat:@"{\"flightdate\":\"%@\",\"flightno\":\"%@\",\"boardingno\":\"%@\",\"filelength\":%d,\"filemd5\":\"%@\",\"filename\":\"%@\"}",selected_date,flight_num,boardin_num,data.length,imageHash,upload_picname];
                       
                       [LogUtil debug:[NSString stringWithFormat:@"%s json2: %@",__FUNCTION__,json_str]];
                       //
                       //    NSString *file_len=[NSString stringWithFormat:@"%d",data.length];
                       //使用post方法请求http
                       NSString *token_url=[NSString stringWithFormat:@"%@/token",kapod_file_server];
                       NSURL *url = [NSURL URLWithString:token_url];
                       NSError *error;
                       
                       NSData *testData = [json_str dataUsingEncoding: NSUTF8StringEncoding];
                       // Byte *testByte = (Byte *)[testData bytes];
                       
                       ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                       //    [request setDelegate:self];
                       [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
                       [request addRequestHeader:@"Accept" value:@"application/json"];
                       [request setRequestMethod:@"POST"];
                       [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
                       [request setPostBody:testData];
                       [request startSynchronous];
                       
                       NSError *error1 = [request error];
                       NSString *response=nil;
                       if (!error1) {
                           int statuscode=[request responseStatusCode];
                           if (statuscode==200) {
                               
                               NSString* temp_response = [request responseString];
                               NSDictionary *dic=[temp_response objectFromJSONString];
                               response=[dic objectForKey:@"result"];
                               if (response!=nil) {
                               kapok_object.image_token=response;
                               NSLog(@"--here---Token：%@",response);
                               [[KapokDAO getDatabase]updateKapodUploadToken:self.modify_type_upload_id andPicName:exestr andToken:response];//设置图片token
                               }
                           }
                       }
                       if (response==nil) {
                           NSLog(@"-token----error1：%@",error1);
                           [[KapokDAO getDatabase]updateKapodUploadState:self.modify_type_upload_id andState:3];//设置上传失败
                       }
                   }
               }
           }
       [[LCLLoadingView currentIndicator]hiddenForcibly:true];
       [self.navigationController popViewControllerAnimated:YES];
   }else
   {
       NSString *selected_date=dateChoose.titleLabel.text;
       NSString *flight_num=FlightField.text;
       NSString *airport_num=AirportField.text;
       NSString *boardin_num=NoBoardingField.text;
       NSString *emp_code=lastField.text;
       for (int i=0; i<[manyPicArray count]; i++) {
           
           NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
           CGImageRef imageRef;
           ALAsset *asset=[[manyPicArray objectAtIndex:i] asset];
           ALAssetRepresentation* rep = [asset defaultRepresentation];
           imageRef = [rep fullResolutionImage];
           CGImageRef small_imageRef = [asset thumbnail];
           UIImage *image = nil;
           NSData * data=nil;
           if(imageRef)
           {
               image = [UIImage imageWithCGImage:imageRef];
               CGSize _size = [talkSessionUtil getImageSizeAfterCropForKapod:image];
               if(_size.width > 0 && _size.height > 0)
               {
                   image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
               }
               image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:rep.orientation];
               
               data =UIImageJPEGRepresentation(image, 0.7);
               
           }
          
           NSString *picname=[NSString stringWithFormat:@"%@_%d.jpg",nowTime,i];
           //存入本地
           NSString *picpath = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname];
           //   NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
           if (data!=nil) {
               
               BOOL success= [data writeToFile:picpath atomically:YES];
               if (!success) {
                   [pool release];
                   return;
               }
               
           }
           
            //-----获取token--------
           NSString *imageHash=[StringUtil getFileMD5WithPath:picpath];
           NSString * upload_picname=[NSString stringWithFormat:@"%@_%d.jpg",emp_code,i];
           NSString *json_str=[NSString stringWithFormat:@"{\"flightdate\":\"%@\",\"flightno\":\"%@\",\"boardingno\":\"%@\",\"filelength\":%d,\"filemd5\":\"%@\",\"filename\":\"%@\"}",selected_date,flight_num,boardin_num,data.length,imageHash,upload_picname];
           
           [LogUtil debug:[NSString stringWithFormat:@"%s json3:%@",__FUNCTION__,json_str]];

           //    NSString *file_len=[NSString stringWithFormat:@"%d",data.length];
           //使用post方法请求http
           NSString *token_url=[NSString stringWithFormat:@"%@/token",kapod_file_server];
           NSURL *url = [NSURL URLWithString:token_url];
           NSError *error;
           
           NSData *testData = [json_str dataUsingEncoding: NSUTF8StringEncoding];
           // Byte *testByte = (Byte *)[testData bytes];  
           ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
           //    [request setDelegate:self];
           [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
           [request addRequestHeader:@"Accept" value:@"application/json"];
           [request setRequestMethod:@"POST"];
           [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
           [request setPostBody:testData];
           [request startSynchronous];
           
           NSError *error1 = [request error];
           NSString *response=nil;
           
           if (!error1) {
               int statuscode=[request responseStatusCode]; 
               if (statuscode==200) {
                   
               NSString* temp_response = [request responseString];
               NSDictionary *dic=[temp_response objectFromJSONString];
                response=[dic objectForKey:@"result"];
                   
                   [LogUtil debug:[NSString stringWithFormat:@"%s token2 is %@ ;dic is %@",__FUNCTION__,response,[dic description]]];

             if (response!=nil) {

               NSDictionary *picdic=[NSDictionary dictionaryWithObjectsAndKeys:nowTime,@"upload_id",picname,@"image_name",picname,@"image_code",@"1",@"upload_state",response,@"image_token",@"0",@"upload_start_index", nil];
               [[KapokDAO getDatabase] addUploadImage:picdic];
                    }
               }
             
           }
           if (response==nil) {
               NSLog(@"-token----error1：%@",error1);
               [[KapokDAO getDatabase]updateKapodUploadState:nowTime andState:3];//设置上传失败
               NSDictionary *picdic=[NSDictionary dictionaryWithObjectsAndKeys:nowTime,@"upload_id",picname,@"image_name",picname,@"image_code",@"1",@"upload_state",@"0",@"upload_start_index", nil];
               [[KapokDAO getDatabase] addUploadImage:picdic];
           }
  
           if(small_imageRef)
           {
               image = [UIImage imageWithCGImage:small_imageRef];
               data =UIImageJPEGRepresentation(image, 1);
               
           }
           picname=[NSString stringWithFormat:@"%@_icon_%d.jpg",nowTime,i];
           //存入本地
           picpath = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname];
           //  NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
           if (data!=nil) {
               
               BOOL success= [data writeToFile:picpath atomically:YES];
               if (!success) {
                   [pool release];
                   return;
               }
               
           }
           [pool release];
       }
       [[LCLLoadingView currentIndicator]hiddenForcibly:true];
       [self.navigationController popViewControllerAnimated:YES];
   
   
   }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [memberScroll subviews])
    {
        [eachView removeFromSuperview];
    }
    
}

-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
//    可以选择的图片的最大数量
    max_num = max_upload_pic_count - [manyPicArray count];
    
//    整个scrollView高度
    float scrollViewHeight;

    //    item总数
    int totalMemberCount = manyPicArray.count;
    
//    要显示的图标总数，除了图片外 可能还有加减号
    int totalCount = totalMemberCount;

    //    是否需要显示 + -
    BOOL displayAdd = NO;
    BOOL displayMinus = NO;
    
//    如果是可编辑状态，那么如果图片个数是0，那么不显示减号；如果图片个数是5那么加号不能点击，如果是删除的状态，那么减号不显示
    if (canEditPic) {
        displayAdd = YES;
        totalCount++;

        if (manyPicArray.count > 0 && !self.start_Delete) {
            displayMinus = YES;
            totalCount++;
        }
    }
    
//    计算总行数
    int rowCount = totalCount / perRowCount;
    
    if (totalCount % perRowCount > 0) {
        rowCount ++ ;
    }
    
//    根据总行数得到显示总高度
     scrollViewHeight = rowCount * (perItemHeight + itemSpaceY) + item0Y * 2;
    
    //    修改scrollView的frame
    CGRect scrollViewFrame = memberScroll.frame;
    scrollViewFrame.size.height = scrollViewHeight;
    memberScroll.frame = scrollViewFrame;

//    计算每一项的水平间距
    float itemSpaceX = (scrollViewFrame.size.width - item0X * 2 - perItemWidth * perRowCount) / (perRowCount - 1);
    
    for (int i = 0; i < totalCount; i++) {
        //        item所在的行数 从0开始
        int rowNumber = i / perRowCount;
        
        //        item所在的列数 从0开始
        int colNumber = i % perRowCount;
        
        //        item的X值和Y值
        float itemX = item0X + colNumber * (perItemWidth + itemSpaceX);
        float itemY = item0Y + rowNumber * (perItemHeight + itemSpaceY);
        
        UIView *itemView = [[UIView alloc]init];
        itemView.frame = CGRectMake(itemX, itemY, perItemWidth, perItemWidth);
        
        itemView.backgroundColor = [UIColor clearColor];
        [memberScroll addSubview:itemView];
        [itemView release];
        
        CGRect _frame = CGRectMake(iconViewX, iconViewY, iconViewWidth, iconViewHeight);

        UIButton *iconbutton = [[UIButton alloc]initWithFrame:_frame];
        iconbutton.backgroundColor = [UIColor clearColor];
        
        iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
        iconbutton.layer.masksToBounds = YES;//设为NO去试试
        
        [itemView addSubview:iconbutton];
        [iconbutton release];
        
        if (i < totalMemberCount)
        {
//            显示图片项
            UIImage *image = nil;
            
            if (canEditPic) {
                iconbutton.tag = iconbutton_tag_0 + i;

                ALAsset *asset=[[manyPicArray objectAtIndex:i] asset];
                CGImageRef imageRef = [asset thumbnail];
                if(imageRef)
                {
                    image = [UIImage imageWithCGImage:imageRef];
                }
            }
            else
            {
                NSString *picpath = [manyPicArray objectAtIndex:i];
                
                NSData *data=[NSData dataWithContentsOfFile:picpath];
                
                image =[UIImage imageWithData:data];
            }
            
            if(image)
            {
                [iconbutton setBackgroundImage:image forState:UIControlStateNormal];
            }
            else
            {
                [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到图片",__FUNCTION__]];
            }
            
            if (self.start_Delete) {
                //            删除按钮
                CGRect _frame = CGRectMake(0, 0, deleteGroupMemberButtonSize, deleteGroupMemberButtonSize);
                UIButton *deletebutton=[[UIButton alloc]initWithFrame:_frame];
                deletebutton.tag = deletebutton_tag_0 + i;
                [deletebutton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"red_delete" andType:@"png"]] forState:UIControlStateNormal];
                [deletebutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];
                [itemView addSubview:deletebutton];
                [deletebutton release];
                
                //        如果是删除状态，那么点击头像也是删除成员
                [iconbutton addTarget:self action:@selector(deleteGroupMemberAction:) forControlEvents:UIControlEventTouchUpInside];

            }
            
        }
        else if(i == totalMemberCount)
        {
            //            是+号
            [iconbutton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"addmember" andType:@"png"]] forState:UIControlStateNormal];
            iconbutton.tag = -1;
            
            if (manyPicArray.count == max_upload_pic_count) {
                iconbutton.enabled = NO;
            }
            else
            {
                iconbutton.enabled = YES;
                [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else if(i == totalMemberCount + 1)
        {
            //            是-号
            [iconbutton setBackgroundImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"deleteGroupMember" andType:@"png"]] forState:UIControlStateNormal];
            iconbutton.tag = -2;
            
            [iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

-(void)showOldMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    int showiconNum=showiconNum;
    
	int sumnum=[manyPicArray count];
   
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
	memberScroll.pagingEnabled = NO;
    memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width , memberScroll.frame.size.height* pagenum);
    memberScroll.showsHorizontalScrollIndicator = YES;
    memberScroll.showsVerticalScrollIndicator = YES;
    memberScroll.scrollsToTop = NO;
    
	UIButton *pageview;
	
	int nowindex=0;
    UIView *itemview;
	UIButton *iconbutton;
   // UIButton *deletebutton;
    
	int x;
	int y;
	int cx;
	int cy;
    
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, memberScroll.frame.size.width, memberScroll.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
   // [pageview addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
	x=8;
	y=0;
	cx=5;
	cy=0;
    // 加号按钮在圆角矩形中的相对位置
    int constLength;
    int row=0;
	for (int j=0; j<sumnum; j++) {
		 nowindex=j;
        
		if (j/showiconNum==row) {
            
            cx=cx+67;
			if (j==0) {
                cx=7;
            }
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+constLength+5,60,60)];
            
			
		}else if (j/showiconNum!=row) {
        	
            cx=7;
            cy=cy+80;
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+constLength+5,60,60)];
            
		}
        
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
        
        
        [itemview addSubview:iconbutton];
    
        
		row=j/showiconNum;
		
        //存入本地
        NSString *picpath = [manyPicArray objectAtIndex:nowindex];
        
        NSData *data=[NSData dataWithContentsOfFile:picpath];
        
        UIImage *image =[UIImage imageWithData:data];
        		
        
		[iconbutton setBackgroundImage:image forState:UIControlStateNormal];
		iconbutton.tag=nowindex;
		
		iconbutton.backgroundColor=[UIColor clearColor];
		
		[pageview addSubview:itemview];
		[iconbutton release];
        
	}
	pageview.frame=CGRectMake(0, 0,memberScroll.frame.size.width,y+cy+115);
	//pageview.backgroundColor=[UIColor clearColor];
	[memberScroll addSubview:pageview];
	memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width, y+cy+115);
    
	[pageview release];
    
    memberScroll.frame=CGRectMake(10, 235, 300, y+cy+100);
    
}
#pragma mark - pic
- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
}

- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
	LCLShareThumbController*assetTable		=	[[LCLShareThumbController alloc]initWithNibName:nil bundle:nil];
    assetTable.isForKapokFly=YES;
    assetTable.kapok_num=max_num;
	ELCImagePickerController *elcPicker		=	[[ELCImagePickerController alloc] initWithRootViewController:assetTable];
    assetTable.pre_delegete=self;
    [assetTable setParent:elcPicker];
    [assetTable preparePhotos:pictures];
	[elcPicker setDelegate:self];
	
    [self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [assetTable release];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
}
-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    
    NSLog(@"----index-- %d",index);
    if (index==-1) {
        [self dismissKeyView];
        
        if (self.start_Delete) {
            [self onClickForDeleteStatus];
        }
        else
        {
            if(nil == pictureManager)
            {
                pictureManager	=	[[PictureManager alloc]init];
            }
            [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
        }
        
    }
    else if(index==-2)
    {
        NSLog(@"start delete group member .....");
        self.start_Delete=YES;
        [self showMemberScrollow];
    }

}
-(void)deleteGroupMemberAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=button.tag;
    
    if (index >= deletebutton_tag_0) {
        index = index - deletebutton_tag_0;
    }else if (index >= iconbutton_tag_0)
    {
        index = index - iconbutton_tag_0;
    }
    
    [manyPicArray removeObjectAtIndex:index];
    
    if (manyPicArray.count == 0) {
        self.start_Delete = NO;
    }
    [self showMemberScrollow];
}
-(void)onClickForDeleteStatus{
    //点击操作内容
    if ( self.start_Delete) {
        self.start_Delete=NO;
        [self showMemberScrollow];
    }
    
}
#pragma mark - FlatDatePicker Delegate

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
  
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FlatDatePicker" message:@"Did cancelled !" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alertView show];
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    

    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
       
    NSString *value = [dateFormatter stringFromDate:date];
    
    [dateChoose setTitle:value forState:UIControlStateNormal];

}

@end
