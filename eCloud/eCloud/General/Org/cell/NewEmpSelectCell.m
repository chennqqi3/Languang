
#import "NewEmpSelectCell.h"

#import "eCloudConfig.h"

#import "UserDisplayUtil.h"
#import "Emp.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "OrgSizeUtil.h"
#import "UIAdapterUtil.h"

#define default_name_width (210.0)
#define select_btn_size (30.0)
@implementation NewEmpSelectCell

@synthesize infoView;

- (void)dealloc{
    [self.infoView release];
    self.infoView = nil;
    
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		//头像
		UIImageView *logoView = [UserDisplayUtil getUserLogoView];
        logoView.contentMode = UIViewContentModeScaleToFill;
        logoView.userInteractionEnabled = YES;
		logoView.tag = emp_logo_tag;
		CGRect _frame = logoView.frame;
		_frame.origin.x = 30;
		_frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
		logoView.frame = _frame;
		[self.contentView addSubview:logoView];
        
        //empId label
        UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        empIdLabel.tag = emp_id_tag;
        [logoView addSubview:empIdLabel];
        [empIdLabel release];
        
		//名字
		float x = logoView.frame.origin.x + logoView.frame.size.width + 5;
		float y = 0;
		float w = default_name_width;
		float h = emp_row_height;
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		nameLabel.tag = emp_name_tag;
		nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        nameLabel.font = [UIFont systemFontOfSize:16.5];
		[self.contentView addSubview:nameLabel];
		[nameLabel release];
//        nameLabel.backgroundColor = [UIColor yellowColor];
		
        //签名
		UILabel *deptLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		deptLabel.backgroundColor = [UIColor clearColor];
		deptLabel.textColor=[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
        deptLabel.font=[UIFont systemFontOfSize:14];
		deptLabel.contentMode = UIViewContentModeTop;
		deptLabel.tag = emp_dept_tag;
        
        if ([UIAdapterUtil isTAIHEApp]) {
            deptLabel.numberOfLines = 2;
        }
        
        deptLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:deptLabel];
		[deptLabel release];
//        deptLabel.backgroundColor = [UIColor yellowColor];
        
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, select_btn_size, select_btn_size)];
        selectView.tag = emp_select_tag;
        selectView.userInteractionEnabled=NO;
        [self.contentView addSubview:selectView];
        [selectView release];
//        selectView.backgroundColor = [UIColor blueColor];
        
        UIImageView *infoBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, emp_row_height, emp_row_height)];
        infoBackView.userInteractionEnabled = YES;
//        infoBackView.backgroundColor = [UIColor redColor];
        infoBackView.tag = emp_info_btn_tag;
        [self addSubview:infoBackView];
        [infoBackView release];
        
        self.infoView =[[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, emp_row_height, emp_row_height)];
        [infoBackView addSubview:self.infoView];
    }
    return self;
}

-(void)configureCell:(Emp*)emp
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
//	[UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
	CGRect _frame = logoView.frame;
    _frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent] + select_btn_size + 10;
    _frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];

    //用户名
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
//	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
    
//	nameLabel.text = [NSString stringWithFormat:@"%@(%@)",emp.emp_name,emp.empCode];
    nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];

    _frame = nameLabel.frame;
    _frame.origin.x = logoView.frame.origin.x + logoView.frame.size.width + 5;
    _frame.origin.y = logoView.frame.origin.y;
    _frame.size.height =logoView.frame.size.height;
    float nameWidth = [UIAdapterUtil getTableCellContentWidth] - logoView.frame.size.width - logoView.frame.origin.x - RIGHT_ROW_SIZE;
    _frame.size.width = nameWidth;
    nameLabel.frame = _frame;
    
    //职位
    UILabel *deptLabel = (UILabel *)[self.contentView viewWithTag:emp_dept_tag];
	deptLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height, nameLabel.frame.size.width, 25);
    
//    直接打开 不显示部门
    deptLabel.text = @"";// emp.parent_dept_list;
	[deptLabel sizeToFit];
    
    if (deptLabel.text == nil) {
        CGPoint _newCenter = nameLabel.center;
        _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
    
	UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:emp_select_tag];
	if(!selectButton.hidden){
        _frame = selectButton.frame;
        _frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent];
        _frame.origin.y = (emp_row_height - select_btn_size) / 2;
        selectButton.frame = _frame;
        
//        NSLog(@"%s selectbutton frame is %@",__FUNCTION__,NSStringFromCGRect(_frame));
        
		[NewEmpSelectCell selectBtn:selectButton andSelected:emp.isSelected];
	}
    
    //右边点击区域
    UIImageView *infoBackView = (UIImageView *)[self viewWithTag:emp_info_btn_tag];
	_frame = infoBackView.frame;
    _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width-20.0;
    _frame.origin.y = 0.0;
    infoBackView.frame = _frame;
}


-(void)configureWithDeptCell:(Emp*)emp
{
    UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
//	[UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
    CGRect _frame = logoView.frame;
    _frame.origin.x = 50.0;
    _frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];

    //姓名
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
//	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
    
    if ([[eCloudConfig getConfig]dspUserCodeWhenSearchOrg]) {
        nameLabel.text = [NSString stringWithFormat:@"%@(%@)",emp.emp_name,emp.empCode];
    }else{
        nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];        
    }
    

    _frame = nameLabel.frame;
    _frame.origin.x = logoView.frame.origin.x + logoView.frame.size.width + 5;
    _frame.origin.y = logoView.frame.origin.y;
    _frame.size.height =logoView.frame.size.height / 2;
    float nameWidth = [UIAdapterUtil getTableCellContentWidth]  - logoView.frame.size.width - 50 - select_btn_size;
    _frame.size.width = nameWidth;
    nameLabel.frame = _frame;

    //职位
    UILabel *deptLabel = (UILabel *)[self.contentView viewWithTag:emp_dept_tag];
    
#define default_dept_name_label_height (25.0)
    
	deptLabel.frame = CGRectMake(_frame.origin.x, _frame.origin.y + _frame.size.height, _frame.size.width, default_dept_name_label_height);
//    deptLabel.backgroundColor = [UIColor clearColor];
    deptLabel.text = emp.parent_dept_list;
//	[deptLabel sizeToFit];

    if (deptLabel.text == nil) {
        CGPoint _newCenter = nameLabel.center;
        _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
//        展示部门需要的实际高度
        CGFloat labelHeight = [deptLabel sizeThatFits:CGSizeMake(deptLabel.frame.size.width, MAXFLOAT)].height;
        if (labelHeight > default_dept_name_label_height) {
            
            float diff = labelHeight - default_dept_name_label_height;
            
//重新设置nameLabel的高度
            _frame = nameLabel.frame;
            _frame.size.height -= diff;
            nameLabel.frame = _frame;
            
//            重新设置deptLabel的高度 和 y值
            _frame = deptLabel.frame;
            _frame.size.height += diff;
            _frame.origin.y -= diff;
            deptLabel.frame = _frame;
        }
        
    }
    //    NSNumber *count = @((labelHeight) / deptLabel.font.lineHeight);

    
	UIButton *selectButton = (UIButton*)[self.contentView viewWithTag:emp_select_tag];
	if(!selectButton.hidden){
        _frame = selectButton.frame;
        _frame.origin.x = 10.0;
        _frame.origin.y = (emp_row_height - select_btn_size) / 2;
        selectButton.frame = _frame;
		[NewEmpSelectCell selectBtn:selectButton andSelected:emp.isSelected];
	}
    
    //右边点击区域
    UIImageView *infoBackView = (UIImageView *)[self viewWithTag:emp_info_btn_tag];
	_frame = infoBackView.frame;
    _frame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width-20.0;
    _frame.origin.y = 0.0;
    infoBackView.frame = _frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    float indentPoints = self.indentationLevel * self.indentationWidth;
//    self.contentView.frame = CGRectMake(
//										indentPoints,
//										self.contentView.frame.origin.y,
//										self.contentView.frame.size.width - indentPoints,
//										self.contentView.frame.size.height
//										);
//}

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
