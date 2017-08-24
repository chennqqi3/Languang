//
//  UIWebViewWithPageTitle.m
//  eCloud
//
//  Created by shisuping on 14-2-27.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "UIWebViewWithPageTitle.h"

@implementation  UIWebView(UIWebViewWithPageTitle)

- (NSString*)pageTitle
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
