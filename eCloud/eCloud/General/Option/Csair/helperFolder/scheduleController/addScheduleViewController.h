//
//  addScheduleViewController.h
//  JBCalendar
//
//  Created by  lyong on 13-10-18.
//  Copyright (c) 2013年 JustBen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class conn;
@class Emp;
@class chooseMemberViewController;
@class textInputViewController;
@class specialChooseMemberViewController;
@class personInfoViewController;
@class MWViewController;
@interface addScheduleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    int showdate;
    UITextField *titleField;
    UITextView *detailField;
    UILabel *selectLabel;
    MWViewController *datepicker;
    UIScrollView *memberScroll;
     BOOL start_Delete;
      int deleteIndex;
      NSArray *dataArray;
    	bool isFresh;
      conn *_conn;
     chooseMemberViewController *chooseMember;
    NSDate *startDate;
    NSDate *endDate;
    NSMutableDictionary *ringdic;
    NSString *getRingStr;
    int getRingtype;
    UILabel *placeholderlabel;
    Emp *nowUser;
    UILabel *ringLabel;
    textInputViewController *textInput;
    UIView *detailView;
    UIImageView *detailLineImage;
    specialChooseMemberViewController *_specialchooseMember;
    bool is_from_group;
     personInfoViewController *personInfo;
}
@property(assign) bool is_from_group;
@property(nonatomic,retain)specialChooseMemberViewController *specialchooseMember;
@property(nonatomic,retain) UIImageView *detailLineImage;
@property(nonatomic,retain) UIView *detailView;
@property(nonatomic,retain) UILabel *ringLabel;
@property(nonatomic,retain) UITextField *titleField;
@property(nonatomic,retain) UITextView *detailField;
@property(nonatomic,retain) UILabel *selectLabel;
@property(nonatomic,retain) UILabel *placeholderlabel;
@property(nonatomic,retain)  UIScrollView *memberScroll;
@property(assign) BOOL start_Delete;
@property(assign)int deleteIndex;
@property(nonatomic,retain) NSArray *dataArray;
@property(nonatomic,retain)chooseMemberViewController *chooseMember;
@property(nonatomic,retain)NSDate *startDate;
@property(nonatomic,retain)NSDate *endDate;
@property(nonatomic,retain)NSString *getRingStr;
@property(assign)int getRingtype;
-(void)showMemberScrollow;
@end
