//
//  broadcastRecoredMoreMemberViewController.h
//  eCloud
//
//  Created by  lyong on 14-1-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class conn;
@interface broadcastRecoredMoreMemberViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *broadcastMemberListTable;
    NSMutableArray *otheremps_Array;
    int msg_id;
    conn *_conn;
    UIImage *newMsgImage;
}
@property(assign)int msg_id;
@property(nonatomic,retain) NSMutableArray *otheremps_Array;
@end
