//
//  FunctionButtonModel.h
//  eCloud
//
//  Created by shisuping on 15-10-8.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FunctionButtonModel : NSObject

@property (nonatomic,retain) NSString *functionName;
@property (nonatomic,retain) NSString *imageName;
@property (nonatomic,retain) NSString *hlImageName;
@property (nonatomic,assign) SEL clickSelector;



@end
