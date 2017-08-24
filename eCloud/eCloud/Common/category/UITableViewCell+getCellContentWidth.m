//
//  UITableViewCell+getCellContentWidth.m
//  eCloud
//
//  Created by shisuping on 15-8-5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "UITableViewCell+getCellContentWidth.h"
#import "UIAdapterUtil.h"

@implementation UITableViewCell (getCellContentWidth)

- (float)getCellContentWidth
{
    return [UIAdapterUtil getTableCellContentWidth];
}

@end
