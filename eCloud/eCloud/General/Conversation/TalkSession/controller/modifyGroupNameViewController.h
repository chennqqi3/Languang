//
//  modifyGroupNameViewController.h
//  eCloud
//  修改群组名称界面
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HASCHANGEDGROUPNAME @"hasChangedGroupName"

@interface modifyGroupNameViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{
}

/** 最后一条消息id，主要用来判断群组是否已创建 现在移动端发起群组时，就发起创建讨论组命令，服务器返回成功后，才保存在本地的，所以这个已经没有什么用途了 */
@property(assign) int last_msg_id;
/** 这个是为了修改前一个界面的标题，不过现在也已经没用了 */
@property(nonatomic,retain)  id delegete;

/** 会话id */
@property(nonatomic,retain) NSString *convId;
/** 旧的群组名称 */
@property(nonatomic,retain) NSString *oldGroupName;
@end
