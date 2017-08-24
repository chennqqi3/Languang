//
//  GSAEHMHeader.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/29.
//  Copyright © 2016年 Gome. All rights reserved.
//

#ifndef GSAEHMHeader_h
#define GSAEHMHeader_h

#import "NSString+UUID.h"
#import "NSString+TimeStamp.h"
#import "GSAEvaluationObtainedModel.h"
#import "GSAEvaluationMadeModel.h"
#import "GSAEvaluationMadeDetailModel.h"
#import "GSAEvaluationTaskListModel.h"
#import "GSAEvaluationTaskDetailModel.h"
#import "GSASpecialModel.h"
#import "GSAPunishmentModel.h"
#import "GSAExamineModel.h"
#import "GSAExamineDetailModel.h"
#import "GSAEmolumentDetailModel.h"
#import "GSAEmolumentMainModel.h"
#import "YYModel.h"

#define entrance 2 //1代表800 2代表500

#if entrance == 1
#define kEvaluationURL @"http://g.corp.gome.com.cn/ygzz/appAction_appaction.action"
#define kPunishmentURL @"http://g.corp.gome.com.cn/ygzz/rewardPunishAppAction_queryRewardPunish"
#define kSpecialURL @"http://g.corp.gome.com.cn/ygzz/appAction_appaction.action"
#define kExamineURL @"http://g.corp.gome.com.cn/ygzz/performanceAppAcion_queryPositionScore"
#define kExaminePositionURL @"http://g.corp.gome.com.cn/ygzz/performanceAppAcion_positionScoreDetail"
#define kEmolumentURL @"http://g.corp.gome.com.cn/ygzz/appAction_appaction.action"
#define kMeetingURL @"http://g.corp.gome.com.cn/ygzz/webService/rs/uni/"
#elif entrance == 2
//#define kEvaluationURL @"http://10.122.2.5:11100/ygzz/appAction_appaction.action"
#define kEvaluationURL @"http://10.128.11.95:11100/ygzz/appAction_appaction.action"
#define kPunishmentURL @"http://10.128.11.95:11100/ygzz/rewardPunishAppAction_queryRewardPunish"
#define kSpecialURL @"http://10.128.11.95:11100/ygzz/appAction_appaction.action"
#define kExamineURL @"http://10.128.11.95:11100/ygzz/performanceAppAcion_queryPositionScore"
#define kExaminePositionURL @"http://10.122.2.5:11100/ygzz/performanceAppAcion_positionScoreDetail"
#define kEmolumentURL @"http://10.128.11.95:11100/ygzz/appAction_appaction.action"
#define kMeetingURL @"http://api.ehm.gome.work/ygzz/webService/rs/uni/"
#endif

#define kEvaluationParamsName @"special"
#define kPunishmentParamsName @"per"
#define kSpecialParamsName @"special"
#define kExamineParamsName @"per"
#define kEmolumentParamsName @"special"
#define kMeetingParamsName @"meeting"

#endif /* GSAEHMHeader_h */
