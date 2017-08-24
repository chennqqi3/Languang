//
//  aboutViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eCloudUser.h"
#import "conn.h"
@interface aboutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
	conn *_conn;
}
@end
