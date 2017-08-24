//
//  Conversation.m
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "Conversation.h"
#import "eCloudDefine.h"
#import "eCloudDAO.h"
#import "QueryResultCell.h"
#import "ConvRecord.h"
#import "Emp.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "UserDisplayUtil.h"

@implementation Conversation
@synthesize groupType;
@synthesize conv_id = _conv_id;
@synthesize conv_type = _conv_type;
@synthesize conv_title = _conv_title;
@synthesize conv_remark = _conv_remark;
@synthesize recv_flag = _recv_flag;
@synthesize create_emp_id = _create_emp_id;
@synthesize create_time = _create_time;
@synthesize last_record = _last_record;
@synthesize unread = _unread;
@synthesize emp=_emp;
@synthesize msg_time;
@synthesize last_msg_id;
@synthesize serviceModel;
@synthesize appModel;
@synthesize recordType;
@synthesize lastInput_msg;
@synthesize is_tip_me;

@synthesize displayRcvMsgFlag;
@synthesize displayTime;
@synthesize specialColor;
@synthesize specialStr;
@synthesize totalEmpCount;

@synthesize isSetTop;
@synthesize setTopTime;

@synthesize groupLogoEmpArray;

@synthesize displayMergeLogo;
@synthesize convEmps;

-(void)dealloc
{
    self.groupLogoEmpArray = nil;
    
    self.specialStr = nil;
    self.specialColor = nil;
    
	self.serviceModel = nil;
	self.msg_time = nil;
	self.conv_id = nil;
	self.conv_title = nil;
	self.conv_remark = nil;
	self.create_time = nil;
	self.last_record = nil;
	self.emp = nil;
    self.lastInput_msg=nil;
    self.appModel = nil;
    
	[super dealloc];
}

- (Conversation *)initWithConversation:(Conversation *)_conv
{
    Conversation *conv = [self init];
    conv.conv_id = _conv.conv_id;
    conv.conv_title = _conv.conv_title;
    conv.conv_type = _conv.conv_type;
    conv.emp = _conv.emp;
    
    conv.displayMergeLogo = _conv.displayMergeLogo;
    conv.groupLogoEmpArray = _conv.groupLogoEmpArray;
    
    return conv;
}

- (NSString *)getConvTitle
{
    NSString *convTitle = @"";
    if (self.conv_type == singleType) {
        convTitle = [self.emp getEmpName];
    }
    else if(self.conv_type == mutiableType)
    {
        convTitle = self.conv_title;
    }
    if (!convTitle) {
        convTitle = @"";
    }
    return convTitle;
}

- (NSArray *)getConvEmps
{
    if (self.conv_type == singleType) {
        
        return [NSArray arrayWithObject:self.emp];
    }
    else if(self.conv_type == mutiableType)
    {
        eCloudDAO *_ecloud = [eCloudDAO getDatabase];
        return [_ecloud getAllConvEmpBy:self.conv_id];
    }
    return nil;
}

//只需要根据最近一条的消息时间来排序 不考虑是否置顶
- (NSComparisonResult)compareByLastMsgTimeOnly:(Conversation *) anotherElement
{
    NSComparisonResult _result = [self.last_record.msg_time compare:anotherElement.last_record.msg_time];
    if (_result == NSOrderedAscending) {
        return NSOrderedDescending;
    }
    if (_result == NSOrderedDescending) {
        return NSOrderedAscending;
    }
    return _result;
}


//增加根据最近一条的消息时间来排序
- (NSComparisonResult)compareByLastMsgTime:(Conversation *) anotherElement
{
#ifdef _GOME_FLAG_
//    应用通知消息如果有未读的，那么优先级最高，显示在最上面
    if (self.conv_type == appNoticeBroadcastConvType && self.unread) {
        return NSOrderedAscending;
    }else if (anotherElement.conv_type == appNoticeBroadcastConvType && anotherElement.unread){
        return NSOrderedDescending;
    }
#endif
    
    if (self.isSetTop) {
        if (anotherElement.isSetTop) {
            int curTime = self.last_record.msg_time.intValue;
            if (self.setTopTime > curTime) {
                curTime = self.setTopTime;
            }
            
            int anotherTime = anotherElement.last_record.msg_time.intValue;
            if (anotherElement.setTopTime > anotherTime) {
                anotherTime = anotherElement.setTopTime;
            }
            if (curTime > anotherTime) {
                return NSOrderedAscending;
            }
            else if(curTime < anotherTime)
            {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedAscending;
        }
    }
    else
    {
        if (anotherElement.isSetTop) {
            return NSOrderedDescending;
        }
        else
        {
            NSComparisonResult _result = [self.last_record.msg_time compare:anotherElement.last_record.msg_time];
            if (_result == NSOrderedAscending) {
                return NSOrderedDescending;
            }
            if (_result == NSOrderedDescending) {
                return NSOrderedAscending;
            }
            return _result;
        }
    }
 }

//万达需求，增加一个获取显示在群组头像的成员列表，按照empSort排序,最多四个
- (void)getGroupLogoEmpArray
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    self.groupLogoEmpArray = [_ecloud getGroupLogoEmpArrayBy:self.conv_id];
}


//几张图片合成一张图片
+ (void)mergedImageOfConv:(Conversation *)conv
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //    合并小图的背景
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"big_group_logo_bg" ofType:@"png"]];
    
    float bgWidth = backgroundImage.size.width;
    float bgHeight = backgroundImage.size.height;
    
    
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, bgWidth, bgHeight)];
    
    
    //    小图的size 是通过背景的大小来计算
    float subViewWidth = (bgWidth- 3 * group_logo_subview_spacing) / 2.0;
    float subViewHeight = (bgHeight - 3 * group_logo_subview_spacing) / 2.0;
    
    //    小图的origin需要计算
    NSArray *empsRow = [QueryResultCell getLogoRowsAndColsOfConv:conv];
    
    //    CGRect _parentFrame = groupLogoParentView.frame;
    
    NSInteger rowCount = empsRow.count;
    
    for (int i = 0; i < rowCount; i++)
    {
        NSArray *empsCol = [empsRow objectAtIndex:i];
        
        NSInteger colCount = empsCol.count;
        
        for (int j = 0; j < colCount; j++)
        {
            
            Emp *_emp = [empsCol objectAtIndex:j];
#ifdef _LANGUANG_FLAG_
            
#else
            if ([eCloudConfig getConfig].useOriginUserLogo) {
                subViewWidth = (subViewHeight * _emp.logoImage.size.width) / _emp.logoImage.size.height;
            }
    
#endif

            

#ifdef _ZHENGRONG_FLAG_
            subViewWidth = (subViewHeight * _emp.logoImage.size.width) / _emp.logoImage.size.height;
#endif
            
            float x = 0.0;
            float y = 0.0;
            
            float adjust = 0.0;
            
            switch (colCount) {
                case 1:
                {
                    x= group_logo_subview_spacing;

                }
                    break;
                case 2:
                {
                    if (j == 0)
                    {
                        NSArray *temp = [empsRow objectAtIndex:0];
                        if (temp.count == 1) {
                            x = bgWidth - group_logo_subview_spacing - subViewWidth;

                        }else{
                        
#ifdef _LANGUANG_FLAG_
                            x = group_logo_subview_spacing + adjust;
                            
#else
                            x = group_logo_subview_spacing + adjust;

                            if ([eCloudConfig getConfig].useOriginUserLogo) {
                                float temp = ((bgWidth - group_logo_subview_spacing * 3) / 2 - subViewWidth) / 2;
                                x = group_logo_subview_spacing + adjust + temp;
                            }
                            
#endif

                        }

                        
#ifdef _ZHENGRONG_FLAG_
                        float temp = ((bgWidth - group_logo_subview_spacing * 3) / 2 - subViewWidth) / 2;
                        x = group_logo_subview_spacing + adjust + temp;
#endif
                    }
                    else if (j == 1)
                    {
#ifdef _LANGUANG_FLAG_
                        x = bgWidth- group_logo_subview_spacing - subViewWidth;

#else
                        x = bgWidth- group_logo_subview_spacing - subViewWidth;
                        
                        if ([eCloudConfig getConfig].useOriginUserLogo) {
                            float temp = ((bgWidth - group_logo_subview_spacing * 3) / 2 - subViewWidth) / 2;
                            x = bgWidth - group_logo_subview_spacing - subViewWidth - temp;
                        }
                        

#endif
                       
#ifdef _ZHENGRONG_FLAG_
                        float temp = ((bgWidth - group_logo_subview_spacing * 3) / 2 - subViewWidth) / 2;
                        x = bgWidth - group_logo_subview_spacing - subViewWidth - temp;
#endif
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            switch (rowCount) {
                case 1:
                {
                    y = (bgHeight - subViewHeight) / 2.0;
                }
                    break;
                case 2:
                {
                    if (i == 0)
                    {
                        y = group_logo_subview_spacing + adjust;
                        if (colCount == 1) {
                            subViewHeight = bgHeight - group_logo_subview_spacing*2;

                        }
                    }
                    else if (i == 1)
                    {
                        NSArray *temp = [empsRow objectAtIndex:0];
                        if ( temp.count == 1 && j == 0) {
                            y = group_logo_subview_spacing + adjust;
                            subViewHeight = (bgHeight - 3 * group_logo_subview_spacing) / 2.0;

                        }else{
                        
                            y = bgHeight - group_logo_subview_spacing - subViewHeight;
                            subViewHeight = (bgHeight - 3 * group_logo_subview_spacing) / 2.0;
                        }

                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            if (_emp.logoImage) {
                if ([_emp.logoImage isEqual:default_logo_image]) {
                    NSDictionary *_dic = [UserDisplayUtil getUserDefinedGroupLogoDicOfEmp:_emp];
                    UIImage *_image = [ImageUtil createUserDefinedLogo:_dic];
                    if (_image) {
                        [_image drawInRect:CGRectMake(x, y, subViewWidth, subViewHeight)];
                    }
                }else{
                    [_emp.logoImage drawInRect:CGRectMake(x, y, subViewWidth, subViewHeight)];
                }
            }
        }
    }
    
    CGImageRef newMergeImageRef = CGImageCreateWithImageInRect(UIGraphicsGetImageFromCurrentImageContext().CGImage,
                                                               CGRectMake(0, 0, bgWidth, bgHeight));
    UIGraphicsEndImageContext();
    [pool release];
    
    if (newMergeImageRef)
    {
        NSString *detailMergedGroupLogoName = [StringUtil getDetailMergedGroupLogoName:conv];
        if (detailMergedGroupLogoName.length > 0)
        {
            NSString *detailMergedGroupLogoPath = [StringUtil getMergedGroupLogoPathWithName:detailMergedGroupLogoName];
            
            UIImage *newImage = [UIImage imageWithCGImage:newMergeImageRef];
            BOOL success = [UIImageJPEGRepresentation(newImage,1) writeToFile:detailMergedGroupLogoPath atomically:YES];
            if (success) {
                NSLog(@"已生成 %@ 群组的头像",conv.conv_title);
            }
        }
        else
        {
           NSLog(@"生成群组头像失败,群组id为空");
        }
    }
    else
    {
        NSLog(@"生成群组头像失败");
    }
}

@end
