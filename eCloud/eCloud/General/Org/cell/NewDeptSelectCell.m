
#import "NewDeptSelectCell.h"
#import "NewDeptCell.h"
#import "Dept.h"
#import "StringUtil.h"
#import "NewEmpSelectCell.h"
#import "OrgSizeUtil.h"
#import "UIAdapterUtil.h"
#define select_btn_size (40.0)


@implementation NewDeptSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [NewDeptCell addCommonView:self];
        
        //添加选择按钮
        float x = self.frame.size.width - select_btn_size - 10;
        float y = (self.frame.size.height - select_btn_size) / 2;
        
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(x, y, select_btn_size, select_btn_size)];
        selectView.userInteractionEnabled = YES;//点击部门时 整行点击是展开部门，点击此按钮才选择部门，所以这里设置为YES
        selectView.tag = dept_select_btn_tag;
        [self.contentView addSubview:selectView];
        [selectView release];
        selectView.hidden = YES;
    }
    return self;
}

- (void)configCell:(Dept *)dept search:(BOOL)isSearch
{
    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:dept_name_tag];
    nameLabel.text = dept.dept_name;
    
    CGRect  _frame = nameLabel.frame;
    float row_height = dept_row_height;
    float textWidth = self.frame.size.width - 40 - select_btn_size ;
    if (isSearch) {
        textWidth = textWidth+20.0;
        _frame.origin.x = 14.0;
    }
    else{
        _frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent];
    }
    
    _frame.size.width = textWidth;
    _frame.size.height = row_height;
	nameLabel.frame = _frame;
    
    UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:dept_select_btn_tag];// self.accessoryView;
	if(!selectButton.hidden)
	{
        _frame = selectButton.frame;
        _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
        selectButton.frame = _frame;
		[NewEmpSelectCell selectBtn:selectButton andSelected:dept.isChecked];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



@end
