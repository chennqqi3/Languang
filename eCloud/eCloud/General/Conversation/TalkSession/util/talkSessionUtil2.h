//把目前的talksessioncontroller里的部分代码放在此类中，以便简化talksessionController类

#import <Foundation/Foundation.h>

@class ConvRecord;
@interface talkSessionUtil2 : NSObject

/** 获取单例 */
+(talkSessionUtil2*)getTalkSessionUtil;

/**
 获取默认的聊天的title

 @param convType 会话类型
 @param convEmpArray 聊天成员
 @return 默认的标题
 */
+(NSString*)getDefaultTitle:(int)convType andConvEmpArray:(NSArray*)convEmpArray;

/**
 生成新的会话id
 1 时间(s数)
 2 8位的员工id，不够8位前补0
 3 0-9之间的数字 循环

 @param nowTime 当前的时间
 @return 新的会话id
 */
+(NSString*)getNewConvIdByNowTime:(NSString*)nowTime;


/**
 新建群聊会话 (群聊 另外一个是群发，这个是南航的定制功能，而且没有再使用了)

 @param convType 会话类型
 @param convId 会话id
 @param title 会话标题
 @param createTime 创建时间
 @param convEmpArray 成员
 @param massTotalEmpCount 群发总人数
 */
+(void)createConversation:(int)convType andConvId:(NSString*)convId andTitle:(NSString*)title andCreateTime:(NSString*)createTime andConvEmpArray:(NSArray*)convEmpArray andMassTotalEmpCount:(int)massTotalEmpCount;


/**
 文件开始下载后，保存到下载列表

 @param _convRecord 消息模型
 */
-(void)addRecordToDownloadList:(ConvRecord*)_convRecord;

/**
 查看下载列表中是否有此消息，如果有则设置下载属性

 @param _convRecord 消息模型
 */
-(void)setDownloadPropertyOfRecord:(ConvRecord*)_convRecord;

/**
 下载完成后，从下载列表中移除

 @param _convRecord 消息模型
 */
-(void)removeRecordFromDownloadList:(int)msgId;

/**
 创建单聊会话

 @param convId 会话id
 @param titleStr 会话标题
 */
-(void)createSingleConversation:(NSString *)convId andTitle:(NSString *)titleStr;

//根据要转发的记录，得到群聊的标题
/** deprecated */
- (NSString *)getTitleStrByConvRecord:(ConvRecord *)convRecord;

/**
 文件开始上传后，保存在上传列表

 @param _convRecord 消息模型
 */
-(void)addRecordToUploadList:(ConvRecord*)_convRecord;


/**
 如果消息在上传列表中，那么设置上传属性

 @param _convRecord 消息模型
 */
-(void)setUploadPropertyOfRecord:(ConvRecord*)_convRecord;

/**
 判断消息是否在上传列表中

 @param _convRecord 消息模型
 @return 在就返回YES，否则返回NO
 */
-(BOOL)isRecordInUploadList:(ConvRecord*)_convRecord;


/**
 上传完成后，从上传列表中移除

 @param msgId 消息id
 */
-(void)removeRecordFromUploadList:(int)msgId;

/*
 功能描述
 给虚拟账户发送消息时，如果应答是虚拟账户不在线，那么提示用户 "客户服务人员暂时无法提供服务，如有紧急事宜请拨打电话联系."
 生成一条新的提示消息
 
 */

- (void)createTipsRecordOfVirtualUser:(NSString *)convId;

/** 生成密聊提示 */
- (void)createMiliaoTips:(NSString *)convId;

/** 生成密聊提示  增加一个参数 提示时间*/
- (void)createMiliaoTips:(NSString *)convId andTipsTime:(int)tipTime;

//设置表情icon
+ (void)setFaceIcon:(UIButton *)button;
    //设置语音icon
+ (void)setAudioIcon:(UIButton *)button;

        //设置加号图标
+ (void)setPlusIcon:(UIButton *)button;

            //设置键盘图标
+ (void)setKeyboardIcon:(UIButton *)button;
@end
