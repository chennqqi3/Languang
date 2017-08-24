//
//  broadcastRecordMemberViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class conn;
@interface broadcastRecordMemberViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
 UIScrollView *memberScroll;
 UITableView *actionTable;
 NSString *record_id;
 NSString *conv_id;
    int msg_id;
    conn *_conn;
    UIImage *newMsgImage;
}
@property(nonatomic,retain) NSString *record_id;
@property(nonatomic,retain) NSString *conv_id;
@property(assign)int msg_id;
@end
