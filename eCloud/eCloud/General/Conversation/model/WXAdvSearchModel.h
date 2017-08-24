//
//  WXAdvSearchModel.h
//  eCloud
//  高级查询 结果模型
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXAdvSearchModel : NSObject

/** 搜索的条件 */
@property (nonatomic,retain) NSString *searchStr;

/** 查询结果类型 */
@property (nonatomic,assign) int searchResultType;

/** header title */
@property (nonatomic,retain) NSString *headerTitle;

/** header */
//@property (nonatomic,retain) UIView *headerView;

/** footer title*/
@property (nonatomic,retain) NSString *footerTitle;

/** footer */
//@property (nonatomic,retain) UIView *footerView;

/** 所有的查询结果 */
@property (nonatomic,retain) NSArray *allItemArray;

/** 要显示的查询结果 */
@property (nonatomic,retain) NSArray *dspItemArray;

@end
