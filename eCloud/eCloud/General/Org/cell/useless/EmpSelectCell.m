
#import "EmpSelectCell.h"
#import "UserDisplayUtil.h"
#import "Emp.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "OrgSizeUtil.h"

#define default_name_width (210.0)
#define select_btn_size (30.0)
@implementation EmpSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
		//		头像
		UIImageView *logoView = [UserDisplayUtil getUserLogoView];
        logoView.contentMode = UIViewContentModeScaleToFill;
        logoView.userInteractionEnabled = YES;
		logoView.tag = emp_logo_tag;
		CGRect _frame = logoView.frame;
		_frame.origin.x = 10;
		_frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
		logoView.frame = _frame;
		[self.contentView addSubview:logoView];
        
        //        empId label
        UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        empIdLabel.tag = emp_id_tag;
        [logoView addSubview:empIdLabel];
        [empIdLabel release];
        
		//		名字
		float x = logoView.frame.origin.x + logoView.frame.size.width + 5;
		float y = 0;
		float w = default_name_width;
		float h = emp_row_height;
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		nameLabel.tag = emp_name_tag;
		nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:nameLabel];
		[nameLabel release];
		
        //		签名
		UILabel *deptLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		deptLabel.backgroundColor = [UIColor clearColor];
		deptLabel.textColor=[UIColor grayColor];
        deptLabel.font=[UIFont systemFontOfSize:12];
		deptLabel.contentMode = UIViewContentModeTop;
        deptLabel.hidden=YES;
		deptLabel.tag = emp_dept_tag;
        deptLabel.numberOfLines = 2;
        deptLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:deptLabel];
		[deptLabel release];
        
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, select_btn_size, select_btn_size)];
        selectView.tag = emp_select_tag;
        selectView.userInteractionEnabled=NO;
        [self.contentView addSubview:selectView];
        [selectView release];
    }
    return self;
}

-(void)configureCell:(Emp*)emp
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
	[UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
	
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];

    float indentPoints = emp.emp_level * self.indentationWidth;

	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
	nameLabel.text = emp.emp_name;
    
    CGRect _frame = nameLabel.frame;
    _frame.origin.y = 0;
    _frame.size.height = emp_row_height;
    float nameWidth = [UIAdapterUtil getDeviceMainScreenWidth] - indentPoints - logoView.frame.size.width - 15 - select_btn_size - 10;

    _frame.size.width = nameWidth;
	nameLabel.frame = _frame;

	UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:emp_select_tag];
	if(!selectButton.hidden)
	{
        _frame = selectButton.frame;
        _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
        _frame.origin.y = (nameLabel.frame.size.height - select_btn_size) / 2;
        selectButton.frame = _frame;
        
		[EmpSelectCell selectBtn:selectButton andSelected:emp.isSelected];
	}
}
-(void)configureWithDeptCell:(Emp*)emp
{
    UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
	[UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];

    float indentPoints = emp.emp_level * self.indentationWidth;

	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
	nameLabel.text = emp.emp_name;

    CGRect _frame = nameLabel.frame;
    _frame.origin.y = logoView.frame.origin.y;
    _frame.size.height =logoView.frame.size.height / 2;
    float nameWidth = [UIAdapterUtil getDeviceMainScreenWidth] - indentPoints - logoView.frame.size.width - 25 - select_btn_size;
    _frame.size.width = nameWidth;
    nameLabel.frame = _frame;

    UILabel *deptLabel = (UILabel *)[self.contentView viewWithTag:emp_dept_tag];
	deptLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height, nameLabel.frame.size.width, 25);
	deptLabel.hidden=NO;
    deptLabel.text = emp.parent_dept_list;
	[deptLabel sizeToFit];

	UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:emp_select_tag];
	if(!selectButton.hidden)
	{
        _frame = selectButton.frame;
        _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
        _frame.origin.y = (emp_row_height - select_btn_size) / 2;
        selectButton.frame = _frame;

		[EmpSelectCell selectBtn:selectButton andSelected:emp.isSelected];
	}
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

+(void)selectBtn:(UIButton*)selectButton andSelected:(BOOL)isSelected
{
	if (isSelected)
	{ //选中
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateHighlighted];
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateSelected];
	}
	else   //未选择
	{
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateHighlighted];
		[selectButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateSelected];
	}
}

@end
