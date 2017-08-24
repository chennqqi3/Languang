// 监控状态
/*
 
 以SDK方式集成到其它App 会话界面标题的内容要根据状态不同进行变化
 
 */
#import <Foundation/Foundation.h>

@interface StatusMonitor : NSObject

/*
 
 连接状态属性
 
 状态定义
 //未连接、连接中、下载组织架构，收取中、正常
 typedef enum
 {
	not_connect_type = 0,
	linking_type,
	download_org,
	rcv_type,
	normal_type
 }connect_type;
 
 */
@property (nonatomic,assign) int connStatus;

/*
 通讯录同步提示
 
 包括以下几种提示
 1 同步组织机构
 2 同步部门
 3 保存部门
 4 同步员工
 5 保存员工
 
 */
//定义一个 会话列表标题显示的状态字符串
@property (nonatomic,retain) NSString *downloadOrgTips;


/*

 功能描述：
 获取StatusMonitor实例
 
 */
+ (StatusMonitor *)getStatusMonitor;

/*
 
 功能描述：
 获取显示在会话界面导航栏的标题内容
 
 返回值说明：
 调用程序需要对 connStatus 和 downloadOrgTips 属性进行观察，并且在这两个属性发生变化时，通过getTips方法获取到标题内容并显示在界面上
 
 示例代码：
 1 #import "StatusMonitor.h"
 2 在viewDidLoad里增加监听
 
 //    状态监听
 [[StatusMonitor getStatusMonitor] addObserver:self forKeyPath:@"connStatus" options:NSKeyValueObservingOptionNew context:nil];
 //    状态监听
 [[StatusMonitor getStatusMonitor] addObserver:self forKeyPath:@"downloadOrgTips" options:NSKeyValueObservingOptionNew context:nil];
 
 3 收到监听后进行处理
 
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
 if ([keyPath isEqualToString:@"connStatus"] || [keyPath isEqualToString:@"downloadOrgTips"]) {
 [self performSelectorOnMainThread:@selector(changeConnStatus:) withObject:nil waitUntilDone:YES];
 }
 }
 
 - (void)changeConnStatus:(NSString *)tips
 {
 self.title = [[StatusMonitor getStatusMonitor]getTips];
 }

 4 在dealloc方法里取消监听
 
 [[StatusMonitor getStatusMonitor] removeObserver:self forKeyPath:@"connStatus"];
 [[StatusMonitor getStatusMonitor] removeObserver:self forKeyPath:@"downloadOrgTips"];
 
 */
- (NSString *)getTips;

@end
