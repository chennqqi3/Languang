//
//  chatMessageViewController.h
//  eCloud
//  查看聊天资料界面 这个界面展示了会话的成员，可以增加、删除人员、可以设置新消息提醒等功能
//  Created by  lyong on 13-2-21.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
/** 头像高度 */
#define iconViewHeight 60

/** 名字label的高度 */
#define nameLabelHeight (20.0)

/** 删除成员的图标的size */
#define deleteGroupMemberButtonSize (30.0)

/** 每个item的宽度和高度 */
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)

#define perItemWidth (50.0)

#else

#define perItemWidth (60.0)

#endif

/** 头像(60) nameLabel(20) 10 头像上面留空 10 */
#define perItemHeight (iconViewHeight + nameLabelHeight + deleteGroupMemberButtonSize/2)

/**     第一行，第一列的item的x值和y值 */
#define x0 (25)
#define y0 (0)

/** 每行 之间 每列之间 item的间隔 */
//间隔需要根据宽度 根据显示的个数计算出来
//#define spaceX (10)
//#define spaceX ((self.view.frame.size.width-40-240)/4)
#define spaceY (0)

/** 展开收起群组成员的view的宽度和高度 */
#define expandButtonWidth (60.0)
#define expandButtonHeight (40.0)

#import <UIKit/UIKit.h>
@class specialChooseMemberViewController;
@class conn;
@class chatBackgroudViewController;
@class Emp;
@class SettingItem;

@interface chatMessageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

}
/** 删除成员时，记录要删除的人员下标 */
@property(assign)int deleteIndex;

/** deprecated */
@property(assign)int last_msg_id;

/** 是否正在删除讨论组成员 */
@property(assign) BOOL start_Delete;

/** 讨论组创建人 id */
@property(assign)int create_emp_id;

/** deprecated */
@property   BOOL isVirGroup;

/** 会话类型 */
@property  int talkType;

/** 会议id */
@property(nonatomic,retain) NSString *convId;

/** 会话标题 */
@property(nonatomic,retain) NSString *titleStr;

/** 因为聊天界面是一个单例，所以这个属性 deprecated  */
@property(nonatomic,retain)  id predelegete;

/** 聊天成员数组 */
@property(nonatomic,retain) NSArray *dataArray;

/** 如果是单聊，那么保存和当前用户单聊的联系人模型 */
@property(nonatomic,retain)Emp *emp;

/** 刷新讨论组成员 */
-(void)showMemberScrollow;
@end
