//
//  XINHUAEmpCell.h
//  eCloud
//
//  Created by Alex-L on 2017/4/13.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emp.h"
#import "Conversation.h"

@interface XINHUAEmpCellArc : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *empName;
@property (retain, nonatomic) IBOutlet UILabel *empClass;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL isselected;

@property (nonatomic, assign) BOOL canBeSelected;

@property (nonatomic, copy) NSString *searchEmpStr;
@property (nonatomic, copy) NSString *searchConvStr;

@property (nonatomic, strong) Emp *emp;
@property (nonatomic, strong) Conversation *conv;

@end
