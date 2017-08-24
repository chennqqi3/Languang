//
//  APPIntroViewController.h
//  eCloud
//
//  Created by Pain on 14-7-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPIntroViewController : UITableViewController{
    NSString *appid;
}
- (id)initWithAppID:(NSString *)appid;
@end
