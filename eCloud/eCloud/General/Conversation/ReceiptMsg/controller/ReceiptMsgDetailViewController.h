//
//  ReceiptMsgDetailViewController.h
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConvRecord;

@interface ReceiptMsgDetailViewController : UIViewController

@property (nonatomic, assign) NSInteger msgId;

@property (nonatomic, strong) ConvRecord *convRecord;

@end
