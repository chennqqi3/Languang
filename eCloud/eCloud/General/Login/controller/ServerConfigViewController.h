//
//  ServerConfigViewController.h
//  eCloud
//
//  Created by robert on 12-12-10.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class eCloudUser;
@class ServerConfig;

@interface ServerConfigViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
	UITextField *primaryIPText;
	UITextField *primaryPortText;
	UITextField *secondIPText;
	UITextField *secondPortText;
    UITextField *otherIPText;
    UITextField *otherPortText;
	
	UITextField *fileServerText;
	UITextField *fileServerPortText;
	UITextField *fileServerUrlText;
	
	int keyboardHeight;
	BOOL keyboardIsShowing;
	
	UITableView *_tableView;
	
	eCloudUser *_db;
	ServerConfig *_serverConfig;
}
@property (nonatomic, retain) UITextField *currentTextField;
@property (nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) ServerConfig* serverConfig;

-(void) backButtonPressed:(id) sender;
@end
