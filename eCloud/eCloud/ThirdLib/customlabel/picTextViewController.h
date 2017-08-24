//
//  picTextViewController.h
//  eCloud
//
//  Created by  lyong on 13-7-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMCustomLabel.h"
@interface picTextViewController : UIViewController<NMCustomLabelDelegate,UIAlertViewDelegate>
{
    NSMutableString *inputStr;
    NSMutableString *inputStrCopy;
    UIAlertView *telAlert;
  
}
@property (nonatomic,retain) NSMutableString *inputStr;
@property (nonatomic,retain) NSMutableString *inputStrCopy;


-(void)showPicOrText:(NSMutableArray *)data;
@end
