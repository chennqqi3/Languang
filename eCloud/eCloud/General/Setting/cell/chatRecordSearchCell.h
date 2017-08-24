//
//  chatRecordSearchCell.h
//  eCloud
//
//  Created by shinehey on 15/2/3.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conversation.h"
#import "eCloudDefine.h"
#import "QueryResultCell.h"
#import "LastRecordView.h"

@interface chatRecordSearchCell : QueryResultCell
{
//    int startIndex;
//    int endIndex;
}
//@property (nonatomic,retain) NSMutableAttributedString *convName;
/** 会话名称 */
@property (nonatomic,retain) LastRecordView *convNameLalbel;
/** 让搜索的关键字变成高亮的颜色 */
- (void)configConvName:(Conversation *)conv andSearchStr:(NSString *)searchStr;

@end
