//
//  modifySexViewController.h
//  eCloud
//
//  Created by  lyong on 12-11-3.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface modifySexViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    //	会话id
    NSString* _emp_id;
    UITextField *inputField;
    UIButton *boyButton;
    UIButton *girlButton;
    int sextype;
	int oldSexType;
}
@property int sextype;
@property(nonatomic,retain) NSString *emp_id;
@end
