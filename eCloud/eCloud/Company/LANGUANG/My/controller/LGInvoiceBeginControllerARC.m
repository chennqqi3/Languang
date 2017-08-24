//
//  LGInvoiceBeginController.m
//  eCloud
//
//  Created by Ji on 17/7/11.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGInvoiceBeginControllerARC.h"
#import "StringUtil.h"
#import "LGAddInvoiceControllerARC.h"
#import "UIAdapterUtil.h"

@interface LGInvoiceBeginControllerARC ()
@property (retain, nonatomic) IBOutlet UIImageView *noMsgImage;

@end

@implementation LGInvoiceBeginControllerARC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"开票信息";
    _noMsgImage.image = [StringUtil getImageByResName:@"img_meeting_nothing"];
#ifdef _LANGUANG_FLAG_
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
 
#endif
    
}
- (IBAction)addInvoice:(id)sender {
    
    LGAddInvoiceControllerARC *add = [[LGAddInvoiceControllerARC alloc]init];
    [self.navigationController pushViewController: add animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {

}
@end
