//
//  DisplayPicViewController.m
//  eCloud
//
//  Created by yanlei on 15/11/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "DisplayPicViewController.h"
#import "ForwardingRecentViewController.h"

#import "eCloudConfig.h"

#import "talkSessionViewController.h"

#import "UserTipsUtil.h"

#import "ReusableView.h"
#import "XLPlainFlowLayout.h"
#import "TimeUtil.h"
#import "ViewPicUtil.h"
#import "EncryptFileManege.h"
#import "UIImageOfCrop.h"

#import "MyCollectionViewCell.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"
#import "MassDAO.h"
#import "eCloudDAO.h"
#import "UserDefaults.h"

#define EDIT_BUTTON_TAG (100)

#define BOTTOM_BAR_HEIGHT (44.0)

#define KEY_RECORDS @"records"
#define KEY_GROUP_TIME @"records_date"

#define HEADVIEW_HIGHT (30)
#define CELL_SPACE (0.5)

static NSString *cellID = @"cellID";
static NSString *headerID = @"headerID";

@interface DisplayPicViewController () <MyCollectionViewCellDelegate,ForwardingDelegate>
{
    MassDAO *massDAO;
    eCloudDAO *_ecloud ;
    UIView *showPicBackView;
    float maxSendFileSize;
    
    UICollectionView *collectionView;
    
    UIButton *addButton;
    BOOL editing; //判断是否批量状态
    UIView *bottomNavibar;
    
    NSMutableArray *selectArray;
    
    FGalleryViewController *networkGallery;
    
//    记录用户是否执行了删除操作，如果删除了，那么回到聊天界面的时候 需要刷新聊天界面，因为有些记录已经删除了
    BOOL hasDelete;
    
}
@property (nonatomic,strong) NSMutableArray *recordList;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation DisplayPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
//    万达版本增加此按钮
    if ([eCloudConfig getConfig].chatMessageDisplayPicMsgEntrance) {
        //右边按钮
        addButton = [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"edit"] andTarget:self andSelector:@selector(addButtonPressed:)];
    }

    self.navigationItem.title = [StringUtil getLocalizableString:@"chatmessage_pic_chat_record"];
    
    // 加载会话中的图片数据
    [self loadData];
    
    // 加载界面视图
    [self loadMyView];
    
//    加载底部视图
    [self addBottomBar];
}


- (void)formatData
{
    self.dataArray = [NSMutableArray array];
    
    NSMutableArray *tempRecordsArray = [NSMutableArray arrayWithArray:self.recordList];
    //    本周的图片
    NSMutableArray *curWeekRecords = [NSMutableArray array];
    
    for (int i = self.recordList.count - 1; i >= 0; i--) {
        ConvRecord *_convRecord = tempRecordsArray[i];
        //        如果是本周的图片 则另外放到curWeekRecords数组里
        if ([TimeUtil isCurWeek:_convRecord.msg_time.intValue]) {
            [curWeekRecords insertObject:_convRecord atIndex:0];
            [tempRecordsArray removeObject:_convRecord];
        }else{
            break;
        }
    }
    
    //    NSLog(@"%s 本周的图片张数%d",__FUNCTION__,curWeekRecords.count);
    
    //    某个月份的图片
    NSMutableArray *curMonthRecordArray = [NSMutableArray array];
    
    NSString *lastMsgMonth = nil;
    
    for (ConvRecord *tmpConvRecord in tempRecordsArray) {
        int msgTime = [tmpConvRecord.msg_time intValue];
        NSString *curMsgMonth = [TimeUtil getMonthOfTime:msgTime];
        
        //            如果月份相等
        if ([curMsgMonth isEqualToString:lastMsgMonth]) {
            [curMonthRecordArray addObject:tmpConvRecord];
        }else{
            //            生成一个新的月份的数组
            curMonthRecordArray = [NSMutableArray array];
            //            保存
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:curMonthRecordArray,KEY_RECORDS,curMsgMonth,KEY_GROUP_TIME, nil];
            [self.dataArray addObject:dic];
            
            [curMonthRecordArray addObject:tmpConvRecord];
            //            保存月份 方便和下一条匹配
            lastMsgMonth = [NSString stringWithString:curMsgMonth];
        }
    }
    
    if (curWeekRecords.count) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:curWeekRecords,KEY_RECORDS,[StringUtil getLocalizableString:@"file_cur_week"],KEY_GROUP_TIME, nil];
        [self.dataArray addObject:dic];
    }
}

- (void)loadData{
     _ecloud = [eCloudDAO getDatabase] ;
    self.recordList= [NSMutableArray arrayWithArray:[_ecloud getPicConvRecordBy:self.convId]];
    [self formatData];
    
    
//    for (NSDictionary *dic in self.dataArray) {
//        NSArray *tempArray = dic[KEY_RECORDS];
//        NSString *curTime = dic[KEY_GROUP_TIME];
//        NSLog(@"%s curtime is %@ count is %d",__FUNCTION__,curTime,tempArray.count);
//    }
}

- (void)loadMyView{
    XLPlainFlowLayout *layout = [[XLPlainFlowLayout new]autorelease];
    layout.itemSize = CGSizeMake(self.view.frame.size.width/4 - 4, self.view.frame.size.width/4 - 4);
    layout.sectionInset = UIEdgeInsetsMake(CELL_SPACE, CELL_SPACE, CELL_SPACE, CELL_SPACE);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;

    //使用layout来创建collectionView
    collectionView = [[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64) collectionViewLayout:layout]autorelease];
    collectionView.backgroundColor = self.view.backgroundColor;
    collectionView.delegate = self;
    collectionView.dataSource =self;
    [self.view addSubview:collectionView];
    
    [collectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:headerID];

    [collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    
    [collectionView reloadData];
    
//   定位到某一张图片
    [self position];
}

- (void) position
{
    if (self.selectedIndex) {
        if (self.selectedIndex < self.recordList.count) {
            
            NSIndexPath *indexPath = [self getIndexPathByIndex:self.selectedIndex];
            
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)addBottomBar{
    
    float toolbarY = self.view.frame.size.height - BOTTOM_BAR_HEIGHT;
    
    bottomNavibar=[[UIView alloc]initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, BOTTOM_BAR_HEIGHT + 2)];
    bottomNavibar.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    bottomNavibar.hidden = YES;
    [self.view addSubview:bottomNavibar];
    [bottomNavibar release];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, bottomNavibar.frame.size.width, 1.0)];
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [bottomNavibar addSubview:lineLab];
    [lineLab release];
    
    int buttonCount = 2;
    
    for (int i = 0; i < buttonCount; i ++) {
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenW/buttonCount * i, 0.0, screenW/buttonCount-1, 46.0)];
        editBtn.backgroundColor = [UIColor clearColor];
        editBtn.tag = EDIT_BUTTON_TAG + i;
        [editBtn setTitleColor:[UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0] forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        editBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        [editBtn addTarget:self action:@selector(clickOnBottomNavibarBtn:) forControlEvents:UIControlEventTouchUpInside];
        [bottomNavibar addSubview:editBtn];
        [editBtn release];
        
        if (i == 0) {
            [editBtn setTitle:[StringUtil getLocalizableString:@"forward"] forState:UIControlStateNormal];
        }
        else{
            [editBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [editBtn setTitleColor:[UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0] forState:UIControlStateHighlighted];
            
            [editBtn setTitle:[StringUtil getLocalizableString:@"delete"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - collectionView的代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}
//每个section有几个cell
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //取到每个self.dataArray的元素,并返回元素个数
    NSDictionary *dic = [self.dataArray objectAtIndex:section];
    NSArray *array = [dic objectForKey:KEY_RECORDS];
    return [array count];
}

//确定显示什么图片
- (void)setPropertyOfConvRecord:(ConvRecord *)_convRecord
{
    //        如果内存里已经有了则显示内存里保存的
    if (_convRecord.imageDisplay) {
        //        NSLog(@"%s 内存里已经保存了图片",__FUNCTION__);
    }else{
        //            查看是否有正方形的图片
        UIImage *squareImage = nil;//[ViewPicUtil getPicWithMsgBody:_convRecord.msg_body andPicType:pic_type_square];
        if (squareImage) {
            //            NSLog(@"%s 已经有了正方形图片",__FUNCTION__);
            _convRecord.imageDisplay = squareImage;
        }else{
            //                    查看大图是否存在
            UIImage *originImage = [ViewPicUtil getPicWithMsgBody:_convRecord.msg_body andPicType:pic_type_origin];
            if (originImage) {
                //                NSLog(@"%s 有大图",__FUNCTION__);
                //                    裁剪成正方形图片
                UIImage *tempImage = [originImage imageByScalingAndCroppingForSize:CGSizeMake(1.0, 1.0)];
                if (tempImage) {
                    //                    NSLog(@"%s 大图成功裁剪为正方形图片",__FUNCTION__);
                    
                    _convRecord.imageDisplay = tempImage;
                    //                        保存正方形图片
                    NSData *_data = [ViewPicUtil convertImageToData:tempImage];
                    
                    if (_data) {
                        [EncryptFileManege saveFileWithPath:[ViewPicUtil getPicPathWithMsgBody:_convRecord.msg_body andPicType:pic_type_square] withData:_data];
                    }
                    
                }else {
                    //                    NSLog(@"%s 大图裁剪失败",__FUNCTION__);
                    _convRecord.imageDisplay = originImage;
                }
            }else{
                //                查看是否有小图
                UIImage *smallImage = [ViewPicUtil getPicWithMsgBody:_convRecord.msg_body andPicType:pic_type_small];
                if (smallImage) {
                    //                    NSLog(@"%s 有缩略图",__FUNCTION__);
                    _convRecord.imageDisplay = smallImage;
                    [self autoDownloadPic:_convRecord];
                }
            }
        }
    }
}

//自动下载大图
- (void)autoDownloadPic:(ConvRecord *)_convRecord
{
    if (!_convRecord.isDownLoading) {
        _convRecord.isDownLoading = true;
     
        dispatch_queue_t queue = dispatch_queue_create("download pic", NULL);
        dispatch_async(queue, ^{
            
            NSURL *url = [NSURL URLWithString:[ViewPicUtil getPicDownloadUrl:_convRecord.msg_body andPicType:pic_type_origin]];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            
            if(imageData)
            {
                //                            保存方形图
                UIImage *originImage = [UIImage imageWithData:imageData];
                if (originImage) {
                    NSLog(@"%s 大图下载完毕，保存大图并且生成方形图 msgbody is %@",__FUNCTION__,_convRecord.msg_body);
                    //                            保存大图
                    [EncryptFileManege saveFileWithPath:[ViewPicUtil getPicPathWithMsgBody:_convRecord.msg_body andPicType:pic_type_origin] withData:imageData];
                    
                    UIImage *tempImage = [originImage imageByScalingAndCroppingForSize:CGSizeMake(1.0, 1.0)];
                    if (tempImage) {
                        NSLog(@"%s 大图成功裁剪为正方形图片",__FUNCTION__);
                        
                        _convRecord.imageDisplay = tempImage;
                        //                        保存正方形图片
                        NSData *_data = [ViewPicUtil convertImageToData:tempImage];
                        
                        if (_data) {
                            [EncryptFileManege saveFileWithPath:[ViewPicUtil getPicPathWithMsgBody:_convRecord.msg_body andPicType:pic_type_square] withData:_data];
                        }
                        
                    }else {
                        NSLog(@"%s 大图裁剪失败",__FUNCTION__);
                        _convRecord.imageDisplay = originImage;
                    }
                    _convRecord.isDownLoading = false;
                    //                        怎么刷新主线程呢
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%s msgid is %d 刷新界面",__FUNCTION__,_convRecord.msgId);
                        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:_convRecord.imageIndexPath]];
                    });
                }else{
                    NSLog(@"%s 大图下载失败 格式不对",__FUNCTION__);
                }
                
            }else{
                NSLog(@"%s 大图下载失败 不存在",__FUNCTION__);
            }
        });
    }
}

//cell复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.section];

    ConvRecord *_convRecord = [self getRecordByIndexPath:indexPath];
    _convRecord.imageIndexPath = indexPath;
    
    [self setPropertyOfConvRecord:_convRecord];
    
    if (!_convRecord.imageDisplay) {
        cell.imageView.image = [StringUtil getImageByResName:@"default_pic.png"];
        [self autoDownloadPic:_convRecord];
    }else{
        cell.imageView.image = _convRecord.imageDisplay;
    }

    UIButton *button = cell.overlayView;
    
    if (editing) {
        if ([selectArray containsObject:_convRecord]) {
            [button setBackgroundImage:[StringUtil getImageByResName:@"photo_Selection_ok.png"] forState:UIControlStateNormal];
        }else{
            [button setBackgroundImage:[StringUtil getImageByResName:@"photo_Selection.png"] forState:UIControlStateNormal];
        }
        button.hidden = NO;
    }else{
        button.hidden = YES;
    }
    
    button.titleLabel.text = [NSString stringWithFormat:@"%d,%d",indexPath.section,indexPath.row];

    return cell;
}

//itemSize
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int perRowCount = 4;
    if (IS_IPAD && [UIAdapterUtil isLandscap]) {
        perRowCount = 5;
    }
    
    CGSize _size = CGSizeMake(SCREEN_WIDTH/perRowCount - perRowCount, SCREEN_WIDTH/perRowCount - perRowCount);
 
    return _size;
}

//headView大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, HEADVIEW_HIGHT);
}

//定制head  foot
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //判断是head ,还是foot
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        //这里是头部
        ReusableView *header =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerID forIndexPath:indexPath];
        NSDictionary *mdic = self.dataArray[indexPath.section];
        header.text = [NSString stringWithFormat:@"   %@",mdic[KEY_GROUP_TIME]];
        return header;
    }
    return nil;
}

//点击了一个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section==%d,row==%d",indexPath.section,indexPath.row);
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.section];
    ConvRecord *tmpConvRecord = [self getRecordByIndexPath:indexPath];
    
    int currIndex = [self getIndexByIndexPath:indexPath];

    if ([self isPresentViewController]) {
        [self refreshTalksession];
        self.selectedIndex = currIndex;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            NSLog(@"%s",__FUNCTION__);
        }];
    }else{
        if (!networkGallery) {
            networkGallery = [[FGalleryViewController alloc]initWithPhotoSource:self];
        }
        networkGallery.currentIndex = currIndex;
        
        [self.navigationController pushViewController:networkGallery animated:YES];
    }
}

#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return self.recordList.count;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption = @"";
    
    return caption;
}


- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return @"";
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    
    ConvRecord *_convRecord = self.recordList[index];
    
    NSString *pathStr ;
    if (size == FGalleryPhotoSizeThumbnail) {
        pathStr = [ViewPicUtil getPicDownloadUrl:_convRecord.msg_body andPicType:pic_type_small];
    }
    else {
        pathStr = [ViewPicUtil getPicDownloadUrl:_convRecord.msg_body andPicType:pic_type_origin];
    }
    return pathStr;
}

#pragma mark ======collection view delegate========


- (void)clickButton:(UIButton *)button
{
    if (!selectArray) {
        selectArray = [[NSMutableArray alloc]init];
    }
    NSString *str = button.titleLabel.text;
    NSArray *_array = [str componentsSeparatedByString:@","];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_array[1] intValue] inSection:[_array[0] intValue]];
    
    ConvRecord *_convRecord = [self getRecordByIndexPath:indexPath];
    
    if (button.selected) {
        [selectArray removeObject:_convRecord];
    }else{
        [selectArray addObject:_convRecord];
    }
    button.selected = !button.selected;
    [self setButtonImage:button];
}

- (void)setButtonImage:(UIButton *)button
{
    if (button.selected) {
        [button setBackgroundImage:[StringUtil getImageByResName:@"photo_Selection_ok.png"] forState:UIControlStateNormal];
    }else{
        [button setBackgroundImage:[StringUtil getImageByResName:@"photo_Selection.png"] forState:UIControlStateNormal];
    }
}


#pragma mark - 按钮方法实现

- (void)addButtonPressed:(UIButton *) sender{
    int tableH;
    if (editing) {
        [sender setTitle:[StringUtil getLocalizableString:@"edit"] forState:UIControlStateNormal];
        editing = NO;
        
        [selectArray removeAllObjects];
        
        //        非编辑状态
        tableH = self.view.frame.size.height;
        
        bottomNavibar.hidden = YES;
    }
    else{
        [sender setTitle:[StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
        editing = YES;
        //编辑状态
        tableH = self.view.frame.size.height - BOTTOM_BAR_HEIGHT;
        
        CGRect _frame = bottomNavibar.frame;
        _frame.origin.y = tableH;
        bottomNavibar.frame = _frame;
        
        bottomNavibar.hidden = NO;
    }
    
    [collectionView setFrame:CGRectMake(0, 0, self.view.frame.size.width, tableH)];
    [collectionView reloadData];
}

-(void) clickOnBottomNavibarBtn:(UIButton *)sender{
    if (!selectArray.count) {
        return;
    }
    
    NSInteger index = sender.tag - EDIT_BUTTON_TAG;
    if (index == 0) {
//        转发
        [self forwardRecords];
    }else{
//        删除
        [self deleteSelectRecords];
    }
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    
    [self refreshTalksession];

    if ([self isPresentViewController]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            NSLog(@"%s",__FUNCTION__);
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark =======转发提示=========
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

#pragma mark ======util method======

- (void)forwardRecords
{
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc]init];
    forwarding.fromType = transfer_from_image_preview;
    forwarding.forwardingDelegate = self;
    
    forwarding.forwardRecordsArray = [NSArray arrayWithArray:selectArray];
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
//    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (void)deleteSelectRecords
{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
    [self performSelector:@selector(deleteSelectRecords2) withObject:nil afterDelay:0.05];
}
- (void)deleteSelectRecords2
{
    for (ConvRecord *_convRecord in selectArray) {
        [_ecloud deleteOneMsg:[StringUtil getStringValue:_convRecord.msgId]];
        [self.recordList removeObject:_convRecord];
    }
    
    [selectArray removeAllObjects];
    
    hasDelete = YES;
    
    [self formatData];
    
    [collectionView reloadData];
    
    [UserTipsUtil hideLoadingView];
}

//如果删除过 那么刷新聊天界面
- (void)refreshTalksession
{
    if (hasDelete) {
        talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
        [talksession prepareGalleryData:nil];
        talksession.needUpdateTag = 1;
        [talksession refresh];
    }
}

- (ConvRecord *)getRecordByIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.section];
    ConvRecord *_convRecord = [dic objectForKey:KEY_RECORDS][indexPath.row];
    
    return _convRecord;

}

- (NSIndexPath *)getIndexPathByIndex:(int)index
{
    ConvRecord *_convRecord = self.recordList[index];
    //            所在section
    int _section = 0;
    //            所在位置
    int _row = 0;
    
    for (NSDictionary *dic in _dataArray) {
        BOOL isFind = NO;
        NSArray *recordsArray = dic[KEY_RECORDS];
        int _index = [recordsArray indexOfObject:_convRecord];
        if (_index == NSNotFound) {
            _section++;
        }else{
            _row = _index;
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_row inSection:_section];
    
    return indexPath;
}

- (int)getIndexByIndexPath:(NSIndexPath *)indexPath
{
    int currIndex = 0;
    for (int i = 0; i < indexPath.section; i++) {
        NSDictionary *tmpDic = [_dataArray objectAtIndex:i];
        currIndex += [[tmpDic objectForKey:KEY_RECORDS] count];
    }
    
    currIndex += indexPath.row;
    return currIndex;
}

//判断是不是presentModel

- (BOOL)isPresentViewController
{
    UIViewController *rootController = self.navigationController.viewControllers[0];
    if ([rootController isKindOfClass:[self class]]) {
        return YES;
    }
    return NO;
}


-(void)dealloc
{
    if (!selectArray) {
        [selectArray release];
        selectArray = nil;
    }
    
    if (networkGallery) {
        [networkGallery release];
        networkGallery = nil;
    }
    
    self.dataArray = nil;
    self.recordList = nil;
    
    [super dealloc];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = collectionView.frame;
    
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    collectionView.frame = _frame;
    [collectionView reloadData];
}

@end
