//
//  CheckBoxButton.h
//  eCloud
//
//  Created by yanlei on 15/12/15.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckBoxDelegate;

@interface CheckBoxButton : UIButton {
    id<CheckBoxDelegate> _delegate;
    BOOL _checked;
    id _userInfo;
}

@property(nonatomic, assign)id<CheckBoxDelegate> delegate;
@property(nonatomic, assign)BOOL checked;
@property(nonatomic, retain)id userInfo;

- (id)initWithDelegate:(id)delegate;

@end

@protocol CheckBoxDelegate <NSObject>

@optional

- (void)didSelectedCheckBox:(CheckBoxButton *)checkbox checked:(BOOL)checked;

@end
