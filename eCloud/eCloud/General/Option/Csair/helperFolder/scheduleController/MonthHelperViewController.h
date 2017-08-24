//
//  MonthHelperViewController.h
//  eCloud
//
//  Created by  lyong on 13-11-14.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "addScheduleViewController.h"
@interface MonthHelperViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    int ringIndex;
    NSArray *dataArray;
    
}
@property(nonatomic,retain) NSArray *dataArray;
@end
