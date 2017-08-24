//
//  modifyPasswordViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface modifyPasswordViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView* passwordTable;
    NSString *oldPasswordRecord;
    NSString *oldPassword;
    NSString *newPassword;
    NSString *newPasswordAgain;
    UITextField *oldPasswordField;
    UITextField *newPasswordField;
    UITextField *newPasswordAgainField;
    NSString *userEmail;
}
@property(nonatomic,retain) NSString *oldPasswordRecord;
@property(nonatomic,retain)NSString *userEmail;

@end
