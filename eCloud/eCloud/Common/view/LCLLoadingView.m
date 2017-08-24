//
//  LCLLoadingView.m
//  syncClient4
//
//  Created by Richard(wangrichao) on 12-3-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LCLLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "StringUtil.h"

@implementation LCLLoadingView

@synthesize centerMsg, subMsg;
@synthesize ignoreEvent;
@synthesize ignoreKeyboardEvent;
@synthesize delegate;
static LCLLoadingView *loadingIndicator = nil;

+ (LCLLoadingView *)currentIndicator
{
	if (nil == loadingIndicator)
	{
		CGSize	mainSize	=	[UIScreen mainScreen].bounds.size;
		CGFloat width 		= 100;
		CGFloat height 		= 100;
		CGRect centeredFrame = CGRectMake(round(mainSize.width/2 - width/2), round(mainSize.height/2 - height/2), width, height);
		
		loadingIndicator = [[LCLLoadingView alloc] initWithFrame:centeredFrame];
		
		loadingIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		loadingIndicator.opaque = NO;
		loadingIndicator.alpha = 0;
		
		loadingIndicator.layer.cornerRadius = 10;
		
		loadingIndicator.userInteractionEnabled 	=	NO;
		loadingIndicator.autoresizesSubviews 		=	YES;
		loadingIndicator.ignoreEvent					=	YES;
        loadingIndicator.ignoreKeyboardEvent = NO;
		loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;
		
		[[NSNotificationCenter defaultCenter]addObserver:loadingIndicator selector:@selector(resetPosition:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:loadingIndicator selector:@selector(resetPosition:) name:UIKeyboardDidHideNotification object:nil];
	}
	
	return loadingIndicator;
}


- (void)resetPosition:(NSNotification *)notification
{
	//CGSize kbSize	=	[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.ignoreKeyboardEvent) {
        return;
    }
    
	CGRect	rect		=	self.frame;
	if([UIKeyboardDidShowNotification isEqualToString:notification.name])
	{
		rect.origin.y	=	120;
	}
	else if([UIKeyboardDidHideNotification isEqualToString:notification.name])
	{
		CGSize	mainSize	=	[UIScreen mainScreen].bounds.size;
		CGFloat width 		= 100;
		CGFloat height 		= 100;
		rect						= CGRectMake(round(mainSize.width/2 - width/2), round(mainSize.height/2 - height/2), width, height);
		
	}
	self.frame	=	rect;
}



#pragma mark -

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[centerMsg release];
	[subMsg release];
	
	[spinner stopAnimating];
	[spinner release];
	
	[super dealloc];
}

#pragma mark Creating Message

- (void)show{
	//丢弃所有事件
	if(self.ignoreEvent)
	{
		[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
	}
	
	if ([self superview] != [[UIApplication sharedApplication] keyWindow]) 
	{
		[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	}
    
    self.center = [[UIApplication sharedApplication] keyWindow].center;
	
    [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self];
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hideAfterDelay
{
	[self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
}

- (void)hideWithDuration:(NSTimeInterval)dt
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:dt];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hiddenForcibly:)];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
}

- (void)persist
{	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hiddenForcibly:(BOOL)forcibly
{
	//监听所有事件
	[[UIApplication sharedApplication]endIgnoringInteractionEvents];
	
	if (NO == forcibly && [self alpha] > 0)
		return;
	
	self.alpha	=	0.0f;
//	[currentIndicator removeFromSuperview];
//	currentIndicator = nil;
	
	if(delegate && [delegate respondsToSelector:@selector(hideComplete:)])
	{
		[delegate hideComplete:self];
	}
}

- (void)displayActivity:(NSString *)m
{		
	[self setSubMessage:m];
	
	[centerMsg removeFromSuperview];
	centerMsg = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayCompleted:(NSString *)m
{	
	//[self setCenterMessage:@"☞ ☺"];
	[self setSubMessage:m];
	
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
	
	[self hideAfterDelay];
}

- (void)setCenterMessage:(NSString *)message
{	
	if (message == nil && centerMsg != nil)
		self.centerMsg = nil;
	
	else if (message != nil)
	{
		if (centerMsg == nil)
		{
			self.centerMsg = [[[UILabel alloc] initWithFrame:CGRectMake(5,60,self.bounds.size.width-10,20)] autorelease];
//            NSLog(@"%@",self.centerMsg);
//            NSLog(@"%@",[LCLLoadingView currentIndicator]);
            
			centerMsg.backgroundColor = [UIColor clearColor];
			centerMsg.opaque = NO;
			centerMsg.textColor = [UIColor whiteColor];
			centerMsg.font = [UIFont boldSystemFontOfSize:16.0f];
			centerMsg.textAlignment = UITextAlignmentCenter;
			centerMsg.shadowColor = [UIColor darkGrayColor];
			centerMsg.shadowOffset = CGSizeMake(1,1);
//            centerMsg.numberOfLines = 0;
//            [centerMsg sizeToFit];
//			centerMsg.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:centerMsg];
		}
		
		centerMsg.text = message;
	}
    [self showSpinner];
}

- (void)setSubMessage:(NSString *)message
{	
	if (message == nil && subMsg != nil)
		self.subMsg = nil;
	
	else if (message != nil)
	{
		if (subMsg == nil)
		{
			self.subMsg = [[[UILabel alloc] initWithFrame:CGRectMake(12,self.bounds.size.height/2,self.bounds.size.width-24,20)] autorelease];
			subMsg.backgroundColor = [UIColor clearColor];
			subMsg.opaque = YES;
			subMsg.textColor = [UIColor whiteColor];
			subMsg.font = [UIFont boldSystemFontOfSize:16.0f];
			subMsg.textAlignment = UITextAlignmentCenter;
			subMsg.shadowColor = [UIColor darkGrayColor];
			subMsg.shadowOffset = CGSizeMake(1,1);
			subMsg.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:subMsg];
		}
		subMsg.text = message;
	}
}

//Customize Spinner

- (void) showSpinner 
{
	if(nil == spinner)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		
		spinner.frame = CGRectMake((self.frame.size.width - spinner.frame.size.width)/2 ,(self.frame.size.height/3*2 - spinner.frame.size.height)/2,spinner.frame.size.width,spinner.frame.size.height);
        
 		[self addSubview:spinner];
	}
	[spinner startAnimating];
    
//    不显示对号
    if(tickView)
    {
        tickView.hidden = YES;
    }
}

- (void)showTickView
{
    if(tickView == nil)
    {
        UIImage *tickImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"tick" andType:@"png"]];
        tickView = [[UIImageView alloc]initWithImage:tickImage];
        tickView.frame = CGRectMake((self.frame.size.width - tickImage.size.width) / 2, (self.frame.size.height / 3 * 2 - tickImage.size.height)/2, tickImage.size.width, tickImage.size.height);
        NSLog(@"%@",tickView);
        [self addSubview:tickView];
        [tickView release];
    }
//    不显示加载提示
    if(spinner)
    {
        [spinner stopAnimating];  
    }
    tickView.hidden = NO;
}


@end
