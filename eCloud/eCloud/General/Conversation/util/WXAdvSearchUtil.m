//
//  WXAdvSearchUtil.m
//  eCloud
//
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXAdvSearchUtil.h"
#import "APPListModel.h"
#import "APPPlatformDOA.h"
#import "WXAdvSearchModel.h"
#import "StringUtil.h"
#import "eCloudDefine.h"
#import "UserTipsUtil.h"
#import "eCloudDAO.h"
#import "QueryDAO.h"
#import "AdvSearchHeaderView.h"
#import "AdvSearchFooterView.h"
#import "NotificationUtil.h"
#import "Conversation.h"
#import "LogUtil.h"
#import "talkSessionUtil.h"
#import "talkSessionUtil2.h"

/** 最大显示条数 */
#define MAX_DSP_ITEM_COUNT (3)

/** footer view 高度 */
#define FOOTER_VIEW_HEIGHT (50)

static WXAdvSearchUtil *util;
@implementation WXAdvSearchUtil

+ (WXAdvSearchUtil *)getUtil{
    if (!util) {
        util = [[super alloc] init];
    }
    return util;
}

/** 搜索联系人 */
- (void)queryContact:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    int searchType = [StringUtil getSearchStrType:searchStr];
    
    [[eCloudDAO getDatabase] setLimitWhenSearchUser:YES];
    NSArray *empArray= [[eCloudDAO getDatabase] getEmpsByNameOrPinyin:searchStr andType:searchType];
    if (empArray.count) {
        
        /** 把emp类型的对象转换为conversation对象 */
        NSMutableArray *tempResult = [NSMutableArray array];
        
        for (Emp *_emp in empArray) {
            Conversation *tempConv = [[[Conversation alloc]init]autorelease];
            tempConv.conv_id = [StringUtil getStringValue:_emp.emp_id];
            tempConv.conv_type = singleType;
            tempConv.conv_title = _emp.emp_name;
            tempConv.emp = _emp;
            [tempResult addObject:tempConv];
        }
//        实际显示的对象
        empArray = [NSArray arrayWithArray:tempResult];
        
        WXAdvSearchModel *resultModel = [[WXAdvSearchModel alloc]init];
        resultModel.searchResultType = search_result_type_contact;
        resultModel.searchStr = searchStr;
        resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_contact"];// @"联系人";
        resultModel.footerTitle = [StringUtil getLocalizableString:@"key_adv_search_view_more_contact"];// @"查看更多联系人";

        /** header view */

        /** 要显示的联系人 */
        if (empArray.count <= MAX_DSP_ITEM_COUNT) {
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            [dspArray addObjectsFromArray:empArray];
            
            resultModel.dspItemArray = dspArray;
        }else{
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            
            for (int i = 0 ; i < MAX_DSP_ITEM_COUNT;i++ ) {
                [dspArray addObject:empArray[i]];
            }
            //                    需要footerView
            UIView *footerView = [[[AdvSearchFooterView alloc]initViewWithTitle:resultModel.footerTitle]autorelease];
            [dspArray addObject:footerView];
            
            resultModel.dspItemArray = dspArray;
        }
        
        /** 所有符合条件的联系人 */
        NSMutableArray *allItemArray = [NSMutableArray array];
        
        UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
        [allItemArray addObject:headerView];
        [allItemArray addObjectsFromArray:empArray];
        resultModel.allItemArray = allItemArray;

        [searchResults addObject:resultModel];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s %@",__FUNCTION__,resultModel.allItemArray]];
    }
}
/** 搜索群聊 */
- (void)queryGroupConv:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    NSArray *groupArray = [[QueryDAO getDatabase] getConversationBy:searchStr];
    //    去除单聊的会话
    NSMutableArray *tempGroupArray = [NSMutableArray array];
    for (Conversation *conv in groupArray) {
        if (conv.conv_type == mutiableType) {
            [tempGroupArray addObject:conv];
        }
    }
    
    if (tempGroupArray.count) {
        
        WXAdvSearchModel *resultModel = [[WXAdvSearchModel alloc]init];
        resultModel.searchResultType = search_result_type_group;
        resultModel.searchStr = searchStr;
        resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_group"];// @"群聊";
        resultModel.footerTitle = [StringUtil getLocalizableString:@"key_adv_search_view_more_group"];// @"查看更多群聊";

/** 要显示的群聊 */
        if (tempGroupArray.count <= MAX_DSP_ITEM_COUNT) {
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            [dspArray addObjectsFromArray:tempGroupArray];

            resultModel.dspItemArray = dspArray;
        }else{
            NSMutableArray *dspArray =  [NSMutableArray array];

            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];

            for (int i = 0 ; i < MAX_DSP_ITEM_COUNT;i++ ) {
                [dspArray addObject:tempGroupArray[i]];
            }
            //                    需要footerView
            UIView *footerView = [[[AdvSearchFooterView alloc]initViewWithTitle:resultModel.footerTitle]autorelease];
            [dspArray addObject:footerView];

            resultModel.dspItemArray = dspArray;
        }
        
        /** 所有符合条件的联系人 */
        NSMutableArray *allItemArray = [NSMutableArray array];
        
        UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
        [allItemArray addObject:headerView];
        [allItemArray addObjectsFromArray:tempGroupArray];
        resultModel.allItemArray = allItemArray;
        
        [searchResults addObject:resultModel];
    }
}
/** 搜索聊天记录 */
- (void)queryConvRecord:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    
    NSArray *convRecordArray = [[QueryDAO getDatabase] getConversationBySearchConvRecord:searchStr];
    if (convRecordArray.count) {
        WXAdvSearchModel *resultModel = [[WXAdvSearchModel alloc]init];
        resultModel.searchResultType = search_result_type_convrecord;
        resultModel.searchStr = searchStr;
        resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_convrecords"];//@"聊天记录";
        resultModel.footerTitle = [StringUtil getLocalizableString:@"key_adv_search_view_more_convrecords"];//@"查看更多聊天记录";

        /** 要显示的聊天记录 */
        if (convRecordArray.count <= MAX_DSP_ITEM_COUNT) {
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            [dspArray addObjectsFromArray:convRecordArray];

            resultModel.dspItemArray = dspArray;
        }else{
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];

            for (int i = 0 ; i < MAX_DSP_ITEM_COUNT;i++ ) {
                [dspArray addObject:convRecordArray[i]];
            }
            UIView *footerView = [[[AdvSearchFooterView alloc]initViewWithTitle:resultModel.footerTitle]autorelease];
            [dspArray addObject:footerView];

            resultModel.dspItemArray = dspArray;
            
        }
        /** 所有符合条件的联系人 */
        NSMutableArray *allItemArray = [NSMutableArray array];
        
        UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
        [allItemArray addObject:headerView];
        [allItemArray addObjectsFromArray:convRecordArray];
        resultModel.allItemArray = allItemArray;

        [searchResults addObject:resultModel];
    }
}

/** 搜索微应用 */
- (void)queryGomeApp:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    NSArray *gomeAppArray = [[APPPlatformDOA getDatabase]searchGomeAppBy:searchStr];
    NSMutableArray *tempGomeAppArray = [NSMutableArray array];
    
    for (APPListModel *_model in gomeAppArray) {
        Conversation *conv = [[[Conversation alloc]init]autorelease];
        conv.conv_type = appNoticeBroadcastConvType;
        conv.conv_id =  [StringUtil getStringValue:_model.appid];
        conv.appModel = _model;
        [tempGomeAppArray addObject:conv];
    }
    
    if (tempGomeAppArray.count) {
        WXAdvSearchModel *resultModel = [[WXAdvSearchModel alloc]init];
        resultModel.searchResultType = search_result_type_app;
        resultModel.searchStr = searchStr;
        resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_app"];// @"微应用";
        resultModel.footerTitle = [StringUtil getLocalizableString:@"key_adv_search_view_more_app"];//@"查看更多微应用";

        /** 要显示的应用 */
        if (tempGomeAppArray.count <= MAX_DSP_ITEM_COUNT) {
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            [dspArray addObjectsFromArray:tempGomeAppArray];
            
            resultModel.dspItemArray = dspArray;
        }else{
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            
            for (int i = 0 ; i < MAX_DSP_ITEM_COUNT;i++ ) {
                [dspArray addObject:tempGomeAppArray[i]];
            }
            //                    需要footerView
            UIView *footerView = [[[AdvSearchFooterView alloc]initViewWithTitle:resultModel.footerTitle]autorelease];
            [dspArray addObject:footerView];
            
            resultModel.dspItemArray = dspArray;
        }
        
        /** 所有符合条件的联系人 */
        NSMutableArray *allItemArray = [NSMutableArray array];
        
        UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
        [allItemArray addObject:headerView];
        [allItemArray addObjectsFromArray:tempGomeAppArray];
        resultModel.allItemArray = allItemArray;
        
        [searchResults addObject:resultModel];
    }
}

/** 搜索文件 */
- (void)queryFileRecord:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    NSArray *fileRecordList= [[eCloudDAO getDatabase] searchFileConvRecords:searchStr];
    if (fileRecordList.count) {
        for (ConvRecord *_convRecord in fileRecordList) {
            [talkSessionUtil setPropertyOfConvRecord:_convRecord];
            [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];

        }
        
        WXAdvSearchModel *resultModel = [[WXAdvSearchModel alloc]init];
        resultModel.searchResultType = search_result_type_filerecord;
        resultModel.searchStr = searchStr;
        resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_file"];
        resultModel.footerTitle = [StringUtil getLocalizableString:@"key_adv_search_view_more_file"];

        /** 要显示的文件 */
        if (fileRecordList.count <= MAX_DSP_ITEM_COUNT) {
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            [dspArray addObjectsFromArray:fileRecordList];

            resultModel.dspItemArray = dspArray;
        }else{
            NSMutableArray *dspArray =  [NSMutableArray array];
            UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
            [dspArray addObject:headerView];
            
            for (int i = 0 ; i < MAX_DSP_ITEM_COUNT;i++ ) {
                [dspArray addObject:fileRecordList[i]];
            }
            //                    需要footerView
            UIView *footerView = [[[AdvSearchFooterView alloc]initViewWithTitle:resultModel.footerTitle]autorelease];
            [dspArray addObject:footerView];
            
            resultModel.dspItemArray = dspArray;
        }
        
        /** 所有符合条件的联系人 */
        NSMutableArray *allItemArray = [NSMutableArray array];
        
        UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
        [allItemArray addObject:headerView];
        [allItemArray addObjectsFromArray:fileRecordList];
        resultModel.allItemArray = allItemArray;

        [searchResults addObject:resultModel];
        
    }
}

/** 网页 */
- (void)queryWebPage:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults{
    
    WXAdvSearchModel *resultModel = [[[WXAdvSearchModel alloc]init]autorelease];
    resultModel.searchStr = searchStr;
    resultModel.searchResultType = search_result_type_webpage;
    resultModel.headerTitle = [StringUtil getLocalizableString:@"key_adv_search_webpage"];
    
    NSMutableArray *dspArray =  [NSMutableArray array];
    UIView *headerView = [[[AdvSearchHeaderView alloc]initViewWithTitle:resultModel.headerTitle]autorelease];
    [dspArray addObject:headerView];
    [dspArray addObject:resultModel.headerTitle];

    resultModel.dspItemArray = dspArray;
    
    [searchResults addObject:resultModel];

}

- (void)advSearchAction:(NSString *)searchStr{
    
    NSMutableArray *searchResults = [NSMutableArray array];
    
    /** 1 搜索联系人 */
    [self queryContact:searchStr andSearchResults:searchResults];
    
//    2 搜索符合条件的群聊
    [self queryGroupConv:searchStr andSearchResults:searchResults];
    
//    3 查看聊天记录
    [self queryConvRecord:searchStr andSearchResults:searchResults];
    
//    4 微应用
    [self queryGomeApp:searchStr andSearchResults:searchResults];
    
 //    5 搜索文件 暂时使用文件助手搜索文件的方式
    [self queryFileRecord:searchStr andSearchResults:searchResults];
    
//    6 搜索网页
    [self queryWebPage:searchStr andSearchResults:searchResults];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(loadSearchResults:)]) {
        [self.delegate loadSearchResults:searchResults];
    }
//    [[NotificationUtil getUtil]sendNotificationWithName:ADV_SEARCH_FINISH_NOTIFICATION andObject:nil andUserInfo:[NSDictionary dictionaryWithObject:searchResults forKey:SEARCH_RESULT_KEY]];
}

- (void)advSearch:(NSString *)searchStr{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"searching"]];
    [self performSelector:@selector(advSearchAction:) withObject:searchStr afterDelay:0.01];
}

@end
