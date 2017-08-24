//
//  modifyPositionViewController.h
//  eCloud
//
//  Created by  lyong on 13-11-9.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class eCloud;

@interface modifyPositionViewController : UIViewController<UITextFieldDelegate>
{
    //	会话id
    NSString* _emp_id;
    eCloud *_ecloud;
    UITextField *inputField;
    NSString *_oldPosition;
    UILabel *titlelabel;
}
@property(nonatomic,retain) NSString *emp_id;
@property(nonatomic,retain) NSString *oldPosition;
@end
