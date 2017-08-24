//
//  LocaLFilesViewController.h
//  QuickLookDemo
//
//  Created by Pain on 14-4-10.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
@protocol LocaLFilesViewControllerDelegate;

@interface LocaLFilesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate,UIAlertViewDelegate>
{
	UITableView *readTable;
    UIButton *sendeBtn;
    UILabel *sendLab;
    NSObject <LocaLFilesViewControllerDelegate> *_locaLFilesDelegate;
    NSMutableArray *delectedArr;
    NSInteger allFileSize;
}

@property (nonatomic,assign) NSObject <LocaLFilesViewControllerDelegate> *locaLFilesDelegate;

@end

@protocol LocaLFilesViewControllerDelegate

@optional

- (void)locaLFilesViewControllerClickOnBackBtn:(LocaLFilesViewController*)localFilesCtr withSelectFiles:(NSMutableArray *)filesArr;//返回刷新会话列表

@end