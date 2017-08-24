//
//  PSContactViewUtil.h
//  eCloud
//
//  Created by Richard on 13-10-31.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
//add by shisp 这个类已经不再使用，和会话列表使用同样地cell定义

#import <Foundation/Foundation.h>

#define row_height 55

#define icon_view_tag 1
#define title_label_tag 2
#define time_label_tag 3
#define detail_view_tag 4
#define unread_label_tag 5
#define unread_view_tag 6

@class Conversation;
@interface FltGroupListViewUtil : NSObject

+(UITableViewCell*)initCell:(NSString*)identifier;

+(void)configCell:(UITableViewCell*)cell andConversation:(Conversation*)conv;

@end
