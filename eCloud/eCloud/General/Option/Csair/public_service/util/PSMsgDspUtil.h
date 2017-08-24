
//  PSMsgDspUtil.h
//  eCloud
//  显示公众号消息的工具类 公众号和普通消息一样 显示在talksessionController这个类里面。公众号消息有新闻类型(单条或者多条)，文本类型、图片类型
//  Created by shisuping on 15-6-26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>


/*点击收到的公众号图片 可以查看大图 并且如果没有下载则可以下载
参照 会话 把大图片和缩略图的图片对应的属性传进去，但是为了和普通的消息进行区分，所以要能根据传入的url，得到保存在本地的文件的名称和目录，如果本地没有保存此文件，还需要能够根据传入的url下载文件，并保存在本地，现在定义一个固定的字符串，用来区分这是公众号收到的图片消息，并且公众号id，公众号消息对应的消息id，图片对应的url，要以|线分隔，作为参数 比如：
*/
#define public_service_message_flag @"PublicServiceMessage"

@class ServiceModel;
@class NewMsgNotice;
@class ConvRecord;

@interface PSMsgDspUtil : NSObject

+ (PSMsgDspUtil *)getUtil;

//如果此公众号 有未读消息，那么把未读消息设置为已读
- (void)makeReadIfExistUnread;

//查看某个公众号的详细资料
-(void)viewServiceInfo:(UIViewController *)curController andServiceModel:(ServiceModel *)serviceModel;

//获取tableView一共有几个section
- (NSInteger)getNumberOfSection;

//获取每一个section有几行
- (int)getRowCountOfSection:(NSInteger)section;

//获取每一行的高度
- (CGFloat)getHeightOfIndexPath:(NSIndexPath *)indexPath;

//cellwilldisplay时的处理
- (void)processWhenCellWillDisplay:(UITableView *)tableView andCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath;

//获取cell
- (UITableViewCell *)getCellOfTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

//获取section header 高度
- (CGFloat)getHeaderHeightOfSection:(NSInteger)section;

//获取section view
- (UIView *)getHeaderViewOfSection:(NSInteger)section;

//点击了表格的某一行
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)displayRcvPsMsg:(NewMsgNotice *)_notice;

//显示 长按 菜单
- (void)showMenu:(id)dic;

//图文消息支持删除，其它消息支持复制
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender;

//长按公众号消息时弹出菜单
-(void)menuDisplay;

//长按菜单消失
-(void)menuHide;

#pragma mark ===发送公众号消息，目前上行消息是没有实现的===
-(void)sendPSMessage;

//保存录音和图片类型的消息到数据库
-(BOOL)saveMediaPsMsg:(int)iMsgType message:(NSString *)messageStr filesize:(int)fsize filename:(NSString *)fname;

//实现在会话列表界面 可以点击小图 查看大图功能
- (NSString *)getPSMsgImageUrl:(ConvRecord *)convRecord;

//根据url，得到对应的serviceid msgid url等，方便下载
- (ConvRecord *)getConvRecordFromPSMsgImgUrl:(NSString *)imageUrl;

#pragma mark 滑动到最底部
-(void)scrollToEnd;

#pragma mark ====上传图片语音时msgid要特殊处理，否则无法区分是否为 服务号 上传，目前无法发送语音、图片消息到服务号，文本消息也无法送达====
- (NSString *)getRealMsgIdByMsgId:(NSString *)msgId;

- (NSString *)getServiceIdByMsgId:(NSString *)msgId;

- (NSString *)createCustomMsgId:(ConvRecord *)convRecord;

@end
