//
//  GSAViewHeader.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/3.
//  Copyright © 2016年 Gome. All rights reserved.
//

#ifndef GSAViewHeader_h
#define GSAViewHeader_h

#import "GSARootViewController.h"
#import "GSAUtilities.h"
#import "UIView+Common.h"

#define BUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"GomeSubApplication.bundle"]
#define GSAmageNamed(imageName)  ([UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",BUNDLE_PATH,imageName]])

#endif /* GSAViewHeader_h */
