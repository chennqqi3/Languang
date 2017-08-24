//
//  ReceiptMsgDetailViewController.m
//  eCloud
//
//  Created by Alex L on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptMsgDetailViewController.h"
#import "UserInterfaceUtil.h"
#import "NewOrgViewController.h"
#import "talkSessionViewController.h"
#import "eCloudDefine.h"

#import "CollectionHeaderView.h"
#import "ReceiptCollectionContentView.h"
#import "ReceiptCollectionFooterView.h"

#import "ReceiptMsgCollectionViewCell.h"

#import "ReceiptDAO.h"
#import "ImageUtil.h"
#import "UserDisplayUtil.h"
#import "CollectionUtil.h"

#import "EncryptFileManege.h"

#define ITEM_COUNT (IS_IPHONE_6P ? 5:4)

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "ReceiptMsgDetailHeaderView.h"
#endif


#define KSCREEN_BOUNDS ([UIScreen mainScreen].bounds)

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *headerIdentifier = @"headerIdentifier";
static NSString *seperateHeaderID = @"seperateHeaderID";
static NSString *footerIdentifier = @"footerIdentifier";
static NSString *contentViewIdentifier = @"contentIdentifier";

@interface ReceiptMsgDetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, footerViewReloadDelegate>
{
    amrToWavMothod *amrtowav;
    NSTimer *_timer;
    NSInteger _readItemArrayCount;
    NSInteger _unreadItemArrayCount;
    CGFloat _record_fileSize;
    
    BOOL _flag1;
    BOOL _flag2;
    
    // 录音是否正在播放
    BOOL isPlaying;
}

@property (nonatomic, strong) talkSessionViewController *talkSessionCtl;

@property (nonatomic, copy) NSString *long_text;
@property (nonatomic, strong) NSArray *readItemArray;
@property (nonatomic, strong) NSArray *unReadItemArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *voicePlayImg;

@end

@implementation ReceiptMsgDetailViewController

- (void)dealloc
{
    if (isPlaying)
    {
        [self.talkSessionCtl stopPlayAudio];
    }
}

- (NSArray *)readItemArray
{
    if (_readItemArray == nil)
    {
        ReceiptDAO *db = [ReceiptDAO getDataBase];
        _readItemArray = [NSArray arrayWithArray:[db getReceiptUser:self.msgId andReadFlag:1]];
    }
    return _readItemArray;
}

- (NSArray *)unReadItemArray
{
    if (_unReadItemArray == nil)
    {
        ReceiptDAO *db = [ReceiptDAO getDataBase];
        _unReadItemArray = [NSArray arrayWithArray:[db getReceiptUser:self.msgId andReadFlag:0]];
    }
    return _unReadItemArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    self.title = @"接收人列表";
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(((KSCREEN_BOUNDS.size.width - 10) / ITEM_COUNT) - 5, ((KSCREEN_BOUNDS.size.width - 10 )/ ITEM_COUNT) -5);
    // 行间距
    flowLayout.minimumLineSpacing = 5;
    // 列间距
    flowLayout.minimumInteritemSpacing = 5;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[ReceiptMsgCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    [self.collectionView registerClass:[ReceiptMsgDetailHeaderView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:seperateHeaderID];
#endif
    
    [self.collectionView registerClass:[ReceiptCollectionContentView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:contentViewIdentifier];
    [self.collectionView registerClass:[ReceiptCollectionFooterView class] forSupplementaryViewOfKind: UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    [self.view addSubview:self.collectionView];
    
    // 设置返回按钮
    [self setLeftBtn];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    if (_timer.isValid)
    {
        [_timer invalidate];
        _timer = nil ;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (_flag1 == NO && self.unReadItemArray.count >= (ITEM_COUNT*3))
        {
            return (ITEM_COUNT*3);
        }
        return self.unReadItemArray.count;
    }
    else
    {
        if (_flag2 == NO && self.readItemArray.count >= (ITEM_COUNT*3))
        {
            return (ITEM_COUNT*3);
        }
        return self.readItemArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiptMsgCollectionViewCell *cell = (ReceiptMsgCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Emp *emp = nil;
    if (indexPath.section == 0)
    {
        emp = [self.unReadItemArray objectAtIndex:indexPath.row];
        // 用户名
        cell.userName.text = emp.emp_name;
        // 在线状态
        cell.userStatus.image = [self getStatusImg:emp];
        // 头像
        UIImage *icon = [ImageUtil getEmpLogo:emp];
        cell.icon.image = icon;
    }
    else
    {
        emp = [self.readItemArray objectAtIndex:indexPath.row];
        // 用户名
        cell.userName.text = emp.emp_name;
        // 在线状态
        cell.userStatus.image = [self getStatusImg:emp];
        // 头像
        UIImage *icon = [ImageUtil getEmpLogo:emp];
        cell.icon.image = icon;
    }
    
    if ([cell.icon.image isEqual:default_logo_image]) {
        NSDictionary *mDic = [UserDisplayUtil getUserDefinedChatMessageLogoDicOfEmp:emp];
        [UserDisplayUtil setUserDefinedLogo:cell.icon andLogoDic:mDic];
    }else{
        [UserDisplayUtil hideLogoText:cell.icon];
    }

    return cell;
}

- (UIImage *)getStatusImg:(Emp *)emp
{
    // 默认是离线
    NSString *statusImageName = @"offline_icon";
    // 显示成员状态
    if([UserDisplayUtil isLoginWithCellPhone:emp])
    {
        statusImageName = @"cell_phone";
    }else if(emp.emp_status == status_leave)
    {
        statusImageName = @"status_leave";
    }else if ([UserDisplayUtil isLoginWithPC:emp])
    {
        statusImageName = @"pc_login";
    }
    
    UIImage *statusImg = [StringUtil getImageByResName:statusImageName];
    
    return statusImg;
}

// 定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 0, 5);
}

// 这个方法是返回Header的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.unReadItemArray.count == 0 && section == 0)
    {
        return CGSizeMake(120, 0);
    }
    if (self.readItemArray.count == 0 && section == 1)
    {
        return CGSizeMake(120, 0);
    }
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    if (self.unReadItemArray.count && self.readItemArray.count) {
        return CGSizeMake(SCREEN_WIDTH, (SEPERATE_VIEW_HEIGHT + 30));
    }
#endif

    return CGSizeMake(120, 30);
}

// 这个方法是返回Footer的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.unReadItemArray.count > 12)
        {
            return CGSizeMake(120, 35);
        }
        return CGSizeZero;
    }
    else
    {
        if (self.readItemArray.count > 12)
        {
            return CGSizeMake(120, 35);
        }
        return CGSizeZero;
    }
}

//获取Header或Footer的方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
       //从缓存中获取 HeaderCell
        CollectionHeaderView *cell = (CollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        
        if (indexPath.section == 0)
        {
            cell.headerLabel.text = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"receipt_msg_unread"],self.unReadItemArray.count];
        }
        else if (indexPath.section == 1)
        {
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
            if (self.unReadItemArray.count && self.readItemArray.count) {
                
                ReceiptMsgDetailHeaderView *cell = (ReceiptMsgDetailHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:seperateHeaderID forIndexPath:indexPath];
                cell.headerLabel.text = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"receipt_msg_read"],self.readItemArray.count];
                return cell;
            }            
#endif

            cell.headerLabel.text = [NSString stringWithFormat:@"%@(%d)",[StringUtil getLocalizableString:@"receipt_msg_read"],self.readItemArray.count];
        }
        
        return cell;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        //从缓存中获取 FooterCell
        ReceiptCollectionFooterView *cell = (ReceiptCollectionFooterView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        
        if (indexPath.section == 0)
        {
            if (_flag1)
            {
                [cell.expandOrPutAwary setTitle:[StringUtil getLocalizableString:@"chatmessage_pack_up"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.expandOrPutAwary setTitle:[StringUtil getLocalizableString:@"chatmessage_more"] forState:UIControlStateNormal];
            }
        }
        else if (indexPath.section == 1)
        {
            if (_flag2)
            {
                [cell.expandOrPutAwary setTitle:[StringUtil getLocalizableString:@"chatmessage_pack_up"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.expandOrPutAwary setTitle:[StringUtil getLocalizableString:@"chatmessage_more"] forState:UIControlStateNormal];
            }
        }
        
        cell.expandOrPutAwary.tag = indexPath.section + 200;
        
        cell.reloadDelegate = self;
        
        return cell;
    }
    
    return nil;
}

- (void)playOrPause
{
    if (isPlaying)
    {
        if ([_timer isValid])
        {
            [_timer invalidate];
            _timer = nil;
        }
        
        // 结束动画
        [self.voicePlayImg stopAnimating];
        // 初始化时间
        _record_fileSize = [self.convRecord.file_size doubleValue];
        self.durationLabel.text = [NSString stringWithFormat:@"%.f",_record_fileSize];
        // 停止时间
        if ([self.talkSessionCtl stopPlayAudio])
        {
            return;
        }
    }
    // 不是正在播放
    else
    {
        // 开始动画
        [self.voicePlayImg startAnimating];
        
        // 更新时间的计时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
        [[NSRunLoop  currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        
        // 是否需要解密
        if ([eCloudConfig getConfig].needFixSecurityGap)
        {
            NSData *data = [EncryptFileManege getDataWithPath:self.convRecord.msg_body];
            NSString *tmpDir = NSTemporaryDirectory();
            NSArray *arr = [self.convRecord.msg_body componentsSeparatedByString:@"/"];
            NSString *newPath = [tmpDir stringByAppendingPathComponent:[arr lastObject]];
            [data writeToFile:newPath atomically:YES];
            
            self.convRecord.msg_body = newPath;
        }
        
        NSRange range = [self.convRecord.msg_body rangeOfString:@".amr"];
        if (range.length > 0)
        {//需要转换
            NSString * docFilePath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:@"amrAudio.wav"];
            [amrtowav startAMRtoWAV:self.convRecord.msg_body tofile:docFilePath];
            if (self.talkSessionCtl == nil)
            {
                _talkSessionCtl = [talkSessionViewController getTalkSession];
            }
            [self.talkSessionCtl playAudio:docFilePath];
            
            return;
        }
        [self.talkSessionCtl playAudio:self.convRecord.msg_body];
    }
    
    isPlaying = !isPlaying;
}

- (NSString *)getReceiptTime
{
    NSString *receiptTime = nil;
    
    // 计算什么时候收藏的
    NSInteger _timeNow = [[NSDate date] timeIntervalSince1970];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger zoneTime = [zone secondsFromGMT];
    NSInteger timeFromYesterday = (([self.convRecord.msg_time integerValue] + zoneTime)/ 3600) % 24;
    
    NSInteger time = _timeNow - [self.convRecord.msg_time integerValue];
    NSInteger hours = time/(60*60) + timeFromYesterday;
    NSInteger days = hours / 24;
    
    if (days == 0)
    {
        NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[self.convRecord.msg_time integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        receiptTime = date;
    }
    else
    {
        NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[self.convRecord.msg_time integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM/dd"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        receiptTime = date;
    }
    
    return receiptTime;
}

- (void)_timerAction:(id)timer
{
    if (_record_fileSize > 0)
    {
        self.durationLabel.text = [NSString stringWithFormat:@"%.f",--_record_fileSize];
    }
}

#pragma mark - 播放结束发送的通知
- (void)playbackQueueStopped:(NSNotification *)note
{
    isPlaying = NO;
    // 停止动画
    [self.voicePlayImg stopAnimating];
    
    if ([_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    self.durationLabel.text = self.convRecord.file_size;
}

#pragma mark - footerViewReloadDelegate
- (void)reload:(NSInteger)tag
{
    if (tag == 200)
    {
        _flag1 = !_flag1;
    }
    else if (tag == 201)
    {
        _flag2 = !_flag2;
    }
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        Emp *emp = [self.unReadItemArray objectAtIndex:indexPath.row];
        
        [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
    }
    else if (indexPath.section == 1)
    {
        Emp *emp = [self.readItemArray objectAtIndex:indexPath.row];
        
        [NewOrgViewController openUserInfoById:[StringUtil getStringValue:emp.emp_id] andCurController:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
@end
