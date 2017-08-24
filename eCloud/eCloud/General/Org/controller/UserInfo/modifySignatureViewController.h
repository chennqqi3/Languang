//
//  modifyTelephoneViewController.h
//  eCloud
//
//  Created by  lyong on 12-11-3.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class eCloud;

@interface modifySignatureViewController : UIViewController<UITextFieldDelegate>
{
//	会话id
NSString* _emp_id;
eCloud *_ecloud;
UITextField *inputField;
NSString *_oldSignature;
int modifyType;// 0 手机号码  1 电话
UILabel *titlelabel;
}
@property(nonatomic,retain) NSString *emp_id;
@property(nonatomic,retain) NSString *oldSignature;
@property (assign) int modifyType;
@end
