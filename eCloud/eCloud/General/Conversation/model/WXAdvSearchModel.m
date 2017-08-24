//
//  WXAdvSearchModel.m
//  eCloud
//
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXAdvSearchModel.h"

@implementation WXAdvSearchModel

- (void)dealloc{
    
    self.headerTitle = nil;
    self.footerTitle = nil;
    
    self.searchStr = nil;
    self.dspItemArray = nil;
    self.allItemArray = nil;
//    self.headerView = nil;
//    self.footerView = nil;
    
    [super dealloc];
}
@end
