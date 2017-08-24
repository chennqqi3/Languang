//
//  DisplayImgtxtTableView.m
//  eCloud
//
//  Created by yanlei on 15/11/8.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "DisplayImgtxtTableView.h"
#import "ImgtxtMsgSubCell.h"
//#import "UIImageView+IM_AFNetworking.h"
#import "openWebViewController.h"
#import "StringUtil.h"

@implementation DisplayImgtxtTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.dataArray = [[[NSMutableArray alloc]init]autorelease];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
//        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
//            [self setSeparatorInset:UIEdgeInsetsZero];
//        }
//        
//        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
//            [self setLayoutMargins:UIEdgeInsetsZero];
//        }
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return  0.1;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UILabel *titleLabel = [[[UILabel alloc]init]autorelease];
//    
//    NSDictionary *dic = self.dataArray[section];
//    titleLabel.text = [dic valueForKey:@"Title"];
//    
//    return titleLabel;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"imgtxtsubcellId";
    ImgtxtMsgSubCell *subCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSDictionary *dic = self.dataArray[indexPath.section];
    
    if (!subCell) {
        subCell = [[[ImgtxtMsgSubCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
        subCell.backgroundColor = [UIColor clearColor];
//        subCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
//        subCell.backgroundColor = [UIColor redColor];
    }
    // Title  Description  PicUrl   Url
    subCell.titleLabel.text = [dic valueForKey:@"Title"];
    
    [subCell.picUrlImageView setImageWithURL:[NSURL URLWithString:[dic valueForKey:@"PicUrl"]] placeholderImage:[StringUtil getImageByResName:@"default_pic"]];
    subCell.picUrlImageView.userInteractionEnabled = YES;
    
    subCell.descriptionLabel.text = [dic valueForKey:@"Description"];
    
    CGFloat desHeight = 0;
    // 计算描述的高度
    if(IOS7_OR_LATER)
    {
        // 计算title的高度  ios7及以上使用
        desHeight = [subCell.descriptionLabel.text boundingRectWithSize:CGSizeMake(subCell.descriptionLabel.frame.size.width,60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height;
    }
    else
    {
        // 计算title的高度  ios6及以上使用
        desHeight = [subCell.descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(subCell.descriptionLabel.frame.size.width,MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height;
    }
    CGRect dateFrame = CGRectMake(subCell.descriptionLabel.frame.origin.x, subCell.descriptionLabel.frame.origin.y, subCell.descriptionLabel.frame.size.width, desHeight);
    subCell.descriptionLabel.frame = dateFrame;
    
    if (indexPath.section == self.dataArray.count-1) {
        subCell.separatorLine.hidden = YES;
    }else{
        subCell.separatorLine.hidden = NO;
    }
    
    return subCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 将点击后的cell置为不选中
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    selectCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = self.dataArray[indexPath.section];
    
    // 拼接要转发的文本
    NSString *forwardStr = [NSString stringWithFormat:@"<soap:Body><ns2:askResponse xmlns:ns2=\"http://www.eastrobot.cn/ws/RobotService\"><robotResponse><commands><args>http://10.199.80.220:7000/robot/imgmsgData/8e78ae8015574cdd85961839393d23b7/articles.xml</args><args>1</args><args>UTF-8</args><args>&lt;![CDATA[&lt;Articles time=\"2015年11月20日\"&gt; &lt;item&gt; &lt;Title&gt;&lt;![CDATA[%@]]&gt;&lt;/Title&gt;&lt;Description&gt;&lt;![CDATA[]]&gt;&lt;/Description&gt;&lt;PicUrl&gt;&lt;![CDATA[%@]]&gt;&lt;/PicUrl&gt;&lt;Url auth=\"%@\"&gt;&lt;![CDATA[%@]]&gt;&lt;/Url&gt;&lt;/item&gt;&lt;/Articles&gt;]]&gt;</args><name>imgtxtmsg</name><state>1</state></commands><moduleId>core</moduleId><nodeId>000000004fedc0310150d04dd6596152</nodeId><similarity>1.0</similarity><type>1</type></robotResponse></ns2:askResponse></soap:Body>",[dic valueForKey:@"Title"],[dic valueForKey:@"PicUrl"],[dic valueForKey:@"Description"],[dic valueForKey:@"Url"]];
    
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.urlstr = [dic valueForKey:@"Url"];
    openweb.forwardStr = forwardStr;
    [[DisplayImgtxtTableView viewControllerByObj:self].navigationController pushViewController:openweb animated:YES];
    [openweb release];
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];   
//    }
//}
#pragma mark - 将tableviewcell切成圆角
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//        if (tableView == self) {
//            CGFloat cornerRadius = 5.f;
//            cell.backgroundColor = UIColor.clearColor;
//            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
//            BOOL addLine = NO;
//            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//            } else if (indexPath.row == 0) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//                addLine = YES;
//            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//            } else {
//                CGPathAddRect(pathRef, nil, bounds);
//                addLine = YES;
//            }
//            layer.path = pathRef;
//            CFRelease(pathRef);
//            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
//            
//            if (addLine == YES) {
//                CALayer *lineLayer = [[CALayer alloc] init];
//                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
//                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
//                [layer addSublayer:lineLayer];
//            }
//            UIView *testView = [[UIView alloc] initWithFrame:bounds];
//            [testView.layer insertSublayer:layer atIndex:0];
//            testView.backgroundColor = UIColor.clearColor;
//            cell.backgroundView = testView;
//        }
//    }
//}
#pragma mark - 获取view所在的controller
+ (UIViewController *)viewControllerByObj:(id)objs{
    for (UIView* next = [objs superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
@end
