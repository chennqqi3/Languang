//
//  KapokUploadViewController.h
//  eCloud
//
//  Created by  lyong on 14-5-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class conn;
@class FlatDatePicker;
@class PictureManager;

@interface KapokUploadViewController : UIViewController
{
    UITextField *FlightField;
    UITextField *AirportField;
    UITextField *NoBoardingField;
    UITextField *lastField;
    UIButton *dateChoose;
    UIScrollView *memberScroll;
     BOOL start_Delete;
    //多选 图片
    PictureManager *pictureManager;
    NSMutableArray *manyPicArray;
    int max_num;
    conn *_conn;
    NSString *modify_type_upload_id;
    BOOL is_modify;
    UIView *tip_textView;
    UIButton *backgroudButton;
}
@property (nonatomic, strong) FlatDatePicker *flatDatePicker;
@property(nonatomic,retain) NSString *modify_type_upload_id;
@property(assign) BOOL start_Delete;
-(void)showSelectedPic:(NSMutableArray*)selectedArr;
@end
