//
//  GMRequestTask.h
//  GMRequestService
//
//  Created by 岳潇洋 on 2017/5/17.
//  Copyright © 2017年 岳潇洋. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `GMRequestTask` is a task that handle a request for you,you can cancel or resume a request by it.
 */

@interface GMRequestTask : NSObject
- (void)cancel;
- (void)resume;
@end
