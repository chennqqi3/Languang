//和IM消息相关的数据库程序

#import "OrgDAO.h"
@class helperObject;
@class Conversation;
@class ConvRecord;
@class RemindModel;

@interface ConvDAO : OrgDAO

#pragma mark ----会话表----
#pragma mark 查看某个群组是否屏蔽了群组消息，如果屏蔽了返回YES

/**
 查看某个会话是否接收新消息提醒

 @param convId 会话id
 @return YES:允许提醒 NO:不提醒
 */
-(BOOL)getRcvMsgFlagOfConvByConvId:(NSString*)convId;

#pragma mark 设置群组是否屏蔽群组消息

/**
 修改会话新消息提醒

 @param convId 会话id
 @param rcvMsgFlag 0:不提醒 1：提醒
 */
-(void)updateRcvMsgFlagOfConvByConvId:(NSString*)convId andRcvMsgFlag:(int)rcvMsgFlag;

#pragma mark  根据会话id，查询会话表，返回会话信息

/**
 根据会话id查询会话表，得到相应的会话

 @param convId 会话id
 @return 如果存在就返回会话信息字典，否则返回nil
 */
-(NSDictionary *)searchConversationBy:(NSString*)convId;

#pragma mark 增加会话

/**
 创建新会话

 @param info 是一个数组，数组的每一个元素是一个字典，包括会话id、会话类型、会话标题、创建人、创建标志灯
 */
-(void)addConversation:(NSArray *) info;

#pragma mark 修改会话，获取到群组消息后，保存会话标题，会话创建人，创建时间

/**
 获取到群组消息后，保存会话标题，会话创建人，创建时间

 @param convId 会话id
 @param dic 是一个字典，包含了真正的标题、创建人、创建时间
 */
-(void)updateConversation:(NSString*)convId andValues:(NSDictionary *)dic;

#pragma mark 展示最近的会话，不包括公众号（显示在会话列表的，没有显示在会话列表的）,用来转发消息

/**
  展示最近的会话，不包括公众号（显示在会话列表的，没有显示在会话列表的）,用来转发消息

 @return 是一个数组，数则的每一个元素为会话数据模型
 */
- (NSArray *)getRecentConvForTransMsg;

#pragma mark 展示最近50个会话：联系人界面调用，按照最后一条会话的时间排序，最近的要排在前面

/**
 展示最近会话：会话界面调用，按照最后一条会话的时间排序，最近的要排在前面

 @param type deprecated
 @return 一个数组，数组的每一个元素为一个conversation对象
 */
-(NSArray *)getRecentConversation:(int)type;

#pragma mark 根据用户输入的内容，查询会话的标题和会话参与人，找到符合条件的会话记录，显示在会话列表

/**
 根据用户输入的内容，查询会话的标题和会话参与人，找到符合条件的会话记录，显示在会话列表

 @param msg 搜索条件
 @return 符合条件的会话列表
 */
-(NSArray *)getConversationBy:(NSString *)msg;

#pragma mark 查询某个会话的会话人员

/**
 输入@时，查询可以@的人员，供用户选择

 @param convId 会话id
 @return 可供选择的人员数组
 */
-(NSArray*)getChooseTipEmp:(NSString *)convId;

#pragma mark 查询所有会话的个数

/**
 查询所有会话的个数，目前没有用到

 @return 所有会话的个数
 */
-(int)getAllConvCount;


#pragma mark 查询某一页的会话记录

/**
 查询某一页的会话记录 目前没有用到

 @param curPage 当前页
 @param totalPage 总页
 @return 某一页的会话
 */
-(NSArray *)getConvsOfPage:(int)curPage andAllPageNum:(int)totalPage;

#pragma mark 查询历史会话记录

/**
 搜索会话表，找到会话标题包含搜索条件的会话

 @param convName 查询提交
 @return 符合条件的会话列表
 */
-(NSArray *)searchChatRecordByConvName:(NSString *)convName;

#pragma mark 删除所有会话记录

/**
 删除所有会话和会话记录
 */
-(void)deleteAllConversation;

#pragma mark 修改会话信息 type:0 会话名称 1 会话备注

/**
 修改会话信息

 @param convId 会话id
 @param type 0 会话名称 1 会话备注 ，目前会话备注已经没有再使用了
 @param newValue 新的会话名称
 */
-(void)updateConvInfo:(NSString*)convId andType:(int)type andNewValue:(NSString*)newValue;

#pragma mark 群组总人数

/**
 群组总人数

 @param convId 会话id
 @return 群组总人数
 */
-(int)getAllConvEmpNumByConvId:(NSString *)convId;

#pragma mark 获取create_emp_id

/**
 获取群组创建人id

 @param convId 会话id
 @return 群组创建人id
 */
-(int)getConvCreateEmpIdByConvId:(NSString*)convId;

#pragma mark --会话人员表---

#pragma mark  增加会话人员 如果增加成功那么就保存在一个Dictionary里

/**
 增加会话人员

 @param info 会话人员列表
 @return 返回的字典，包括真正添加的人员的id
 */
-(NSDictionary*)addConvEmp:(NSArray *) info;

#pragma mark  删除一个会话人员

/**
 删除会话成员

 @param info 要删除的会话成员列表
 */
-(void)deleteConvEmp:(NSArray *)info;

#pragma mark 查询某个会话的会话人员

/**
 获取某个会话的会话人员

 @param convId 会话id
 @return 某个会话的会话人员列表
 */
-(NSArray*)getAllConvEmpBy:(NSString *)convId;

/**
 某个会话的需要显示在会话列表群组头像里的人员

 @param convId 会话id
 @return 人员列表
 */
-(NSArray*)getGroupLogoEmpArrayBy:(NSString *)convId;

#pragma mark 获取最近的10个联系人，修改用户头像后，通知这10个联系人

/**
 获取最近的10个联系人，修改用户头像后，通知这10个联系人 这个机制目前没有用到了

 @return 最近的10个联系人
 */
-(NSArray *)getRecentContact;

#pragma mark 修改会话消息,图片等上传成功后，不修改时间，而是修改状态为正在sending

/**
 图片、文件、语音等上传成功后，修改消息的内容

 @param msgId 消息id
 @param msg_body 消息内容(图片、语音、文件等在文件服务器的token)
 @param file_name 文件名字
 @param nowtime 时间 (deprecated)
 @param conv_id 会话id (deprecated)
 @param msgType 消息类型
 */
-(void)updateConvRecord:(NSString *)msgId andMSG:(NSString*)msg_body andFileName:(NSString*)file_name andNewTime:(NSString *)nowtime andConvId:(NSString *)conv_id andMsgType:(int)msgType;

#pragma mark 保存会话记录

/**
 保存会话记录

 @param info 会话记录列表，通常只有1条
 @return 如果保存成功，那么返回消息的原始id(无符号长整形)和自增长的消息id组成的字典
 */
-(NSDictionary *)addConvRecord:(NSArray *)info;

#pragma mark 根据会话Id，查询某个会话的总的记录个数

/**
 查询某个会话的总的记录个数

 @param convId 会话id
 @return 某个会话的总的记录个数
 */
-(int)getConvRecordCountBy:(NSString*)convId;


#pragma mark 获得所有的未读记录个数

/**
 展示在最近会话里的消息的未读记录个数，包括普通的单聊、群聊、广播、应用通知、公众号消息等

 @return 所有的未读记录个数
 */
-(int)getAllNumNotReadedMessge;


#pragma mark  查询某个会话的，某一页的会话记录

/**
 某个会话的，某一页的会话记录 目前没有使用到

 @param convId 会话id
 @param curPage 页码
 @return 某一页的聊天记录
 */
-(NSArray *)getConvRecordListBy:(NSString*)convId andPage:(int)curPage;


#pragma mark 查询当前会话的未读记录个数，如果>0，那么就返回其msgid数组

/**
  查询当前会话的未读记录个数，如果>0，那么就返回其msgid数组

 @param convId 会话id
 @return 如果>0，那么就返回其msgid数组
 */
-(NSArray*)getNotReadMsgId:(NSString*)convId;

#pragma mark  根据msgId获取一条会话记录

/**
 根据msgId获取一条会话记录

 @param msgId 消息id
 @return 消息id对应的消息模型
 */
-(ConvRecord *)getConvRecordByMsgId:(NSString*)msgId;

#pragma mark 查询所有的发送状态为发送中的消息，登录成功后，自动发送这些消息

/**
 查询所有的发送状态为发送中的消息

 @return 所有的发送状态为发送中的消息，登录成功后，自动发送这些消息
 */
-(NSArray *)getAllSendingRecords;

#pragma mark  根据会话id，查询会话记录，按照时间排序，最近的要排在前面，参数包括limit和offset

/**
 根据会话id，查询会话记录，按照时间排序，最近的要排在前面，聊天界面加载聊天记录使用

 @param convId 会话id
 @param _limit 取的条数
 @param _offset 从第几条开始取
 @return 消息模型列表
 */
-(NSArray *)getConvRecordBy:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset;

#pragma mark  根据会话id，查询会话记录里面的图片记录，按照时间排序，最近的要排在前面

/**
 查询会话记录里面的图片记录，按照时间排序

 @param convId 会话id
 @return 返回图片类型的消息数组
 */
-(NSArray *)getPicConvRecordBy:(NSString *)convId;

#pragma mark  删除群组人员

/**
 删除群组人员

 @param convid 会话id
 @param empid 人员id
 */
-(void)deleteGroupMember:(NSString *)convid empid:(int)empid;

#pragma mark   清除会话记录

/**
 清除某会话的所有会话记录

 @param convId 会话id
 */
-(void)deleteConvRecordBy:(NSString*)convId;

#pragma mark  清除会话记录的同时，清除会话本身

/**
 清除会话记录的同时，清除会话本身

 @param convId 会话id
 */
-(void)deleteConvAndConvRecordsBy:(NSString*)convId;

#pragma mark 删除某一条聊天记录

/**
 删除某一条聊天记录

 @param msgid 消息id
 */
-(void)deleteOneMsg:(NSString *)msgid;

#pragma mark 把所有的未读记录，设置为已读

/**
 把所有的未读记录，设置为已读，不仅包括普通的聊天记录，也包括广播消息、应用通知、公众号消息等
 */
-(void)setAllUnReadToReaded;

#pragma mark  修改消息状态为已读

/**
 修改消息状态为已读

 @param msgId 消息id
 @param sendread deprecated
 */
-(void)updateReadStatusByMsgId:(NSString*)msgId sendRead:(int)sendread;

#pragma mark  修改消息状态，发送失败还是成功，发送或接受的状态

/**
 修改消息状态

 @param msgId 消息id
 @param flag 消息状态(sendResult 集合)
 */
-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag;

#pragma mark  在程序异常退出的情况下，会走自动登录的入口，这时需要把未上传成功的图片和录音的状态修改为上传失败，便于再次上传

/**
 自动登录后，把未上传成功的图片和录音的状态修改为上传失败，便于再次上传
 */
-(void)updateSendFlagToUploadFailIfUploading;

#pragma mark  消息发送成功或失败后，需要通知页面更新状态。需要根据通知带回的消息id，查询到对应的自增长列的值

/**
 根据原始的消息id找到本地保存的自增长消息id

 @param _originMsgId 原始消息id
 @return 保存在本地时的自增长消息id
 */
-(NSString *)getMsgIdByOriginMsgId:(NSString*)_originMsgId;

#pragma mark 根据originMsgId得到所有符合条件的msgid，用于发送一呼百应已读请求成功后的处理

/**
 根据originMsgId得到所有符合条件的msgid

 @param _originMsgId 原始消息id
 @param senderId 发送人id
 @return 对应的消息记录
 */
-(NSArray*)getMsgIdArrayByOriginMsgId:(NSString*)_originMsgId andSenderId:(int)senderId;

#pragma 用户读了录音文件后，把红点标志设置为0

/**
 用户读了录音文件后，把红点标志设置为不显示

 @param msgId 录音消息id
 */
-(void)updateMessageToReadState:(NSString *)msgId;

#pragma mark 更新为已读，并且返回未读记录的个数，如果有未读消息，则可以进入会话后，定位在不同的位置，便于显示上下文

/**
 把某一个会话的所有未读消息设置为已读

 @param conv_id 会话id
 @return 0 目前不再判断
 */
-(int)updateTextMessageToReadState:(NSString *)conv_id;

#pragma mark 获取最后一条输入信息

/**
 获取某个会话的草稿，就是用户输入了，但是没有发出的消息

 @param conv_id 会话id
 @return 草稿，如果没有则返回@""
 */
-(NSString *)getLastInputMsgByConvId:(NSString *)conv_id;

#pragma mark 更新最后输入信息

/**
 保存草稿信息

 @param conv_id 会话id
 @param lastInputMsg 草稿内容
 */
-(void)updateLastInputMsgByConvId:(NSString *)conv_id LastInputMsg:(NSString *)lastInputMsg;

#pragma mark 更新最后输入信息时间

/**
 更新某会话的最后一条消息时间

 @param conv_id 会话id
 @param nowTime 当前的消息时间
 */
-(void)updateLastInputMsgTimeByConvId:(NSString *)conv_id nowTime:(NSString *)nowTime;

#pragma mark 判断群组是否创建

/**
 判断群组是否创建 目前都是创建成功后才保存在本地的，所以这个方法已经没什么实际用途

 @param convid 会话id
 @return true:已创建 false:未创建
 */
-(bool)isGroupCreate:(NSString*)convid;

#pragma mark 群组创建成功后，修改last_msg_id,由-1变为0

/**
 群组创建成功后，修改last_msg_id,由-1变为0

 @param convId 会话id
 */
-(void)setGroupCreateFlag:(NSString*)convId;

#pragma mark 修改群组的时间

/**
 修改群组的时间 (目前用途不大)

 @param convId 会话id
 @param _time 最新的群组时间
 */
-(void)updateConversationTime:(NSString*)convId andTime:(int)_time;

#pragma mark 根据会话id删除其对应的会话成员

/**
 删除会话的时候，同时删除会话成员

 @param convId 会话id
 */
-(void)deleteConvEmpBy:(NSString*)convId;

#pragma mark 判断群组成员中是否包含用户自己

/**
 判断群组成员中是否包含用户自己

 @param convId 会话id
 @return true:包括自己 false:没有包含自己
 */
-(bool)userExistInConvEmp:(NSString*)convId;

#pragma mark 根据群组id查询群组消息表，查到最早(type = 0)或最晚(type = 1)的一条消息，如果有，则返回这个消息

/**
 查询某个讨论组最早或者最晚一条消息的时间

 @param convId 会话id
 @param _type 0:查询最早一条消息 1:查询最晚一条消息
 @return 最早或最晚消息的时间，如果没找到，则返回nil
 */
-(NSDictionary *)getConvMsgTime:(NSString*)convId andType:(int)_type;

#pragma mark 收到一条群组信息后，如果本地还没有创建这个群组，那么会在本地会话表里入一条会话，会话标题是收到的消息，会话的创建人是0和创建时间为空，现在查询符合这种条件的会话，在登录完成后，自发的去获取群组消息

/**
 获取需要自动获取群组消息的会话

 @return 需要自动获取群组消息的会话，登录成功后，自动发获取群组资料指令
 */
-(NSArray *)selectConvNeedGetGroupInfo;

#pragma mark 用户详细资料快同步时，如果可能是用户关心的联系人比如常用联系人，常用组包含的成员，最近联系人，最近联系组包含的成员，那么就去下载头像

/**
 需要主动下载头像的联系人 deprecated

 @return 返回需要下载头像的人员
 */
-(NSDictionary*)selectContactNeedDownLoadLogo;

#pragma mark 修改会话纪录为已读  sendread: 0 不发已读 1发已读，之前有配置是否发送已读回执，现在已经没有处理这个 shisp
/** deprecated */
-(void)updateConvInfoToIsReaded:(NSString*)convId sendReadLimt:(int)sendread;

#pragma mark 关闭会话

/**
 在最近列表中隐藏或者显示会话

 @param convId 会话id
 @param displayFlag 0:显示 1：不显示
 */
-(void)updateDisplayFlag:(NSString*)convId andFlag:(int)displayFlag;


/**
 根据字典类型的消息返回对应的消息模型

 @param dic 消息字典
 @return 消息对应模型
 */
-(ConvRecord *)getConvRecordByDicData:(NSDictionary *)dic;

#pragma mark -----------------虚拟组，常用组，常用联系人，广播相关程序-----------------

/** deprecated */
-(NSArray *)getOffenGroup:(NSString *)virgroupid andLevel:(int)level;

/** deprecated */
-(NSArray *)getEmpFromVirGroup:(NSString *)virgroupid andLevel:(int)level;

/** deprecated */
-(NSArray *)getEmpsFromVirGroupByVirgroupid:(NSString *)virgroupid;

/** deprecated */
-(NSArray *)getVirGroupConvRecordListBy:(NSString*)convId andPage:(int)curPage;

/** deprecated */
-(NSArray *)getConvRecordByVirGroup:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset;

/** deprecated */
-(void)deleteContactPersonFromVirGroup:(int)emp_id;

/** deprecated */
-(void)deleteOffenGroupFromVirGroup:(NSString *)emp_id;

/** deprecated */
-(NSArray*)getVirGroups;


/**
 把保存广播消息到数据库的代码单独拿出来，国美邮件服务会用到

 @param dic 广播消息字典
 @return 保存成功返回YES，否则返回NO
 */
- (BOOL)saveBroadcastToDB:(NSDictionary *)dic;

/**
 保存广播类型的消息 包括普通的广播、和应用有关的通知

 @param info 广播消息对应的字典
 */
-(void)saveBroadcast:(NSArray *) info;

/**
 检查该广播是否已经保存

 @param msgId 消息id
 @return YES:已经存在 NO:不存在
 */
-(BOOL)isBroadcastSaved:(NSString*) msgId;

/**
 获取广播消息

 @param broadcastType 广播类型(普通广播消息，应用通知消息等类型 参考ecloudDefine中broadcast相关集合类型定义)
 @return 符合条件的广播消息列表
 */
-(NSMutableArray*)getBroadcastList:(int)broadcastType;

/**
 获取应用通知类型的广播消息

 @param broadcastType 应用通知类型 appNotice_broadcast 这个参数不传也可以
 @param appID 某个应用的应用id
 @return 这个应用的通知
 */
-(NSMutableArray*)getBroadcastList:(int)broadcastType withAppID:(NSString *)appID;

//获取10条广播消息 根据appID和当前条数

/**
 获取一页应用通知消息

 @param broadcastType 应用通知类型 appNotice_broadcast 这个参数不传也可以
 @param appID 某个应用的应用id
 @param count 当前界面显示的条数
 @return 符合条件的应用通知消息
 */
-(NSMutableArray*)getBroadcastList:(int)broadcastType withAppID:(NSString *)appID currentCount:(NSInteger)count;

/** deprecated */
-(void)deleteBroadcastByOne:(NSString *)msg_id andConvId:(NSString *)conv_id;

/**
 删除某一类型的广播消息

 @param broadcastType 广播消息类型
 */
-(void)deleteAllBroadcast:(int)broadcastType;

/**
 获取某一类型广播的未读数

 @param broadcastType 广播消息类型
 @return 未读数
 */
-(int)getAllNoReadBroadcastNum:(int)broadcastType;

//所有未读广播设为已读

/**
 设置某一类型广播消息为已读

 @param broadcastType 广播消息类型
 */
-(void)setAllBroadcastToRead:(int)broadcastType;

//判断是否需要更新广播的ReadFlag

/**
 检查广播消息是否已读

 @param msg_id 广播消息id
 @return 如果是未读返回YES，否则返回NO
 */
-(BOOL)needUpdateBroadcastReadFlag:(NSString *) msg_id;

/**
 设置该广播消息为已读

 @param msg_id 消息id
 @param conv_id 这种类型消息对应的会话id 需要刷新会话列表界面
 @param broadcastType 广播消息类型
 */
-(void)updateBroadcastReadFlagToRead:(NSString *) msg_id andUpdateConvId:(NSString *) conv_id andBroadcastType:(int)broadcastType;

/** deprecated */
-(void)addHelperSchedule:(NSArray *)info;
/** deprecated */
-(void)addHelperEmp:(NSArray *)info;

/** deprecated */
-(NSArray*)getHelperSchedule;
/** deprecated */
-(BOOL)isTheDateHasSchedule:(NSString *)choosedate;
/** deprecated */
-(NSArray*)getTheDateSchedule:(NSString *)choosedate;
/** deprecated */
-(helperObject *)getTheDateScheduleByID:(NSString *)helper_id;
/** deprecated */
-(NSArray *)getEmpByhelperid:(NSString *)helper_id;
/** deprecated */
-(helperObject*)getNewestHelperSchedule;
/** deprecated */
-(void)updateHelperRingTypeByID:(NSString *)helper_id Type:(NSString *)type TypeName:(NSString *)type_name;
/** deprecated */
-(int)getUnreadHelperNumByDate:(NSString *)startdate;
/** deprecated */
-(int)getUnreadHelperNum;
-(int)getUnreadHelperNumByYearMonth:(NSString *)yearmonth;
/** deprecated */
-(NSString *)getGroupIdByHelperID:(NSString *)helper_id;
/** deprecated */
-(int)getHadreadHelperNumByDate:(NSString *)startdate;
/** deprecated */
-(int)getHadreadHelperNumByYearMonth:(NSString *)yearmonth;
// 查询该日期及以后的日程安排
/** deprecated */
-(NSArray*)getTheDateAndFollowingSchedule:(NSString *)choosedate;
//设为已读
/** deprecated */
-(void)setHadReadedByHelperID:(NSString *)helper_id;
// 查询新日程最新收到
/** deprecated */
-(NSArray*)getNewestGetSchedule;
//把最新设置为未读
/** deprecated */
-(void)setNewestBeUnread;
//删除日程成员
/** deprecated */
-(void)deleteHelperScheduleMember:(NSString *)helper_id;
//删除日程
/** deprecated */
-(void)deleteHelperSchedule:(NSString *)helper_id;
//获取日程详细
-(helperObject *)getTheDateScheduleByGroupID:(NSString *)helper_id;


#pragma mark add by shisp 删除和消息相关的文件

/**
 删除和消息相关的文件

 @param dic 包括了删除类型、删除单条、删除多条、删除所有等
 */
-(void)deleteMsgFile:(NSDictionary *)dic;


/**
 查找有没有用户自己创建的，讨论组成员和参数一致的会话，如果有，那么直接返回这个会话的会话id，如果没有则返回nil

 @param convEmps 讨论组成员数组
 @return 如果有，那么直接返回这个会话的会话id，如果没有则返回nil
 */
-(Conversation *)searchConvsationByConvEmps:(NSMutableArray *)convEmps;

/**
 根据会话id，得到能够展示在会话列表里的Conversation对象

 @param convId 会话id
 @return 符合条件的会话对象或者nil
 */
- (Conversation *)getConversationByConvId:(NSString *)convId;

/**
 发出和会话相关的通知

 @param info 通知内容字典
 @param cmdType 通知子类型
 */
- (void)sendNewConvNotification:(NSDictionary *)info andCmdType:(int)cmdType;

/**
 设置置顶或取消置顶

 @param setTopFlag 置顶标志
 @param convId 会话id
 @return 置顶时间
 */
- (int)SetTopFlag:(int)setTopFlag andConv:(NSString *)convId;

#pragma mark ============修改群组成员的屏蔽状态和是否管理员状态=============

/** deprecated */
- (void)setRcvMsgFlagOfConv:(NSString *)convId andEmp:(int)empId andFlag:(int)rcvMsgFlag;


/**
 固定群组 保存管理员

 @param convId 会话id
 @param empId 成员id
 @param adminFlag 是否管理员
 */
- (void)setAdminFlagOfConv:(NSString *)convId andEmp:(int)empId andFlag:(int)adminFlag;


/**
 查看是否管理员

 @param convId 会话id
 @param empId 成员id
 @return 是否管理员
 */
- (int)getAdminFlagOfConv:(NSString *)convId andEmp:(int)empId;

#pragma mark ============修改和获取讨论组的类型，可以是普通群组，也可以是固定群组和常用群组=============


/**
 更改群组类型

 @param convId 会话id
 @param groupType 讨论组类型(固定群、常用讨论组、普通讨论组)
 */
- (void)updateGroupTypeOfConv:(NSString *)convId andGroupType:(int)groupType;


/**
 获取群组类型

 @param convId 会话id
 @return 固定群、常用讨论组或者普通讨论组
 */
- (int)getGroupTypeOfConv:(NSString *)convId;

//，如果包含

/**
 判断群组成员中是否包含某用户

 @param empId 成员id
 @param convId 会话id
 @return 包含返回YES，否则返回NO
 */
-(BOOL)isExistInConvWithEmpId:(NSString *)empId andConvId:(NSString*)convId;

/**
 删除所以测试数据
 */
- (void)deleteTestData;


/**
 生成测试数据

 @param info 测试数据列表
 */
-(void)addConvRecord_temp_test:(NSArray *)info;

#pragma mark ==========群组合成头像部分的数据库操作============

/**
 处理群组头像的逻辑

 @param conv 会话模型
 @param dic 会话消息字典 是显示生成好的群组头像，还是几个头像在一起组合的头像
 */
- (void)processAboutGroupMergedLogoWithConversation:(Conversation *)conv andDicData:(NSDictionary *)dic;

/**
 如果有一个用户的头像修改了，需要重新合成用户所在的群组的头像

 @param empId 变化了头像的成员id
 */
- (void)processWhenLogoChangeWithEmpId:(NSString *)empId;

/**
 根据群组id，群组title生成群组合成头像，群组title是记日志时使用

 @param convId 群组id
 @param convTitle 群组标题
 */
- (void)asynCreateMergedLogoWithConvId:(NSString *)convId andConvTitle:(NSString *)convTitle;

/**
  获取某会话是否置顶

 @param convId 会话id
 @return 置顶返回YES，否则返回NO
 */
- (BOOL)isSetTopWithConvId:(NSString *)convId;

#pragma mark - 文件助手增加的接口

/**
 获取所有文件消息记录

 @param _limit 获取条数限制
 @param _offset 获取位置
 @return 符合条件的文件消息
 */
-(NSArray *)getFileConvRecordsWithLimit:(int)_limit andOffset:(int)_offset;


/**
 获取某个聊天的所有文件消息记录

 @param convId 会话id
 @param _limit 获取条数限制
 @param _offset 获取位置
 @return 符合条件的文件消息
 */
-(NSArray *)getFileConvRecordsWithConvId:(NSString *)convId WithLimit:(int)_limit andOffset:(int)_offset; //


/**
 查询文件消息总的记录个数

 @return 文件消息总的记录个数
 */
-(int)getFileConvRecordsCount;


/**
 获取某个聊天的文件消息总的记录个数

 @param convId 会话id
 @return 某个聊天的文件消息总的记录个数
 */
-(int)getFileConvRecordsCountWithConvId:(NSString *)convId;


/**
 搜索文件消息 匹配文件名字和群组标题

 @param searchStr 搜索条件
 @return 符合条件的文件消息
 */
- (NSArray *)searchConvRecordsWithStr:(NSString *)searchStr;

/** 按照搜索条件 搜索文件名字 */
- (NSArray *)searchFileConvRecords:(NSString *)searchStr;


/**
 文件已过期时标记同一个文件的所有记录

 @param url 过期文件对应的文件token
 */
- (void)setConvRecordsHasExpiredWithUrl:(NSString *)url ;


/**
 同一文件上传后，修改相应文件消息url 独立版本里没有搜索到对这个方法的调用

 @param old_msg_body 临时文件token
 @param msg_body 真正的文件token
 @param _convRecord 对应的消息模型
 */
-(void)updateConvFileRecordWithOLdMSG:(NSString *)old_msg_body andMSG:(NSString*)msg_body andConvRecord:(ConvRecord *)_convRecord;

/**
 事务保存离线消息

 @param offlineMsgArray 离线消息数组
 */
- (void)saveOfflineMsgs:(NSArray *)offlineMsgArray;

/**
 处理同步过来的离线的回执消息

 @param receiptMsgArray 离线回执消息
 */
- (void)processReceiptMsgArray:(NSArray *)receiptMsgArray;

/**
 修改未读为已读

 @param msgReadArray 消息已读通知数组
 */
- (void)updateMsgReadFlag:(NSArray *)msgReadArray;

/**
 查看每个群组现在的未读消息数 离线消息收完后，要统一刷新会话列表界面

 @param array 收到了离线消息的会话
 @return 会话现在的未读消息个数
 */
- (NSArray *)getUnreadMsgCountOfMsgReadArray:(NSArray *)array;

/**
 根据原始的msgid,得到对应的会话id 和 本地的消息id

 @param _originMsgId 原始消息id
 @return 一个字典 包含对应的会话id 和 本地的消息id
 */
-(NSDictionary *)getMsgInfoByOriginMsgId:(NSString *)_originMsgId;

/**
 消息撤回成功后，把这条消息修改为一条群组通知消息，并且删除对应的资源

 @param msgId 撤回消息id
 @return 是否撤回成功
 */
- (BOOL)recallMsgWithMsgId:(NSString *)msgId;

#pragma mark 获取某个会话的所有新消息的数量 还有未读的@消息和回执消息

/**
 获取某个会话的所有新消息的数量 还有未读的@消息和回执消息

 @param convId 会话id
 @return 所有新消息的数量 还有未读的@消息和回执消息，放在一个字典里
 */
-(NSDictionary *)getNewPinMsgs:(NSString *)convId;

#pragma mark 发送未读消息数通知 给SDK调用程序接收
/**
 发送未读消息数通知 给SDK调用程序接收
 */
- (void)sendUnreadMsgNumNotification;

#pragma mark 南航要求保存 轻应用的提醒 ，现在获取轻应用提醒的总数 已经分页获取轻应用数据

/**
 获取轻应用提醒的总数

 @return 轻应用提醒的总数
 */
- (int)getAppRemindTotalCount;

/**
 分页查询 应用提醒消息

 @param _limit 限制条数
 @param _offset 获取位置
 @return 符合条件提醒列表
 */
-(NSArray *)getAppRemindsWithLimit:(int)_limit andOffset:(int)_offset;

#pragma mark 只删除会话

/**
 只删除会话 主要针对 广播消息类型的会话 公众号类型的会话等

 @param convId 会话id
 */
-(void)deleteConvOnly:(NSString*)convId;

#pragma mark 根据msgid找到提醒对应的model

/**
 根据msgid找到提醒对应的model

 @param msgId 提醒消息id
 @return 提醒消息模型
 */
- (RemindModel *)getRemindByMsgId:(NSString *)msgId;

#pragma mark 根据msgid找到提醒对应的RemindDic

/**
 根据msgid找到提醒对应的RemindDic

 @param msgId 提醒消息id
 @return 提醒消息字典
 */
- (NSDictionary *)getRemindDicByMsgId:(NSString *)msgId;

/**
 根据广播会话类型 获取 对应的会话id

 @param _broadcastConvType 广播类型
 @return 某种广播类型消息对应的会话id，方便会话列表刷新
 */
- (NSString *)getConvIdOfBroadcastConvType:(int)_broadcastConvType;

#pragma mark -根据消息id删除提醒

/**
 根据消息id删除提醒

 @param remindMsgId 提醒消息id
 */
- (void)deleteRemindWithMsgId:(NSString *)remindMsgId;

#pragma mark - 删除所有提醒

/**
 删除所有提醒
 */
- (void)deleteAllRemaid;

/*
 功能描述
 当我们删除了某一条应用消息或者是删除了某一个应用的所有消息时，如果这条消息恰巧是最新的，那么需要更新会话列表里相应记录的最后一条消息
 这里主要针对通过 广播协议收到的消息
 目前有 普通广播；万达im通知；南航或者国美的应用消息(龙湖的不保存在本地)
 
 参数
 广播会话类型
 
 */
- (void)updateLastConvRecordOfBroadcastConvType:(int)_broadcastConvType;

/**
 根据会话id 找到会话标题
 
 @param convId 会话id
 
 @return 会话标题
 */
- (NSString *)getConvTitleByConvId:(NSString *)convId;


/**
 根据消息ID和emp_ID搜索具体的消息

 @param msgId 消息ID
 @param userId emp_ID
 @return msgId对应的消息
 */
-(NSArray *)searchConvRecordByMsgId:(NSString *)msgId userId:(int)userId;



/**
 从该会话开始有多少条消息

 @param convRecord 消息对象
 @return 消息条数
 */
- (int)getMsgCountFromConvRecord:(ConvRecord *)convRecord;

/** 查找某一个会话的群组通知类型的消息，如果通知里包含了用户id，那么替换为名字 */
- (void)searchAndReplaceGroupInfoInConv:(NSString *)convId andEmp:(Emp *)_emp;

/** 查找所有的密聊消息 */
- (NSArray *)getAllMiLiaoMsgs;

/** 获取所有密聊消息的未读数 */
- (int)getNewMiLiaoMsgNum;

/** 搜索收到过哪些人发的消息 */
- (NSDictionary *)getAllChatEmps;

#ifdef _LANGUANG_FLAG_
/** 查询某消息是否存在于密聊消息表 */
- (BOOL)isMiLiaoMsgExist:(int)_id;

/** 在密聊消息表里增加一条消息 _id是消息id */
- (void)saveMiLiaoMsg:(int)_id;

/** 从密聊消息表里删除一条消息 */
- (void)deleteMiLiaoMsg:(int)_id;

/** 有没有他人还未读的密聊消息 */
- (BOOL)hasUnreadEncryptMsg:(NSString *)convId;

#endif

//获取所有文件助手表的记录
- (NSArray *)getFileAssistantConvRecordsWithLimit:(int)_limit andOffset:(int)_offset;



@end
