//选择成员界面 部门显示 除了通讯里的部门外，还增加了一个复选框图片
#import <UIKit/UIKit.h>

@class Dept;

#define dept_search_row_height (60.0)
#define dept_select_btn_tag (201)

@interface DeptSelectCell : UITableViewCell

- (void)configCell:(Dept *)dept search:(BOOL)isSearch;

+ (CGSize)setImageView:(UIImageView *)imageView andIsExtend:(BOOL)isExtend;

@end
