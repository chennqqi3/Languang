//
//  LGOrgViewController.h
//  eCloud
//  蓝光 通讯录 选择联系人 界面
//  Created by shisuping on 17/7/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewChooseMemberViewController.h"


@interface LGChooseMemberViewController : UIViewController

/** 最多选人数量 */
@property (nonatomic,assign) int maxSelectCount;

/**
 参数说明:
 单选还是多选
 
 YES：单选 NO：多选
 */
@property (nonatomic,assign) BOOL isSingleSelect;

/** 保存不能选择的人 */
@property(nonatomic,retain) NSArray *oldEmpIdArray;


/**
 参数说明
 选择人员delegate
 
 协议名称：ChooseMemberDelegate
 
 需要实现以下代理方法
 - (void)didSelectContacts:(NSString *)retStr;
 */
@property (nonatomic,assign) id<ChooseMemberDelegate> chooseMemberDelegate;

@property (nonatomic,assign) int curDeptId;

@end
