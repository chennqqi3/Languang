//
//  AdvanceQueryDAO.h
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "eCloud.h"

@interface AdvanceQueryDAO : eCloud

+(id)getDataBase;

//获取所有级别
-(NSArray*)getAllRank;
//保存级别数据
-(BOOL)saveRank:(NSArray*)dataArray;

//获取所有级别
-(NSArray*)getAllProfession;

//根据父级别，获取所有级别
-(NSArray*)getAllArea:(int)parentArea;

//保存业务数据
-(BOOL)saveProf:(NSArray*)dataArray;

//保存地域数据
-(BOOL)saveArea:(NSArray*)dataArray;
#pragma mark 级别
-(NSArray *)getrRankArray;
#pragma mark 业务
-(NSArray *)getrBusinessArray;
#pragma mark 选择市
-(NSArray *)getrCityArray:(int)parentArea;
#pragma mark 筛选结果
-(NSArray *)getChooseArrayByRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list;
//某成员所在所有部门
-(void)createTempDepts:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list;
//某成员所在所有部门
-(void)createTempDeptsByEmpIdList:(NSString *)emp_id_list;
#pragma mark 根据上级部门id，获取直接子部门，并定位级别
-(NSArray *)getTempDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected;
-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
;
-(NSArray *)getTempDeptEmpByParent:(NSString *)dept_id  andSelected:(bool)isSelected andRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
;
//获取数量
-(int)getAllNumFromResult:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list;
-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andEmpList:(NSString *)emp_id_list;
@end
