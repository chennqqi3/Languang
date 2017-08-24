/*
 权限：2字节
 短信权限：1-有 0-无
 部门广播权限：1-有 0-无 	部门ID列表：当有 ？
 全网广播权限：1-有 0-无
 远程桌面：1-有 0-无
 应用共享：1-有 0-无
 移动端客户端语音片段：1-有，0-无
 */

//南航权限
//Id	name	description	parameter
//1	发起大讨论组会话权限	配置权限后，允许用户发起超过100人以上讨论组	100
//2	发起大文件权限	配置权限后，允许用户发起超过50M以内的文件	50
//3	点对点方式传送文件	配置权限后，允许用户点对点传输文件	0
//4	发送全员广播消息	配置权限后，允许用户发送全员广播	0
//5	发送所属部门广播消息	配置权限后，允许用户发送部门广播	0
//6	发送短信	配置权限后，允许用户发送短信	100
//7	发起一呼百应	发起一呼百应	0
//8	发起一呼万应	发起一呼万应	200
//9	木棉童飞	木棉童飞	0


#import "AuthModel.h"
#import "StringUtil.h"

@interface AuthModel()

@end

static AuthModel *authModel;
@implementation AuthModel
{
    NSString *authStr;
    
    BOOL isMMTF;
    BOOL isYHBY;
    BOOL isYHWY;
}
@synthesize auth;
@synthesize authDic;

- (void)dealloc
{
    self.authDic = nil;
    [super dealloc];
}
+ (AuthModel *)getModel
{
    if (authModel == nil) {
        authModel = [[AuthModel alloc]init];
    }
    return authModel;
}

- (void)setAuth:(int)_auth
{
    auth = _auth;
//    authStr = [StringUtil toBinaryStr:auth andByteCount:2];
    
    isYHBY = [self checkBit:7];
    isYHWY = [self checkBit:8];
    isMMTF = [self checkBit:9];
    
}

//检查某一位是0还是1
- (BOOL)checkBit:(int)_bit
{
//    把1左移8位
    int temp = 1 << (_bit - 1);
    int temp2 = auth & temp;
    if (temp2) {
        return YES;
    }
    return NO;
}

//是否有一呼百应权限
- (BOOL)canYHBY
{
    return isYHBY;
}
//是否有一呼万应权限
- (BOOL)canYHWY
{
    return isYHWY;
}
//如果有一呼万应权限，那么最多人数是多少
- (int)maxYHWY
{
    return [[self.authDic valueForKey:@"8"]intValue];
}
//是否有木棉童飞权限
- (BOOL)canMMTF
{
    return isMMTF;
}


@end
