//
//  ReceiptMsgUtil.m
//  eCloud
//
//  Created by shisuping on 15/11/23.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgUtil.h"
#import "eCloudDefine.h"
#import "eCloudDAO.h"
#import "talkSessionUtil.h"

#import "eCloudConfig.h"

#import "talkSessionViewController.h"

#import "StringUtil.h"

#import "ConvRecord.h"
#import "LogUtil.h"

static ReceiptMsgUtil *receiptMsgUtil;

@interface ReceiptMsgUtil ()

@end

@implementation ReceiptMsgUtil
{
    CustomReceiptMsgButton *pinMsgButton;
}

@synthesize pinMsgArray;
@synthesize unreadMsgNumber;

+ (ReceiptMsgUtil *)getUtil
{
    if (!receiptMsgUtil) {
        receiptMsgUtil = [[ReceiptMsgUtil alloc]init];
    }
    return receiptMsgUtil;
}
//如果回执消息 是 未发送回执的情况 那么 就发送回执 并且 高亮显示

//在talksession中增加一个view 用来显示重要的消息
- (void)addPinMsgButton
{
    if ([eCloudConfig getConfig].needImportantMsgSetTop) {
        if (!pinMsgButton) {
            pinMsgButton = [[[CustomReceiptMsgButton alloc]init]autorelease];
            pinMsgButton.frame = CGRectMake(0, 0, [talkSessionViewController getTalkSession].view.frame.size.width, 50);
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
            pinMsgButton.backgroundColor = [talkSessionUtil getBgColorOfReceiptModelColor];
            [pinMsgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
#else
            if ([UIAdapterUtil isTAIHEApp]) {
                pinMsgButton.backgroundColor = [UIColor colorWithRed:87 / 255.0 green:170 / 255.0 blue:47 / 255.0 alpha:0.75];
                [pinMsgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                pinMsgButton.backgroundColor = [UIColor colorWithRed:0xee / 255.0 green:0xe9 / 255.0 blue:0xc1 / 255.0 alpha:1];
                [pinMsgButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
#endif
            [pinMsgButton setImage:[StringUtil getImageByResName:@"dingxiaoxi.png"] forState:UIControlStateNormal];
            //[pinMsgButton setTitle:@"这是一条钉消息" forState:UIControlStateNormal];
            [pinMsgButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            
            pinMsgButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [[talkSessionViewController getTalkSession].view addSubview:pinMsgButton];
            
            [pinMsgButton addTarget:self action:@selector(scrollToMsg:) forControlEvents:UIControlEventTouchUpInside];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 增加钉消息button",__FUNCTION__]];

        }
        pinMsgButton.hidden = YES;
    }
}

- (void)scrollToMsg:(id)sender
{
    talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
    
    int count = self.pinMsgArray.count;
    if (count) {
        ConvRecord *lastRecord = self.pinMsgArray.lastObject;
        
        int _index = [talksession getArrayIndexByMsgId:lastRecord.msgId];
        
        if(_index < 0){
            [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到这条pinMsg %@",__FUNCTION__,[self getPinMsgTip:lastRecord]]];
            return;
        }else{
            [LogUtil debug:[NSString stringWithFormat:@"%s  找到了对应的pinmsg %@ ，自动滑动到这条pinmsg",__FUNCTION__,[self getPinMsgTip:lastRecord]]];
        }
        
        NSIndexPath *_indexPath = [talksession getIndexPathByIndex:_index];
        [talksession.chatTableView scrollToRowAtIndexPath:_indexPath
                                  atScrollPosition: UITableViewScrollPositionMiddle
                                          animated:NO];
    }
}

//读取新消息的数目 和 未读的@消息和回执消息
- (void)getNewPinMsgs
{
    if (pinMsgButton) {
        eCloudDAO *_ecloud = [eCloudDAO getDatabase];
        NSDictionary *dic = [_ecloud getNewPinMsgs:[talkSessionViewController getTalkSession].convId];
        self.pinMsgArray =  dic[@"pin_msgs"];
        self.unreadMsgNumber = [dic[@"unread_msg_count"]intValue];
        [LogUtil debug:[NSString stringWithFormat:@"%s  钉消息总条数%d 未读消息总条数%d",__FUNCTION__,(int)self.pinMsgArray.count,self.unreadMsgNumber]];
    }
}

- (NSString *)getPinMsgTip:(ConvRecord *)_convRecord
{
    NSString *empName = _convRecord.emp_name;
    NSString *msgBody = _convRecord.msg_body;
    int msgType = _convRecord.msg_type;
    
    if (msgType == type_text) {
        if ([msgBody isEqualToString:FIRST_NEW_MSG_TIPS]) {
//            如果是第一条未读消息，那么直接返回，就不再显示谁发送的了
            return FIRST_NEW_MSG_TIPS;
        }
    }
    NSString *_msg = [StringUtil getUserTipsWithMsgType:msgType andMsg:msgBody];
    
    NSString *retStr = [NSString stringWithFormat:@"%@%@",empName,_msg];
    
    return retStr;
}

//显示最近的pin消息
- (void)displayRecentPinMsg
{
    if (pinMsgButton) {
        if (self.pinMsgArray.count) {
            pinMsgButton.hidden = NO;
            
            ConvRecord *_convRecord = [self.pinMsgArray lastObject];
            if (_convRecord.isHuizhiMsg) {
                pinMsgButton.isDingMsg = YES;
            }else{
                pinMsgButton.isDingMsg = NO;
            }

            NSString *title = [self getPinMsgTip:[self.pinMsgArray lastObject]];
            [pinMsgButton setTitle:title forState:UIControlStateNormal];
            [LogUtil debug:[NSString stringWithFormat:@"%s 当前显示的钉消息是%@",__FUNCTION__,title]];

        }else{
            pinMsgButton.hidden = YES;
            [LogUtil debug:[NSString stringWithFormat:@"%s 所有钉消息已经读取，不用再显示钉消息按钮",__FUNCTION__]];
        }
    }
}

//从数组里删除一个
- (void)deletePinMsg:(ConvRecord *)convRecord
{
    int _count = self.pinMsgArray.count;
    if (_count) {
        for (int i = _count - 1; i >= 0; i--) {
            ConvRecord *temp = self.pinMsgArray[i];
            if (temp.msgId == convRecord.msgId) {
                [LogUtil debug:[NSString stringWithFormat:@"%s  pin msg  %@ 已经显示 可以移除",__FUNCTION__,[self getPinMsgTip:temp]]];
                [self.pinMsgArray removeObject:temp];
                [self displayRecentPinMsg];
                break;
            }
        }
    }
}

//隐藏pinMsgButton
- (void)hidePinMsgButton
{
    if (pinMsgButton && pinMsgButton.hidden == NO) {
        pinMsgButton.hidden = YES;
    }
}

@end

@implementation CustomReceiptMsgButton
@synthesize isDingMsg;

#define DING_IMAGE_SIZE (16)

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (isDingMsg) {
        UIImage *image = [StringUtil getImageByResName:@"dingxiaoxi.png"];
        if (image) {
            float imageHeight = DING_IMAGE_SIZE * image.size.height / image.size.width;
            return CGRectMake(10,(contentRect.size.height - imageHeight) / 2, DING_IMAGE_SIZE, imageHeight);
        }
        return CGRectMake(10,(contentRect.size.height - DING_IMAGE_SIZE) / 2, DING_IMAGE_SIZE, DING_IMAGE_SIZE);
    }
    return CGRectZero;
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleX = 20;
    if (isDingMsg) {
        titleX = 20 + DING_IMAGE_SIZE;
    }
    CGFloat titleY = 0;
    CGFloat titleW = contentRect.size.width - 10 - titleX;
    CGFloat titleH = contentRect.size.height;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
@end
