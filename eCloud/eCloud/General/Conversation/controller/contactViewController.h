//
//  contactViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class chooseMemberViewController;
@class talkSessionViewController;
@class specialChooseMemberViewController;
@class personInfoViewController;
@class personGroupViewController;
@class conn;
@class eCloudNotification;
@class helperObject;
@class Conversation;

#define SEARCHBAR_X 42


@interface contactViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIAlertViewDelegate,UISearchDisplayDelegate>
{
    id delegete;
    talkSessionViewController *_talkSession;
    NSMutableArray * itemArray ;

	UITableView *_personTable;

    personInfoViewController *_personInfo;
	UIView *_reLinkView;

	personGroupViewController *personGroup;
	UITextView *searchTextView;
	conn *_conn;
	
	BOOL isSearch;              /** 是否正在搜索 */
	NSString *_searchText;      /** 搜索的关键字 */
	
    UISearchBar *_searchBar;
    UIButton *backgroudButton;
    
   
//	手动连接选择在一个新的线程里进行，这样不会阻塞主线程，所以从连接线程里发出通知，需要通知在主线程上执行
	NSString *notificationName;//通知名称
	eCloudNotification *notificationObject;//通知带的对象
    UIView *footview;
    helperObject *hObject;  /** 最近时间的日程 */
    
    UIAlertView *loginErrorAlert;
    UIImageView*listenModeView;
    
    UISearchBar * theSearchBar;
}

/** deprecated */
@property (nonatomic,assign) BOOL isLoad;

/** 展示会话列表的tableview */
@property(nonatomic,retain)UITableView *personTable;

/** 当用户被踢后，显示重新连接的view */
@property(nonatomic,retain)UIView *reLinkView;

/** 会话列表数组 */
@property (atomic , retain) NSMutableArray * itemArray ;

/** 保存一个Dictionary，key是convId value是对应的Conversation对象 */
@property (atomic,retain) NSMutableDictionary *itemDic;

/** deprecated */
@property(nonatomic,assign)id delegete;

/** 聊天界面对象，talkSessionViewController是单例 所以定义这个也没有必要 */
@property(nonatomic,retain) talkSessionViewController *talkSession;

/** 已弃用 */
@property(retain) NSString* searchText;

/** 已弃用 */
@property (nonatomic,retain) NSTimer *searchTimer;

/** 搜索的关键字 */
@property (nonatomic,retain) NSString *searchStr;

/**
 找到包含查询条件的文本类型的消息，如果某个会话只包含了一条，则直接返回匹配的这条消息，如果包含了多条，则显示n条记录，生成对应的Conversation对象，放到数组里返回用来在界面上展示
*/
@property (nonatomic,retain) NSMutableArray *searchResults;
@property (nonatomic,retain) NSMutableArray *convSearchResults;      /** 包含关键字的会话 */


/**
 从会话界面打开某个会话

 @param conv 要打开的会话
 */
- (void)openConversation:(Conversation *)conv;


/**
 拨打电话时或者结束通话时，重新计算Frame
 */
- (void)reCalculateFrame;


/**
 打开会话 静态方法 在查询历史记录或者其它情况 时 可以使用

 @param conv 会话model
 @param curViewController 当前界面
 */
+ (void)openConversation:(Conversation *)conv andVC:(UIViewController *)curViewController;


/**
 获取未读数，在会话标签上显示未读数
 */
-(void)showNoReadNum;

/** 如果是听筒模式，那么在导航栏增加一个耳朵的图标 */
+ (UIView *)addListenModeView:(UIViewController *)curVC;

/** 修改听筒模式图标的位置 */
+ (void)setListenModeViewFrame:(UIView *)modeView andTitleWidth:(float)titleWidth;

/** 打开搜索到的单人聊天或者群里 */
+ (void)openSearchConv:(Conversation *)conv andCurVC:(UIViewController *)curVC;

/** 打开搜索到的聊天记录 */
+ (void)openSearchConvRecords:(Conversation *)conv andCurVC:(UIViewController *)curVC andSearchStr:(NSString *)searchStr;

- (void)cancelSearchStatus;

#pragma mark =====提供给SDK调用的接口======

/*
 功能描述：
 获取导航栏右侧按钮
 */
- (UIButton *)rightBarButton;

/*
 功能描述：
 点击导航栏右侧按钮事件
 */
- (void)onRightBarButton;

/*
 功能描述
 双击滑动到下一条包含未读消息的会话
 */
- (void)scrollToNextUnreadConv;
@end
