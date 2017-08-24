//
//  ReceiptCollectionFooterView.h
//  eCloud
//
//  Created by Alex L on 15/11/6.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol footerViewReloadDelegate<NSObject>

- (void)reload:(NSInteger )tag;

@end

@interface ReceiptCollectionFooterView : UICollectionReusableView

@property (nonatomic, strong) UIButton *expandOrPutAwary;

@property (nonatomic, assign) id<footerViewReloadDelegate>reloadDelegate;

@end
