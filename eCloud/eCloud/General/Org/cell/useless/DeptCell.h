//通讯录中部门的样式 包括一个图片(标志展开或收起)，第一个文本(部门名称),第二个文本(在线人数和总人数)
#import <UIKit/UIKit.h>

#define dept_row_height (45.0)
#define arrow_image_tag (101)
#define dept_name_tag (102)
#define dept_emp_count_tag (103)

#define name_font_size (17.0)
#define emp_count_font_size (12.0)

@class Dept;
@interface DeptCell : UITableViewCell

- (void)configCell:(Dept *)dept;

#pragma mark 把需要显示的view增加到cell中，因为要和带选择功能的cell共用，所以增加了这个接口
+ (void)addCommonView:(UITableViewCell *)cell;

@end
