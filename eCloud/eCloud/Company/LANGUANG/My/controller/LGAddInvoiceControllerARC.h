//
//  LGAddInvoiceControllerARC.h
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol invoiceListDelegate
- (void)returnString:(NSString *)string;
@end

@interface LGAddInvoiceControllerARC : UIViewController

@property (nonatomic, strong) id <invoiceListDelegate> delegate;

@end
