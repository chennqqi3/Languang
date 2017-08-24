//
//  modifyAddressViewController.h
//  eCloud
//
//  Created by yanlei on 2017/2/16.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class eCloud;

@interface modifyAddressViewController : UIViewController<UITextFieldDelegate>
{
    //	会话id
    NSString* _emp_id;
    eCloud *_ecloud;
    UITextField *inputField;
    NSString *_oldAddress;
    UILabel *titlelabel;
}

@property(nonatomic,retain) NSString *emp_id;
@property(nonatomic,retain) NSString *oldAddress;
@end
