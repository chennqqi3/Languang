//
//  CollectionConn.m
//  eCloud
//
//  Created by Alex L on 16/2/18.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CollectionConn.h"
#import "NotificationUtil.h"
#import "eCloudDAO.h"
#import "talkSessionUtil.h"
#import "CollectionDAO.h"
#import "StringUtil.h"
#import "CollectionUtil.h"
#import "conn.h"
#import "UserDefaults.h"
#import "ConvRecord.h"
#import "UserTipsUtil.h"
#import "eCloudUser.h"
#import "LogUtil.h"

#import "RobotResponseXmlParser.h"


#define XML_START @"<soap:Body>"
#define XML_END @"</soap:Body>"

#define FILE_IS_DOWNLOADING @"1"

@interface CollectionConn ()
//用来记载收藏对应的资源是否正在下载的dic,计划key使用msgid_fileurl value就是FILE_IS_DOWNLOADING
//如果开始下载 那么增加；下载完毕时 删除；去下载时也要判断是否已经正在下载；当发现文件不存在时就要走下载的流程
@property (nonatomic,retain) NSMutableDictionary *downloadDic;
@property (nonatomic,retain) NSMutableDictionary *myDic;
@end

static CollectionConn *userDataConn;
@implementation CollectionConn
{
    int curCount;
}

//初始化 downloadDic
- (id)init{
    self = [super init];
    if (self) {
        self.downloadDic = [NSMutableDictionary dictionary];
        self.myDic = [NSMutableDictionary dictionary];
    }
    return self;
}
+ (CollectionConn *)getConn
{
    if (!userDataConn) {
        userDataConn = [[CollectionConn alloc]init];
    }
    return userDataConn;
}

//收藏同步请求
- (void)sendCollectionSync:(NSDictionary *)dic
{
    if ([eCloudConfig getConfig].supportCollection) {
        conn *_conn = [conn getConn];
        CONNCB *_conncb = [_conn getConnCB];
        
        int ret = CLIENT_FavoriteSync(_conncb, _conn.oldCollectUpdateTime,TERMINAL_IOS);
        
        [LogUtil debug:[NSString stringWithFormat:@"%s updatetime is %d",__FUNCTION__,_conn.oldCollectUpdateTime]];
        curCount = 0;
    }
}

//处理收藏同步应答
- (void)processCollectionSyncAck:(FAVORITE_SYNC_ACK *)syncAck
{
//    eCloudUser *eCloud = [eCloudUser getDatabase];
//    [eCloud saveCollectUpdateTime];
}

//收藏修改请求
- (void)sendModiRequestWithMsg:(NSDictionary *)dic
{
    ConvRecord *_convRecord = dic[@"editRecord"];
    if (_convRecord) {
        NSLog(@"======%lld",_convRecord.origin_msg_id);
    }
    [self.myDic setObject:dic forKey:[NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id]];
  
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    FAVORITE_MODIFY_REQ favoriteModify;
    memset(&favoriteModify, 0, sizeof(favoriteModify));
    favoriteModify.dwCompID  = [UserDefaults getCompId];           //企业ID
    favoriteModify.dwUserID  = _conn.userId.intValue;              //用户ID
    favoriteModify.cTerminal = TERMINAL_IOS;                       //终端类型
    favoriteModify.cOperType = [dic[@"operationType"] intValue];   //操作类型 1新增,2修改,3删除
    
    // 新增收藏
    if (favoriteModify.cOperType == 1)
    {
        struct favorite_info STFavoriteInfo;
        memset(&STFavoriteInfo, 0, sizeof(STFavoriteInfo));
        
        ConvRecord *editRecord = dic[@"editRecord"];
        
        NSLog(@"%s msgbody is %@ filename is %@ filesize is %@",__FUNCTION__,editRecord.msg_body,editRecord.file_name,editRecord.file_size);
        
        STFavoriteInfo.dwCompID = [UserDefaults getCompId];               //企业ID
        STFavoriteInfo.dwUserID = _conn.userId.intValue;                  //用户ID
        STFavoriteInfo.dwCollTime = [dic[@"time"] intValue];              //消息收藏时间
        STFavoriteInfo.cUpdateType = 1;                                   //1新增，2修改，3删除
        STFavoriteInfo.dwSender = editRecord.emp_id;                      //原始消息发送者
        STFavoriteInfo.cIsGroup = editRecord.conv_type;                   //是不是群组消息
        
        if (editRecord.conv_type == mutiableType) {
            char *cConvId = [StringUtil getCStringByString:editRecord.conv_id];
            memcpy(STFavoriteInfo.strGroupID, cConvId, strlen(cConvId));
        }
        STFavoriteInfo.ddwMsgID = editRecord.origin_msg_id;               //消息ID
        STFavoriteInfo.dwSendTime = editRecord.msg_time.intValue;         //发送时间
        STFavoriteInfo.wMsgType = editRecord.msg_type;                    //消息类型
        
        switch (editRecord.msg_type) {
            case type_text:
            {
                // 测试用的  lyalyan
//                STFavoriteInfo.wMsgType = type_text;
                
                const char *cMsg = [editRecord.msg_body cStringUsingEncoding:NSUTF8StringEncoding];
                int len = strlen(cMsg);
                /*-------------------------------补前面10位为0-------------------------*/
                char temp[len+10];
                memset(temp,0,sizeof(temp));
                
                memcpy(temp+10,cMsg,len);
                len=len+10;
                cMsg=temp;
                STFavoriteInfo.dwMsgSize = len;                            //消息长度
                memcpy(STFavoriteInfo.strMsgContent, cMsg, STFavoriteInfo.dwMsgSize);
            }
                break;
                case type_record:
                case type_pic:
                case type_file:
                case type_video:
            {
                
                const char *_fileName = [editRecord.file_name cStringUsingEncoding:NSUTF8StringEncoding];
                int fileNameLen = strlen(_fileName);
                
                const char *_fileUrl = [editRecord.msg_body cStringUsingEncoding:NSUTF8StringEncoding];
                int fileUrlLen = strlen(_fileUrl);
                
                FILE_META fileinfo;
                memset(&fileinfo, 0, sizeof(FILE_META));
                
                //	文件大小
                fileinfo.dwFileSize = htonl(editRecord.file_size.intValue);
                //	文件名字
                memcpy(fileinfo.aszFileName, _fileName, fileNameLen);
                //	文件url
                memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
                
                char* msg = (char*)&fileinfo;
                
                STFavoriteInfo.dwMsgSize = sizeof(fileinfo);                            //消息长度
                memcpy(STFavoriteInfo.strMsgContent, msg, STFavoriteInfo.dwMsgSize);
            }
                break;
                
                case type_long_msg:
            {
                NSString *tempFileName = [NSString stringWithFormat:@"%@.txt",editRecord.msg_body];
                const char *_fileName = [tempFileName cStringUsingEncoding:NSUTF8StringEncoding];
                int fileNameLen = strlen(_fileName);
                
                const char *_fileUrl = [editRecord.msg_body cStringUsingEncoding:NSUTF8StringEncoding];
                int fileUrlLen = strlen(_fileUrl);
                
                FILE_META fileinfo;
                memset(&fileinfo, 0, sizeof(FILE_META));
                
                //	文件大小
                fileinfo.dwFileSize = htonl(editRecord.file_size.intValue);
                //	文件名字
                memcpy(fileinfo.aszFileName, _fileName, fileNameLen);
                //	文件url
                memcpy(fileinfo.aszURL,_fileUrl,fileUrlLen);
                
                //	长消息head,定长50个字符
                const char *cMsgHead = [editRecord.file_name cStringUsingEncoding:NSUTF8StringEncoding];
                int messageHeadLen = strlen(cMsgHead);
                //	[LogUtil debug:[NSString stringWithFormat:@"messageHeadLen is %d",messageHeadLen);
                
                char _msgHead[50];
                memset(_msgHead, 0, sizeof(_msgHead));
                memcpy(_msgHead,cMsgHead, messageHeadLen > 50?50:messageHeadLen);
                
                
                //	消息体的总长度(字体+文件+消息头部)
                int totalLen = 10 + sizeof(FILE_META) + 50;
                //	总消息体
                char totalMsg[totalLen];
                memset(totalMsg,0,sizeof(totalMsg));
                memcpy(totalMsg + 10,&fileinfo,sizeof(FILE_META));
                memcpy((totalMsg + 10 + sizeof(FILE_META)), _msgHead, 50);
                
                STFavoriteInfo.dwMsgSize = sizeof(totalMsg);                            //消息长度
                memcpy(STFavoriteInfo.strMsgContent, totalMsg, STFavoriteInfo.dwMsgSize);
            }
                break;
                
            default:
                break;
        }
        
        favoriteModify.stFavoriteInfo = STFavoriteInfo;
    }
    // 批量删除收藏
    else if (favoriteModify.cOperType == 3)
    {
        NSArray *arr = dic[@"delete"];
//        favoriteModify.wTotalNum = arr.count;                //总条数
//        favoriteModify.wCurNum   = arr.count;                //当前条数
        struct favorite_batch_opera STFavoriteBatch;
        memset(&STFavoriteBatch, 0, sizeof(STFavoriteBatch));
        STFavoriteBatch.wNum = arr.count;                      //数量
        for (int i = 0; i < arr.count; i++) {
            NSString *msgIDstr = arr[i];
            long long msgID = msgIDstr.longLongValue;
            STFavoriteBatch.ddwMsgID[i] = msgID;
        }
        
        favoriteModify.stFavoriteBatch = STFavoriteBatch;
    }
    
    int req = CLIENT_FavoriteModifyReq(_conncb, &favoriteModify);
}

-(void)ModiRequestAck:(FAVORITE_MODIFY_ACK *)info
{
    NSMutableArray *MyArr = [NSMutableArray array];
    for (int i = 0; i < info->stFavoriteBatch.wNum; i ++ ) {
        
        NSLog(@"%s %d msgid is %lld ",__FUNCTION__,i,info->stFavoriteBatch.ddwMsgID[i]);
        [MyArr addObject:[NSString stringWithFormat:@"%lld",info->stFavoriteBatch.ddwMsgID[i]]];
    }
    
    if (info->dwResult == RESULT_SUCCESS) {
        if (info->cOperType == 1)
        {
            NSLog(@"收藏成功");
            // 把收藏保存到本地
            CollectionDAO *collectionDAO = [CollectionDAO shareDatabase];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i = 0; i < info->stFavoriteBatch.wNum; i ++ ) {
                
                NSLog(@"%s %d msgid is %lld ",__FUNCTION__,i,info->stFavoriteBatch.ddwMsgID[i]);
                dict = [self.myDic objectForKey:[NSString stringWithFormat:@"%lld",info->stFavoriteBatch.ddwMsgID[i]]];
                [collectionDAO addCollection:dict];
                [self.myDic removeObjectForKey:[NSString stringWithFormat:@"%lld",info->stFavoriteBatch.ddwMsgID[i]]];
            }

        }
        else if (info->cOperType == 3)
        {
            NSLog(@"删除成功");
            [[CollectionDAO shareDatabase] deleteLocalCollection:MyArr];
            
            [[NotificationUtil getUtil]sendNotificationWithName:COLLECT_DELETED_SUCCESSFULLY andObject:nil andUserInfo:nil];
            
        }
        
        [[eCloudUser getDatabase]saveCollectUpdateTime];
    }
    else
    {
        if (info->cOperType == 1)
        {
            NSLog(@"收藏失败");
       
        }
        else if (info->cOperType == 3)
        {
            NSLog(@"删除失败");
        }
    }
}

//处理通知应答
- (void)collectNotice:(FAVORITE_NOTICE *)info
{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 总条数:%d  当前条数:%d",__FUNCTION__,info->wTotalNum,info->wCurNum]];

    if (info->cOperType == 1)
    {
        NSString *msgBody = nil;
        
//        UINT16	wTotalNum;		//总条数
//        UINT16	wCurNum;		//当前条数
        

        struct favorite_info favoriteInfo = info->stFavoriteInfo;
        
        ConvRecord *convRecord = [[ConvRecord alloc] init];
        
        int msgType = favoriteInfo.wMsgType;
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"editRecord"] = convRecord;
        dictionary[@"time"] = [NSString stringWithFormat:@"%u",favoriteInfo.dwCollTime];

//
        convRecord.msg_type = msgType;
        convRecord.origin_msg_id = favoriteInfo.ddwMsgID;
        convRecord.emp_id = favoriteInfo.dwSender;
        convRecord.msg_time = [NSString stringWithFormat:@"%ld",favoriteInfo.dwSendTime];
//        增加保存 会话id 会话标题 会话类型 ，还要保存真正的类型
        if (favoriteInfo.cIsGroup == 0) {
//            单聊
            convRecord.conv_type = singleType;
            convRecord.conv_title = [StringUtil getLocalizableString:@"personal"];
            
        }else{
//            固定群或普通群
            convRecord.conv_type = mutiableType;
            //        获取会话id
            convRecord.conv_id = [StringUtil getStringByCString:favoriteInfo.strGroupID];
            
            //        从本地获取会话title
            convRecord.conv_title = [[eCloudDAO getDatabase]getConvTitleByConvId:convRecord.conv_id];
        }
        
//        真正的类型默认和收到的类型一样
        convRecord.realMsgType = convRecord.msg_type;
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 添加收藏 收到的收藏类型为 %d 对应的原始消息id是%lld",__FUNCTION__,msgType, convRecord.origin_msg_id]];
        
        BOOL needSave = YES;
        
        switch (msgType) {
            case type_text:
            {
                int msgLen = favoriteInfo.dwMsgSize - 10;
                char temp[msgLen + 1];
                memset(temp,0,sizeof(temp));
                memcpy(temp,favoriteInfo.strMsgContent+10, msgLen);
                msgBody = [StringUtil getStringByCString:temp];
                
                convRecord.msg_body = msgBody;
                
                if ([[CollectionDAO shareDatabase]isXiaoWanMsg:msgBody]) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s 收到了一条小万消息收藏",__FUNCTION__]];
                }else{
                    // 判断类型
                    NSMutableArray *array = [NSMutableArray array];
                    [StringUtil seperateMsg:msgBody andImageArray:array];
                    if (array.count == 1)
                    {
                        if([msgBody hasPrefix:PC_CROP_PIC_START] && [msgBody hasSuffix:PC_CROP_PIC_END])
                        {
                            convRecord.msg_type = type_pic;
                            convRecord.realMsgType = convRecord.msg_type;
                            
                            NSString *imageUrl = [StringUtil getPicMsgUrlByMsgBody:msgBody];
                            if(imageUrl.length > 0)
                            {
                                convRecord.msg_body = imageUrl;
                                convRecord.file_name = [StringUtil getPicNameByPicUrl:imageUrl];
                            }
                        }
                    }
                    else
                    {
                        convRecord.msg_type = type_normal_imgtxt;
                        convRecord.realMsgType = type_normal_imgtxt;
                    }
                }
            }
                break;
            case type_pic:
            case type_record:
            case type_file:
            case type_video:
            {
                FILE_META *fileInfo = (FILE_META *)&favoriteInfo.strMsgContent;

                convRecord.msg_body = [StringUtil getStringByCString:fileInfo->aszURL];
                convRecord.file_name = [StringUtil getStringByCString:fileInfo->aszFileName];
                convRecord.file_size = [NSString stringWithFormat:@"%d",ntohl(fileInfo->dwFileSize)];
            }
                break;
            case type_long_msg:
            {
                //		取出长消息文件信息
                char _fileInfo[sizeof(FILE_META)];
                memset(_fileInfo,0,sizeof(_fileInfo));
                memcpy(_fileInfo,favoriteInfo.strMsgContent + 10,sizeof(FILE_META));
                
                FILE_META *fileInfo = (FILE_META *)_fileInfo;
                //		长消息字节数
                convRecord.file_size = [NSString stringWithFormat:@"%d",ntohl(fileInfo->dwFileSize)];
                convRecord.msg_body = [StringUtil getStringByCString:fileInfo->aszURL];
            }
                break;
            default:
            {
                needSave = NO;
            }
                break;
        }
        if (needSave) {
            
            //              保存到收藏表
            [[CollectionDAO shareDatabase] addCollection:dictionary];
            
            
            
            if (_delegate && [_delegate respondsToSelector:@selector(addCollection)])
            {
                [_delegate addCollection];
            }
//            自动下载对应的文件消息
//            保存到数据库时下载
//            [self downloadFile:convRecord];
        }
    }
    else if (info->cOperType == 3)
    {
        struct favorite_batch_opera stFavoriteBatch = info->stFavoriteBatch;
        int deleteNum = stFavoriteBatch.wNum;
        
        NSMutableArray *mArr = [NSMutableArray array];
//        NSInteger count = sizeof(stFavoriteBatch.ddwMsgID) / sizeof(stFavoriteBatch.ddwMsgID[0]);
        for (int i = 0; i < deleteNum; i++)
        {
            NSString *str = [NSString stringWithFormat:@"%lld",stFavoriteBatch.ddwMsgID[i]];
            [mArr addObject:str];
            [LogUtil debug:[NSString stringWithFormat:@"%s 删除收藏 msgid is %@",__FUNCTION__,str]];
        }
        [[CollectionDAO shareDatabase] deleteLocalCollection:mArr];
        
        if (_delegate && [_delegate respondsToSelector:@selector(deleteCollectionByArray:)] && info->wTotalNum == info->wCurNum)
        {
            [_delegate deleteCollectionByArray:mArr];
        }
    }
    
    //        如果只有一条 那么马上保存时间戳
    if (info->wTotalNum == 1) {
        [[eCloudUser getDatabase]saveCollectUpdateTime];
    }else{
        curCount++;
        if (curCount == info->wTotalNum) {
            [[eCloudUser getDatabase]saveCollectUpdateTime];
            curCount = 0;
        }
    }
}


//下载图片
- (void)downloadPic:(NSString *)msgBody
{
    
    NSString *imageUrl = [StringUtil getPicMsgUrlByMsgBody:msgBody];
    
    if (imageUrl.length) {
        
        //图片
        NSString *messageStr = imageUrl;
        NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
        NSString *picpath = [[CollectionUtil newCollectFilePath] stringByAppendingPathComponent:picname];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s picpath is %@",__FUNCTION__,picpath]];
        
        // 如果本地没有就下载
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:picpath];
        if (!isExist)
        {
            NSString *downloadKey = [NSString stringWithFormat:@"%@",imageUrl];
            if ([self isFileDownloading:downloadKey]) {
                return;
            }

            [self saveToDownloadDicOnMainThread:downloadKey];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@%@",[[[eCloudUser getDatabase]getServerConfig] getNewPicDownloadUrl],imageUrl,[StringUtil getResumeDownloadAddStr]];
            [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,urlStr]];
            
            dispatch_queue_t queue;
            queue = dispatch_queue_create("getCollection", NULL);
            dispatch_async(queue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                [data writeToFile:picpath atomically:YES];
                [LogUtil debug:[NSString stringWithFormat:@"%s 图片下载保存成功 文件路径是%@",__FUNCTION__,picpath]];
                
                [self removeFromDownloadDicOnMainThread:downloadKey];
            });
        }else{
            [LogUtil debug:[NSString stringWithFormat:@"%s 图片已经存在",__FUNCTION__]];
        }
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s image url is nil 参数是%@",__FUNCTION__,msgBody]];
    }
}

//下载一个文件 参数是文件对应的url 和 保存的文件名字
- (void)downloadFile:(ConvRecord *)convRecord
{
    // 如果是小万消息
    if (convRecord.robotModel)
    {
        [self downloadXiaoWanFile:convRecord];
        
        return;
    }
    // 如果是普通消息
    if (convRecord.msg_type == type_text) {
        return;
    }
    
    
    [LogUtil debug:[NSString stringWithFormat:@"%s msgbody(fileurl) is %@ filename is %@ filesize is %@",__FUNCTION__,convRecord.msg_body,convRecord.file_name,convRecord.file_size]];

    if (convRecord.msg_type == type_normal_imgtxt) {

        //		如果是文本消息 不能直接入库，要看下有没有pc端发来的截图,如果有那么自动下载
        NSMutableArray *array = [NSMutableArray array];
        [StringUtil seperateMsg:convRecord.msg_body andImageArray:array];
        //		NSLog(@"%@",array.description);
        
        for(NSString *str in array)
        {
            [self downloadPic:str];
        }
    }else if (convRecord.msg_type == type_pic) {
        [self downloadPic:convRecord.msg_body];
    }else {
        NSString *fileUrl = convRecord.msg_body;
        NSString *downloadKey = [NSString stringWithFormat:@"%lld_%@",convRecord.origin_msg_id,fileUrl];
        if ([self isFileDownloading:downloadKey]) {
            return;
        }

        NSString *filePath = nil;
        if (convRecord.msg_type == type_long_msg) {
            filePath = [talkSessionUtil getLongMsgPath:convRecord];
        }else if (convRecord.msg_type == type_record){
            convRecord.file_name = [StringUtil getAudioNameByAudioUrl:fileUrl];
            filePath = [talkSessionUtil getAudioPath:convRecord];
        }else if (convRecord.msg_type == type_video){
            NSString *fileName = [NSString stringWithFormat:@"%@.mp4",convRecord.msg_body];
            filePath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:fileName];
        }
        else{
            filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:[talkSessionUtil getFileName:convRecord]];
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s filePath is %@",__FUNCTION__,filePath]];

        
        if (filePath) {
            // 如果本地没有就下载
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (!isExist)
            {
                [self saveToDownloadDicOnMainThread:downloadKey];

                NSString *urlStr = [NSString stringWithFormat:@"%@?token=%@&%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],fileUrl,[StringUtil getResumeDownloadAddStr]];
                
                [LogUtil debug:[NSString stringWithFormat:@"%s urlStr is %@",__FUNCTION__,urlStr]];

                dispatch_queue_t queue;
                queue = dispatch_queue_create("getCollection", NULL);
                dispatch_async(queue, ^{
                    
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                    [data writeToFile:filePath atomically:YES];
                    
                    [talkSessionUtil transferFile:convRecord];
                    
                    [LogUtil debug:[NSString stringWithFormat:@"%s 下载保存成功 文件路径是%@",__FUNCTION__,filePath]];

                    [self removeFromDownloadDicOnMainThread:downloadKey];
                });
            }else{
                [LogUtil debug:[NSString stringWithFormat:@"%s 文件已经存在,不用下载",__FUNCTION__]];
            }
        }
    }
}

- (void)downloadXiaoWanFile:(ConvRecord *)convRecord
//- (void)downloadXiaoWanFile:(RobotResponseModel *)robotModel withTitle:(NSInteger)title withURL:(NSInteger)URL
{
    NSArray *argsArray = convRecord.robotModel.argsArray;
    
    NSString *titleStr = nil;
    NSString *fileURL = nil;

    switch (convRecord.robotModel.msgType) {
        case type_pic:
        case type_video:
        case type_record:
        {
            titleStr = convRecord.robotModel.msgFileName;
            fileURL = convRecord.robotModel.msgFileDownloadUrl;
        }
            break;
        case type_wiki:
        {
//            百科消息
            if (argsArray.count >= 3) {
                titleStr = [NSString stringWithFormat:@"robot_%@", argsArray[0]];
                fileURL = argsArray[2];                
            }
        }
            break;
        case type_imgtxt:
        {
            //                图文消息
            NSArray *argsArray = convRecord.robotModel.imgtxtArray;
            
            if (argsArray.count) {
                NSDictionary *dic = argsArray[0];
                NSLog(@"%@",[dic description]);
                titleStr = [NSString stringWithFormat:@"robot_%@",dic[@"Title"]];
                fileURL = dic[@"PicUrl"];
            }
        }
        default:
            break;
    }

    NSString *downloadKey = [NSString stringWithFormat:@"%lld_%@",convRecord.origin_msg_id,fileURL];
    if ([self isFileDownloading:downloadKey]) {
        return;
    }
    
//    NSString *titleStr = argsArray[title];
//    NSString *fileURL = argsArray[URL];
    if ([convRecord.robotModel.nameString isEqual:@"wiki"]) {
        titleStr = [NSString stringWithFormat:@"%@.jpg",titleStr];
        NSRange range = [fileURL rangeOfString:@"src="];
        if (range.length > 0) {
            NSInteger start = range.location+range.length;
            fileURL = [fileURL substringWithRange:NSMakeRange(start, fileURL.length-start)];
        }
    }else if ([convRecord.robotModel.nameString isEqual:@"imgtxtmsg"]) {
//        保存文件时需要拼接jpg
        titleStr = [NSString stringWithFormat:@"%@.jpg",titleStr];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[CollectionUtil newCollectFilePath],titleStr];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 参数:%@ filepath is %@",__FUNCTION__,[argsArray description],filePath]];

    // 如果本地没有就下载
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExist)
    {
        [self saveToDownloadDicOnMainThread:downloadKey];
        dispatch_queue_t queue;
        queue = dispatch_queue_create("getCollection", NULL);
        dispatch_async(queue, ^{
            
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
            [data writeToFile:filePath atomically:YES];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 下载保存成功 文件路径是%@",__FUNCTION__,filePath]];
            [self removeFromDownloadDic:downloadKey];
        });
    }
}

//保存到字典
- (void)saveToDownloadDicOnMainThread:(NSString *)key
{
    [self performSelectorOnMainThread:@selector(saveToDownloadDic:) withObject:key waitUntilDone:YES];
}

- (void)saveToDownloadDic:(NSString *)key
{
    [LogUtil debug:[NSString stringWithFormat:@"%s 开始下载 %@",__FUNCTION__,key]];
    [self.downloadDic setValue:FILE_IS_DOWNLOADING forKey:key];
}

//从字典删除
- (void)removeFromDownloadDicOnMainThread:(NSString *)key
{
    [self performSelectorOnMainThread:@selector(removeFromDownloadDic:) withObject:key waitUntilDone:YES];
}

- (void)removeFromDownloadDic:(NSString *)key
{
    [LogUtil debug:[NSString stringWithFormat:@"%s 下载完毕 %@",__FUNCTION__,key]];

    [self.downloadDic removeObjectForKey:key];
}

//判断是否已经在下载
- (BOOL)isFileDownloading:(NSString *)key
{
    if ([self.downloadDic valueForKey:key]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 正在下载 %@",__FUNCTION__,key]];
        return YES;
    }
    return NO;
}
@end
