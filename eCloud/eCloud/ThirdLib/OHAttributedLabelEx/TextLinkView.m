//
//  TextLinkView.m
//  eCloud
//
//  Created by  lyong on 13-10-11.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "TextLinkView.h"
#import "OHAttributedLabelEx.h"
#import "eCloudDefine.h"
#import "FontSizeUtil.h"
#import "PersonServiceSingle.h"
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

@interface TextLinkView()
{
    OHAttributedLabelEx * labelEx_;
    UIWebView *callPhoneWebVw;
    // TestFrameView * testFrameView_;
}
@property(nonatomic, retain) OHAttributedLabelEx * labelEx;
@property(nonatomic, retain)  UIWebView *callPhoneWebVw;

//@property(nonatomic, retain) TestFrameView * testFrameView;
@end

@implementation TextLinkView
@synthesize textColor;
@synthesize linkTextColor;

@synthesize labelEx = labelEx_;
@synthesize callPhoneWebVw = callPhoneWebVw_;
@synthesize textstr;
@synthesize textWidth;
//@synthesize testFrameView = testFrameView_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        UIFont * font = [UIFont systemFontOfSize:16];
//        self.labelEx = [[[OHAttributedLabelEx alloc] init] autorelease];
//        self.labelEx.delegate = (id)self;
//        [self.labelEx setTextColor:[UIColor blackColor]];
//        [self.labelEx setLinkColor:[UIColor blueColor]];
//        [self.labelEx setFont:font];
        
    }
    return self;
}
-(CGSize)getViewSize
{
    if (self.labelEx!=nil) {
        [self.labelEx.view removeFromSuperview];
    }
    UIFont * font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
    self.labelEx = [[[OHAttributedLabelEx alloc] init] autorelease];
    self.labelEx.delegate = (id)self;
    [self.labelEx setTextColor:self.textColor];
    [self.labelEx setLinkColor:self.linkTextColor];
    [self.labelEx setFont:font];
	self.labelEx.text = self.textstr;
    self.labelEx.maxWidth = self.textWidth;
    [self.labelEx updateUI];
    self.labelEx.frameOrigin = CGPointMake(0,0);
    self.frame=self.labelEx.view.frame;
    
    return self.labelEx.view.frame.size;
}

-(void)updateShowContent
{

    [self addSubview:self.labelEx.view];
    self.labelEx.frameOrigin = CGPointMake(0,0);
    self.frame=self.labelEx.view.frame;
}


- (void)dealloc
{
    self.linkTextColor = nil;
    self.textColor = nil;
    
    [labelEx_ release];
    [callPhoneWebVw_ release];
    //   [testFrameView_ release];
    [super dealloc];
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
    //    NSString *newstr=[urlstr lowercaseString];
    NSRange httprange=[urlstr rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    NSRange httpsrange=[urlstr rangeOfString:@"https://"];
    NSString *newhttp=urlstr;
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
    }else if([urlstr rangeOfString:@"lyancom"].length > 0){
        NSMutableArray *linkArrTmp = [NSMutableArray array];
        
        
        if ([label.text rangeOfString:@"[link]"].length > 0 || [label.text rangeOfString:@"[link submit="].length > 0) {
            if ([label.text rangeOfString:@"[link submit="].length > 0) {
                NSArray *linksTmpArr = [label.text componentsSeparatedByString:@"[link submit="];
                for (int i = 1; i < linksTmpArr.count; i++) {
                    label.text = [label.text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[link submit=\"%d\"]",i] withString:@"[link]"];
                }
            }
                
            // 将标签内容选出来
            NSArray *linksArr = [label.text componentsSeparatedByString:@"[link]"];
            // 将标签内容选出来
            for (int i = 1; i < linksArr.count; i++) {
                NSString *linkContent = linksArr[i];
                [linkArrTmp addObject:[linkContent componentsSeparatedByString:@"[/link]"][0]];
                // 若选中的内容中包含AGENT标签，用空串替换掉
                if (linkArrTmp[i-1] && [linkArrTmp[i-1] rangeOfString:@"[AGENT]"].length > 0) {
                    linkArrTmp[i-1] = [linkArrTmp[i-1] stringByReplacingOccurrencesOfString:@"[AGENT]" withString:@""];
                    linkArrTmp[i-1] = [linkArrTmp[i-1] stringByReplacingOccurrencesOfString:@"[/AGENT]" withString:@""];
                }
            }
        }
        if (_robotClickTextBlock)
        {
            // 发送点击的文本
            NSString *clickName = linkArrTmp[[[urlstr componentsSeparatedByString:@"."][1] intValue]];
            
            PersonServiceSingle *personServiceSingle = [PersonServiceSingle sharePersonServiceSingle];
            if (personServiceSingle.personServiceArray) {
                for (NSString *convName in personServiceSingle.personServiceArray) {
                    if ([clickName isEqualToString:convName]) {
                        NSLog(@"跳转到人工服务会话");
                        _robotClickTextBlock(clickName,YES);
                        return;
                    }
                }
            }
            _robotClickTextBlock(clickName,NO);
//            _robotClickTextBlock([NSString stringWithFormat:@"%d",[[urlstr componentsSeparatedByString:@"."][1] intValue]+1]);
        }
    }else if([urlstr rangeOfString:@"href-"].length > 0){
//        NSString *requestUrl = [[urlstr componentsSeparatedByString:@"-"][1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *requestUrl = [urlstr componentsSeparatedByString:@"-"][1];
        // 将&amp;转换为&符号
        requestUrl = [requestUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestUrl]];
    }else//网址链接
    {
        [self showUrl:urlstr];
    }
    
}
#pragma mark - 设置block 将带有链接标签的选中文字传递到会话界面(void (^)(NSString *, BOOL))
- (void)setRobotClickTextBlock:(void (^)(NSString *, BOOL))robotClickTextBlock{
    _robotClickTextBlock = [robotClickTextBlock copy];
}
@end
