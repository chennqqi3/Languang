//
//  safeKeyboard.h
//  safeKeyboard
//
//  Created by Alex L on 15/11/13.
//  Copyright © 2015年 Alex L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SafeKeyboardDelegate <NSObject>

- (void)setPasswordTextField:(NSString *)text;
- (void)clickLoginButton;

@end

@interface SafeKeyboard : UIWindow

@property (nonatomic, assign) id<SafeKeyboardDelegate> safeKeyBoardDelegate;

@end
