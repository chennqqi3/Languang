//
//  KapokHistoryViewController.h
//  eCloud
//
//  Created by  lyong on 14-5-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
@class kapokUploadEventObject;
#define num_kapok_uploadevent 5
@interface KapokHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *dataArray;
    NSMutableArray *readyArray;
    UITableView*   kapokUploadTable;
    
    UIActivityIndicatorView *loadingIndic;
	bool isLoading;
    UIActivityIndicatorView *tabelIndicator;
    //	查询会话时用到的参数
	int limit;
	int offset;
   
    int totalCount;//总记录数
	int curPage;//当前页
	int totalPage;//总页数
    int loadCount;
    
    UILabel *tipLabel;
    ASINetworkQueue *networkQueueForImage;
    UIWebView *webView;
    kapokUploadEventObject *kapokObjectForUploading;
    UILabel *NoPhotoTipLabel;
    BOOL is_susucess_upload;
}
@property(nonatomic,retain)NSMutableArray *dataArray;
@property(nonatomic,retain) NSMutableArray *readyArray;

@end
