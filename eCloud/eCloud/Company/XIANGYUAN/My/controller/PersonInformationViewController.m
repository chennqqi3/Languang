//
//  PersonInformationViewController.m
//  WanDaOAP3_IM
//
//  Created by 张作伟 on 14-11-28.
//  Copyright (c) 2014年 Wanda. All rights reserved.
//

#import "PersonInformationViewController.h"
#import "OfficeMeInfoCell.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "IOSSystemDefine.h"
#import "TTTAttributedLabel.h"
#define kCellHeight             44.0
#define kCelPixHeight           26
#define kActionSheetTakePhoto   100
#define kPixTableViewHeight     20
#define kCellLineHeight         0.8
#define kCellSubTitleLabelWidth 215

@interface PersonInformationViewController ()
{
 
    CGFloat _onelineHeight;
    CGSize _labelSize;
    NSArray *_titleArray;
    conn *_conn;
    eCloudDAO *db;
    float newHeight;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property(nonatomic,retain) NSMutableArray *locationArr;
@property(nonatomic,retain) NSMutableArray *lengthArr;

@property(retain,nonatomic) Emp *emp;

@end

@implementation PersonInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setExtraCellLineHidden:self.tableview];
    self.tableview.backgroundColor = [UIColor clearColor];
    
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    self.emp = [db getEmpInfo:_conn.userId];
    _titleArray = @[@"",
                    @"姓名",
                    @"职务",
                    @"",
                    @"邮箱",
                    @"手机",
                    @"",
                    @"座机",
                    @"传真",
                    @"地址"];
    self.title = @"个人信息";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * string = nil;
    switch (indexPath.row) {
        case 0:
            return 15;
            break;
        case 3:
            return kPixTableViewHeight;
            break;
        case 6:
            return kPixTableViewHeight;
            break;
        case 1:
            string = self.emp.emp_name;
            break;
        case 2:
    
            string = self.emp.titleName;
            break;
        case 4:{
            string = self.emp.emp_mail;
            break;
        }
        case 5:{
            string = self.emp.emp_mobile;
            break;
        }
        case 7:{
            string = self.emp.emp_tel;
            break;
        }
        case 8:{
            string = self.emp.empFax;
            break;
        }
        case 9:{
            string = self.emp.empAddress;
            break;
        }
        case 10:{
            return kPixTableViewHeight;
            break;
        }
        case 11:{
            string = nil;
            return kCellHeight;
        }
            
        default:
            break;
    }
    
    _onelineHeight = [@"地址" sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 70, NSIntegerMax) lineBreakMode:NSLineBreakByCharWrapping].height;
    
    _labelSize = [string sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 70, NSIntegerMax) lineBreakMode:NSLineBreakByCharWrapping];
    
//    _labelSize = [self getSpaceLabelHeight:string withFont:[UIFont systemFontOfSize:15] withWidth:SCREEN_WIDTH - 70];
    
    if (indexPath.row == 2) {
        
        return newHeight;
    }
    if (_labelSize.height >= _onelineHeight*2) {
//        if (indexPath.row == 2) {
//            
//            if (_labelSize.height > 100) {
//                
//                _labelSize.height = _labelSize.height + 45;
//            }
////            else if (_labelSize.height < 100 && _labelSize.height > 50){
////                
////                _labelSize.height = _labelSize.height + 20;
////            }
//            else{
//                _labelSize.height = _labelSize.height + 30;
//            }
//            
//        }
        return _labelSize.height + 10;
    }
    else{
        _labelSize.height = kCellHeight;
        return kCellHeight;
    }
    return kCellHeight;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"OfficeMeInfoCell";
    OfficeMeInfoCell *officeMeInfocell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (officeMeInfocell == nil) {
        officeMeInfocell = [OfficeMeInfoCell loadFromXib];
    }
    if (indexPath.row == 0||indexPath.row == 3||indexPath.row == 6)
    {
        officeMeInfocell.contentView.backgroundColor = [UIColor clearColor];
        officeMeInfocell.backgroundColor = [UIColor clearColor];
        officeMeInfocell.selectionStyle = UITableViewCellSelectionStyleNone;
        officeMeInfocell.accessoryType = UITableViewCellAccessoryNone;
//        officeMeInfocell.accessory.hidden = YES;
//        officeMeInfocell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
//        CGRect _frame = officeMeInfocell.subTitleLabel.frame;
//        _frame.size = _labelSize;
//        officeMeInfocell.subTitleLabel.frame = _frame;
    }
    officeMeInfocell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];
    officeMeInfocell.titleLabel.font = [UIFont systemFontOfSize:16];
    
    officeMeInfocell.subTitleLabel.font = [UIFont systemFontOfSize:16];
    
    if (indexPath.row == 1) {
        officeMeInfocell.subTitleLabel.text = self.emp.emp_name;
    }else if (indexPath.row == 2){
        
        if (self.emp.titleName.length) {
            
            NSString *titleName = [self.emp.titleName substringToIndex:[self.emp.titleName length] - 1];
            NSArray *tempArr=[titleName componentsSeparatedByString:@";"];
            NSMutableString *nameStr = [NSMutableString string];
            self.locationArr = [NSMutableArray array];
            self.lengthArr = [NSMutableArray array];
            for (int i = 0; i < tempArr.count; i++) {
                
                NSString *string = tempArr[i];
                NSArray *arr = [string componentsSeparatedByString:@":"];
                if (arr.count == 2) {
                    
                    NSDictionary *dic = [db searchDept:[NSString stringWithFormat:@"%@",arr[1]]];
                    NSLog(@"dept is %@, %@",arr[1],[dic valueForKey:@"dept_name_contain_parent"]);
                    NSString *deptParent = [dic valueForKey:@"dept_name_contain_parent"];
//                    if (tempArr.count >2) {
//                        
//                        deptParent = [NSString stringWithFormat:@"%@\n",deptParent];
//                    }
                    if (i == 0) {
                        
                        NSString *str = [NSString stringWithFormat:@"%@\r%@\r",arr[0],deptParent];
                        [nameStr appendFormat:@"%@", str];
                        
                    }else if(i == tempArr.count){
                        
                        [nameStr appendFormat:@"\r%@\r%@",arr[0],deptParent];
                    }else{
                        
                        [nameStr appendFormat:@"\r%@\r%@\r",arr[0],deptParent];
                    }

                    NSRange range;
                    
                    range = [nameStr rangeOfString:arr[0]];
                    
                    if (range.location != NSNotFound) {
                        
                        [self.locationArr addObject:[NSString stringWithFormat:@"%lu",range.location]];
                        [self.lengthArr addObject:[NSString stringWithFormat:@"%lu",range.length]];
                    }
                    
                }
            }
            
            self.emp.titleName = nameStr;
        }
        
        officeMeInfocell.subTitleLabel.font = [UIFont systemFontOfSize:14];
        officeMeInfocell.subTitleLabel.textColor = [UIColor grayColor];
        officeMeInfocell.subTitleLabel.text = self.emp.titleName;
        [self changeLineSpaceForLabel:officeMeInfocell.subTitleLabel WithSpace:5];

        CGSize size = [self getSpaceLabelHeight:officeMeInfocell.subTitleLabel.text withFont:[UIFont systemFontOfSize:15] withWidth:SCREEN_WIDTH - 70];
        newHeight = size.height + 10;
//        10
        CGRect _frame = officeMeInfocell.subTitleLabel.frame;
        _frame.size.height = newHeight;
        _frame.origin.y = _frame.origin.y + 5;
//        5
        officeMeInfocell.subTitleLabel.frame = _frame;
        
        
    }else if (indexPath.row == 4) {
        officeMeInfocell.subTitleLabel.text = self.emp.emp_mail;
    }else if (indexPath.row == 5){
        officeMeInfocell.subTitleLabel.text = self.emp.emp_mobile;
    }else if (indexPath.row == 7){
        officeMeInfocell.subTitleLabel.text = self.emp.emp_tel;
    }else if (indexPath.row == 8){
        officeMeInfocell.subTitleLabel.text = self.emp.empFax;
    }else if (indexPath.row == 9){
        officeMeInfocell.subTitleLabel.text = self.emp.empAddress;
    }

    if (indexPath.row != 2) {
        
       
        
    }

    return officeMeInfocell;
}

- (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space {
    
    NSString *labelText = label.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setLineSpacing:space];
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    
    for (int i = 0 ; i < self.locationArr.count; i++) {
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([self.locationArr[i] intValue],[self.lengthArr[i] intValue])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange([self.locationArr[i] intValue],[self.lengthArr[i] intValue])];
    }
    label.attributedText = attributedString;
    //[label sizeToFit];
    
//    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString withConstraints:CGSizeMake(SCREEN_WIDTH - 70, MAXFLOAT) limitedToNumberOfLines:0].height;
//    return height;
}

-(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 0;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, NSIntegerMax) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size;
}

@end
