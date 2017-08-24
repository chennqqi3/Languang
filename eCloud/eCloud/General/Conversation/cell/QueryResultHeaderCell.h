// 在会话列表界面，输入查询条件，既可以根据会话标题和会话成员查询会话，也可以根据查询条件查询会话记录，并可以对查询结果进行分组，返回section的headerview

#import <UIKit/UIKit.h>

//定义headerview高度
#define search_result_header_view_hight (40)
@interface QueryResultHeaderCell : UITableViewCell


/**
 表格header cell

 @param cellName 要在header cell中显示的文字
 */
- (void)configCell:(NSString *)cellName;
@end
