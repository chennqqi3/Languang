//
//  JsObjectCViewController.h
//  eCloud
//
//  Created by  lyong on 14-5-26.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "specialChooseMemberViewController.h"
@interface JsObjectCViewController : UIViewController<UIWebViewDelegate>
{
    specialChooseMemberViewController *chooseMember;
    NSMutableArray *dataArray;
}
@property(nonatomic,retain) NSMutableArray *dataArray;
@end
