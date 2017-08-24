//
//  main.m
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
	signal(SIGPIPE, SIG_IGN);
    @autoreleasepool {
        
        // 监听APP崩溃
#ifdef _GOME_FLAG_
        [NBSAppAgent startWithAppID:@"0eba5b77ff7d43fca162c34403d38266"];
#endif
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
