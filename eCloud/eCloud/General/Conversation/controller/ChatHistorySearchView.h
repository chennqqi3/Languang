//
//  ViewController.h
//  eCloud
//  查看聊天资料界面--查找聊天记录功能--输入搜索条件界面
//  Created by SH on 14-12-30.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatHistorySearchView : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>

/** 会话id */
@property(nonatomic,retain) NSString *convId;
/** 会话名字 */
@property(nonatomic,retain) NSString *convName;
/** 会话类型 */
@property(nonatomic,assign) int talkType;

@end
