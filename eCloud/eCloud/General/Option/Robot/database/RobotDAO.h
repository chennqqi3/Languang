//和机器人有关的数据库

#import <Foundation/Foundation.h>
#import "ecloud.h"

@interface RobotDAO : eCloud

+ (RobotDAO *)getDatabase;

//创建机器人表
- (void)createTable;

//保存机器人资料
- (void)saveRobotInfo:(NSArray *)info;

//初始化机器人 查询机器人，把内存中机器人的状态设置为pc在线，并且设置Emp的isRobot属性为YES
- (void)initRobots;

//判断一个用户是否是机器人用户
- (BOOL)isRobotUser:(int)empId;

//插入问候语或修改问候语的时间为最近的时间
- (void)initGreetingsWithRobotId:(int)robotId andRobotName:(NSString *)robotName;

//保存小万的菜单数据
- (BOOL)saveRobotMenu:(NSString *)menuString;

//获取小万的菜单
- (NSString *)getRobotMenu;
//
////保存小万的主题
//- (BOOL)saveRobotTopic:(NSString *)topic;
//
////获取小万的主题
//- (NSString *)getRobotTopic;

//取出小万的id，生成内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsOfIRobot;

// 处理蓝信小秘书欢迎语
- (void)createOneNewMsgOfGreetingsOfLanxin;

//取出文件助手的id，生成内容是欢迎语的新消息
- (void)createOneNewMsgOfGreetingsOfFileTransfer;

//取出小万的userid
- (int)getRobotId;

@end
