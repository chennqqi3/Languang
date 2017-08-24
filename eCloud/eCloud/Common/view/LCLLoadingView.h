//
//  LCLLoadingView.h
//  syncClient4
//
//  Created by Richard(wangrichao) on 12-3-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LCLLoadingDelegate <NSObject>
@optional
- (void)hideComplete:(id)sender;

@end

@interface LCLLoadingView : UIView
{
	id<LCLLoadingDelegate>delegate;
	
	UILabel *centerMsg;
	UILabel *subMsg;
	UIActivityIndicatorView *spinner;
	BOOL		IgnoreEvent;
    BOOL ignoreKeyboardEvent;//设置是否监听键盘事件
    UIImageView *tickView;
    
}
@property(nonatomic,assign)id<LCLLoadingDelegate>delegate;
@property BOOL		ignoreEvent;
@property (nonatomic,assign) BOOL		ignoreKeyboardEvent;
@property (nonatomic, retain) UILabel *centerMsg;
@property (nonatomic, retain) UILabel *subMsg;


+ (LCLLoadingView *) currentIndicator;

- (void)show;
- (void)hideAfterDelay;
- (void)hideWithDuration:(NSTimeInterval)dt;
- (void)hiddenForcibly:(BOOL)forcibly;
- (void)displayActivity:(NSString *)m;
- (void)displayCompleted:(NSString *)m;
- (void)setCenterMessage:(NSString *)message;
- (void)setSubMessage:(NSString *)message;
- (void)showSpinner;

//显示对号，不显示indiciator
- (void)showTickView;

@end
