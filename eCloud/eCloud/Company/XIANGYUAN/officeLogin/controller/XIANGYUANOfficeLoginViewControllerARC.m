//
//  XIANGYUANOfficeLoginViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANOfficeLoginViewControllerARC.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"
#import "Emp.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"
#import "XIANGYUANAppViewControllerARC.h"

@interface XIANGYUANOfficeLoginViewControllerARC ()

@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UILabel *tipLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property(retain,nonatomic) Emp *emp;

@end

@implementation XIANGYUANOfficeLoginViewControllerARC
{
    conn *_conn;
    eCloudDAO *db;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.iconImage.image = [StringUtil getImageByResName:@"diannao.png"];
    
    self.loginButton.layer.borderColor = [[UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1] CGColor];
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.cornerRadius = 5.0f;
    
    if (iPhone5) {
        
        self.tipLabel.font = [UIFont systemFontOfSize:17.0];
        self.loginButton.titleLabel.font=[UIFont systemFontOfSize:17];
        self.cancelButton.titleLabel.font=[UIFont systemFontOfSize:17];
        
    }
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
}

- (void)backButtonPressed:(id) sender{
    
    XIANGYUANAppViewControllerARC *homeVC = [[XIANGYUANAppViewControllerARC alloc] init];
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[homeVC class]]){
            target = controller;
        }
    }
    if (target) {
        [self.navigationController popToViewController:target animated:YES];
    }
}

- (IBAction)login:(UIButton *)sender {
    
    [self Officelogin];
    
}
- (IBAction)cancel:(id)sender {
    
    XIANGYUANAppViewControllerARC *homeVC = [[XIANGYUANAppViewControllerARC alloc] init];
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[homeVC class]]){
            target = controller;
        }
    }
    if (target) {
        [self.navigationController popToViewController:target animated:YES];
    }
    
}

- (void)Officelogin{
    
    //                RequestParam={" CLIENTRANDOM ":"123333XX "," CLIENTID ":"20"," SECRET ":"7HJD3d7k2X23jslkda34k"," LOGON_NAME ":"zhoul_test"," UID ":"7dl99288889"," SID ":"20170413000001"};
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
    self.emp = [db getEmpInfo:_conn.userId];
    //随机字符串
    NSString *CLIENTRANDOM = [StringUtil getRandomString];
    NSString *CLIENTID = @"29e574fd-b0ef-486f-b46f-d1c358d86741";
    NSString *SECRET = @"t8l6rmmhlE+Q097JNTUxFQ9vdpvIyJtIwL5SWqrdD4M=";
    NSString *LOGON_NAME = self.emp.empCode;
    NSString *UID = self.dict[@"uid"];
    NSString *SID = self.dict[@"sid"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:CLIENTRANDOM,@"CLIENTRANDOM", CLIENTID,@"CLIENTID",SECRET,@"SECRET",LOGON_NAME,@"LOGON_NAME",UID,@"UID",SID,@"SID", nil];
    NSString *jsonString = [dict JSONString];
    NSDictionary *paramers = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"RequestParam", nil];
    
    NSString *urlStr= [NSString stringWithFormat:@"http://36.7.71.121:8088/isso/loginbydev/oauth/imlogin"];
//    NSString *urlStr= [NSString stringWithFormat:@"http://36.7.71.121:8088/isso/loginbydev/oauth/imlogin?%@",paramers];
//    ASIFormDataRequest * request =[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
// 
//    [request setPostValue:@"RequestParam" forKey:jsonString];
//    request.delegate=self;
//    [request startSynchronous];
    
    ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    //设置需要POST的数据，这里提交两个数据，A=a&B=b
    [requestForm setPostValue:jsonString forKey:@"RequestParam"];
    [requestForm startSynchronous];
    
    //输入返回的信息
    NSString *resultStr = [requestForm responseString];
    NSData* jsonData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s办公登录结果%@",__FUNCTION__,resultDict]];
    
    if ([resultDict[@"RESULT"] isEqualToString:@"SUCCESS"]) {
        
        XIANGYUANAppViewControllerARC *homeVC = [[XIANGYUANAppViewControllerARC alloc] init];
        UIViewController *target = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[homeVC class]]){
                target = controller;
            }
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"登录失败" delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    
}
@end
