
#import "EmpLogoUtil.h"
#import "conn.h"
#import "eCloudUser.h"
#import "ASIFormDataRequest.h"
#import "LogUtil.h"
#import "eCloudNotification.h"
#import "eCloudDAO.h"
#import "StringUtil.h"
#import "WandaNotificationNameDefine.h"
#import "eCloudDefine.h"

static EmpLogoUtil *empLogoUtil;

@interface EmpLogoUtil ()

@property (nonatomic,assign) int newLogoTimestamp;
@property (nonatomic,retain) NSData *newLogoData;

@end

@implementation EmpLogoUtil
{
    conn *_conn;
    eCloudDAO *db;
    
    ASIFormDataRequest *request;
}

@synthesize logoImage;
@synthesize newLogoTimestamp;

+ (EmpLogoUtil *)getUtil
{
    if (empLogoUtil == nil)
    {
        empLogoUtil = [[EmpLogoUtil alloc]init];
    }
    return empLogoUtil;
}

- (id)init
{
    id _id = [super init];
    if (_id) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
    }
    return _id;
}

- (void)dealloc
{
    self.logoImage = nil;
    [super dealloc];
}

- (void)uploadImage
{
    if (_conn.userStatus == status_online)
    {
        if (self.logoImage)
        {
            //    万达 新的头像时间戳
            self.newLogoTimestamp = [_conn getCurrentTime];
            
            self.newLogoData = UIImageJPEGRepresentation(self.logoImage, 0.5);
            
            NSLog(@"更新用户头像，时间戳%d",self.newLogoTimestamp);
            
            NSURL *uploadUrl = [NSURL URLWithString:[[[eCloudUser getDatabase]getServerConfig]getWandaLogoUploadUrlWithNewTimestamp:self.newLogoTimestamp]];
            request = [ASIFormDataRequest requestWithURL:uploadUrl];
            
            //    只需要把头像数据传给服务器端即可
            [request appendPostData:self.newLogoData];
            
            [request setTimeOutSeconds:15];
            [request setDelegate:self];
            [request setUploadProgressDelegate:self];
            request.showAccurateProgress=YES;
            
//            [request setDidFinishSelector:@selector(requestCommitDone:)];
//            [request setDidFailSelector:@selector(requestCommitWrong:)];

            [request startAsynchronous];
        }
        else
        {
            NSString *errorMsg = [StringUtil getLocalizableString:@"userInfo_upload_fail"];
            [self postNotification:[NSDictionary dictionaryWithObject:errorMsg forKey:key_update_logo_error_msg]];
        }
    }
    else
    {
        NSString *errorMsg = [StringUtil getLocalizableString:@"userInfo_upload_fail"];
        [self postNotification:[NSDictionary dictionaryWithObject:errorMsg forKey:key_update_logo_error_msg]];
    }
}

-(void)setProgress:(float)newProgress
{
    if (newProgress == 1)
    {
        if([[conn getConn]modifyUserInfo:15 andNewValue:[StringUtil getStringValue:self.newLogoTimestamp]])
        {
            [self addNotification];
        }
        else
        {
            //            返回错误
            [self requestCommitWrong:nil];
        }
        
        if (!request.isFinished){
            [request clearDelegatesAndCancel];
        }
        request = nil;
        
    }
    NSLog(@"progress %f", newProgress);
}

//从网络返回数据成功
- (void)requestCommitDone:(ASIHTTPRequest *)request
{
    NSString *responseStr = request.responseString;
    [LogUtil debug:[NSString stringWithFormat:@"%s,response is %@",__FUNCTION__,responseStr]];
    
    //    如果应答信息中包含了success字样，则表示设置成功
    if (request.responseStatusCode == 200 && [responseStr rangeOfString:@"success"].length > 0)
    {

        if([[conn getConn]modifyUserInfo:15 andNewValue:[StringUtil getStringValue:self.newLogoTimestamp]])
        {
            [self addNotification];
        }
        else
        {
//            返回错误
            [self requestCommitWrong:request];
        }
    }
    else
    {
        //        代表修改失败了
        [self requestCommitWrong:request];
    }
}

//从网络返回数据失败
- (void)requestCommitWrong:(ASIHTTPRequest *)request
{
    NSString *errorMsg = [StringUtil getLocalizableString:@"userInfo_upload_fail"];
    [self postNotification:[NSDictionary dictionaryWithObject:errorMsg forKey:key_update_logo_error_msg]];

}


- (void)addNotification
{
    //            添加通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
}

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
 	eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
    
	switch (cmd.cmdId)
	{
        case modify_userinfo_success:
        {
            [self removeNotification];

            NSString *userId = _conn.userId;
            
            NSString *newTimestamp = [StringUtil getStringValue:self.newLogoTimestamp];
            
            [db updateUserAvatar:newTimestamp :userId.intValue];
            
            [StringUtil deleteUserLogoIfExist:userId];
            
            //        保存头像
            NSString *smallLogoPath = [StringUtil getLogoFilePathBy:userId andLogo:newTimestamp];
//            [self.newLogoData writeToFile:smallLogoPath atomically:YES];
            
            UIImage *curImage = [UIImage imageWithData:self.newLogoData];
            
            [StringUtil createAndSaveMicroLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            [StringUtil createAndSaveSmallLogo:curImage andEmpId:userId andLogo:default_emp_logo];
            
            //			保存大头像，否则会去下载
            NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:userId andLogo:newTimestamp];
            [self.newLogoData writeToFile:bigLogoPath atomically:YES];
            
            
            //        保存头像的时间戳
            _conn.newCurUserLogoUpdateTime = self.newLogoTimestamp;
            [[eCloudUser getDatabase]saveCurUserLogoUpdateTime];
            
            //            发出通知 把用户id 用户头像 发出去
            [StringUtil sendUserlogoChangeNotification:[NSDictionary dictionaryWithObjectsAndKeys:userId,@"emp_id",newTimestamp,@"emp_logo", nil]];
            
            [self postNotification:[NSDictionary dictionaryWithObject:smallLogoPath forKey:key_new_logo_path]];
        }
            break;
        case modify_userinfo_failure:
        {
            [self removeNotification];
            NSString *errorMsg = [StringUtil getLocalizableString:@"userInfo_upload_fail"];
            [self postNotification:[NSDictionary dictionaryWithObject:errorMsg forKey:key_update_logo_error_msg]];
        }
            break;
		case cmd_timeout:
		{
            [self removeNotification];
            NSString *errorMsg = [StringUtil getLocalizableString:@"usual_communication_timeout"];
            [self postNotification:[NSDictionary dictionaryWithObject:errorMsg forKey:key_update_logo_error_msg]];
		}
			break;
		default:
			break;
	}
}

- (void)postNotification:(NSDictionary *)dic
{
     [[NSNotificationCenter defaultCenter]postNotificationName:com_wanda_ecloud_im_setportrait object:dic];
}

@end
