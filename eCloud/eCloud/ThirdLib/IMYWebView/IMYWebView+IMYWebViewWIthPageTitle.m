//
//  IMYWebView+IMYWebViewWIthPageTitle.m
//  eCloud
//
//  Created by shisuping on 16/5/19.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "IMYWebView+IMYWebViewWIthPageTitle.h"

@implementation IMYWebView (IMYWebViewWIthPageTitle)
- (NSString*)pageTitle
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}
@end
