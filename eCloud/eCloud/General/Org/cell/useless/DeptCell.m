#import "DeptCell.h"
#import "Dept.h"
#import "StringUtil.h"

#define default_name_width  280 //(280 * 0.75)
#define default_emp_count_width (280 * 0.25)

@implementation DeptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [DeptCell addCommonView:self];
    }
    return self;
}


- (void)configCell:(Dept *)dept
{
    UIImageView *arrowImg = (UIImageView *)[self.contentView viewWithTag:arrow_image_tag];
    
    UIImage *image;
    
    if (dept.isExtended)
    {
        image = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_down" andType:@"png"]];
    }
    else
    {
        image = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_right" andType:@"png"]];
    }
    arrowImg.image = image;
    
    float indentPoints = dept.dept_level * self.indentationWidth;

    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:dept_name_tag];
    nameLabel.text = dept.dept_name;
    
    CGRect _frame = nameLabel.frame;
    _frame.size.width = default_name_width - indentPoints;
	nameLabel.frame = _frame;
    
//    万达版本 不显示在线人数/总人数
    return;
    
    UILabel *onlineLabel = (UILabel *)[self.contentView viewWithTag:dept_emp_count_tag];
    onlineLabel.text = [NSString stringWithFormat:@"[%d/%d]",dept.onlineNum,dept.totalNum];
    
    _frame = onlineLabel.frame;
    _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
    onlineLabel.frame = _frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark 把需要显示的view增加到cell中，因为要和带选择功能的cell共用，所以增加了这个接口
+ (void)addCommonView:(UITableViewCell *)cell
{
    UIImage *arrow = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"arrow_down" andType:@"png"]];
    float x = 10;
    float y = (dept_row_height - arrow.size.height) / 2;
    float w = arrow.size.width;
    float h = arrow.size.height;
    
    UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    arrowImg.tag = arrow_image_tag;
    [cell.contentView addSubview:arrowImg];
    [arrowImg release];
    
    //        部门名称
    x = arrowImg.frame.origin.x + arrowImg.frame.size.width + 10;
    y = 0;
    w = default_name_width;
    h = dept_row_height;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
    nameLabel.numberOfLines = 2;
    nameLabel.tag = dept_name_tag;
    nameLabel.font = [UIFont systemFontOfSize:name_font_size];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [cell.contentView addSubview:nameLabel];
    [nameLabel release];
    
//    万达版本不显示在线人数，总人数
    return;
    
    //        在线人数 总人数
    x = cell.frame.size.width - 20 - default_emp_count_width;
    y = 0;
    w = default_emp_count_width;
    h = dept_row_height;
    
    UILabel *onlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
    onlineLabel.tag = dept_emp_count_tag;
    onlineLabel.textAlignment = NSTextAlignmentRight;
    onlineLabel.backgroundColor = [UIColor clearColor];
    onlineLabel.lineBreakMode = UILineBreakModeTailTruncation;
    onlineLabel.font = [UIFont systemFontOfSize:emp_count_font_size];
    [cell.contentView addSubview:onlineLabel];
    [onlineLabel release];
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
