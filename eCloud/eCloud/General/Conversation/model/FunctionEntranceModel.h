//
//  FunctionEntranceModel.h
//  eCloud
//  功能入口模型
//  Created by shisuping on 15/11/17.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionEntranceModel : NSObject

@property (nonatomic,assign) CGRect frame;
@property (nonatomic,assign) SEL clickSelector;
@property (nonatomic,retain) NSString *normalImageName;
@property (nonatomic,retain) NSString *highlightImageName;
@property (nonatomic,retain) NSString *title;

@end
