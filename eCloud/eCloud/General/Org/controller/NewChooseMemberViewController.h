//
//  NewChooseMemberViewController
//  eCloud
//  选择联系人界面 发起群聊、单聊或者提供给其它应用选择人员
//  Created by  lyong on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForwardingProtocol.h"

#define GROUP_SECTION_HEADER_HEIGHT (40.0)

@class ConvRecord;
@class talkSessionViewController;
@class conn;
@class AdvancedSearchViewController;
@class rankChooseViewController;
@class businessChooseViewController;
@class zoneChooseViewController;

@protocol ChooseMemberDelegate <NSObject>

@optional

/**
 功能描述
 轻应用里打开选择联系人界面，当用户选择好人员后，会调用此接口告知轻应用
 
 参数说明：
 retStr：用户选择的人员的账号，如果是多个账号，则使用,分隔
 
 */
- (void)didSelectContacts:(NSString *)retStr;

/**
 功能描述
 为了适应不同风格的通讯录界面，封装了选人后的业务逻辑。选人界面只负责选人，选好人员后，由独立的模块去实现业务逻辑
 
 参数说明：
 userArray:用户选择的人员数组。数组的元素可以是字典类型，也可以是Emp类型;
 */
- (void)didFinishSelectContacts:(NSArray *)userArray;

@end

@interface NewChooseMemberViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,assign) id<ForwardingDelegate> forwardingDelegate;
/** deprecated */
@property(nonatomic,retain) NSString *rank_list_str;
/** deprecated */
@property(nonatomic,retain) NSString *business_list_str;
/** deprecated */
@property(nonatomic,retain) UILabel *rankLabel;
/** deprecated */
@property(nonatomic,retain) UILabel *bussinesslLabel;


/** 已经选中的人 */
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;
/** 保存不能选择的人 */
@property(nonatomic,retain) NSMutableArray *oldEmpIdArray;


/** deprecated */
@property (nonatomic , retain) NSMutableArray * chooseArray ;
/** deprecated */
@property(nonatomic,retain) NSMutableArray *zoneArray;



/** 已经包含的成员 对应的字典 */
@property(nonatomic,retain) NSMutableDictionary *mOldEmpDic;

/** 主要是指chatMessageViewController 主要是加人成功后，这个界面也需要刷新，聊天界面也需要刷新*/
@property (nonatomic , retain) id delegete;

/** 当前正在展示的数组 */
@property (nonatomic , retain) NSMutableArray * itemArray;
/** 最近讨论组，最近联系人 */
@property (nonatomic , retain) NSMutableArray * typeArray ;
/** 所有的员工 */
@property (nonatomic , retain) NSMutableArray * employeeArray ;
/** 已废弃 */
@property (nonatomic , retain) NSMutableArray *deptArray;
/** 已废弃 */
@property (nonatomic,retain) NSTimer *searchTimer;
/** 搜索的关键字 */
@property (nonatomic,retain) NSString *searchStr;
/** 左边导航栏的部门数组 */
@property (nonatomic,retain)NSMutableArray *deptNavArray;
/** 群组数组，包括常联系人、常用部门、固定群组、我的群组 */
@property (nonatomic,retain)NSMutableArray *groupArray;

/** 转发消息 新建会话 */
@property (nonatomic, retain)ConvRecord *forwardRecord;
/** 会话ID */
@property (nonatomic,retain) NSString *newConvId;
/** 会话名称 */
@property (nonatomic,retain) NSString *newConvTitle;
/** 会话类型 */
@property (nonatomic,assign) int newConvType;
/** 搜索出来的联系人 */
@property (nonatomic,retain)NSMutableArray *searchResults;
/** 是不是从聊天记录来的 */
@property (nonatomic,assign)bool isComeFromChatHistory;
/** 文件助手转发的消息 */
@property (nonatomic,retain) NSMutableArray * forwardRecordsArray;
/** 是不是从文件助手打开的 */
@property (nonatomic,assign)BOOL isComeFromFileAssistant;

/** deprecated */
@property(nonatomic,assign)BOOL isAdvancedSearch;

/** 转发类型 */
@property (nonatomic,assign) int transferFromType;



/** 用来记录之前的层级所在的位置，返回时就让界面在上次离开时的位置 */
@property (nonatomic,retain) NSMutableArray *contentOffSetYArray;




/** 转发来自哪个界面 功能和转发类型相似，应该可以通过扩展转发类型实现 */

@property (nonatomic,retain) NSString *fromWhere;


/** 选中或未选中 */
-(void)selectByDept:(int)dept_id status:(bool)selectedStatus;
-(void)selectByEmployee:(int)emp_id status:(bool)selectedStatus;
-(void)selectAction:(id)sender;


/**
 
 参数说明
 选择联系人类型
 
 */
@property(nonatomic,assign)int typeTag;


/**
 参数说明:
 单选还是多选
 
 YES：单选 NO：多选
 */
@property (nonatomic,assign) BOOL isSingleSelect;

/**
 参数说明
 选择人员delegate
 
 协议名称：ChooseMemberDelegate
 
 需要实现以下代理方法
 - (void)didSelectContacts:(NSString *)retStr;
 */
@property (nonatomic,assign) id<ChooseMemberDelegate> chooseMemberDelegate;

/**
 参数说明
 默认已经选中的用户账号
 
 如果没有则可以传nil或者@"",每个账号之间使用,分隔
 */
@property(nonatomic,retain) NSString *defaultSelectedUserAccounts;

@end
