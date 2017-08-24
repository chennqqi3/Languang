//
//  LGMeetingDetailEmpCell.m
//  mettingDetail
//
//  Created by Alex-L on 2017/1/2.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "LGMeetingDetailEmpCellArc.h"
#import "LGEmpCollectionCellArc.h"
#import "StringUtil.h"
#import "ImageUtil.h"

#import "eCloudDAO.h"
#import "UserDefaults.h"
#import "OpenCtxManager.h"
#import "UIImageView+WebCache.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static NSString *LGMeetingDetailEmpCellArcID = @"LGMeetingDetailEmpCellArcID";
@interface LGMeetingDetailEmpCellArc ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreBtnBottom;


@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *showMoreBtn;
@property(nonatomic,strong)UIImage *logoImage;

- (IBAction)showMoreClick:(UIButton *)sender;

@end

@implementation LGMeetingDetailEmpCellArc

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(66, 80);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    self.collectionView.collectionViewLayout = layout;
    
    
    [self.collectionView registerClass:[LGEmpCollectionCellArc class] forCellWithReuseIdentifier:LGMeetingDetailEmpCellArcID];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
    }
    
    return self;
}

- (void)setEmpArray:(NSArray *)empArray
{
    _empArray = empArray;
    
    CGFloat height = [StringUtil getHeightWithItemCount:_empArray.count isShowMoreEmp:self.showMoreBtn.selected];
    self.contentViewHeight.constant = height;
    
    NSInteger lineCount = _empArray.count/6 + 1;
    if (lineCount>1)
    {
        self.showMoreBtnBottom.constant = 0;
    }
    else
    {
        self.showMoreBtnBottom.constant = -45;
    }
}



#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.empArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGEmpCollectionCellArc *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LGMeetingDetailEmpCellArcID forIndexPath:indexPath];
    
    NSDictionary *dic = self.empArray[indexPath.row];
    cell.userName.text = dic[@"logname"]?:@"";
    
    Emp *emp = [[eCloudDAO getDatabase] getEmpByUserAccount:@"loginname"];
//    UIImage *logo = [ImageUtil getLogo:emp];
    NSString *oaToken = [UserDefaults getLoginToken];
    NSString *userId = dic[@"id"];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://api.brc.com.cn:8088/open/org/list_person_image?access_token=%@&id=%@",oaToken,userId];

    /** 暂时先用默认头像 */
//    UIImage *logo = [self getImageFromURL:urlStr];
//    if (logo == nil) {
//        
//        logo = [StringUtil getImageByResName:@"offline.png"];
//    }
    UIImage *logo = [StringUtil getImageByResName:@"offline.png"];
    cell.icon.image = logo;
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
}

- (IBAction)showMoreClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (_showDelegate && [_showDelegate respondsToSelector:@selector(showMoreEmp:)])
    {
        [_showDelegate showMoreEmp:sender.selected];
    }
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
 
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
    
}

@end
