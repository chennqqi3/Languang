//
//  chooseChatBackGroudViewController.h
//  eCloud
//
//  Created by  lyong on 14-6-25.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chooseChatBackGroudViewController : UIViewController
{
  UIScrollView *memberScroll;
  UIImageView *selectedView;
  NSString *one_chat_imagename;
}
@property(nonatomic,retain)NSString *one_chat_imagename;
@end
