//
//  MiLiaoConvListViewControllerArc.m
//  miliao
//
//  Created by Alex-L on 2017/6/14.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "MiLiaoBeginViewControllerArc.h"
#import "MiLiaoBrieftViewControllerArc.h"
#import "StringUtil.h"

@interface MiLiaoBeginViewControllerArc ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *knowMoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *beginMiliaoBtn;
@property (retain, nonatomic) IBOutlet UIImageView *beginImage;

- (IBAction)knowMoreClick:(UIButton *)sender;
- (IBAction)beginMiliaoClick:(UIButton *)sender;

@end

@implementation MiLiaoBeginViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"密聊";
    
    self.beginMiliaoBtn.clipsToBounds = YES;
    self.beginMiliaoBtn.layer.cornerRadius = 3;
    self.descriptionLabel.text = @"消息已读后自动销毁,在各端不留痕";
    self.beginImage.image = [StringUtil getImageByResName:@"img_secret_chat_empty"];
}

- (IBAction)knowMoreClick:(UIButton *)sender
{
    MiLiaoBrieftViewControllerArc *brieftCtl = [[MiLiaoBrieftViewControllerArc alloc] init];
    [self.navigationController pushViewController:brieftCtl animated:YES];
}

- (IBAction)beginMiliaoClick:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startMiLiao)]) {
        [self.delegate startMiLiao];
    }
}

- (void)dealloc {

}
@end
