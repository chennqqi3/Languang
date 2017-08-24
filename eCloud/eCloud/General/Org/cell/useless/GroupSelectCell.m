
#import "GroupSelectCell.h"
#import "RecentGroup.h"
#import "eCloudDefine.h"
#import "EmpSelectCell.h"

#define  select_btn_tag (103)

#define select_btn_size (40.0)

@implementation GroupSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone ;

        [GroupCell addCommonObject:self];
        
//        复选框
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, select_btn_size, select_btn_size)];
        selectView.tag = select_btn_tag;
        selectView.userInteractionEnabled=NO;
        [self.contentView addSubview:selectView];
        [selectView release];
    }
    return self;
}
- (void)configCell:(RecentGroup *)itemObject
{
    float indentPoints = itemObject.type_level * self.indentationWidth;
    
    UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:group_name_tag];
	nameLabel.text = itemObject.type_name;
    
    CGRect _frame = nameLabel.frame;
    float nameWidth = self.frame.size.width - indentPoints - chatview_logo_size - 20 - select_btn_size;

    _frame.size.width = nameWidth;
    nameLabel.frame = _frame;
    
    UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:select_btn_tag];
	if(!selectButton.hidden)
	{
        _frame = selectButton.frame;
        _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
        _frame.origin.y = (self.frame.size.height - select_btn_size) / 2;
        selectButton.frame = _frame;
        selectButton.userInteractionEnabled = YES;
        
		[EmpSelectCell selectBtn:selectButton andSelected:itemObject.isChecked];
	}
}

- (UIButton *)getSelectButton
{
    UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:select_btn_tag];
    return selectButton;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
    float indentPoints = self.indentationLevel * self.indentationWidth;
	
    self.contentView.frame = CGRectMake(
										indentPoints,
										self.contentView.frame.origin.y,
										self.contentView.frame.size.width - indentPoints,
										self.contentView.frame.size.height
										);
}

@end
