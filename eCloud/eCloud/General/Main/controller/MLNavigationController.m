//
//  MLNavigationController.m
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "MLNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "broadcastListViewController.h"

@interface MLNavigationController ()<UIGestureRecognizerDelegate>
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@end

@implementation MLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.screenShotsList = [[[NSMutableArray alloc]init]autorelease];
        self.canDragBack = YES;
        
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // draw a shadow for navigation view to differ the layers obviously.
    // using this way to draw shadow will lead to the low performace
    // the best alternative way is making a shadow image.
    //
    //self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    //self.view.layer.shadowOffset = CGSizeMake(5, 5);
    //self.view.layer.shadowRadius = 5;
    //self.view.layer.shadowOpacity = 1;
    
    UIImageView *shadowImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]]autorelease];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
    UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(paningGestureReceive:)]autorelease];
    [recognizer delaysTouchesBegan];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    
    [super pushViewController:viewController animated:animated];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -

// get the current view screen shot
/*
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
 
//    NSData *data;
//    
//    if (UIImagePNGRepresentation(img) == nil) {
//        
//        data = UIImageJPEGRepresentation(img, 1);
//        
//    } else {
//        
//        data = UIImagePNGRepresentation(img);
//        
//    }
//    
//     NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *filePath = @"/Users/peihuazhu/Desktop";
//    [fileManager createFileAtPath:[filePath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
 
    return img;
}
*/

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions([[UIScreen mainScreen] bounds].size, self.view.opaque, 0.0);
    
    if (self.parentViewController) {
        [self.parentViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }else{
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


// set lastScreenShotView 's position and alpha when paning

- (void)moveViewWithX:(float)x
{
    float width = self.view.frame.size.width;
    //   NSLog(@"Move to:%f",x);
    x = x>width?width:x;
    x = x<0?0:x;
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
//    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    //    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    
    frame = lastScreenShotView.frame;
    frame.origin.x =  (x - width)*0.3;
    lastScreenShotView.frame = frame;
    blackMask.alpha = alpha;
}

/*
- (void)moveViewWithX:(float)x
{
    
//    NSLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
//    float scale = (x/6400)+0.95;
    float alpha = 0.2+(x/300);

//    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
//    blackMask.alpha = alpha;
    lastScreenShotView.alpha = alpha;
//    CGRect _backFream = self.backgroundView.frame;
//    _backFream.origin.x +=x/3;
//    self.backgroundView.frame = _backFream;
}
*/


#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    

    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        self.backgroundView = nil;
        
//        if (!self.backgroundView)
//        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
      
            [self.backgroundView setBackgroundColor:[UIColor blackColor]];

            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
//            blackMask.backgroundColor = [UIColor redColor];

            [self.backgroundView addSubview:blackMask];
            [blackMask release];
//            [self.view.superview insertSubview:blackMask belowSubview:self.view];
//        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView)
        {
            [lastScreenShotView removeFromSuperview];

        }

        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        /*
        NSData *data;
        
        if (UIImagePNGRepresentation(lastScreenShot) == nil) {
            
            data = UIImageJPEGRepresentation(lastScreenShot, 1);
            
        } else {
            
            data = UIImagePNGRepresentation(lastScreenShot);
            
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *filePath = @"/Users/peihuazhu/Desktop";
        [fileManager createFileAtPath:[filePath stringByAppendingString:@"/last.png"] contents:data attributes:nil];
        */
        
        lastScreenShotView = [[[UIImageView alloc]initWithImage:lastScreenShot] autorelease];
//        [lastScreenShotView setBackgroundColor:[UIColor blueColor]];

        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }
    
    
    else if(recoginzer.state == UIGestureRecognizerStateChanged){
        if(touchPoint.x - startTouch.x<10)
        {
            return;
        }
    }
    
    else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 判断是不是UIButton的类 或者是文本框 输入框的类
    if ([touch.view isKindOfClass:[UIButton class]]||[touch.view isKindOfClass:[UITextView class]])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if((self.viewControllers.count == 2) && [self.viewControllers[1] isKindOfClass:[broadcastListViewController class]])
    {
        return YES;
    }
    return NO;
}


@end
