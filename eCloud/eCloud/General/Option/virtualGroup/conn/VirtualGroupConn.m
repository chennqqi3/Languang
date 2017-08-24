//
//  VirtualGroupConn.m
//  eCloud
//
//  Created by yanlei on 15/12/3.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "VirtualGroupConn.h"

#import "conn.h"
#import "StringUtil.h"
#import "UserDefaults.h"
#import "VirtualGroupDAO.h"
#import "VirtualGroupInfoModel.h"
#import "VirtualGroupMemberModel.h"

#import "LogUtil.h"

static VirtualGroupConn *virtualGroupConn;

@interface VirtualGroupConn (){
    // 虚拟组个数
    int synVirtualGroupCount;
}

@property (nonatomic,retain) NSMutableArray *synVirtualGroupArray;
@end

@implementation VirtualGroupConn

+ (VirtualGroupConn *)getVirtualGroupConn
{
    if (!virtualGroupConn) {
        virtualGroupConn = [[super alloc]init];
    }
    return virtualGroupConn;
}

//发起同步虚拟组信息请求
- (BOOL)syncVirtalGroupInfo:(CONNCB *)_conncb
{
    // 取出虚拟组里面最大的时间戳
    NSString *updateTimer = [[VirtualGroupDAO getDatabase]getUpdate_time];
    if (!updateTimer) {
        updateTimer = @"0";
    }
    int ret = CLIENT_VirtualGroupInfoReq(_conncb,[updateTimer intValue],2);
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,同步虚拟组 时间戳 %@ ",__FUNCTION__,updateTimer]];

    if(ret != RESULT_SUCCESS)
    {
        return NO;
    }
    return YES;
}

#pragma mark - 解析同步虚拟组请求的应答
-(void)processVirtualGroupInfoAck:(VIRTUAL_GROUP_INFO_ACK *)info
{
    // UINT32 dwResult; // UINT8  cTerminalType; //终端类型 UINT32 dwCompID; //企业ID UINT32 dwUserID; //用户id  UINT16 wVirGroupNum;	//返回变化的虚拟组个数
    synVirtualGroupCount = info->wVirGroupNum;
    
    [LogUtil debug:[NSString stringWithFormat:@"同步虚拟组下方的个数 %d",synVirtualGroupCount]];
}

#pragma mark - 解析虚拟组通知内容
-(void)processVirtualGroupInfoNotice:(VIRTUAL_GROUP_INFO_NOTICE *)info
{
    // 通知内容
    //UINT8  cTerminalType; //终端类型 UINT32 dwCompID; //企业ID UINT32 dwUserID; //用户id
    //UINT16 wTotalNum; //总共变化的群组 UINT16 wCurNum; //当前是第几个 struct virtual_group_info mVirGroupInfo; //成员结构体
    
//    dwGroupMember
    
    // 成员信息
    /*UINT32	dwMainUserID;				//虚拟组关联账号
    char	strGroupID[GROUPID_MAXLEN];	//虚拟组ID
    UINT32	dwGroupTime;				//虚拟组时间戳
    UINT8	cUpdateType;				//虚拟组更新类型
    UINT16	wMemberNum;					//虚拟组成员个数
    UINT16	wSingleSvcNum;				//单个成员服务的最大人数
    UINT16	wTimeoutMinute;				//连接空闲超时时间
    UINT8	cDisplaysUsercode;			//是否显示真实的usercode
    char	strWaiting[MAX_VIR_GRP_PMT_LEN];//等待提示语
    char	strHangup[MAX_VIR_GRP_PMT_LEN];	//挂断提示语
    char	strOncall[MAX_VIR_GRP_PMT_LEN];	//建立连接提示语
     */
    /*
     `main_userid` int(4) NOT NULL COMMENT '虚拟组主账号',
     `groupid` varchar(20) COLLATE utf8_unicode_ci NOT NULL COMMENT '虚拟组ID',
     `member_num` int(2) NOT NULL DEFAULT '1' COMMENT '虚拟组成员个数',
     `single_svc_num` int(2) NOT NULL DEFAULT '1' COMMENT '单个成员支持人员上限',
     `timeout_minute` int(2) NOT NULL DEFAULT '3' COMMENT '服务过期时间，单位分钟',
     `waiting_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '等待提示语',
     `hangup_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '挂断提示语',
     `oncall_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '接通提示语',
     `real_code` int(1) NOT NULL DEFAULT '0' COMMENT '是否显示真是账号 0不显示，非0显示',
     `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
     `update_type` int(1) NOT NULL DEFAULT '1',
     */
    if (!_synVirtualGroupArray) {
        _synVirtualGroupArray = [[NSMutableArray alloc]init];
    }
    
    struct virtual_group_info groupMemberInfo = info->mVirGroupInfo;
    // 获取虚拟组信息
    struct virtual_group_basic_info groupMemberBaseInfo = groupMemberInfo.mBasicInfo;
    // 获取虚拟组中的成员个数
    int memberNum = groupMemberBaseInfo.wMemberNum;
    [LogUtil debug:[NSString stringWithFormat:@"虚拟组通知下发内容 ,变化的群组个数 is %d,当前是第%d个群组,当前虚拟组的成员个数为: %d",info->wTotalNum,info->wCurNum,memberNum]];
    
    VirtualGroupInfoModel *groupInfoModel = [[VirtualGroupInfoModel alloc]init];

    groupInfoModel.main_userid = groupMemberBaseInfo.dwMainUserID;
    groupInfoModel.groupid = [StringUtil getStringByCString:groupMemberBaseInfo.strGroupID];
    groupInfoModel.member_num = memberNum;
    groupInfoModel.single_svc_num = groupMemberBaseInfo.wSingleSvcNum;
    groupInfoModel.timeout_minute = groupMemberBaseInfo.wTimeoutMinute;
    groupInfoModel.waiting_prompt = [StringUtil getStringByCString:groupMemberBaseInfo.strWaiting];
    groupInfoModel.hangup_prompt = [StringUtil getStringByCString:groupMemberBaseInfo.strHangup];
    groupInfoModel.oncall_prompt = [StringUtil getStringByCString:groupMemberBaseInfo.strOncall];
    groupInfoModel.real_code = groupMemberBaseInfo.cDisplaysUsercode;
    groupInfoModel.update_time = [StringUtil getStringValue:groupMemberBaseInfo.dwGroupTime];
    groupInfoModel.update_type = groupMemberBaseInfo.cUpdateType;
    
    // 加载虚拟组成员
    for (int i = 0; i < memberNum; i++)
    {
        VirtualGroupMemberModel *groupMemberModel = [[VirtualGroupMemberModel alloc]init];
        groupMemberModel.groupid = groupInfoModel.groupid;
        groupMemberModel.userid = groupMemberInfo.dwGroupMember[i];
        groupMemberModel.update_time = [StringUtil getStringValue:groupMemberBaseInfo.dwGroupTime];
        groupMemberModel.update_type = groupMemberBaseInfo.cUpdateType;
        [LogUtil debug:[NSString stringWithFormat:@"虚拟组id：%@,成员id：%d",groupInfoModel.groupid,groupMemberModel.userid]];
        [groupInfoModel.virtualMemberArray addObject:groupMemberModel];
        [groupMemberModel release];
    }
    
    [self.synVirtualGroupArray addObject:groupInfoModel];
    [groupInfoModel release];
    if (info->wTotalNum == info->wCurNum) {
        // 进行数据保存
        [[VirtualGroupDAO getDatabase]saveSynVirtualGroupInfo:self.synVirtualGroupArray];
    }
}

- (void)dealloc{
    if (_synVirtualGroupArray) {
        [_synVirtualGroupArray release];
        _synVirtualGroupArray = nil;
    }
    [super dealloc];
}
@end
