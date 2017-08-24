
#import "WXMsgDialog.h"
#import "MBProgressHUD.h"
#import <unistd.h>

//#import "LeafNotification.h"


@implementation WXMsgDialog

static WXMsgDialog *instance = nil;

+ (WXMsgDialog *)Instance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [self new];
        }
    }
    return instance;
}



+ (void)toast:(UIViewController *)controller withMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
//    hud.cornerRadius=5;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1];
}


+ (void)toast:(NSString *)message withPosition:(float)position
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoom;
	hud.labelText = message;
//    hud.cornerRadius=5;
	hud.margin = 10.f;
	hud.yOffset = position; 
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1];
}


+ (void)toast:(NSString *)message withPosition:(float)position delay:(float)time
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
//    hud.cornerRadius=5;
    hud.margin = 10.f;
    hud.yOffset = position;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}


+ (void)toast:(NSString *)message delay:(float)time {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoom;
	hud.labelText = message;
//    hud.cornerRadius = 5;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:time];
}

//+ (void)simpleToast:(NSString *)message
//{
//    [SVProgressHUD showOnlyStatus:message withDuration:2.3];
//}
//
//+ (void)hideSimpleToast
//{
//    [SVProgressHUD dismissAfterDelay:2];
//}

+ (void)toastCenter:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.animationType = MBProgressHUDAnimationZoom;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = -20.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1.0];
}
+ (void)toastCenter:(NSString *)message delay:(CGFloat)delayTimer{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = -20.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delayTimer];
}

+ (void)toastCenter:(NSString *)message onView:(UIView *)view delay:(CGFloat)delayTimer{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.opacity = 0.5;
    hud.cornerRadius = 10.0;
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
    hud.yOffset = 150;
    hud.margin = 10;
    hud.color = [UIColor blackColor];
    hud.labelColor = [UIColor whiteColor];
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delayTimer];
}

+ (void)toastCustoastCenter:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationZoom;

    UILabel *notic = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 90)];
    notic.text = message;
    notic.textAlignment = NSTextAlignmentCenter;
    notic.font = [UIFont systemFontOfSize:17];
    notic.textColor = [UIColor whiteColor];
    notic.numberOfLines = 0;
    hud.customView = notic;
    hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1];
}

+ (void)progressToast:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = -20.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1];
}


- (void)gradient:(UIViewController *)controller seletor:(SEL)method {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
	[controller.view addSubview:HUD];
//	HUD.dimBackground = YES;
	HUD.delegate = self;
	[HUD showWhileExecuting:method onTarget:controller withObject:nil animated:YES];
}

- (void)showProgress:(UIViewController *)controller {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
//    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
}

- (void)showProgress:(UIViewController *)controller withLabel:(NSString *)labelText {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
    HUD.delegate = self;
//    HUD.dimBackground = YES;
    HUD.labelText = labelText;
    [HUD show:YES];
}

- (void)showCenterProgressWithLabel:(NSString *)labelText
{
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.delegate = self;
    //    HUD.dimBackground = YES;
    HUD.labelText = labelText;
    [HUD show:YES];
}

- (void)hideProgress {
    [HUD hide:YES];
}

- (void)progressWithLabel:(UIViewController *)controller seletor:(SEL)method {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
    HUD.delegate = self;
    //HUD.labelText = @"数据加载中...";
    [HUD showWhileExecuting:method onTarget:controller withObject:nil animated:YES];
}

#pragma mark -
#pragma mark Execution code

- (void)myTask {
	sleep(3);
}

- (void)myProgressTask {
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
}

- (void)myMixedTask {
	sleep(2);
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Progress";
	float progress = 0.0f;
	while (progress < 1.0f)
	{
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Cleaning up";
	sleep(2);
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]] ;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
	sleep(2);
}

#pragma mark -
#pragma mark NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedLength = [response expectedContentLength];
	currentLength = 0;
	HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	currentLength += [data length];
	HUD.progress = currentLength / (float)expectedLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
	HUD.mode = MBProgressHUDModeCustomView;
	[HUD hide:YES afterDelay:1];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[HUD hide:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	HUD = nil;
}


#pragma mark---------hhhhhh------
+(void)toastCustom:(NSString *)message delay:(float)time {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled=NO;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = message;
//    hud.cornerRadius=5;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}


//+(void)LeafNoti:(NSString *)message controller:(UIViewController *)controller
//{
//    [LeafNotification showInController:controller withText:message ntype:LeafNotificationTypeWarrning];
//}
//
//+(void)LeafNoti:(NSString *)message controller:(UIViewController *)controller delay:(float)time
//{
//    LeafNotification  *notView=[[LeafNotification alloc]initWithController:controller text:message type:LeafNotificationTypeWarrning];
//    notView.duration=time;
//    [controller.view  addSubview:notView];
//    [notView showWithAnimation:YES];
//}



@end
