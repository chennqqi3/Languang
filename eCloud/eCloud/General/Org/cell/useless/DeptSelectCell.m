
#import "DeptSelectCell.h"
#import "DeptCell.h"
#import "Dept.h"
#import "StringUtil.h"
#import "EmpSelectCell.h"

#define select_btn_size (40.0)


@implementation DeptSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        self.backgroundColor = [UIColor greenColor];
//        self.contentView.backgroundColor = [UIColor greenColor];
//        增加展开收缩图片，部门名称，部门在线人数
        [DeptCell addCommonView:self];
        
//        添加选择按钮
        float x = self.frame.size.width - select_btn_size - 10;
        float y = (self.frame.size.height - select_btn_size) / 2;
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(x, y, select_btn_size, select_btn_size)];
        //        点击部门时 整行点击是展开部门，点击此按钮才选择部门，所以这里设置为YES
        selectView.userInteractionEnabled = YES;
        selectView.tag = dept_select_btn_tag;
        [self.contentView addSubview:selectView];
        [selectView release];
    }
    return self;
}

- (void)configCell:(Dept *)dept search:(BOOL)isSearch
{
    float row_height = dept_row_height;
    if (isSearch) {
        row_height = dept_search_row_height;
    }
  
    UIImageView *arrowImg = (UIImageView *)[self.contentView viewWithTag:arrow_image_tag];
    
    CGSize imageSize = [DeptSelectCell setImageView:arrowImg andIsExtend:dept.isExtended];
    
    CGRect _frame = arrowImg.frame;
    _frame.origin.y = (row_height - imageSize.height) / 2;
    arrowImg.frame = _frame;
    
    float indentPoints = dept.dept_level * self.indentationWidth;

    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:dept_name_tag];
    nameLabel.text = dept.dept_name;
    
    float temp = (row_height - select_btn_size)/2;
    
    float textWidth = self.frame.size.width - 30 - select_btn_size - indentPoints;
    if (isSearch) {
        textWidth = textWidth - 10;
    }
    
    _frame = nameLabel.frame;
    _frame.size.width = textWidth;// * 0.75;
    _frame.size.height = row_height;
	nameLabel.frame = _frame;
    
//    万达版本不显示在线人数总人数
//    UILabel *onlineLabel = (UILabel *)[self.contentView viewWithTag:dept_emp_count_tag];
//    onlineLabel.text = [NSString stringWithFormat:@"[%d/%d]",dept.onlineNum,dept.totalNum];
//    
//    _frame = onlineLabel.frame;
//    _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
//    _frame.size.height = row_height;
//    _frame.size.width = textWidth * 0.25;
//    onlineLabel.frame = _frame;
    
    UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:dept_select_btn_tag];// self.accessoryView;
	if(!selectButton.hidden)
	{
        _frame = selectButton.frame;
//        _frame.origin.x = onlineLabel.frame.origin.x + onlineLabel.frame.size.width;
        _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
        selectButton.frame = _frame;
		[EmpSelectCell selectBtn:selectButton andSelected:dept.isChecked];
	}
}

//展开时使用向下的箭头
//收起时使用向右的箭头
+ (CGSize)setImageView:(UIImageView *)imageView andIsExtend:(BOOL)isExtend
{
    UIImage *image;
    
    if (isExtend)
    {
        image=[StringUtil getImageByResName:@"arrow_down.png"];
    }else
    {
        image=[StringUtil getImageByResName:@"arrow_right.png"];
    }
    imageView.image = image;
    return image.size;
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
										self.frame.size.width - indentPoints,
										self.contentView.frame.size.height
										);
//    NSLog(@"%.0f,width is %.0f,%@",indentPoints,self.frame.size.width,self.contentView);
}

@end
