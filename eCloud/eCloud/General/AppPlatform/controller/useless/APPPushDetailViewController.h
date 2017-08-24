//
//  APPPushDetailViewController.h
//  eCloud
//
//  Created by Pain on 14-6-24.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;

@interface APPPushDetailViewController :UITableViewController
{
    Conversation *conv;
}
- (id)initWithConversation:(Conversation *)_conv;

//应用推送消息
@property (nonatomic,retain) NSMutableArray *appPushArr;

@end
