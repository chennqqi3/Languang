//
//  textInputViewController.h
//  eCloud
//
//  Created by  lyong on 13-11-5.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textInputViewController : UIViewController<UITextViewDelegate>
{
 UITextView *detailField;
 id predelegete;
    int fromtype;
}
@property(nonatomic,retain) UITextView *detailField;
@property(assign) id predelegete;
@property(assign) int fromtype;
@end
