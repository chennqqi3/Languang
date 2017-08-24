//
//  RobotDisplayUtil.m
//  eCloud
//
//  Created by shisuping on 15/11/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "RobotDisplayUtil.h"
#import "FGalleryViewController.h"

#import "PicMsgCell.h"
#import "DownloadFileModel.h"
#import "RobotFileUtil.h"
#import "FileRecord.h"
#import "CustomQLPreviewController.h"
#import "AudioViewController.h"
#import "DisplayVideoViewController.h"
#import "RobotUtil.h"
#import "NewFileMsgCell.h"
#import "NotificationDefine.h"
#import "eCloudNotification.h"
#import "NewMyViewControllerOfCustomTableview.h"
#import "ConvRecord.h"
#import "RobotResponseModel.h"
#import "talkSessionUtil.h"
#import "StringUtil.h"
#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#endif

#import "UIAdapterUtil.h"
#import "GDataXMLNode.h"

#import "KxMenu.h"

#import "talkSessionViewController.h"

#import "LogUtil.h"

#import "RobotConn.h"

#import "RobotDAO.h"
#import "RobotMenu.h"
#import "RobotMenuParser.h"

#define ROBOT_ALL_KNOWLEDGE @"全部"

#define ROBOT_MENU_FREQUENT_QUESTION @"相关知识"
#define ROBOT_MENU_MANUAL_WORK @"人工服务"

@interface RobotDisplayUtil () <QLPreviewControllerDataSource,FGalleryViewControllerDelegate>

@property (nonatomic,retain) ConvRecord *previewRecord;
@end

static RobotDisplayUtil *_robotDisplayUtil;

@implementation RobotDisplayUtil
{
    
}
@synthesize selectRobotMenu;
@synthesize previewRecord;

+ (RobotDisplayUtil*)getUtil
{
    if (!_robotDisplayUtil) {
        _robotDisplayUtil = [[RobotDisplayUtil alloc]init];
    }
    return _robotDisplayUtil;
}

- (NSArray *)getMenuArray
{
    NSMutableArray *menuArray = [NSMutableArray array];
    RobotMenu *topRobotMenu = [[[RobotMenu alloc]init]autorelease];
    topRobotMenu.menuName = ROBOT_MENU_FREQUENT_QUESTION;
    [menuArray addObject:topRobotMenu];
    
    
    topRobotMenu = [[[RobotMenu alloc]init]autorelease];
    topRobotMenu.menuName = ROBOT_MENU_MANUAL_WORK;
    [menuArray addObject:topRobotMenu];
    
    return menuArray;
}

//给menuview设置一级菜单
- (void)setTopMenuForRobot:(IM_MenuView *)menuView
{
    NSArray *menuArray = [self getMenuArray];
    
    if (menuArray) {
        NSMutableArray *topMenuArray = [NSMutableArray array];
        for (RobotMenu *_menu in menuArray) {
            [topMenuArray addObject:_menu.menuName];
        }
        [menuView setBottomItems:topMenuArray];
    }
}
- (void)clickOrKeyAction:(NSInteger)ksel
{
    if (ksel == 0) {
        if ([self.selectRobotMenu.menuName isEqualToString:ROBOT_ALL_KNOWLEDGE]) {
            //            如果是全部 那么就发送相关知识
            [[talkSessionViewController getTalkSession]sendMsgToRobot:ROBOT_MENU_FREQUENT_QUESTION];
        }else{
            [[talkSessionViewController getTalkSession]sendMsgToRobot:[NSString stringWithFormat:@"%@%@",self.selectRobotMenu.menuName,ROBOT_MENU_FREQUENT_QUESTION]];
        }
    }else if (ksel == 1)
    {
        //        人工客服
        if ([self.selectRobotMenu.menuName isEqualToString:ROBOT_ALL_KNOWLEDGE]) {
            //            如果是全部 那么就发送相关知识
            [[talkSessionViewController getTalkSession]sendMsgToRobot:ROBOT_MENU_MANUAL_WORK];
        }else{
            [[talkSessionViewController getTalkSession]sendMsgToRobot:[NSString stringWithFormat:@"%@%@",self.selectRobotMenu.menuName,ROBOT_MENU_MANUAL_WORK]];
        }
    }
}
//{
//    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//
//    int i = 0;
//    for (RobotMenu *robotMenu in [talkSessionViewController getTalkSession].robotMenuArray) {
//        if (i == ksel) {
//            robotMenu.isSelected = YES;
//        }else{
//            robotMenu.isSelected = NO;
//        }
//        i++;
//    }
//}

- (NSArray *)upMenuItemsAtBottomIndex:(NSInteger)index
{
    return nil;
}
//{
//    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//
//    RobotMenu *topRobotMenu = [talkSessionViewController getTalkSession].robotMenuArray[index];
//
//    NSMutableArray *subMenuArray = [NSMutableArray array];
//
//    for (RobotMenu *_robotMenu in topRobotMenu.subMenu) {
//        [subMenuArray addObject:_robotMenu.menuName];
//    }
//    if (subMenuArray.count) {
//        [[talkSessionViewController getTalkSession]displayTableBackGroudButtonForHiddenSubMenu];
//    }
//    return subMenuArray;
//}

- (void)selectedUpMenuItemAtIndex:(NSInteger)upItemIndex bottomIndex:(NSInteger)bottomIndex
{
    
}
//{
//    [LogUtil debug:[NSString stringWithFormat:@"%s upItemIndex is %d bottomIndex is %d",__FUNCTION__,upItemIndex,bottomIndex]];
//
//    RobotMenu *topMenu = ([talkSessionViewController getTalkSession].robotMenuArray)[bottomIndex];
//    RobotMenu *subMenu = topMenu.subMenu[upItemIndex];
//
//    [LogUtil debug:[NSString stringWithFormat:@"%s upItemIndex is %@ bottomIndex is %@",__FUNCTION__,subMenu.menuName,topMenu.menuName]];
//}

#pragma mark ==========知识库===========

//获取知识库数组
- (NSArray *)getKnowledgeArray
{
    NSArray *menuArray = [RobotConn getConn].robotMenuArray;
    if (!menuArray) {
        NSString *menuString = [[RobotDAO getDatabase]getRobotMenu];
        if (menuString) {
            RobotMenuParser *_parser = [[RobotMenuParser alloc]init];
            [_parser parseRobotMenu:menuString];
            menuArray = _parser.menuArray;
        }
    }
    return menuArray;
}

//打开知识库 下拉菜单
- (void)openKnowledgeBase
{
    NSArray *kowledgeArray = [self getKnowledgeArray];
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    for (RobotMenu *topMenu in kowledgeArray) {
        KxMenuItem *menuItem = [KxMenuItem menuItem:topMenu.menuName
                                              image:nil
                                             target:self
                                             action:@selector(selectMenuItem:)];
        
        menuItem.infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:topMenu,@"knowledge_object", nil];
        [menuItems addObject:menuItem];
    }
    if (menuItems.count > 0) {
        [KxMenu showMenuInView:[talkSessionViewController getTalkSession].view fromRect:CGRectMake([talkSessionViewController getTalkSession].view.frame.size.width - 30, 0, 0, 0) menuItems:menuItems];
    }
}

// 用户选中某一个知识库的时候 给属性赋值
- (void)selectMenuItem:(KxMenuItem *)menuItem
{
    //    NSLog(@"%s menu title is %@",__FUNCTION__,menuItem.title);
    UIButton *_button = [UIAdapterUtil setRightButtonItemWithTitle:menuItem.title andTarget:[talkSessionViewController getTalkSession] andSelector:@selector(chatMessageAction:)];
    
    UIImageView *arrowsImg = [[UIImageView alloc] initWithImage:[StringUtil getImageByResName:@"knowledge_down52-32.png"]];
    arrowsImg.frame = CGRectMake(_button.frame.size.width - 21, 13, 15, 20);
    arrowsImg.tag = 501;
    [_button addSubview:arrowsImg];
    _button.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    
    
    RobotMenu *robotMenu = [menuItem.infoDictionary valueForKey:@"knowledge_object"];
    //    NSLog(@"%s menu title is %@ menu key is %@",__FUNCTION__,robotMenu.menuName,robotMenu.menuKey);
    
    self.selectRobotMenu = robotMenu;
    
    //    需要自动发送一条消息
    if ([selectRobotMenu.menuName isEqualToString:ROBOT_ALL_KNOWLEDGE]) {
        //        如果用户选择了 全部 那么 就什么都不发
        return;
    }
    //    发送 xxx相关知识
    [[talkSessionViewController getTalkSession]sendMsgToRobot:[NSString stringWithFormat:@"%@%@",robotMenu.menuName,ROBOT_MENU_FREQUENT_QUESTION]];
}

#define ELE_ROBOT_REQUEST @"robotRequest"
#define ELE_KEY @"key"
#define ELE_THEME @"theme"
#define ELE_VALUE @"value"
#define ELE_QUESTION @"question"

//根据消息内容返回格式化的消息 小万发出去的消息是xml
- (NSString *)formatMsg:(NSString *)msgBody
{
    if (self.selectRobotMenu.menuName.length > 0) {
        //    根节点
        GDataXMLElement *rootElement = [GDataXMLNode elementWithName:ELE_ROBOT_REQUEST];
        
        //    key 节点
        GDataXMLElement *keyElement = [GDataXMLNode elementWithName:ELE_KEY];
        
        //    key下的theme节点
        GDataXMLElement *themeElement = [GDataXMLNode elementWithName:ELE_THEME stringValue:self.selectRobotMenu.menuName];
        
        [keyElement addChild:themeElement];
        
        //    key下的value节点
        GDataXMLElement *valueElement = [GDataXMLNode elementWithName:ELE_VALUE stringValue:self.selectRobotMenu.menuKey];
        
        [keyElement addChild:valueElement];
        
        [rootElement addChild:keyElement];
        
        //    question节点
        GDataXMLElement *questionElement = [GDataXMLNode elementWithName:ELE_QUESTION stringValue:msgBody];
        
        [rootElement addChild:questionElement];
        
        GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc]initWithRootElement:rootElement];
        [xmlDoc setVersion:@"1.0"];
        [xmlDoc setCharacterEncoding:@"UTF-8"];
        
        NSData *data = xmlDoc.XMLData;
        
        NSString *xmlStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        return xmlStr;
    }
    return msgBody;
}

//根据选择的menu获取右侧按钮的title
- (NSString *)getRightBtnTitle
{
    NSString *btnTitle = [StringUtil getLocalizableString:@"chats_talksession_right_btn_title_of_irobot"];
    
    if (self.selectRobotMenu) {
        NSArray *kowledgeArray = [self getKnowledgeArray];
        if (kowledgeArray.count == 0) {
            return btnTitle;
        }else{
            if ([kowledgeArray indexOfObject:self.selectRobotMenu] == 0) {
                return btnTitle;
            }else{
                return self.selectRobotMenu.menuName;
            }
        }
    }
    return btnTitle;
}

//图文消息点击可以打开连接
- (void)addImgTxtViewGesture:(UITableViewCell *)cell
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImgTxtMsgUrl:)];
    UIView *view = [cell viewWithTag:new_imgtxt_parent_view_tag];
    [view addGestureRecognizer:tap];
    [tap release];
}

- (void)openImgTxtMsgUrl:(UIGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:[talkSessionViewController getTalkSession].chatTableView];
    NSIndexPath *indexPath = [[talkSessionViewController getTalkSession].chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[[talkSessionViewController getTalkSession] getIndexByIndexPath:indexPath]];
    if (_convRecord.isRobotImgTxtMsg) {
        NSDictionary *dic = _convRecord.robotModel.imgtxtArray[0];
        NSString *clickUrl = dic[@"Url"];
        [NewMyViewControllerOfCustomTableview openLongHuHtml5:clickUrl withController:[talkSessionViewController getTalkSession]];
    }
#ifdef _XINHUA_FLAG_
    else if (_convRecord.systemMsgModel)
    {
        [NewMyViewControllerOfCustomTableview openLongHuHtml5:_convRecord.systemMsgModel.urlStr withController:[talkSessionViewController getTalkSession]];
    }
#endif
}
//机器人的文件下载后，接收通知，处理界面
- (void)processDownloadRobotFile:(NSNotification *)notification
{
    eCloudNotification *notiObject = notification.object;
    
    if (notiObject) {
        ConvRecord *curConvRecord = [notiObject.info valueForKey:@"ConvRecord"];
        
        int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:curConvRecord.msgId];
        if(_index < 0)return;
        
        ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:_index];
        
#ifdef _XINHUA_FLAG_
        if (_convRecord.systemMsgModel)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[talkSessionViewController getTalkSession].chatTableView reloadData];
            });
            
            return;
        }
        
#endif
        
        
        if (curConvRecord) {
            switch (notiObject.cmdId) {
                case download_robot_file_complete:{
                    if (_convRecord.isRobotImgTxtMsg) {
                        [[talkSessionViewController getTalkSession].chatTableView reloadData];
                    }else if (_convRecord.isRobotFileMsg){
                        
                        int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:_convRecord.msgId];
                        
                        if(_index < 0)
                        {
//                            用户已经不在机器人界面
                        }else{
                            _convRecord.isDownLoading = false;
                            _convRecord.downloadRequest = nil;
                            
                            UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:[[talkSessionViewController getTalkSession] getIndexPathByIndex:_index]];
                            
                            UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                            [spinner stopAnimating];
                            
                            _convRecord.download_flag = state_download_success;
                            
                            _convRecord.isFileExists = YES;
                            [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
                        }
                    }else if (_convRecord.isRobotPicMsg){
                        [[talkSessionViewController getTalkSession].chatTableView reloadData];
                    }
                }
                    break;
                case download_robot_file_fail:{
                    
                    int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:_convRecord.msgId];
                    
                    if(_index < 0)
                    {
                        //                            用户已经不在机器人界面
                    }else{
                        _convRecord.isDownLoading = false;
                        _convRecord.downloadRequest = nil;
                        
                        UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:[[talkSessionViewController getTalkSession] getIndexPathByIndex:_index]];
                        
                        UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                        [spinner stopAnimating];
                        
                        _convRecord.download_flag = state_download_failure;
                        
                        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];

                    }

                }
                    break;
                default:
                    break;
            }
            
        }
    }
}

- (NewFileMsgCell *)getNewFileMsgCell{
    static NSString *fileMsgCellID = @"fileMsgCellID";
    NewFileMsgCell *cell = [[talkSessionViewController getTalkSession].chatTableView dequeueReusableCellWithIdentifier:fileMsgCellID];
    if (cell == nil) {
        cell = [[[NewFileMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileMsgCellID]autorelease];
        //                增加文件消息点击事件
        [[talkSessionViewController getTalkSession] addGestureToFile:cell];
        //断点续传
        [[talkSessionViewController getTalkSession] addGestureToStopFileDownload:cell];
        [[talkSessionViewController getTalkSession] addCommonGesture:cell];
    }

    return cell;
}

- (void)onClickRobotFile:(ConvRecord*)_convRecord{
    NSString *robotFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    if ([[NSFileManager defaultManager]fileExistsAtPath:robotFilePath]) {

        if (_convRecord.robotModel.msgType == type_video) {
            [self playVideo:robotFilePath andCurVc:[talkSessionViewController getTalkSession]];
        }else if (_convRecord.robotModel.msgType == type_record){
            [self playMusic:_convRecord.robotModel.msgFileName andFilePath:robotFilePath andConvRecord:_convRecord andCurVC:[talkSessionViewController getTalkSession]];
        }else{
            self.previewRecord = _convRecord;
            [self openNormalFile:self andCurVC:[talkSessionViewController getTalkSession]];
        }
    
    }else{
//        检查是否已经在下载？
        if (!_convRecord.isDownLoading) {
            [[RobotFileUtil getUtil]downloadRobotFile1:_convRecord];
        }
    }
}
#pragma mark =======封装了 播放视频文件 播放音乐文件 打开普通文件的方法==========
- (void)playVideo:(NSString *)videoPath andCurVc:(UIViewController *)curVc
{
    DisplayVideoViewController *videoCtrl = [[DisplayVideoViewController alloc]init];
    videoCtrl.message = videoPath;
    [[talkSessionViewController getTalkSession].navigationController pushViewController:videoCtrl animated:YES];
    [videoCtrl release];
}

- (void)playMusic:(NSString *)fileName andFilePath:(NSString *)filePath andConvRecord:(ConvRecord *)_convRecord andCurVC:(UIViewController *)curVC{
    AudioViewController *audioVC = [[AudioViewController alloc] init];
    audioVC.fileName = fileName;
    audioVC.filePath = filePath;
    audioVC.convRecord = _convRecord;
    curVC.navigationItem.hidesBackButton = YES;
    [curVC.navigationController pushViewController:audioVC animated:YES];
    [audioVC release];
}
- (void)openNormalFile:(id)fileDelegate andCurVC:(UIViewController *)curVC{
    curVC.title = nil;
    QLPreviewController* previewController = [[CustomQLPreviewController alloc] init];
    previewController.dataSource=fileDelegate;
    [curVC.navigationController setToolbarHidden:YES];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7)
    {
        [curVC presentModalViewController:previewController animated:YES];
    }
    else
    {
        [curVC.navigationController pushViewController:previewController animated:YES];
    }
    [previewController release];
}

#pragma mark =====QLPreviewController delegate=======
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return [[NSNumber numberWithInt:1]integerValue];
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    FileRecord *_fileRecord = [[FileRecord alloc]init];
    _fileRecord.convRecord = self.previewRecord;
    return [_fileRecord autorelease];
}

- (PicMsgCell *)getPicMsgCell{
    static NSString *picMsgCellID = @"picMsgCellID";
    PicMsgCell *cell = [[talkSessionViewController getTalkSession].chatTableView dequeueReusableCellWithIdentifier:picMsgCellID];
    if (cell == nil) {
        cell = [[[PicMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:picMsgCellID]autorelease];
        //                增加图片消息点击事件
        [[talkSessionViewController getTalkSession] addSingleTapToPicViewOfCell:cell];
        [[talkSessionViewController getTalkSession] addCommonGesture:cell];
    }
    return cell;
}

- (void)onClickRobotImage:(ConvRecord *)_convRecord{
    
    NSString *picPath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    if ([[NSFileManager defaultManager]fileExistsAtPath:picPath]) {
        
        self.previewRecord = _convRecord;
        
        FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
        [[talkSessionViewController getTalkSession].navigationController pushViewController:localGallery animated:YES];
        [localGallery release];
    }
}


#pragma mark - FGalleryViewControllerDelegate Methods
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    return self.previewRecord.robotModel.argsArray[0];
}
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [RobotUtil getDownloadFilePathWithConvRecord:self.previewRecord];
}


@end
