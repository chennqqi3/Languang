//
//  RobotDisplayUtil.h
//  eCloud
//  显示小万消息 使用到的 工具类
//  Created by shisuping on 15/11/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IM_MenuView.h"

@class NewFileMsgCell;
@class RobotMenu;
@class ConvRecord;
@class PicMsgCell;

@interface RobotDisplayUtil : NSObject <MenuViewDelegate>

//用户选中的知识库
@property (nonatomic,retain) RobotMenu *selectRobotMenu;

+ (RobotDisplayUtil*)getUtil;

//机器人聊天界面底部菜单 现在固定为两个选项 “常见问题” 和 “人工服务”
- (NSArray *)getMenuArray;

//显示机器人菜单
- (void)setTopMenuForRobot:(IM_MenuView *)menuView;

//==========知识库===========

//获取知识库数组 知识库数组 是 通过http协议同步到的，解析后保存在数据库，并且放在内存里 ，国美的知识库 包括 IT服务台、人力资源中心、财务共享中心，不同公司知识库的内容不同
- (NSArray *)getKnowledgeArray;

//打开知识库 下拉菜单
- (void)openKnowledgeBase;

//根据消息内容返回格式化的消息 小万发出去的消息是xml
- (NSString *)formatMsg:(NSString *)msgBody;

//根据选择的menu获取右侧按钮的title
- (NSString *)getRightBtnTitle;

//==========机器人消息处理===========

#pragma mark ====图文类型机器人消息====
/*
 功能描述
 在聊天界面单击机器人 图文消息点击可以打开连接
 */
- (void)addImgTxtViewGesture:(UITableViewCell *)cell;

#pragma mark ====视频，音频机器人消息====
/*
 功能描述
 如果是小万的视频消息 音频消息，那么都按照文件消息显示
 另外普通的文件消息也可以使用这个方法
 
 */
- (NewFileMsgCell *)getNewFileMsgCell;

/*
 功能描述
 点击小万的文件消息的处理
 
 如果文件已经存在，那么就打开查看文件
 如果文件不存在，那么查看文件是否已经在下载，如果正在下载，那么提示用户，正在下载；如果文件还没有开始下载，那么开启下载
 */
//- (void)onClickRobotFile:(UITapGestureRecognizer*)gesture;
- (void)onClickRobotFile:(ConvRecord*)_convRecord;

/*
 功能描述
 播放视频
 
 参数
 videoPath:视频文件路径
 
 curVc:当前的ViewController
 */
- (void)playVideo:(NSString *)videoPath andCurVc:(UIViewController *)curVc;

/*
 功能描述
 播放音频文件
 
 参数
 fileName:音频文件名称
 filePath:音频文件路径
 convRecord:文件对应的消息记录
 curVC:当前界面的viewcontroller
 */
- (void)playMusic:(NSString *)fileName andFilePath:(NSString *)filePath andConvRecord:(ConvRecord *)_convRecord andCurVC:(UIViewController *)curVC;

/*
 功能描述
 展示普通的文件
 
 参数
 fileDelegate:提供文件源的delegate
 */
- (void)openNormalFile:(id)fileDelegate andCurVC:(UIViewController *)curVC;

#pragma mark =====图片类型机器人消息======
/*
 功能描述
 返回图片类型的消息cell
 */
- (PicMsgCell *)getPicMsgCell;

/*
 功能描述
 点击机器人图片，放大显示图片
 
 */
- (void)onClickRobotImage:(ConvRecord *)_convRecord;
@end
