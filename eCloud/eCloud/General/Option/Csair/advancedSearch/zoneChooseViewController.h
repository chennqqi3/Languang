//
//  zoneChooseViewController.h
//  eCloud
//
//  Created by  lyong on 13-12-17.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class countryChooseViewController;
@class provinceChooseViewController;
@class cityChooseViewController;

@interface zoneChooseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    id delegete;
    UITableView *chooseTable;
    countryChooseViewController *countryChoose;
    provinceChooseViewController *provinceChoose;
    cityChooseViewController *cityChoose;
    UILabel *countryLabel;
    UILabel *provinceLabel;
    UILabel *cityLabel;
    int country_id;
    int province_id;
     NSString *area_id_strings;
}
@property(nonatomic,retain) NSString *area_id_strings;
@property (assign)int country_id;
@property (assign)int province_id;
@property (nonatomic , retain) id delegete;
@property(nonatomic,retain)UILabel *countryLabel;
@property(nonatomic,retain)UILabel *provinceLabel;
@property(nonatomic,retain)UILabel *cityLabel;
@end
