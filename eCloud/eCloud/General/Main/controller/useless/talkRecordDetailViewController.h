//
//  talkRecordDetailViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import <AVFoundation/AVFoundation.h>
#import "FGalleryViewController.h"
#import "amrToWavMothod.h"

@class ConvRecord;
@class Conversation;

@class UserInfo;
@class conn;
@class AudioPlayForIOS6;
@interface talkRecordDetailViewController : UIViewController<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,FGalleryViewControllerDelegate>
{
	UITableView*  talkTable;
	
	NSString* _convId;
	NSString* _convName;
	int _convType;
	
	int totalCount;//总记录数
	int curPage;//当前页
	int totalPage;//总页数

	 BOOL isWifi;
     conn *_conn;
	 ASINetworkQueue *networkQueue;
     UIImageView *audioImageview;
	
     AVAudioPlayer* audioPlayer;
     amrToWavMothod *amrtowav;
    int watchPreImageTag;
    NSString *nameStrPart;
	
	NSString *copyTextStr;
    NSString *copyMsg_id;
    int copyRow;
    int copyType;//0-text 1-pic 2-aduio
     AudioPlayForIOS6 *audioplayios6;
    UserInfo *uinfo;
    BOOL isVirGroup;
	
	//	收到的和发送的声音的播放动画
	UIImageView *sendVoicePlayView;
	UIImageView *rcvVoicePlayView;

    //预览图片
    FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
    NSString *preImageFullPath;
}
@property(nonatomic,retain)  NSString *preImageFullPath;
//add by shisp 记录录音是否是暂停播放，主要用于判断是否连续播放录音
@property(nonatomic,assign)bool isAudioPause;
@property(nonatomic,retain)NSString *curRecordPath;

@property  BOOL isVirGroup;
@property(nonatomic,retain) Conversation *conv;
@property(nonatomic,retain) NSString* convId;
@property(nonatomic,retain) NSString* convName;
@property(nonatomic,assign) int convType;
@property(nonatomic,retain) NSMutableArray *itemArray;

//复制或删除消息
@property(nonatomic,retain)NSString *editMsgId;
//复制或删除对应的消息记录
@property(nonatomic,retain)ConvRecord *editRecord;
//编辑的记录的行号
@property(nonatomic,assign)int editRow;
//操作类型，如果是删除，那么就不用恢复原来的显示
@property(nonatomic,assign)bool isDeleteAction;


- (UIView *)picView:(NSData *)imagedata progress:(UIProgressView *)progressCell from:(BOOL)fromType path:(NSString *)picPath record:(ConvRecord *)recordObject;
@end
