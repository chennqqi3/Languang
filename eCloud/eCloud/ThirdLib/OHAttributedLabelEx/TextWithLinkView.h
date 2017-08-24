//
//  TextWithLinkView.h
//  eCloud
//
//  Created by  lyong on 13-10-11.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkTextViewController.h"
@interface TextWithLinkView : UIView
{
    LinkTextViewController *textObject;
    NSString *message;
    float maxwidth;
    
}
@property(nonatomic,retain)NSString *message;
@property(assign)float maxwidth;
-(void)updateShowContent;
-(CGSize)getViewSize;
@end
