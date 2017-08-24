//
//  eCloudConfig.m
//  TestConfig
//
//  Created by shisuping on 15-8-11.
//  Copyright (c) 2015年 mimsg. All rights reserved.
//

#import "eCloudConfig.h"
#import "StringUtil.h"
#import "DES.h"

static eCloudConfig *_eCloudConfig;

@implementation eCloudConfig
{
}

+ (eCloudConfig *)getConfig
{
    if (!_eCloudConfig) {
        _eCloudConfig = [[eCloudConfig alloc]init];
    }
    return _eCloudConfig;
}


- (void)loadConfig
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    self.useContraints = NO;
    
    if ([[StringUtil getAppBundleName] rangeOfString:@"csair" options:NSCaseInsensitiveSearch].length > 0) {
        [self loadEncryptDefaultConfig:mDic];
        [self loadEncryptAppConfig:mDic];
    }else{
        //    首先读默认配置
        [self loadDefaultConfig:mDic];
        
        //    然后读App配置
        [self loadAppConfig:mDic];
    }
    
//    最后再读用户数据目录下的配置
    [self loadUserConfig:mDic];
    
//
    [self parseConfig:mDic];
    
    NSLog(@"%s config is %@",__FUNCTION__,mDic);
    
}

//递归调用
- (void)saveConfig:(NSDictionary *)srcDic toDic:(NSMutableDictionary *)destDic
{
    NSEnumerator *_enum = [srcDic keyEnumerator];
    id _key = nil;
    while (_key = [_enum nextObject]) {
        id _value = [srcDic objectForKey:_key];
        if ([_value isKindOfClass:[NSDictionary class]]) {
            [self saveConfig:(NSDictionary *)_value toDic:destDic];
        }
        else
        {
            [destDic setObject:_value forKey:_key];
        }
    }
}


- (void)loadConfigWithPath:(NSString *)configPath :(NSMutableDictionary *)mDic
{
    if (!configPath) {
        return;
    }
    NSDictionary *srcDic = [[NSDictionary alloc]initWithContentsOfFile:configPath];
    if (!srcDic) {
        return;
    }
    
    [self saveConfig:srcDic toDic:mDic];
}


- (void)loadDefaultConfig:(NSMutableDictionary *)mDic
{
    NSString *configPath = [[StringUtil getBundle]pathForResource:default_config_name ofType:@"plist"];
    
    [self loadConfigWithPath:configPath :mDic];
}

- (void)loadAppConfig:(NSMutableDictionary *)mDic
{
    NSString *configPath = [[StringUtil getBundle]pathForResource:app_config_name ofType:@"plist"];
    
    [self loadConfigWithPath:configPath :mDic];
}

- (void)loadUserConfig:(NSMutableDictionary *)mDic
{
    NSString *configPath = [[StringUtil getHomeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",user_config_name]];
    
    [self loadConfigWithPath:configPath :mDic];
}

- (void)parseConfig:(NSMutableDictionary *)mDic
{
    
    [self parseServerConfig:mDic];
    
    [self parseEngineConfig:mDic];
    
    [self parseOrgConfig:mDic];
    
    [self parseTabBarConfig:mDic];
 
    [self parseSettingConfig:mDic];
    
    [self parseUserInterfaceConfig:mDic];
    
}

- (void)parseServerConfig:(NSDictionary *)mDic
{
    self.primaryServerUrl = mDic[KEY_PRIMARY_SERVER_URL];
    self.primaryServerIp = mDic[KEY_PRIMARY_SERVER_IP];
    self.primaryServerPort = mDic[KEY_PRIMARY_SERVER_PORT];
    
    self.secondServerUrl = mDic[KEY_SECOND_SERVER_URL];
    self.secondServerIp = mDic[KEY_SECOND_SERVER_IP];
    self.secondServerPort = mDic[KEY_SECOND_SERVER_PORT];
    
    self.otherServerUrl = mDic[KEY_OTHER_SERVER_URL];
    self.otherServerIp = mDic[KEY_OTHER_SERVER_IP];
    self.otherServerPort = mDic[KEY_OTHER_SERVER_PORT];
    
    self.fileServerUrl = mDic[KEY_FILE_SERVER_URL];
    self.fileServerPort = mDic[KEY_FILE_SERVER_PORT];
    self.fileServerPath = mDic[KEY_FILE_SERVER_PATH];
    
    self.needConnectByIpIfGPRS = [mDic[KEY_NEED_CONNECT_BY_IP_IF_GPRS]boolValue];

    self.displayServerConfigButton = [mDic[KEY_DISPLAY_SERVER_CONFIG_BUTTON]boolValue];
}

- (void)parseEngineConfig:(NSDictionary *)mDic
{
    self.needDownloadOrgDB = [mDic[KEY_NEED_DOWNLOAD_ORG_DB]boolValue];
    
    self.needApplist = [mDic[KEY_NEED_APPLIST]boolValue];
    
    self.needSwitchFileServer = [mDic[KEY_NEED_SWITCH_FILE_SERVER]boolValue];
    
    self.needEncryptDB = [mDic[KEY_NEED_ENCRYPTDB]boolValue];
    
    self.supportPublicService = [mDic[KEY_SUPPORT_PUBLIC_SERVICE]boolValue];
    
    self.searchTextMinLen = mDic[KEY_SEARCH_TEXT_MIN_LEN];
    
    self.facePrefix = mDic[KEY_FACE_PREFIX];
    if ([self.facePrefix isEqualToString:@"newface"]) {
        self.useNewFaceDefine = YES;
    }
    
    self.myViewModeType = mDic[KEY_MYVIEW_MODE_TYPE];
      
    self.userLogoRoundArc = mDic[KEY_USER_LOGO_ROUND_ARC];
    
    self.isUserLogoCircle = NO;
    if (self.userLogoRoundArc.floatValue == 0.5) {
        self.isUserLogoCircle = YES;
    }
    
    self.uploadUserLogoWidth = mDic[KEY_UPLOAD_USER_LOGO_WIDTH];
    
    self.uploadUserLogoHeight = mDic[KEY_UPLOAD_USER_LOGO_HEIGTH];
    
    self.canModifyUserInfo = [mDic[KEY_CAN_MODIFY_USER_INFO]boolValue];
    
    self.supportYHBY = [mDic[KEY_SUPPORT_YHBY]boolValue];
    
    self.supportReceiptMsg = [mDic[KEY_SUPPORT_RECEIPT_MSG]boolValue];
    
    self.delayWhenLaunch = [mDic[KEY_DELAY_WHEN_LAUNCH]boolValue];
    
    self.backgroundPicNum = mDic[KEY_BACKGROUND_PIC_NUM];
    
    self.supportCollection = [mDic[KEY_SUPPORT_COLLECTION]boolValue];
    
    self.supportGuidePages = [mDic[KEY_SUPPORT_GUIDEPAGES]boolValue];
    
    self.supportSavePassword = [mDic[KEY_SUPPORT_SAVEPASSWORD]boolValue];
    
    self.supportAudioToTxt = [mDic[KEY_SUPPORT_AUDIOTOTXT]boolValue];
    
    self.supportVideo = [mDic[KEY_SUPPORT_VIDEO]boolValue];
    
    self.supportRecallMsg = [mDic[KEY_SUPPORT_RECALLMSG]boolValue];

    self.supportSendLocation = [mDic[KEY_SUPPORT_SEND_LOCATION]boolValue];
    
    self.supportSendRedPacket = [mDic[KEY_SUPPORT_SEND_RED_PACKET]boolValue];
    
    self.supportShareExtension = [mDic[KEY_SUPPORT_SHARE_EXTENSION]boolValue];

    self.dspUserCodeWhenSearchOrg = [mDic[KEY_DSP_USERCODE_WHEN_SEARCH_ORG]boolValue];
    
    self.needShowAlertWhenOptionUpdate = [mDic[KEY_NEED_SHOW_ALERT_WHEN_OPTION_UPDATE]boolValue];
    
    self.contactListRightBtnClickMode = [mDic[KEY_CONTACT_LIST_RIGHT_BTN_CLICK_MODE]intValue];
    
    self.chatMessageDisplayReceiptMsgEntrance = [mDic[KEY_CHAT_MESSAGE_DISPLAY_RECEIPT_MSG_ENTRANCE]boolValue];
    
    self.chatMessageDisplayPicMsgEntrance = [mDic[KEY_CHAT_MESSAGE_DISPLAY_PIC_MSG_ENTRANCE]boolValue];
    
    self.chatMessageDisplayFileMsgEntrance = [mDic[KEY_CHAT_MESSAGE_DISPLAY_FILE_MSG_ENTRANCE]boolValue];
    
    self.needFixSecurityGap = [mDic[KEY_NEED_FIX_SECURITY_GAP]boolValue];
    
    self.autoSendMsgReadOfHuizhiMsg = [mDic[KEY_AUTO_SEND_MSG_READ_OF_HUIZHI_MSG]boolValue];
    
    self.needImportantMsgSetTop = [mDic[KEY_NEED_IMPORTANT_MSG_SET_TOP]boolValue];
    
    self.needDisplayUserStatus = [mDic[KEY_NEED_DISPLAY_USER_STATUS]boolValue];
        
    self.needSyncDeptShowConfig = [mDic[KEY_NEED_SYNC_DEPT_SHOW_CONFIG]boolValue];

}

- (void)parseOrgConfig:(NSDictionary *)mDic
{
    self.needCalculateDeptSubDept = [mDic[KEY_NEED_CALCULATE_DEPT_SUB_DEPT]boolValue];
    self.needCalculateDeptParentDept = [mDic[KEY_NEED_CALCULATE_DEPT_PARENT_DEPT]boolValue];
    self.needCalculateDeptEmpCount = [mDic[KEY_NEED_CALCULATE_DEPT_EMP_COUNT]boolValue];
    
    self.needGetDeptSubDeptToMemory = [mDic[KEY_NEED_GET_DEPT_SUB_DEPT_TO_MEMORY]boolValue];
    self.needGetDeptParentDeptToMemory = [mDic[KEY_NEED_GET_DEPT_PARENT_DEPT_TO_MEMORY]boolValue];
    
    self.needCreateDeptPinyinByDeptName = [mDic[KEY_NEED_CREATE_DEPT_PINYIN_BY_DEPTNAME]boolValue];
    
    self.needCreateEmpPinyinByEmpName = [mDic[KEY_NEED_CREATE_EMP_PINYIN_BY_EMPNAME]boolValue];
    
    self.needGetEmpSimplePinyinToMemory = [mDic[KEY_NEED_GET_EMP_SIMPLE_PINYIN_TO_MEMORY]boolValue];
    self.needGetEmpAllPinyinToMemory = [mDic[KEY_NEED_GET_EMP_ALL_PINYIN_TO_MEMORY]boolValue];
    
    
    self.searchEmpByLetter = mDic[KEY_SEARCH_EMP_BY_LETTER];
    self.searchEmpByNumber = mDic[KEY_SEARCH_EMP_BY_NUMBER];
    self.searchEmpBySpecialChar = mDic[KEY_SEARCH_EMP_BY_SPECIAL_CHAR];
    self.needSearchDept = [mDic[KEY_NEED_SEARCH_DEPT]boolValue];
    
    self.supportSearchByPhone = [mDic[KEY_SUPPORT_SEARCH_BY_PHONE]boolValue];
    self.supportSearchByTitle = [mDic[KEY_SUPPORT_SEARCH_BY_TITLE]boolValue];
    
    
}

- (void)parseTabBarConfig:(NSDictionary *)mDic
{
    self.conversationIndex = [mDic[KEY_CONVERSATION_INDEX]intValue];
    self.orgIndex = [mDic[KEY_ORG_INDEX]intValue];
    self.myIndex = [mDic[KEY_MY_INDEX]intValue];
    self.settingIndex = [mDic[KEY_SETTING_INDEX]intValue];
    self.homepageIndex = [mDic[KEY_HOMEPAGE_INDEX]intValue];
}

- (void)parseSettingConfig:(NSDictionary *)mDic
{
    self.supportFontStyleSetting = [mDic[KEY_SUPPORT_FONTSTYLE_SETTING]boolValue];
    self.supportLanguageSetting = [mDic[KEY_SUPPORT_LANGUAGE_SETTING]boolValue];
}

/** 解析UI方面的配置 */
- (void)parseUserInterfaceConfig:(NSDictionary *)mDic{
    self.needWaterMark = [mDic[KEY_NEED_WATERMARK]boolValue];
    self.backToLoginWhenLoginOtherTerminal = [mDic[KEY_BACK_TO_LOGIN_WHEN_LOGIN_OTHER_TERMINAL]boolValue];
    self.backToLoginWhenForbidden = [mDic[KEY_BACK_TO_LOGIN_WHEN_FORBIDDEN]boolValue];
    
    self.useNameAsLogo = [mDic[KEY_USE_NAME_AS_LOGO]boolValue];
    
    self.useOriginUserLogo = [mDic[KEY_USE_ORIGIN_USER_LOGO]boolValue];
}

- (void)saveUserConfig:(NSDictionary *)mDic
{
    NSMutableDictionary *rootDic = [NSMutableDictionary dictionary];
    rootDic[KEY_SERVER_CONFIG] = mDic;
    
    NSString *userConfigPath = [[StringUtil getHomeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",user_config_name]];
    
//    保存配置
    [rootDic writeToFile:userConfigPath atomically:YES];
    
//    把新配置读到内存
    self.primaryServerUrl = mDic[KEY_PRIMARY_SERVER_URL];
    self.primaryServerPort = mDic[KEY_PRIMARY_SERVER_PORT];
    
    self.secondServerUrl = mDic[KEY_SECOND_SERVER_URL];
    self.secondServerPort = mDic[KEY_SECOND_SERVER_PORT];
    
    self.otherServerUrl = mDic[KEY_OTHER_SERVER_URL];
    self.otherServerPort = mDic[KEY_OTHER_SERVER_PORT];
    
    self.fileServerUrl = mDic[KEY_FILE_SERVER_URL];
    self.fileServerPort = mDic[KEY_FILE_SERVER_PORT];
    self.fileServerPath = mDic[KEY_FILE_SERVER_PATH];
}

#pragma mark =======加密过的config==========
- (void)loadEncryptDefaultConfig:(NSMutableDictionary *)mDic
{
    NSString *configPath = [[StringUtil getBundle]pathForResource:encrypt_default_config_name ofType:nil];
    
    [self loadEncryptConfig:configPath andDic:mDic];
}

- (void)loadEncryptAppConfig:(NSMutableDictionary *)mDic
{
    NSString *configPath = [[StringUtil getBundle]pathForResource:encrypt_app_config_name ofType:nil];
    
    [self loadEncryptConfig:configPath andDic:mDic];
}


//    解密后保存为临时文件，读取配置，再删除临时文件
- (void)loadEncryptConfig:(NSString *)configPath andDic:(NSMutableDictionary *)mDic
{
//    首先读取密文
    NSString *encryptConfig = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
    
    if (encryptConfig) {
//        解密得到明文
        NSString *decryptConfig = [DES decryptString:encryptConfig];
//        NSLog(@"%@",decryptConfig);
        
        //        把明文保存为一个临时的plist文件
        NSString *tempName = @"temp.plist";
        NSString *tempConfigPath = [[StringUtil getTempDir]stringByAppendingString:tempName];
        
        NSData *tempData = [decryptConfig dataUsingEncoding:NSUTF8StringEncoding];
        if (tempData) {
            //        读完配置后，再把这个临时的plist文件删除
            [[NSFileManager defaultManager]createFileAtPath:tempConfigPath contents:tempData attributes:nil];
            
            [self loadConfigWithPath:tempConfigPath :mDic];
            
            [[NSFileManager defaultManager]removeItemAtPath:tempConfigPath error:nil];
            
        }
    }
}

@end
