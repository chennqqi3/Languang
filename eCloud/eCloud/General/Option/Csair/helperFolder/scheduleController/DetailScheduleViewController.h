//
//  DetailScheduleViewController.h
//  eCloud
//
//  Created by  lyong on 13-10-23.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class conn;
@class editScheduleViewController;
@class personInfoViewController;
@class helperObject;

@interface DetailScheduleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSString *helper_id;
    UIScrollView *memberScroll;
    BOOL start_Delete;
    int deleteIndex;
    NSArray *dataArray;
    bool isFresh;
    conn *_conn;
    editScheduleViewController *editSchedule;
     personInfoViewController *personInfo;
    UILabel *selectLabel;
    UILabel *ringLable;
    NSMutableDictionary *ringdic;
    helperObject *hobject;
    UIButton*editbuton;
}
@property(nonatomic,retain)  NSString *helper_id;
@property(nonatomic,retain)  UIScrollView *memberScroll;
@property(nonatomic,retain) UILabel *selectLabel;
@property(assign) BOOL start_Delete;
@property(assign)int deleteIndex;
@property(nonatomic,retain) NSArray *dataArray;
@end
