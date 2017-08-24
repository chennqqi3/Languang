//
//  ImgtxtMsgCell.h
//  eCloud
//
//  Created by yanlei on 15/11/6.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ParentMsgCell.h"

@interface ImgtxtMsgCell : ParentMsgCell<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain) UITableView *imgtxtTable;
@end
