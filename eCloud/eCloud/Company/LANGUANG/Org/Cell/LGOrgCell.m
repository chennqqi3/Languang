//
//  NewEmpCell.m
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import "LGOrgCell.h"
#import "eCloudConfig.h"
#import "eCloudDefine.h"

#import "UserDisplayUtil.h"
#import "Emp.h"
#import "StringUtil.h"
#import "OrgSizeUtil.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "SettingItem.h"
#import "ImageUtil.h"
#import "Dept.h"
#import "Conversation.h"
#import "JPLabel.h"

#define default_name_width (220) // (205.0)

#define name_label_size (17.0)
#define detail_label_size (13.0)

//头像侧的间隔
#define logo_left_space (12.0)

//名字左边的空白
#define name_left_space (12.0)

//名字的高度
#define name_height (22.0)

//副标题的高度
#define detail_height (16.0)

@implementation LGOrgCell

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    self.dataObject = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        
        self.accessoryType = UITableViewCellAccessoryNone;// UITableViewCellAccessoryDisclosureIndicator;
        
//        选人的按钮
        UIImage *selectImage = [StringUtil getImageByResName:@"btn_checkbox_pressed"];
        UIImage *disableImage = [StringUtil getImageByResName:@"btn_checkbox_unable"];
        UIImage *normalImage = [StringUtil getImageByResName:@"btn_checkbox_normal"];
        
        UIButton *selectView=[[UIButton alloc]initWithFrame:CGRectMake(logo_left_space, (row_height - normalImage.size.height) * 0.5, normalImage.size.width, normalImage.size.height)];
        [selectView setBackgroundImage:normalImage forState:UIControlStateNormal];
        [selectView setBackgroundImage:disableImage forState:UIControlStateDisabled];
        [selectView setBackgroundImage:selectImage forState:UIControlStateSelected];
        selectView.tag = emp_select_tag;
        selectView.hidden = YES;
        [self.contentView addSubview:selectView];
        [selectView release];

        
        //头像
		UIImageView *logoView = [UserDisplayUtil getUserLogoViewWithLogoHeight:logo_height];
        logoView.contentMode = UIViewContentModeScaleToFill;
        logoView.userInteractionEnabled = YES;
		logoView.tag = emp_logo_tag;
		CGRect _frame = logoView.frame;
		_frame.origin.x = logo_left_space;
		_frame.origin.y = (row_height - logoView.frame.size.height) / 2;
		logoView.frame = _frame;
		[self.contentView addSubview:logoView];
        
        //empId label
        UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        empIdLabel.tag = emp_id_tag;
        [logoView addSubview:empIdLabel];
        [empIdLabel release];
        
        //        UIImageView *cellPhoneImageView = [logoView viewWithTag:1000];
        //        cellPhoneImageView.frame = CGRectMake(chatview_logo_size-10,chatview_logo_size-10,15,15);
        
        //名字
		float x = logoView.frame.origin.x + logoView.frame.size.width + name_left_space;
		float y = (row_height - name_height) * 0.5;
		float w = SCREEN_WIDTH - x - logo_left_space;
		float h = name_height;
        
//		UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
//		nameLabel.tag = emp_name_tag;
//		nameLabel.backgroundColor = [UIColor clearColor];
//        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
//        nameLabel.font = [UIFont systemFontOfSize:name_label_size];
//        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
//		[self.contentView addSubview:nameLabel];
        JPLabel *nameLabel = [[JPLabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
        nameLabel.tag = emp_name_tag;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        nameLabel.font = [UIFont systemFontOfSize:name_label_size];
//        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        nameLabel.jp_commonTextColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        [self.contentView addSubview:nameLabel];
        
//        nameLabel.backgroundColor = [UIColor redColor];
        
		[nameLabel release];
		
		x = nameLabel.frame.origin.x;
		y = 0;
		w = nameLabel.frame.size.width;
		h = 0;
        
        //detail
		UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.textColor=[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
        detailLabel.font=[UIFont systemFontOfSize:detail_label_size];
		detailLabel.contentMode = UIViewContentModeTop;
        if ([UIAdapterUtil isTAIHEApp]) {
            detailLabel.numberOfLines = 2;
        }
		detailLabel.tag = emp_detail_tag;
        detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:detailLabel];
		[detailLabel release];
        
    }
    return self;
}

/** 根据不同的对象 配置cell */
-(void)configureCellWithObject:(id)_id{
    
    self.dataObject = _id;
    
    UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    
    UIImageView *realLogoView = [UserDisplayUtil getSubLogoFromLogoView:logoView];
    
    UIButton *selectBtn = (UIButton *)[self.contentView viewWithTag:emp_select_tag];
    
//    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
//    UIView *lineviews = (UIView *)[self.contentView viewWithTag:line_tag];

    //名字
    JPLabel *nameLabel = (JPLabel*)[self.contentView viewWithTag:emp_name_tag];
    
    UILabel *detailLabel = (UILabel *)[self.contentView viewWithTag:emp_detail_tag];
    
    if ([_id isKindOfClass:[SettingItem class]]) {
        SettingItem *item = (SettingItem *)_id;
        nameLabel.text = item.itemName;
        
        if (item.searchContent && ![item.searchContent isEqualToString:@""]) {
            // 需要高亮的字体内容及对应的颜色
            nameLabel.jp_matchArr = @[@{
                                          @"string" : item.searchContent,
                                          @"color" : [StringUtil colorWithHexString:@"#2C84F8"]
                                      }];
        }
        
        if (item.imageName.length > 0) {
//            logo属于资源文件
            UIImage *logoImage = [StringUtil getImageByResName:item.imageName];
            realLogoView.image = logoImage;

        }else if (item.logoDic){
//            logo需要代码生成
            UIImage *logoImage = [ImageUtil createUserDefinedLogo:item.logoDic];
            realLogoView.image = logoImage;
//            [UserDisplayUtil setUserDefinedLogo:logoView andLogoDic:item.logoDic];

        }else{
//            没有设置logo，而且又是部门，那么不显示logo
            if (item.dataObject && [item.dataObject isKindOfClass:[Dept class]]) {
//                Dept *_dept = item.dataObject;
                CGRect _frame = nameLabel.frame;
                _frame.origin.x = logoView.frame.origin.x;
                nameLabel.frame = _frame;
                logoView.hidden = YES;

             } else if (item.dataObject && [item.dataObject isKindOfClass:[Emp class]]) {
                Emp *_emp = item.dataObject;
                
                if (_emp.canChoose) {
                    [selectBtn setSelected:_emp.isSelected];
                }else{
                    selectBtn.enabled = NO;
                }
                
                [UserDisplayUtil setUserLogoView:logoView andEmp:_emp andDisplayCurUserStatus:YES];
                
                nameLabel.text = _emp.emp_name;
                
                detailLabel.text = _emp.parent_dept_list;
                
                CGRect _frame = nameLabel.frame;
                _frame.origin.y = (row_height - name_height - detail_height) * 0.5;
                nameLabel.frame = _frame;
                
                _frame = detailLabel.frame;
                
                _frame.size.height = detail_height;
                _frame.origin.y = nameLabel.frame.origin.y + name_height;
                detailLabel.frame = _frame;
                 


            }else if (item.dataObject && [item.dataObject isKindOfClass:[Conversation class]]){
                Conversation *conv = item.dataObject;
                // 获取群组头像
                [UserDisplayUtil setUserLogoView:logoView andConversation:conv];
                // 单选框显示为灰色
//                放在下面的代码里
//                UIImage *normalImage = [StringUtil getImageByResName:@"btn_checkbox_ban"];
//                [selectBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
                //    修改为显示合成头像
                //    如果显示合成头像，就不用下面的操作
//                if (!conv.displayMergeLogo)
//                {
//                    [QueryResultCell configGroupLogoView:conv andIconView:iconview];
//                }
                nameLabel.text = conv.conv_title;
                
                detailLabel.text = [NSString stringWithFormat:@"%d人",conv.totalEmpCount];
                
                CGRect _frame = nameLabel.frame;
                _frame.origin.y = (row_height - name_height - detail_height) * 0.5;
                nameLabel.frame = _frame;
                
                
                _frame = detailLabel.frame;
                
                _frame.size.height = detail_height;
                _frame.origin.y = nameLabel.frame.origin.y + name_height;
                detailLabel.frame = _frame;
                



            }
        }
       
        [UserDisplayUtil hideStatusView:logoView];

        
        if (item.displaySelectBtn) {
            selectBtn.hidden = NO;
            
            if (item.dataObject && ([item.dataObject isKindOfClass:[Dept class]] || [item.dataObject isKindOfClass:[Conversation class]])) {
                // 显示成灰色
                UIImage *normalImage = [StringUtil getImageByResName:@"btn_checkbox_ban"];
                [selectBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
            }

            
//            设置selectBtn的状态
            
//            变化的x值为
            float changeX = selectBtn.frame.origin.x + selectBtn.frame.size.width;
            
//            如果有头像那么就设置头像的位置
            CGRect _frame;
            
            if (!logoView.hidden) {
//                修改头像frame 显示头像
                _frame = logoView.frame;
                _frame.origin.x = _frame.origin.x + changeX;
                logoView.frame = _frame;
            }
            
            _frame = nameLabel.frame;
            _frame.origin.x = _frame.origin.x + changeX;
            _frame.size.width = _frame.size.width - changeX;
            nameLabel.frame = _frame;
            
            _frame = detailLabel.frame;
            _frame.origin.x = nameLabel.frame.origin.x;
            _frame.size.width = nameLabel.frame.size.width;
            detailLabel.frame = _frame;
            
            [selectBtn addTarget:self action:@selector(clickSelectButton:) forControlEvents:UIControlEventTouchUpInside];

            
        }
    }
}

- (void)clickSelectButton:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectButton:)]) {
        [self.delegate clickSelectButton:self];
    }
}


-(void)configureCell:(Emp*)emp
{
    [self configureCell:emp andDisplayStatus:YES];
}

-(void)configureCell:(Emp*)emp andDisplayStatus:(BOOL)displayStatus
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    if (displayStatus) {
        [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
    }
    else
    {
        [UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
    }
    
//    CGRect _frame = logoView.frame;
//    _frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent];
//    _frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
//    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
    
    //名字
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
    // 不显示工号
    nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];
    
    CGRect _frame = nameLabel.frame;
    
    _frame.origin.y = (row_height - name_height - detail_height) * 0.5;
    nameLabel.frame = _frame;
    
//    float x = logoView.frame.origin.x + logoView.frame.size.width + 10;
//    float y = logoView.frame.origin.y;
//    float w = [UIAdapterUtil getTableCellContentWidth] - x - RIGHT_ROW_SIZE;
//    float h = logoView.frame.size.height / 2;
//    nameLabel.frame = CGRectMake(x, y, w, h);
	
    //职位
	UILabel *detailLabel = (UILabel *)[self.contentView viewWithTag:emp_detail_tag];
    
	detailLabel.text = @"职位信息";// emp.signature;
    _frame = detailLabel.frame;
    
    _frame.size.height = detail_height;
    _frame.origin.y = nameLabel.frame.origin.y + name_height;
    detailLabel.frame = _frame;
//    
//    detailLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, 25);
//	[detailLabel sizeToFit];
    
    if (detailLabel.text == nil || detailLabel.text.length == 0) {
        CGPoint _newCenter = nameLabel.center;
        _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
}

-(void)configureWithDeptCell:(Emp*)emp
{
//    这是用来显示 通讯录 人员搜索结果的cell
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
    CGRect _frame = logoView.frame;
    _frame.origin.x = 10;
    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
    
    //名称
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
//	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];

    if ([[eCloudConfig getConfig]dspUserCodeWhenSearchOrg]) {
        nameLabel.text = [NSString stringWithFormat:@"%@(%@)",emp.emp_name,emp.empCode];
    }
    else
    {
        nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];
    }
    
    float x = logoView.frame.origin.x + logoView.frame.size.width + 10;
    float y = logoView.frame.origin.y;
    float w = [UIAdapterUtil getTableCellContentWidth] - x - RIGHT_ROW_SIZE;// default_name_width;
    float h = logoView.frame.size.height / 2;
    nameLabel.frame = CGRectMake(x, y, w, h);
    
#define default_sig_label_height (25)
	//职位
	UILabel *detailLabel = (UILabel *)[self.contentView viewWithTag:emp_detail_tag];
	detailLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, default_sig_label_height);
    detailLabel.text = emp.parent_dept_list;
//	[detailLabel sizeToFit];
    
    if (detailLabel.text != nil) {
        CGRect _newFrame = nameLabel.frame;
        _newFrame.origin.y = 7.5;
        nameLabel.frame = _newFrame;
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        //        展示部门需要的实际高度
        CGFloat labelHeight = [detailLabel sizeThatFits:CGSizeMake(detailLabel.frame.size.width, MAXFLOAT)].height;
        if (labelHeight > default_sig_label_height) {
            
            float diff = labelHeight - default_sig_label_height;
            
            //重新设置nameLabel的高度
            _frame = nameLabel.frame;
            _frame.size.height -= diff;
            nameLabel.frame = _frame;
            
            //            重新设置deptLabel的高度 和 y值
            _frame = detailLabel.frame;
            _frame.size.height += diff;
            _frame.origin.y -= diff;
            detailLabel.frame = _frame;
        }

    }
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//	
//    float indentPoints = self.indentationLevel * self.indentationWidth;
//    
//    self.contentView.frame = CGRectMake(
//										indentPoints,
//										self.contentView.frame.origin.y,
//										self.contentView.frame.size.width - indentPoints,
//										self.contentView.frame.size.height
//										);
//}



@end
