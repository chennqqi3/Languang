#import "LinkTextViewController.h"
#import "OHAttributedLabelEx.h"
#import "eCloudDefine.h"
//
//UIButton * _UIUGetUIButton(CGRect frame, NSString * title, id target, SEL action);
//
//
//@interface TestFrameView : UIView
//@end
//@implementation TestFrameView
//- (id)initWithFrame:(CGRect)frame
//{
//    if(self = [super initWithFrame:frame])
//    {
//        self.backgroundColor = [UIColor clearColor];
//    }
//    return self;
//}
//- (void)drawRect:(CGRect)rect
//{
//    [[UIColor blackColor] set];
//    
//    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.bounds];
//    [path stroke];
//}
//@end
//

@interface LinkTextViewController()
{
    OHAttributedLabelEx * labelEx_;
    UIWebView *callPhoneWebVw;
   // TestFrameView * testFrameView_;
}
@property(nonatomic, retain) OHAttributedLabelEx * labelEx;
@property(nonatomic, retain)  UIWebView *callPhoneWebVw;

//@property(nonatomic, retain) TestFrameView * testFrameView;
@end

@implementation LinkTextViewController
@synthesize labelEx = labelEx_;
@synthesize callPhoneWebVw = callPhoneWebVw_;
@synthesize textstr;
@synthesize textWidth;
//@synthesize testFrameView = testFrameView_;

- (void)dealloc
{
    [labelEx_ release];
    [callPhoneWebVw_ release];
 //   [testFrameView_ release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    /// AttributedLabeEx:
    //
    UIFont * font = [UIFont systemFontOfSize:16];
//    NSString * text = @"c&lt  &xx <www.baidu.com [face100] www.baidu.com http://baidu.com [xx]http://baidu.com [太开心2]12345 123456781234567890123456 [太开心][太开心][太开心][太开心][太开心][太开心][太开心][太开心][太开心][太开心]";
   // NSString * text = @"www.baidu.com";// 12345566 lkl德国队各国工人国开发机构看jhjljjllhjhihi[/face]  http://google.com [/test]德国队各国工人国开发机构看 [/face]
  //  NSLog(@"self.textstr--- %@",self.textstr);
    CGFloat maxWidth = self.textWidth;
    self.labelEx = [[[OHAttributedLabelEx alloc] init] autorelease];
    self.labelEx.delegate = (id)self;
    self.labelEx.text = self.textstr;
    self.labelEx.maxWidth = maxWidth;
    [self.labelEx setTextColor:[UIColor blackColor]];
    [self.labelEx setLinkColor:[UIColor blueColor]];
    [self.labelEx setFont:font];
    [self.labelEx updateUI];
    
    [self.view addSubview:self.labelEx.view];
    self.labelEx.frameOrigin = CGPointMake(0,0);
    self.view.frame=self.labelEx.view.frame;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.labelEx = nil;
 //   self.testFrameView = nil;
}

-(void)showTelephone:(NSString *)iphoneNumStr
{
 //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *phoneURL;
    //手机call
    phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",iphoneNumStr]];
    NSLog(@"-tel-here---doing-- %@",iphoneNumStr);
    if (self.callPhoneWebVw==nil) {
     self.callPhoneWebVw = [[UIWebView alloc] init];   
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
    [self.callPhoneWebVw loadRequest:request];
 //   [pool release];
}

-(void)showUrl:(NSString *)urlstr
{
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     NSLog(@"-urlstr-here---doing-- %@",urlstr);
    NSString *newstr=[urlstr lowercaseString];
    NSRange httprange=[newstr rangeOfString:@"http://"];
    NSRange httpsrange=[newstr rangeOfString:@"https://"];
    NSString *newhttp=newstr;
    if (httprange.location==NSNotFound && httpsrange.location==NSNotFound ) {
        newhttp=[NSString stringWithFormat:@"http://%@",urlstr];
    }
    [[NSNotificationCenter defaultCenter ]postNotificationName:OPEN_WEB_NOTIFICATION object:newhttp userInfo:nil];
    
    //    NSString *newstr=[urlstr lowercaseString];
    //    NSRange httprange=[newstr rangeOfString:@"http://"];
    //    NSString *newhttp=newstr;
    //    if (httprange.location==NSNotFound) {
    //        newhttp=[NSString stringWithFormat:@"http://%@",urlstr];
    //    }
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newhttp]];
  //  [pool release];
}
#pragma mark - OHAttributedLabelExDelegate

-(void)attributedLabelEx:(OHAttributedLabelEx *)label
     didClickLinkWithURL:(NSURL *)linkURL
{
  //  UDLog(@"see: %@", linkURL);
   NSString *urlstr=[linkURL absoluteString];
    NSLog(@"-linkURL--- %@",linkURL);
    NSRange range=[urlstr rangeOfString:@"."];
    if (range.location==NSNotFound) {//号码
        [self showTelephone:urlstr];
    }else//网址链接
    {
       [self showUrl:urlstr];
    }
  
}

@end


