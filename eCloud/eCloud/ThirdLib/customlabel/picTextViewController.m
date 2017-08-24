//
//  picTextViewController.m
//  eCloud
//
//  Created by  lyong on 13-7-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
#import "picTextViewController.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "eCloudDefine.h"
#import "FaceUtil.h"

#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"
#import <QuartzCore/QuartzCore.h>
@interface picTextViewController ()

@end

@implementation picTextViewController
@synthesize inputStr;
@synthesize inputStrCopy;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if(inputStr==nil){
//        inputStr = [[NSMutableString alloc] initWithCapacity:0];
//    }
//    [inputStr appendFormat:@"www.baidu.com 12345678"];
//    NMCustomLabel *lab = (NMCustomLabel *)[self.view viewWithTag:1];
//    UIFont *fon = [UIFont systemFontOfSize:13.0f];
//    CGSize size=[inputStr sizeWithFont:fon constrainedToSize:CGSizeMake(300, 2000)];
//    [lab setFrame:CGRectMake(10, 32, size.width, size.height+36)];
//    lab.text = inputStr;
//    lab.shouldLinkTypes = kNMShouldLinkURLs | kNMShouldLinkUsernames;
//	lab.delegate = self;
//	lab.linkColor = [UIColor colorWithRed:0 green:102/255.0 blue:153/255.0 alpha:1];
//	lab.activeLinkColor = [UIColor colorWithRed:0 green:170/255.0 blue:255/255.0 alpha:1];
//    
//    [textField resignFirstResponder];
//    return YES;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    //    NMCustomLabel *label3 = [[NMCustomLabel alloc] initWithFrame:CGRectMake(30, 43, self.view.frame.size.width-60, 50)];
    //    [label3 setTag:1];
    //	label3.text = @"test area!!";
    //	[label3 setDefaultStyle:[NMCustomLabelStyle styleWithFont:[UIFont fontWithName:@"Georgia" size:14] color:[UIColor colorWithRed:98/255.0 green:227/255.0 blue:104/255.0 alpha:1]]];
    //	[label3 setStyle:[NMCustomLabelStyle styleWithImage:[StringUtil getImageByResName:@"0.png"] verticalOffset:-8] forKey:@"fez"];
    //	label3.lineHeight = 25;
    //	[self.view addSubview:label3];
    //    return;
    //  创建一个lab，设置默认字体，因为如果不设置默认text则会在第一次加载中崩溃
    //    实际应用中，可以在使用是创建，省去很多麻烦。
    NMCustomLabel *lab = [[NMCustomLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    lab.backgroundColor=[UIColor clearColor];
    //    设置tag，方便复用。
    [lab setTag:1];
    //    默认text
    lab.text = @"welcome to here";
    //    根据string内容智能的绘制lab
    UIFont *fon = [UIFont systemFontOfSize:16];
    CGSize size=[lab.text sizeWithFont:fon constrainedToSize:CGSizeMake(self.view.frame.size.width, 2000)];
    //    绘制frame
   // [lab setFrame:CGRectMake(0, 0, size.width, size.height)];
     [lab setFrame:CGRectMake(0, 0, size.width, size.height+36)];
    //    设置参数
    lab.shouldBoldAtNames = NO;
    //    是否区分url
	lab.shouldLinkTypes = kNMShouldLinkURLs ;
    //    绑定委托
	lab.delegate = [self retain];
    //    设置链接颜色以及点击颜色
	lab.linkColor = [UIColor colorWithRed:0 green:102/255.0 blue:153/255.0 alpha:1];
	lab.activeLinkColor = [UIColor colorWithRed:0 green:170/255.0 blue:255/255.0 alpha:1];
    //    设置字体
	lab.font = fon;
   // lab.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
	lab.kern = 0;
   // lab.textColor = [UIColor grayColor];
	//lab.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    //    设置label每一行的高度
	lab.lineHeight = 26;
    lab.numberOfLines=100;
    [lab setStyle:[NMCustomLabelStyle styleWithFont:fon color:lab.textColor] forKey:NMCustomLabelStyleDefaultKey];
    [self.view addSubview:lab];
    [lab release];
    
    self.view.frame=lab.frame;
//    lab.backgroundColor=[UIColor whiteColor];
//    lab.layer.masksToBounds = YES;//设为NO去试试
//    self.view.layer.masksToBounds = YES;//设为NO去试试
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)showPicOrText:(NSMutableArray *)data
{
    NSString *str;
    NSString *imageName;
    UIImage *image1;
    CGSize  size = CGSizeMake(24, 24);
    UIImage *image=nil;
    NSString *tempStr;
    NMCustomLabel *lab;
    //	先计算view的长度和宽度
	for(int i = 0;i<[data count];i++)
	{   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		tempStr = [data objectAtIndex:i];
        
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
            //    将表情字符串换算成表情，添加到string中
//            NSRange range=[tempStr rangeOfString: BEGIN_FLAG];
//            NSRange range1=[tempStr rangeOfString: END_FLAG];
//            NSString *str;
//            //判断当前字符串是否还有表情的标志。
//            if (range.length>0 && range1.length>0) {
//                str=[tempStr substringWithRange:NSMakeRange(range.location+2, range1.location-2-range.location)];
//                
//            }else
//            {
//                continue;
//            }
            imageName = [FaceUtil getFaceIconNameWithFaceMsg:tempStr];
            
			image1 = [StringUtil getImageByResName:imageName];
//            if (image) {
//                [image release];
//            }
            image= [ImageUtil scaledImage:image1  toSize:size withQuality:kCGInterpolationLow];
            //[image retain];
            
            if(inputStr==nil){
                inputStr = [[NSMutableString alloc] initWithCapacity:0];
                 inputStrCopy= [[NSMutableString alloc] initWithCapacity:0];
            }
            NSString *strid=[NSString stringWithFormat:@"%@%d",str,i];
            [inputStr appendFormat:@"<span class='%@'>——</span>",strid];
            [inputStrCopy appendFormat:@"——"];
            //    通过tag获取到label对象
            lab = (NMCustomLabel *)[self.view viewWithTag:1];
           UIFont *fon = [UIFont systemFontOfSize:16.0f];
            //    设置frame
            CGSize picsize=[inputStrCopy sizeWithFont:fon constrainedToSize:CGSizeMake(230, 2000)];
            [lab setFrame:CGRectMake(0, 0,picsize.width, picsize.height+26)];
    
            //  将选择的表情图片加入到label中
            lab.text = inputStr;
            //lab.lineHeight = 24;
            [lab setStyle:[NMCustomLabelStyle styleWithImage:image verticalOffset:-6] forKey:strid];
//            UIFont *fon=[UIFont systemFontOfSize:16];
//            [lab setStyle:[NMCustomLabelStyle styleWithFont:fon color:lab.textColor] forKey:NMCustomLabelStyleDefaultKey];
           // [label3 setStyle:[NMCustomLabelStyle styleWithFont:fon color:label3.textColor] forKey:NMCustomLabelStyleDefaultKey];
          //  [image release];
 //           NSLog(@"---inputStr- %@",inputStr);
//            UIFont *fon = [UIFont systemFontOfSize:16.0f];
//            //    设置frame
//            int width=self.view.frame.size.width;
//            int heigh=self.view.frame.size.height;
//            CGSize fontsize=[inputStr sizeWithFont:fon constrainedToSize:CGSizeMake(width,heigh)];
//            [label3 setFrame:CGRectMake(0, 0,fontsize.width, fontsize.height)];
		}
		else
		{
            if(inputStr==nil){
                inputStr = [[NSMutableString alloc] initWithCapacity:0];
                inputStrCopy= [[NSMutableString alloc] initWithCapacity:0];
            }
            [inputStr appendFormat:@"%@",tempStr];
            [inputStrCopy appendFormat:@"%@",tempStr];
            lab = (NMCustomLabel *)[self.view viewWithTag:1];
            UIFont *fon = [UIFont systemFontOfSize:20.0f];
            CGSize size=[inputStrCopy sizeWithFont:fon constrainedToSize:CGSizeMake(230, 2000)];
            [lab setFrame:CGRectMake(0, 0, size.width, size.height+26)];
            lab.text = inputStr;
              // lab.shouldLinkTypes = kNMShouldLinkURLs | kNMShouldLinkUsernames;
            //lab.delegate = self;
            //lab.lineHeight = 25;
            lab.linkColor = [UIColor colorWithRed:0 green:102/255.0 blue:153/255.0 alpha:1];
            lab.activeLinkColor = [UIColor colorWithRed:0 green:170/255.0 blue:255/255.0 alpha:1];
//            UIFont *fon=[UIFont systemFontOfSize:16];
//            [lab setStyle:[NMCustomLabelStyle styleWithFont:fon color:lab.textColor] forKey:NMCustomLabelStyleDefaultKey];
//            if ([lab hasHighlightedText]) {
//                NSLog(@"------hasHighlightedText-");
//            }else
//            {
//                NSLog(@"--no----hasHighlightedText");
//            }

		}
        [pool release];
	}
	
    [inputStr release];
     self.view.frame=lab.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NMCustomLabelDelegate
-(void)customLabelDidBeginTouch:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog{
NSLog(@"-tel-here---customLabelDidBeginTouch");
}
-(void)customLabelDidBeginTouchOutsideOfHighlightedText:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog{
NSLog(@"-tel-here---customLabelDidBeginTouchOutsideOfHighlightedText");
}
-(void)customLabel:(NMCustomLabel *)customLabel didChange:(UILongPressGestureRecognizer *)recog{
NSLog(@"-tel-here---didChange");
}
-(void)customLabelDidEndTouch:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog{
NSLog(@"-tel-here---customLabelDidEndTouch");
}
-(void)customLabelDidEndTouchOutsideOfHighlightedText:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog{
 NSLog(@"-tel-here---customLabelDidEndTouchOutsideOfHighlightedText");
}
-(void)customLabel:(NMCustomLabel *)customLabel didSelectText:(NSString *)text type:(kNMTextType)textType{
	switch (textType) {
		case kNMTextTypeLink:
            
			NSLog(@"loading: %@", text);
            //	NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",emp.emp_mobile];
            //	NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",emp.emp_mobile];
            //	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
            NSString *lowerstr=[text lowercaseString];
            NSRange range=[lowerstr rangeOfString:@".com"];
            NSRange range1=[lowerstr rangeOfString:@"www."];
            if (range.location==NSNotFound&&range1.location==NSNotFound) {//电话拨打
                NSURL *phoneURL;
                //手机call
                phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",text]];
                NSLog(@"-tel-here---doing");

                UIWebView *callPhoneWebVw = [[UIWebView alloc] init];
                NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
                [callPhoneWebVw loadRequest:request];
                //[callPhoneWebVw release];
//                if (telAlert==nil) {
//                    telAlert=[[UIAlertView alloc]initWithTitle:@"可能是电话号码或手机号码" message:text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
//                }
//                telAlert.title=@"可能是电话号码或手机号码";
//                telAlert.message=text;
//                [telAlert show];
            }
            else
            {   NSString *newstr=[text lowercaseString];
                NSRange httprange=[newstr rangeOfString:@"http://"];
                NSRange httpsrange=[newstr rangeOfString:@"https://"];
                NSString *newhttp=text;
                if (httprange.location==NSNotFound && httpsrange.location==NSNotFound ) {
                    newhttp=[NSString stringWithFormat:@"http://%@",text];
                }
              [[NSNotificationCenter defaultCenter ]postNotificationName:OPEN_WEB_NOTIFICATION object:newhttp userInfo:nil];
               //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:text]];
            }
 			break;
		case kNMTextTypeUsername:
//			NSLog(@"loading: twitter.com/%@", text);
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", text]]];
			break;
		default:
			break;
	}
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSURL *phoneURL;
        //手机call
        phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",alertView.message]];
        NSLog(@"-tel-here---doing");
        [[UIApplication sharedApplication] openURL:phoneURL];
        //2、用UIWebView来实现，打电话结束后会返回当前应用程序：
//        
        UIWebView *callPhoneWebVw = [[UIWebView alloc] init];
        NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
        [callPhoneWebVw loadRequest:request];
    }

}
@end

