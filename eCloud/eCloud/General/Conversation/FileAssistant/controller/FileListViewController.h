//
//  FileAssistantViewController.h
//  eCloud
//  聊天界面-选择文件界面
//  Created by Pain on 15-1-5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FileListViewControllerDelegate;

@interface FileListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
}
/** 搜索结果 */
@property (nonatomic,retain)NSMutableArray *searchResults;

/** 选择结果 */
@property (nonatomic,retain)NSMutableArray *chooseResults;

/** 用户输入的查询条件 */
@property (nonatomic,retain) NSString *searchStr;

/** 来自哪个Controller */
@property (nonatomic,retain) NSString *fromCtrl;

/** delegate */
@property (assign) NSObject <FileListViewControllerDelegate> *locaLFilesDelegate;
@end

@protocol FileListViewControllerDelegate

@optional
/** 用户选择了文件后，告诉调用的viewcontroller */
- (void)fileListViewControllerClickOnBackBtn:(FileListViewController*)localFilesCtr withSelectFiles:(NSMutableArray *)filesArr;

@end
