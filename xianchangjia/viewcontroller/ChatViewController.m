//
//  ChatViewController.m
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "ChatViewController.h"
#import "Extend.h"
#import "MLTextView.h"
#import "XCAlbumAdditions.h"
#import "XCJChatMessageCell.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#import "Conversation.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "Sequencer.h"
#import "FCMessage.h"
#import "FCUserDescription.h"
#import "LXRequestFacebookManager.h"
#import "CoreData+MagicalRecord.h"
#import "MessageList.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import "XCJSendMapViewController.h"
#import "FDStatusBarNotifierView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FCHomeGroupMsg.h"
#import "FacialView.h"
#import "XCJChatSendImgViewController.h"
#import "XCJChatSendInfoView.h"
#import "XCJWholeNaviController.h"
#import "UIImage+WebP.h"
#import "UIButton+Bootstrap.h"
#import "RemoteImgListOperator.h"
#import "ChatVoiceRecorderVC.h"
#import "VoiceConverter.h"
#import "EGOCache.h"
#import "UIImage+Resize.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"
#import "NSString+Addition.h"
#import "YQUserOrdersViewConsoller.h"
#import "SJAvatarBrowser.h"
#import "JDStatusBarNotification.h"

#import <OHAttributedLabel/OHAttributedLabel.h>
#import <OHAttributedLabel/NSAttributedString+Attributes.h>
#import <OHAttributedLabel/OHASBasicMarkupParser.h>

#import "UIActionSheet+Blocks.h"
#import "RIButtonItem.h"
//#warning like iMesage will dismiss the keyboard
#import "UIViewController+TAPKeyboardPop.h"

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "SCNavigationController.h"



#define kMarginTop 29.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f

#define  keyboardHeight 216
#define  facialViewWidth 300
#define facialViewHeight 180
#define  audioLengthDefine  1050
static NSInteger const kAttributedLabelTag = 100;

@interface ChatViewController () <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate,XCJChatSendImgViewControllerdelegate,UIScrollViewDelegate,facialViewDelegate,XCJChatSendInfoViewDelegate,VoiceRecorderBaseVCDelegate,OHAttributedLabelDelegate,ZBMessageInputViewDelegate,ZBMessageShareMenuViewDelegate,ZBMessageManagerFaceViewDelegate,SCNavigationControllerDelegate>
{
    AFHTTPRequestOperation *  operation;
    NSString * TokenAPP;
    UIImage * ImageFile;
    NSString * PasteboardStr;
    NSArray * userArray;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    UIView  * EmjView;
    XCJChatSendInfoView *SendInfoView;
    NSURL * playingURL;
    XCJChatMessageCell * playingCell;
    
    NSString * CurrentUrl;
    BOOL _loading;
    BOOL AllLoad;
    BOOL AllDBdatabaseLoad;
    NSInteger _currentPage;
    
    /*!
     *  input method about...
     */
    double animationDuration;
    CGRect keyboardRect;
    UIViewAnimationCurve curve_keyboard;
    UIImage * currentImage;
}

@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) UIView *keyboardView;
@property (strong,nonatomic) NSMutableArray *messageList;
@property (nonatomic, readonly) RemoteImgListOperator *m_objImgListOper;
@property (weak, nonatomic) IBOutlet UILabel *label_titleToast;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityindret;


@property (retain, nonatomic)  ChatVoiceRecorderVC      *recorderVC;

@property (retain, nonatomic)   AVAudioPlayer           *player;

@property (copy, nonatomic)     NSString                *originWav;         //原wav文件名

@property (copy, nonatomic)     NSString                *convertAmr;        //转换后的amr文件

@end

@implementation ChatViewController
@synthesize m_objImgListOper = _objImgListOper;
@synthesize recorderVC,player,originWav,convertAmr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initilzer];
    
    [self.navigationController ios6backview];
    
    [[OHAttributedLabel appearance] setLinkColor:ios7BlueColor];
    [[OHAttributedLabel appearance] setHighlightedLinkColor:[UIColor colorWithWhite:0.4 alpha:0.3]];
    [[OHAttributedLabel appearance] setLinkUnderlineStyle:kCTUnderlineStyleNone];
    
    self.tableView.backgroundColor = [UIColor colorWithHex:0xffefefef];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    self.messageList = array;
    
    /*
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    
    UIButton * buttonChangeAudio = (UIButton *) [self.inputContainerView subviewWithTag:7];
    [buttonChangeAudio addTarget:self action:@selector(SHowAudioButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    
    {
        UIButton * buttonAudioss = (UIButton *) [self.inputContainerView subviewWithTag:9];
        //添加长按手势
        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] init];
        [gr addTarget:self action:@selector(recordBtnLongPressed:)];
        gr.minimumPressDuration = 0.15;
        [buttonAudioss addGestureRecognizer:gr];
    }
    
    UIButton * buttonAudio8 = (UIButton *) [self.inputContainerView subviewWithTag:8];
    
    [buttonAudio8 addTarget:self action:@selector(ShowkeyboardButtonClick:) forControlEvents:UIControlEventTouchUpInside ];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.inputContainerView.top = APP_SCREEN_CONTENT_HEIGHT - self.inputContainerView.height-44;
        
        UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:[UIImage imageNamed:@"itemIcon_order"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(SeeUserOrdersClick:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setFrame:CGRectMake(0, 0, 44, 44)];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    }else{
        
        self.inputContainerView.top = self.view.height - self.inputContainerView.height;
        self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
    }
    */
    
    _objImgListOper = [[RemoteImgListOperator alloc] init];
    
    self.title = [DataHelper getStringValue:self.conversation.facebookName defaultValue:@"未知"];
    
    /**
     *  init _data
     */
    _currentPage = 0;
    [self setUpSequencer];
    
    FCMessage * msg =   [self.messageList firstObject];
    if (msg == nil) {
        [self initchatdata:nil];
    }
    
    if ([self.conversation.badgeNumber intValue] > 0) {
        self.conversation.badgeNumber = @(0);
        [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
        
        if (msg) {
            [self fetchNewDataWithLastID];
        }
        //  [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMessageTabBarItemBadge" object:nil];
        double delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // update mesage status
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            [dic setValue:self.conversation.facebookId forKey:@"weChatId"];
            [dic setValue:@"unread" forKey:@"state"];
            [dic setValue:@"read" forKey:@"afterState"];
            [[DAHttpClient sharedDAHttpClient] postRequestWithParameters:dic Action:@"AdminApi/WeChat/UpdateState" success:^(id obj) {
            } error:^(NSInteger index) {
            }];
        });
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refershTableView:) name:NSNotificationCenter_RefreshChatTableView object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChatViewSendPhotoSure:) name:@"ChatViewSendPhotoSure" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNewDataWithLastID) name:@"NotifyBacktoForceView" object:nil];
    
    
}

#pragma mark - 初始化
- (void)initilzer{
    
    animationDuration = 0.25;
    
    CGFloat inputViewHeight = 44.0f;
    
    /*
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7) {
        inputViewHeight = 45.0f;
    }
    else{
        inputViewHeight = 40.0f;
    }*/
    
    ZBMessageInputView * inputView = [[ZBMessageInputView alloc] initWithFrame:CGRectMake(0.0f,
                                                                               self.view.frame.size.height - inputViewHeight,self.view.frame.size.width,inputViewHeight)];
    [inputView setup];
    self.messageToolView = inputView;    
    self.messageToolView.delegate = self;
    [self.view addSubview:self.messageToolView];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        self.messageToolView.top = APP_SCREEN_CONTENT_HEIGHT - self.messageToolView.height-44;
    }else{
        self.messageToolView.top = self.view.height - self.messageToolView.height;
    }
    
    [self shareFaceView];
    [self shareShareMeun];
    
}

- (void)shareFaceView{
    
    if (!self.faceView)
    {
        self.faceView = [[ZBMessageManagerFaceView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                  CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 196)];
        self.faceView.delegate = self;
        [self.view addSubview:self.faceView];
        
    }
}

- (void)shareShareMeun
{
    if (!self.shareMenuView)
    {
        self.shareMenuView = [[ZBMessageShareMenuView alloc]initWithFrame:CGRectMake(0.0f,
                                                                                     CGRectGetHeight(self.view.frame),
                                                                                     CGRectGetWidth(self.view.frame), 196)];
        [self.view addSubview:self.shareMenuView];
        self.shareMenuView.delegate = self;
        
        ZBMessageShareMenuItem *sharePicItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_pic_ios7"]
                                                                                                title:@"照片"];
        ZBMessageShareMenuItem *shareVideoItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_video_ios7"]
                                                                                                  title:@"拍摄"];
//        ZBMessageShareMenuItem *shareLocItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_location_ios7"]
//                                                                                                title:@"位置"];
//        ZBMessageShareMenuItem *shareVoipItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_videovoip"]       title:@"视频聊天"];
        self.shareMenuView.shareMenuItems = [NSArray arrayWithObjects:sharePicItem,shareVideoItem, nil];
        [self.shareMenuView reloadData];
        
    }
}
#pragma mark - ZBMessageInputView Delegate
- (void)didSelectedMultipleMediaAction:(BOOL)changed{
    
    if (changed)
    {
        [self messageViewAnimationWithMessageRect:self.shareMenuView.frame
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowShare];
    }
    else{
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
    
}

- (void)didSendFaceAction:(BOOL)sendFace{
    if (sendFace) {
        [self messageViewAnimationWithMessageRect:self.faceView.frame
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowFace];
    }
    else{
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

- (void)didChangeSendVoiceAction:(BOOL)changed{
    if (changed){
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}

/*
 * 点击输入框代理方法
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView{
    
}

- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:self.messageToolView.frame
                                  andDuration:animationDuration
                                     andState:ZBMessageViewStateShowNone];
    
    if (!self.previousTextViewContentHeight)
    {
        self.previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}

- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [ZBMessageInputView maxHeight];
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if(changeInHeight != 0.0f) {
        
        [UIView animateWithDuration:0.01f
                         animations:^{
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageToolView.frame;
                             self.messageToolView.frame = CGRectMake(0.0f,
                                                                     inputViewFrame.origin.y - changeInHeight,
                                                                     inputViewFrame.size.width,
                                                                     inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}
/*
 * 发送信息
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView{
    if (messageInputTextView.text.length > 0) {
        [self sendtextMessage:messageInputTextView.text];
        [messageInputTextView setText:nil];
        [self inputTextViewDidChange:messageInputTextView];
    }
    
}


/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction
{
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    SLog(@"recordBtnLongPressedss..");
    [self speakClick:nil];
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction
{

}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction
{
    
}
#pragma end

#pragma mark - ZBMessageFaceViewDelegate
- (void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    NSString * text  = self.messageToolView.messageInputTextView.text;
  
    if(dele)
    {
        if(text.length > 0)
        {
            self.messageToolView.messageInputTextView.text = [text substringToIndex:(text.length - 1)];
        }
        
    }else{
        self.messageToolView.messageInputTextView.text = [text stringByAppendingString:faceStr];
    }
    
    [self inputTextViewDidChange:self.messageToolView.messageInputTextView];
    
}

#pragma end

#pragma mark - ZBMessageShareMenuView Delegate
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    SLog(@" index %d",index);
    switch (index) {
        case 0:
            [self choseFromGalleryClick];
            break;
        case 1:
            [self takePhotoClick];
            break;
            
        default:
            break;
    }
}
#pragma end

-(void) refershTableView :(NSNotification * ) notify
{
    if (notify) {
        
        FCMessage* msg =  notify.object;
        if ([msg.wechatid isEqualToString:self.conversation.facebookId]) { //是否是当前会话
            [self.messageList addObject:notify.object];
            [self insertTableRow];
            /*!
             *  清空首页未读消息条数
             */
            self.conversation.badgeNumber = @(0);
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
        }
    }
}

/*!
 *  openurl跳转打开云起亲亲刷新数据问题
 */
- (void) fetchNewDataWithLastID
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.conversation.facebookId forKey:@"weChatId"];
    FCMessage* msg = [self.messageList lastObject];
    [params setValue:msg.messageId forKey:@"messageId"];
    [params setValue:@(30) forKey:@"max"];
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/WeChat/ThreadLatestMessages" success:^(id response) {
        if (response && [DataHelper getIntegerValue:response[@"code"] defaultValue:0] == 200) {
            NSArray * dataarray = response[@"data"];
            if (dataarray && dataarray.count > 0) {
                NSArray * arraySort = [[dataarray reverseObjectEnumerator] allObjects];
                [arraySort enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if(obj )
                    {
                        /*
                         check message id can insert???
                         */
                        NSString * messageidNew = [DataHelper getStringValue:obj[@"messageId"] defaultValue:@""];
                        FCMessage * msgOld =  [[FCMessage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"messageId == %@",messageidNew]] firstObject];
                        if (!msgOld ) {//|| [messageidNew isEqualToString:@""]
                            
                            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                            NSString * date = [DataHelper getStringValue:obj[@"time"] defaultValue:@""];
                            NSDictionary * messageDict = obj[@"message"];
                            NSString * typeMessage = [DataHelper getStringValue:messageDict[@"msgType"] defaultValue:@""];
                            NSString * content = [DataHelper getStringValue:messageDict[@"content"] defaultValue:@""];
                            NSString * to = [DataHelper getStringValue:obj[@"to"] defaultValue:@""];
                            NSString * from = [DataHelper getStringValue:obj[@"from"] defaultValue:@""];
                            FCMessage* msg = [FCMessage MR_createInContext:localContext];
                            if ([content isNilOrEmpty]) {
                                content = @"";
                            }
                            SLog(@"content :%@",content);
                            msg.text = content;
                            msg.sentDate = [tools datebyStr:date];
                            msg.wechatid = self.conversation.facebookId; // proment
                            msg.messageId = messageidNew;
                            if ([typeMessage isEqualToString:@"text"]) {
                                msg.messageType = @(messageType_text);
                            }else if ([typeMessage isEqualToString:@"image"]) {
                                //image
                                msg.messageType = @(messageType_image);
                                NSString * publicUrl = [DataHelper getStringValue:messageDict[@"mediaPath"] defaultValue:@""];
                                msg.imageUrl = publicUrl;
                            }else if ([typeMessage isEqualToString:@"voice"]) {
                                //audio
                                NSString * publicUrl = [DataHelper getStringValue:messageDict[@"mediaPath"] defaultValue:@""];
                                msg.audioUrl = publicUrl;
                                msg.messageType = @(messageType_audio);
                                int length  = 10;//
                                msg.audioLength = @(length/audioLengthDefine);
                            }else{
                                msg.messageType = @(messageType_text);
                                
                            }
                            
                            if ([from isEqualToString:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_name]] && [to isEqualToString:self.conversation.facebookId]) {
                                // me
                                // message did come, this will be on right
                                msg.messageStatus = @(NO);
                            }else{
                                //other
                                // message did come, this will be on left
                                msg.messageStatus = @(YES);
                            }
                            [self.conversation addMessagesObject:msg];
                            [localContext MR_saveToPersistentStoreAndWait];// MR_saveOnlySelfAndWait];
                            [self.messageList addObject:msg];
                        }
                        
                        
                    } 
                }];
                [self.tableView reloadData];
                
                [self scrollToBottonWithAnimation:YES];
            }
            
        }
    } error:^(NSInteger index) {
        
    }];
    
}


-(void) initchatdata:(NSString * ) messageId
{
    [self viewdidloading];
    _loading = YES;
    /*get history message*/
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.conversation.facebookId forKey:@"weChatId"];
    [params setValue:@(20) forKey:@"max"];
    if (messageId && messageId.length > 0) {
        [params setValue:messageId forKey:@"messageId"];
    }

    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/WeChat/Thead" success:^(id response) {
        if (response && [DataHelper getIntegerValue:response[@"code"] defaultValue:0] == 200) {
            NSArray * dataarray = response[@"data"];
            [dataarray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if(obj )
                {
                    /*
                     check message id can insert???
                     */
                    NSString * messageidNew = [DataHelper getStringValue:obj[@"messageId"] defaultValue:@""];
                    FCMessage * msgOld =  [[FCMessage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"messageId == %@",messageidNew]] firstObject];
                    if (!msgOld) {// || [messageidNew isEqualToString:@""]
                        
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        NSString * date = [DataHelper getStringValue:obj[@"time"] defaultValue:@""];
                        NSDictionary * messageDict = obj[@"message"];
                        NSString * typeMessage = [DataHelper getStringValue:messageDict[@"msgType"] defaultValue:@""];
                        NSString * content = [DataHelper getStringValue:messageDict[@"content"] defaultValue:@""];
                        NSString * to = [DataHelper getStringValue:obj[@"to"] defaultValue:@""];
                        NSString * from = [DataHelper getStringValue:obj[@"from"] defaultValue:@""];
                        FCMessage* msg = [FCMessage MR_createInContext:localContext];
                        if ([content isNilOrEmpty]) {
                            content = @"";
                        }
                        SLog(@"content :%@",content);
                        msg.text = content;
                        msg.sentDate = [tools datebyStr:date];
                        msg.wechatid = self.conversation.facebookId; // proment
                        msg.messageId = messageidNew;
                        if ([typeMessage isEqualToString:@"text"]) {
                            msg.messageType = @(messageType_text);
                        }else if ([typeMessage isEqualToString:@"image"]) {
                            //image
                            msg.messageType = @(messageType_image);
                            NSString * publicUrl = [DataHelper getStringValue:messageDict[@"mediaPath"] defaultValue:@""];
                            msg.imageUrl = publicUrl;
                        }else if ([typeMessage isEqualToString:@"voice"]) {
                            //audio
                            NSString * publicUrl = [DataHelper getStringValue:messageDict[@"mediaPath"] defaultValue:@""];
                            msg.audioUrl = publicUrl;
                            msg.messageType = @(messageType_audio);
                            int length  = 10;//
                            msg.audioLength = @(length/audioLengthDefine);
                        }else{
                            msg.messageType = @(messageType_text);
                        }
                        
                        if ([from isEqualToString:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_name]] && [to isEqualToString:self.conversation.facebookId]) {
                            // me
                            // message did come, this will be on right
                            msg.messageStatus = @(NO);
                        }else{
                            //other
                            // message did come, this will be on left
                            msg.messageStatus = @(YES);
                        }
                        [self.conversation addMessagesObject:msg];
                        [localContext MR_saveToPersistentStoreAndWait];// MR_saveOnlySelfAndWait];
//                        [self.messageList insertObject:msg atIndex:0];
                        [self.messageList addObject:msg];
                    }else{
                        [self.messageList insertObject:msgOld atIndex:0];
                    }
                }
                
            }];
            
            if (dataarray.count == 20) {
                AllLoad = NO;
            }else{
                AllLoad = YES;
                [self viewdidloadedComplete];
            }
            _loading = NO;
            
            if (messageId && messageId.length > 0) {
                CGSize sizePre = self.tableView.contentSize;
                [self.tableView reloadData];
                CGSize sizeNew = self.tableView.contentSize;
                
                [self.tableView setContentOffset:CGPointMake(0,  sizeNew.height - sizePre.height-63) animated:NO];
            }else{
                
                [self.tableView reloadData];
                [self scrollToBottonWithAnimation:NO];
            }
        }else{
            AllLoad = NO;
            [self viewdidloadedComplete];
        }
        
    } error:^(NSInteger index) {
        [self.view hideIndicatorViewBlueOrGary];
        _loading = NO;
        SLog(@" error :%d ",index);
    }];
}

/**
 * see user orders
 *  @param sender <#sender description#>
 */
-(IBAction)SeeUserOrdersClick:(id)sender
{    
    YQUserOrdersViewConsoller * orders = [self.storyboard instantiateViewControllerWithIdentifier:@"YQUserOrdersViewConsoller"];
    orders.wechatId = self.conversation.facebookId;
    orders.title = [NSString stringWithFormat:@"%@的订单",self.conversation.facebookName];
    [self.navigationController pushViewController:orders animated:YES];
    
}

-(IBAction)ShowkeyboardButtonClick:(id)sender
{
    ( (UIButton *) [self.inputContainerView subviewWithTag:8]).hidden = YES;
    ( (UIButton *) [self.inputContainerView subviewWithTag:7]).hidden = NO;
    ((UIButton *) [self.inputContainerView subviewWithTag:9]).hidden = YES;
    [self.inputTextView becomeFirstResponder];
    
}
-(IBAction)SHowAudioButtonClick:(id)sender
{
    ( (UIButton *) [self.inputContainerView subviewWithTag:9]).hidden = NO;
    ( (UIButton *) [self.inputContainerView subviewWithTag:8]).hidden = NO;
    ( (UIButton *) [self.inputContainerView subviewWithTag:7]).hidden = YES;
    [self.inputTextView resignFirstResponder];
}

#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    SLog(@"录音完成，文件路径:%@",_filePath);
    
    if (originWav.length > 0){
        self.convertAmr = [originWav stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"]];
        NSString * strAMRName = [VoiceRecorderBaseVC getPathByFileName:convertAmr  ofType:@"amr"];
        if (strAMRName.length > 0) {
            // send amr
            SLog(@"amr : %@",strAMRName);
            UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
//            [buttonAudio setTitle:@"按住开始" forState:UIControlStateNormal];
//            [buttonAudio sendMessageWhiteStyle];
            [buttonAudio setBackgroundImage:[UIImage imageNamed:@"yunqi_按住说话"] forState:UIControlStateNormal];
            //2.audio   3.video
            [self SendMediaSource:strAMRName withType:2];
        }
    }
}

-(void) SendMediaSource:(NSString *) filePath  withType:(NSInteger ) type
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = @"";
    msg.wechatid = self.conversation.facebookId;
    msg.messageSendStatus = @(4); // ready to send
    msg.messageguid = [self getMD4HashWithObj];
    msg.sentDate = [NSDate date];
    msg.messageType = @(messageType_audio);
    msg.audioUrl = filePath;
    int leg = [self getFileSize:filePath];
    msg.audioLength = @(leg/audioLengthDefine);
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageId = [self getMD4HashWithObj];
    self.conversation.lastMessage = @"[语音]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [self.messageList addObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self insertTableRow];
    
    return;
    NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
    if(token.length > 0){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        FCMessage *msg = [FCMessage MR_createInContext:localContext];
        msg.text = @"";
        msg.messageSendStatus = @(4); // ready to send
        msg.messageguid = [self getMD4HashWithObj];
        msg.sentDate = [NSDate date];
        msg.messageType = @(messageType_audio);
        msg.audioUrl = filePath;
        int leg = [self getFileSize:filePath];
        msg.audioLength = @(leg/audioLengthDefine);
        // message did not come, this will be on rigth
        msg.messageStatus = @(NO);
        msg.messageId =  @"";
        self.conversation.lastMessage = @"[语音]";
        self.conversation.lastMessageDate = [NSDate date];
        self.conversation.badgeNumber = @0;
        self.conversation.messageStutes = @(messageStutes_outcoming);
        [self.conversation addMessagesObject:msg];
        [self.messageList addObject:msg];
        [localContext MR_saveToPersistentStoreAndWait];
        [self insertTableRow];
    }else{
        // token has 1 hour expire
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
            if (response) {
                NSString * token =  response[@"token"];
                [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = @"";
                msg.messageSendStatus = @(4); // ready to send
                msg.messageguid = [self getMD4HashWithObj];
                msg.sentDate = [NSDate date];
                msg.messageType = @(messageType_audio);
                msg.audioUrl = filePath;
                // message did not come, this will be on rigth
                msg.messageStatus = @(NO);
                msg.messageId =  @"";
                self.conversation.lastMessage = @"[语音]";
                self.conversation.lastMessageDate = [NSDate date];
                self.conversation.badgeNumber = @0;
                self.conversation.messageStutes = @(messageStutes_outcoming);
                [self.conversation addMessagesObject:msg];
                [self.messageList addObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
                [self insertTableRow];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",@"Message",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
    return;
    
     //2.audio   3.video
    NSString * postType;
    if (self.gid.length > 0) {
        postType = @"Post";
    }else{
        postType = @"Message";
        
    }
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id responsessssss, NSError *error) {
        if (responsessssss) {
            NSString * token =  responsessssss[@"token"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
            [parameters setValue:token forKey:@"token"];
            [parameters setValue:[NSString stringWithFormat:@"%d",type] forKey:@"x:filetype"];
            [parameters setValue:@"" forKey:@"x:content"];
            
            [parameters setValue:@([self getFileSize:filePath]) forKey:@"x:length"];
            [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
            __block NSData * PCMData;
            operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"audio/amr-wb" error:nil ];
                PCMData = [NSData dataWithContentsOfFile:filePath];
                if (PCMData) {
                    [formData appendPartWithFileData:PCMData name:@"file" fileName:@"file" mimeType:@"audio/amr-wb"]; //录音
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
                SLLog(@"responseObject %@",responseObject);
                if (responseObject) {
                    NSDictionary * result =  responseObject[@"result"];
                    if (result) {
                        
                            // update lastmessage id index
                            NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                            
                            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                            if (messageIndex < indexMsgID) {
                                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                [USER_DEFAULT synchronize];
                            }
                            NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                            NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                          //  [self SendImageWithMeImageurl:url withMsgID:msgID];
                        
                        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        FCMessage *msg = [FCMessage MR_createInContext:localContext];
                        msg.text = @"";
                        msg.sentDate = [NSDate date];
                        msg.messageType = @(messageType_audio);
                        msg.audioUrl = url;
                        // message did not come, this will be on rigth
                        msg.messageStatus = @(NO);
                        msg.messageId =  msgID;
                            self.conversation.lastMessage = @"[语音]";
                        self.conversation.lastMessageDate = [NSDate date];
                        self.conversation.badgeNumber = @0;
                        self.conversation.messageStutes = @(messageStutes_outcoming);    
                        [self.conversation addMessagesObject:msg];
                        [self.messageList addObject:msg];
                        [localContext MR_saveToPersistentStoreAndWait];
                    }
                    [SVProgressHUD dismiss];
                    //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                SLLog(@"error :%@",error.userInfo);
                [SVProgressHUD dismiss];
            }];
        }
    } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    
    
}

#pragma mark - 获取文件大小
- (int) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}

-(IBAction)speakClick:(id)sender
{
    if (!self.recorderVC) {
        //初始化录音vc
        self.recorderVC = [[ChatVoiceRecorderVC alloc]init];
        recorderVC.vrbDelegate = self;
    }
    //设置文件名
    self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
    UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
//    [buttonAudio setTitle:@"松开结束" forState:UIControlStateNormal];
//    [buttonAudio infoStyle];
    [buttonAudio setBackgroundImage:[UIImage imageNamed:@"yunqi_松开结束"] forState:UIControlStateNormal];
    //开始录音
    [recorderVC beginRecordByFileName:self.originWav];
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//    [super touchesEnded:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//    [super touchesMoved:touches withEvent:event];
//}

-(void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer
{

     UIButton * buttonAudio = (UIButton *) [self.inputContainerView subviewWithTag:9];
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        SLog(@"recordBtnLongPressedss..");
        [self speakClick:nil];
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
//        [buttonAudio sendMessageWhiteStyle];
//        buttonAudio.backgroundColor = [UIColor whiteColor];
//        [buttonAudio setTitle:@"按住说话" forState:UIControlStateNormal];
        [buttonAudio setBackgroundImage:[UIImage imageNamed:@"yunqi_按住说话"] forState:UIControlStateNormal];
        
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:nil forKey:@"data"]]];
    }
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
//    }
//}


-(IBAction)SeeUserInfoClick:(id)sender
{
    //查看好友资料
//    XCJAddUserTableViewController * addUser = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJAddUserTableViewController"];
//    addUser.UserInfo = self.userinfo;
//    [self.navigationController pushViewController:addUser animated:YES];
}

-(IBAction)SeeGroupInfoClick:(id)sender
{
//    XCJSettingGroupViewController * groupsettingview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSettingGroupViewController"];
//    groupsettingview.title = self.title;
//    NSMutableArray * array = [[NSMutableArray alloc] init];
//    [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSString * uid = [DataHelper getStringValue:obj[@"uid"] defaultValue:@""];
//        if (uid.length > 0) {
//            [array addObject:uid];
//        }
//    }];
//    groupsettingview.uidArray = array;
//    groupsettingview.gid = self.gid;
//    [self.navigationController pushViewController:groupsettingview animated:YES];
}

- (void) setUpSequencer
{
    if (AllDBdatabaseLoad ) {
        return;
    }
     NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"FCMessage" inManagedObjectContext:localContext];
    
    [request setEntity:entity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"wechatid == %@",self.conversation.facebookId];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor  alloc] initWithKey:@"sentDate"  ascending:NO];
    
    NSArray *sortDescriptors = [[NSArray  alloc] initWithObjects:sortDescriptor, nil];
    
    [request setSortDescriptors:sortDescriptors];
    
    [request setFetchLimit:20];
    
    [request  setFetchOffset:_currentPage * 20];
    
    NSArray  *rssTemp  = [FCMessage MR_executeFetchRequest:request];
    
    if (rssTemp.count == 20) {
        AllDBdatabaseLoad = NO;
    }else{
        AllDBdatabaseLoad = YES;
        [self viewdidloadedComplete];
    }
    if (rssTemp.count > 0) {
        if (_currentPage == 0) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
            [rssTemp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.messageList insertObject:obj atIndex:0];
            }];
            
            [self.tableView reloadData];
            //tableView底部
            [self scrollToBottonWithAnimation:NO];
            
        }else{
            [rssTemp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.messageList insertObject:obj atIndex:0];
            }];
            
            CGSize sizePre = self.tableView.contentSize;
            [self.tableView reloadData];
            CGSize sizeNew = self.tableView.contentSize;
           
            [self.tableView setContentOffset:CGPointMake(0,  sizeNew.height - sizePre.height-63) animated:NO];
        }
    }
    
    _loading = NO;
    _currentPage++;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardChange:)
                                                name:UIKeyboardDidChangeFrameNotification
                                              object:nil];
    
    
    /* receive websocket message
     */
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSocketDidReceivePushMessage:)name: MLNetworkingManagerDidReceivePushMessageNotification   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:@"UIDeviceProximityStateDidChangeNotification"   object:nil];
    
    /**
     *  从后台切换到前台收取数据
     *
     *  @param webSocketDidReceivePushMessage: <#webSocketDidReceivePushMessage: description#>
     *
     *  @return <#return value description#>
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSocketDidReceiveForceMessage:)name: MLNetworkingManagerDidReceiveForcegroundMessageNotification   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PostLoacationClick:) name:@"PostChatLoacation" object:nil];
    
    [self.tableView reloadData];
}


#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{

    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    curve_keyboard =  [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    /*
    //创建表情键盘
    if (scrollView==nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, keyboardHeight)];
        [scrollView setBackgroundColor:[UIColor whiteColor]];
        for (int i=0; i<6; i++) {
            FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(10+320*i, 30, facialViewWidth, facialViewHeight)];
            [fview setBackgroundColor:[UIColor clearColor]];
            [fview loadFacialView:i size:CGSizeMake(42, 42)];
            fview.delegate=self;
            [scrollView addSubview:fview];
        }
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.contentSize=CGSizeMake(320*5, keyboardHeight);
        scrollView.pagingEnabled=YES;
        scrollView.delegate=self;
        
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(98, keyboardHeight-40, 150, 30)];
        [pageControl setCurrentPage:0];
        pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];//RGBACOLOR(195, 179, 163, 1);
        pageControl.currentPageIndicatorTintColor = ios7BlueColor;//RGBACOLOR(132, 104, 77, 1);
        pageControl.numberOfPages = 5;//指定页面个数
        [pageControl setBackgroundColor:[UIColor clearColor]];
        [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
        
        EmjView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, keyboardHeight)];
        [EmjView addSubview:scrollView];
        [EmjView addSubview:pageControl];
        [self.view addSubview:EmjView];
    }
     
     [self keyboardWillShowHide:notification];
     scrollView.delegate = self;
     
     */
    

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve_keyboard];
    [UIView setAnimationBeginsFromCurrentState:YES];

    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    CGRect inputViewFrame = self.inputContainerView.frame;
    CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
    // for ipad modal form presentations
    CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
    if (inputViewFrameY > messageViewFrameBottom)
        inputViewFrameY = messageViewFrameBottom;
    
    [self setTableViewInsetsWithBottomValue:self.view.height - inputViewFrameY - 44];
    [UIView commitAnimations];
    
    [self scrollToBottonWithAnimation:YES];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
    scrollView.delegate = nil;
    if(self.inputContainerView)
    {
        ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
        ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
    }
}


- (void)keyboardChange:(NSNotification *)notification{
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [self messageViewAnimationWithMessageRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:0.25
                                         andState:ZBMessageViewStateShowNone];
    }
}


#pragma mark - messageView animation
- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve_keyboard];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(self.view.frame),CGRectGetHeight(inputViewRect));
    
    switch (state) {
        case ZBMessageViewStateShowFace:
        {
            self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
            
            self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
        }
            break;
        case ZBMessageViewStateShowNone:
        {
            self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
            
            self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
        }
            break;
        case ZBMessageViewStateShowShare:
        {
            self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
            
            self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
        }
            break;
            
        default:
            break;
    }
    [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
     - self.messageToolView.frame.origin.y - self.messageToolView.height];
    [UIView commitAnimations];
}

#pragma end

#pragma mark - Keyboard
- (void)keyboardWillShowHide:(NSNotification *)notification
{
    //    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameForTextField = [self.inputContainerView.superview convertRect:keyboardFrame fromView:nil];
    CGRect keyboardRects = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newTextFieldFrame = self.inputContainerView.frame;
    newTextFieldFrame.origin.y = keyboardFrameForTextField.origin.y - newTextFieldFrame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGFloat keyboardY = [self.view convertRect:keyboardRects fromView:nil].origin.y;
    
    CGRect inputViewFrame = self.inputContainerView.frame;
    CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
    // for ipad modal form presentations
    CGFloat messageViewFrameBottom = self.view.frame.size.height - inputViewFrame.size.height;
    if (inputViewFrameY > messageViewFrameBottom)
        inputViewFrameY = messageViewFrameBottom;
    
    [self.inputContainerView setTop:inputViewFrameY];
    
    [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
     - self.inputContainerView.frame.origin.y - self.inputContainerView.height];
    
    [UIView commitAnimations];
    
    {
        //    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        //        self.tableView.height = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
        //        self.inputContainerView.frame = newTextFieldFrame;
        //    } completion:nil];
        
        //tableView滚动到底部
        //    [self scrollToBottonWithAnimation:YES];
        
        
        //    if (self.keyboardView&&self.keyboardView.frameY<self.keyboardView.window.frameHeight) {
        //        //到这里说明其不是第一次推出来的，而且中间变化，无需动画直接变
        ////        self.inputContainerViewBottomConstraint.top = keyboardFrame.size.height;
        //        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
        ////        [self.view setNeedsUpdateConstraints];
        //        return;
        //    }
        
        //    [self animateChangeWithConstant:keyboardFrame.size.height withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        
        //晚一小会获取。
        //   [self performSelector:@selector(resetKeyboardView) withObject:nil afterDelay:0.001];
    }
    
}


#pragma mark - Dismissive text view delegate

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.tableView.contentInset = insets;
    //    self.tableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    insets.bottom = bottom;
    
    return insets;
}


 -(void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        SLog(@"Device is close to user");
         [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
         SLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

-(void) webSocketDidReceiveForceMessage:(NSNotification * ) notify
{
    if (notify.object) {
        
//         [self fillDatawithType:@"newmsg" Dicty:notify.object];
        NSDictionary * dict =  notify.object;
        if (dict) {
            
            FCMessage * message = dict[@"message"];
            NSString * facebookid =  dict[@"fromid"];
            
            if ([self.conversation.facebookId isEqualToString:facebookid]) {
                if ([self.conversation.badgeNumber intValue] > 0) {
                    self.conversation.badgeNumber = @(0);
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] saveContext];
                }
                [self.messageList addObject:message]; //table reload
                [self insertTableRow];
                
            }
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollViewDat
{
    
    if (scrollViewDat && scrollViewDat == scrollView) {
        int page = scrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
        pageControl.currentPage = page;//pagecontroll响应值的变化
    }
    
    if ([scrollViewDat isKindOfClass:[UITableView class]]) {
        
        if (AllLoad) {
            return;
        }
        if ( scrollViewDat.contentOffset.y < -30.0f && !_loading) {
            if (AllDBdatabaseLoad) {
                
                FCMessage * message =  [self.messageList firstObject];
                if (message.messageId && [message.messageId length] > 0) {
                    [self initchatdata:message.messageId];
                }else{
                    [self viewdidloadedComplete];
                }
            }else{
                _loading = YES;
                double delayInSeconds = .5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self setUpSequencer];
                });

            }
        }
        
    }
}

- (void) viewdidloadedComplete
{
    self.activityindret.hidden = YES;
    self.label_titleToast.text = @"加载完成";
}

- (void) viewdidloading
{
    self.activityindret.hidden = NO;
    self.label_titleToast.text = @"加载中...";
}




-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollViewDat
{
    if ([scrollViewDat isKindOfClass:[UITableView class]]) {
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        //[self.messageInputTextView resignFirstResponder];
        if(self.messageToolView)
        [self.messageToolView hiddenKeyboard];
        
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
        }
    }
    
}

- (void)webSocketDidReceivePushMessage:(NSNotification *)notification
{
    //获取了webSocket的推过来的消息
    NSDictionary * MsgContent  = notification.userInfo;
    SLLog(@"MsgContent :%@",MsgContent);
    if ([MsgContent[@"push"] intValue] == 1) {
        NSString *requestKey = [tools getStringValue:MsgContent[@"type"] defaultValue:nil];
        [self fillDatawithType:requestKey Dicty:MsgContent ];
    }
}

/**
 *  插入数据
 *
 *  @param requestKey requestKey description
 *  @param MsgContent MsgContent description
 */
-(void) fillDatawithType:(NSString * ) requestKey Dicty:(NSDictionary* ) MsgContent
{
    if ([requestKey isEqualToString:@"newmsg"]) {
        /*
         
           {"push":false,"errno":0,"result":{"message":[{"content":"露是呢","msgid":2220,"toid":1,"time":1394264178.0,"fromid":2,"type":"txt"}]},"cdata":"PGUVBCBWSQ","error":"no error"}  
         
         {"push": true, "data": {"message": {"toid": 14, "msgid": 5, "content": "\u6211\u6765\u4e86sss", "fromid": 2, "time": 1388477804.0}}, "type": "newmsg"}
         */
      
        
        NSDictionary * dicResult = MsgContent[@"data"];
        
        NSDictionary *  dicMessage = dicResult[@"message"];
        
        // update lastmessage id index
        NSInteger indexMsgID = [DataHelper getIntegerValue:dicMessage[@"msgid"] defaultValue:0];
        
        NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
        if (messageIndex < indexMsgID) {
            [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            [USER_DEFAULT synchronize];
        }
        
        NSString *facebookID = [tools getStringValue:dicMessage[@"fromid"] defaultValue:@""];
        if ([self.conversation.facebookId isEqualToString:facebookID]) {
            // int view
            NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
            NSString * typeMessage = [tools getStringValue:dicMessage[@"type"] defaultValue:@""];
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            //                FCMessage  find this infomation
            NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
            FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
            if (message) {
                // change by tinkl   ....MARK:  has this record
                [self.messageList addObject:message]; //table reload
                self.conversation.badgeNumber = @0;
                self.conversation.messageStutes = @(messageStutes_incoming);
                [localContext MR_saveToPersistentStoreAndWait];
                
            }else{
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                msg.wechatid = self.conversation.facebookId;
                msg.sentDate = date;
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                if ([typeMessage isEqualToString:@"txt"]) {
                    if ([content containString:@"sticker_"]) {
                        msg.messageType = @(messageType_emj);
                        self.conversation.lastMessage = @"[表情]";
                    }else{
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                }else if ([typeMessage isEqualToString:@"emj"]) {
                    if ([content containString:@"sticker_"]) {
                        msg.messageType = @(messageType_emj);
                        self.conversation.lastMessage = @"[表情]";
                    }else{
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                }else if ([typeMessage isEqualToString:@"pic"]) {
                    //image
                    msg.messageType = @(messageType_image);
                    self.conversation.lastMessage = @"[图片]";
                    msg.imageUrl = imageurl;
                }else if ([typeMessage isEqualToString:@"vic"]) {
                    //audio
                    NSString * audiourl = [tools getStringValue:dicMessage[@"voice"] defaultValue:@""];
                    self.conversation.lastMessage = @"[语音]";
                    msg.audioUrl = audiourl;
                    msg.messageType = @(messageType_audio);
                    int length  = [dicMessage[@"length"] intValue];
                    msg.audioLength = @(length/audioLengthDefine);
                }else if ([typeMessage isEqualToString:@"map"]) {
                    self.conversation.lastMessage = @"[位置信息]";
                    msg.imageUrl = imageurl;
                    msg.messageType = @(messageType_map);
                }else if ([typeMessage isEqualToString:@"video"]) {
                    self.conversation.lastMessage = @"[视频]";
                    msg.videoUrl = imageurl;
                    msg.messageType = @(messageType_video);
                }
                
                msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                
                self.conversation.lastMessageDate = date;
                self.conversation.badgeNumber = @0;
                self.conversation.messageStutes = @(messageStutes_incoming);
                [self.conversation addMessagesObject:msg];
                [self.messageList addObject:msg]; //table reload
                [localContext MR_saveToPersistentStoreAndWait];
            }
            [self insertTableRow];
            
        }else if(![self.conversation.facebookId isEqualToString:facebookID]){
            //out view
            NSString * content = dicMessage[@"content"];
            NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
            NSString * typeMessage = [tools getStringValue:dicMessage[@"type"] defaultValue:@""];
            
            // update lastmessage id index
            NSInteger indexMsgID = [DataHelper getIntegerValue:dicMessage[@"msgid"] defaultValue:0];
            
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            
            NSPredicate * preCMD = [NSPredicate predicateWithFormat:@"messageId == %@",[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"]];
            FCMessage * message =  [FCMessage MR_findFirstWithPredicate:preCMD];
            if (message) {
                // change by tinkl   ....MARK:  has this record
            }else{
                
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                msg.wechatid = self.conversation.facebookId;
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                msg.sentDate = date;
                if ([typeMessage isEqualToString:@"txt"]) {
                    if ([content containString:@"sticker_"]) {
                        msg.messageType = @(messageType_emj);
                        self.conversation.lastMessage = @"[表情]";
                    }else{
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                }else if ([typeMessage isEqualToString:@"emj"]) {
                    if ([content containString:@"sticker_"]) {
                        msg.messageType = @(messageType_emj);
                        self.conversation.lastMessage = @"[表情]";
                    }else{
                        msg.messageType = @(messageType_text);
                        self.conversation.lastMessage = content;
                    }
                }else if ([typeMessage isEqualToString:@"pic"]) {
                    //image
                    msg.messageType = @(messageType_image);
                    self.conversation.lastMessage = @"[图片]";
                    msg.imageUrl = imageurl;
                }else if ([typeMessage isEqualToString:@"vic"]) {
                    //audio
                    NSString * audiourl = [tools getStringValue:dicMessage[@"voice"] defaultValue:@""];
                    self.conversation.lastMessage = @"[语音]";
                    msg.audioUrl = audiourl;
                    msg.messageType = @(messageType_audio);
                }else if ([typeMessage isEqualToString:@"map"]) {
                    self.conversation.lastMessage = @"[位置信息]";
                    msg.imageUrl = imageurl;
                    msg.messageType = @(messageType_map);
                }else if ([typeMessage isEqualToString:@"video"]) {
                    self.conversation.lastMessage = @"[视频]";
                    msg.videoUrl = imageurl;
                    msg.messageType = @(messageType_video);
                }
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]
                                           dismissAfter:3.0
                                              styleName:JDStatusBarStyleDark];
                
//                [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]];
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                msg.messageId = [tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                self.conversation.lastMessage = content;
                self.conversation.lastMessageDate = date;
                self.conversation.messageStutes = @(messageStutes_incoming);
                // increase badge number.
                int badgeNumber = [self.conversation.badgeNumber intValue];
                badgeNumber ++;
                self.conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                
                [self.conversation addMessagesObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
            }
        }
    }else if ([requestKey isEqualToString:@"newpost_error"]){
        // group new msg
        /*
         “data”:{
         “post”:{
         “postid”:
         “uid”:
         “group_id”:
         “content”:
         */
        NSDictionary * dicResult = MsgContent[@"data"];
        
        NSDictionary * dicMessage = dicResult[@"post"];
        NSString * gid = [tools getStringValue:dicMessage[@"gid"] defaultValue:@""];
        
        //获取群组消息类型 然后做相关写入操作
        NSPredicate * parCMDss = [NSPredicate predicateWithFormat:@"gid == %@ ",gid];
        FCHomeGroupMsg * groupMessage = [FCHomeGroupMsg MR_findFirstWithPredicate:parCMDss];
        if ([groupMessage.gType isEqualToString: @"2"]) {
            
            NSString * uid = [tools getStringValue:dicMessage[@"uid"] defaultValue:@""];
            if([uid isEqualToString:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_id]])
            {
                return;
            }
            
            
            NSString * facebookID = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_GroupMessage,gid];
            if ([self.conversation.facebookId isEqualToString:facebookID]) {
                // int view
                NSString * content = [tools getStringValue:dicMessage[@"content"] defaultValue:@""];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                msg.wechatid = self.conversation.facebookId;
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                msg.sentDate = date;
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                if (imageurl.length > 5)
                {
                    msg.messageType = @(messageType_image);
                    self.conversation.lastMessage = @"[图片]";
                }
                
                else
                {
                    msg.messageType = @(messageType_text);
                    self.conversation.lastMessage = content;
                }
                
                msg.imageUrl = imageurl;
                msg.messageId = [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                
                self.conversation.lastMessageDate = date;
                self.conversation.badgeNumber = @0;
                self.conversation.messageStutes = @(messageStutes_incoming);
                [self.conversation addMessagesObject:msg];
                [self.messageList addObject:msg]; //table reload
                [localContext MR_saveToPersistentStoreAndWait];
                [self insertTableRow];
                
            }else if(![self.conversation.facebookId isEqualToString:facebookID]){
                //out view
                NSString * content = dicMessage[@"content"];
                NSString * imageurl = [tools getStringValue:dicMessage[@"picture"] defaultValue:@""];
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                msg.text = content;
                msg.wechatid = self.conversation.facebookId;
                NSTimeInterval receiveTime  = [dicMessage[@"time"] doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:receiveTime];
                msg.sentDate = date;
                if (imageurl.length > 5)
                {
                    msg.messageType = @(messageType_image);
                    self.conversation.lastMessage = @"[图片]";
                }
                else
                {
                    msg.messageType = @(messageType_text);
                    self.conversation.lastMessage = content;
                }
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]
                                           dismissAfter:3.0
                                              styleName:JDStatusBarStyleDark];
                
//                [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:[NSString stringWithFormat:@"%@:%@",self.conversation.facebookName,self.conversation.lastMessage]];
                // message did come, this will be on left
                msg.messageStatus = @(YES);
                msg.messageId =  [NSString stringWithFormat:@"UID_%@", uid];//[tools getStringValue:dicMessage[@"msgid"] defaultValue:@"0"];
                [[[LXAPIController sharedLXAPIController] requestLaixinManager] getUserDesPtionCompletion:^(id response, NSError *error) {
                    if (response) {
                        FCUserDescription * localdespObject = response;
                        self.conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",localdespObject.nick,content];
                    }
                   
                } withuid:uid];
                self.conversation.lastMessageDate = date;
                self.conversation.messageStutes = @(messageStutes_incoming);
                // increase badge number.
                int badgeNumber = [self.conversation.badgeNumber intValue];
                badgeNumber ++;
                self.conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
                
                [self.conversation addMessagesObject:msg];
                [localContext MR_saveToPersistentStoreAndWait];
            }
        }
        
    }
}

- (void)dealloc
{
    //删除Observer
//	[self.messageList removeObserver:self forKeyPath:@"array"];
        
    @try {
        if(player && ![player isKindOfClass:[NSNull class]] && [player isPlaying])
        {
            [player stop];
            player = nil;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
    if(player )
    {
        player = nil;
    }
    
    self.messageToolView = nil;
    self.faceView = nil;
    self.shareMenuView = nil;
    
    scrollView.delegate  = nil;
    [_tableView setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MLNetworkingManagerDidReceivePushMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSNotificationCenter_RefreshChatTableView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification object:nil];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString * ) getMD4HashWithObj
{
     NSTimeInterval doub = [[NSDate date] timeIntervalSinceNow];
    int x = arc4random() % 1000000;
    NSString * guid = [[NSString stringWithFormat:@"%f%d",doub, x] md5Hash];
    SLLog(@"gener guid: %@",guid);
    return guid;
}

#pragma mark -
#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    
    
    /*
     */
    self.inputTextView.text = [NSString stringWithFormat:@"%@%@",self.inputTextView.text,str];
    
    
    return;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = str;
    msg.wechatid = self.conversation.facebookId;
    msg.sentDate = [NSDate date];
    msg.messageType = @(messageType_emj);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageguid = [self getMD4HashWithObj];
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageId = @"";
    self.conversation.lastMessage = @"[表情]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [self.messageList addObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self insertTableRow];
    
    SLog(@"str:%@",str);
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button showIndicatorView];
    button.userInteractionEnabled = NO;
    //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
    NSDictionary * parames = @{@"uid":self.conversation.facebookId,@"content":str};
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
        NSDictionary * dic = [responseObject objectForKey:@"result"];
        if (dic) {
            // update lastmessage id index
            NSInteger indexMsgID = [DataHelper getIntegerValue:dic[@"msgid"] defaultValue:0];
            
            NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
            if (messageIndex < indexMsgID) {
                [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                [USER_DEFAULT synchronize];
            }
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = str;
            msg.wechatid = self.conversation.facebookId;
            msg.sentDate = [NSDate date];
            msg.messageType = @(messageType_emj);
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            msg.messageId = [tools getStringValue:dic[@"msgid"] defaultValue:@"0"];
            self.conversation.lastMessage = @"[表情]";
            self.conversation.lastMessageDate = [NSDate date];
            self.conversation.badgeNumber = @0;
            self.conversation.messageStutes = @(messageStutes_outcoming);
            [self.conversation addMessagesObject:msg];
            [self.messageList addObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
            [button defaultStyle];
            [self insertTableRow];
        }
        
        [button hideIndicatorView];
        button.userInteractionEnabled = YES;
    } failure:^(MLRequest *request, NSError *error) {
        
        [button hideIndicatorView];
        button.userInteractionEnabled = YES;
    }];
}

- (IBAction)SendTextMsgClick:(id)sender {
// 群聊
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button showIndicatorView];
    button.userInteractionEnabled = NO;
    if (self.gid) {
        NSString * text = self.inputTextView.text;
        if ([text trimWhitespace].length > 0) {
            
//            self.inputContainerView.height  = 44.0f;
//            ((UIImageView *) [self.inputContainerView subviewWithTag:2]).height = 33.0f;
//            UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
//            imageBg.height = 44.0f;
//            self.inputTextView.height = 33.0f;
//            self.inputContainerView.top = self.view.height - self.inputContainerView.height;
//            self.tableView.height  = self.view.height - self.inputContainerView.height;
            
            NSDictionary * parames = @{@"gid":self.gid,@"content":text};
            [[MLNetworkingManager sharedManager] sendWithAction:@"post.add" parameters:parames success:^(MLRequest *request, id responseObject) {
                NSDictionary * dic = [responseObject objectForKey:@"result"];
                if (dic) {
                    //postid  none nessciary
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = text;
                    msg.wechatid = self.conversation.facebookId;
                    msg.sentDate = [NSDate date];
                    msg.messageType = @(messageType_text);
                    // message did not come, this will be on rigth
                    msg.messageStatus = @(NO);
                    msg.messageId = [tools getStringValue:dic[@"postid"] defaultValue:@"0"];
                    self.conversation.lastMessage = [NSString stringWithFormat:@"%@:%@",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick],text];
                    self.conversation.lastMessageDate = [NSDate date];
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_outcoming);
                    self.inputTextView.text = @"";
                    [self.conversation addMessagesObject:msg];
                    [self.messageList addObject:msg];
                    [localContext MR_saveToPersistentStoreAndWait];
                    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
                    [button defaultStyle];
                    [self insertTableRow];
                }
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            } failure:^(MLRequest *request, NSError *error) {
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            }];
            
        }
        
    }else{
        NSString * text = self.inputTextView.text;
        if ([text trimWhitespace].length > 0) {
            //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            FCMessage *msg = [FCMessage MR_createInContext:localContext];
            msg.text = text;
            msg.wechatid = self.conversation.facebookId;
            msg.sentDate = [NSDate date];
            msg.messageType = @(messageType_text);
            // message did not come, this will be on rigth
            msg.messageStatus = @(NO);
            msg.messageSendStatus = @(4); // ready to send
            msg.messageId = [self getMD4HashWithObj];
            msg.messageguid = [self getMD4HashWithObj];
            self.conversation.lastMessage = text;
            self.conversation.lastMessageDate = [NSDate date];
            self.conversation.badgeNumber = @0;
            self.conversation.messageStutes = @(messageStutes_outcoming);
            self.inputTextView.text = @"";
            [self.conversation addMessagesObject:msg];
            [localContext MR_saveToPersistentStoreAndWait];
            [self.messageList addObject:msg];
            [self insertTableRow];
            
//          dictionary[@"messageId"] = @"";
            
//            NSIndexPath * indexpath = [NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0];
//
//            XCJChatMessageCell * cell = (XCJChatMessageCell*)[self.tableView cellForRowAtIndexPath:indexpath];
//            [cell layoutSubviews];
//            [cell layoutIfNeeded];
//            [cell setNeedsLayout];
//            //(XCJChatMessageCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexpath];
//
            
           /* NSDictionary * parames = @{@"uid":self.conversation.facebookId,@"content":text};
            [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
                //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
                NSDictionary * dic = [responseObject objectForKey:@"result"];
                if (dic) {
                    // update lastmessage id index
                    NSInteger indexMsgID = [DataHelper getIntegerValue:dic[@"msgid"] defaultValue:0];
                    
                    NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    if (messageIndex < indexMsgID) {
                        [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                        [USER_DEFAULT synchronize];
                    }
                    
                    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                    FCMessage *msg = [FCMessage MR_createInContext:localContext];
                    msg.text = text;
                    msg.sentDate = [NSDate date];
                    msg.messageType = @(messageType_text);
                    // message did not come, this will be on rigth
                    msg.messageStatus = @(NO);
                    msg.messageId = [tools getStringValue:dic[@"msgid"] defaultValue:@"0"];
                    self.conversation.lastMessage = text;
                    self.conversation.lastMessageDate = [NSDate date];
                    self.conversation.badgeNumber = @0;
                    self.conversation.messageStutes = @(messageStutes_outcoming);
                    self.inputTextView.text = @"";
                    [self.conversation addMessagesObject:msg];
                  
                    [localContext MR_saveToPersistentStoreAndWait];
                    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
                    [button defaultStyle];
                    [self.messageList addObject:msg];
                    [self insertTableRow];
                }
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            } failure:^(MLRequest *request, NSError *error) {
                
                [button hideIndicatorView];
                button.userInteractionEnabled = YES;
            }];
            */
        }
    }
}

-(void) sendtextMessage:(NSString * ) text
{
    if ([text trimWhitespace].length > 0) {
        //send to websocket message.send(uid,content) 私信 Result={“msgid”:}
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        FCMessage *msg = [FCMessage MR_createInContext:localContext];
        msg.text = text;
        msg.wechatid = self.conversation.facebookId;
        msg.sentDate = [NSDate date];
        msg.messageType = @(messageType_text);
        // message did not come, this will be on rigth
        msg.messageStatus = @(NO);
        msg.messageSendStatus = @(4); // ready to send
        msg.messageId = [self getMD4HashWithObj];
        msg.messageguid = [self getMD4HashWithObj];
        self.conversation.lastMessage = text;
        self.conversation.lastMessageDate = [NSDate date];
        self.conversation.badgeNumber = @0;
        self.conversation.messageStutes = @(messageStutes_outcoming);
        self.inputTextView.text = @"";
        [self.conversation addMessagesObject:msg];
        [localContext MR_saveToPersistentStoreAndWait];
        [self.messageList addObject:msg];
        [self insertTableRow];
    }
}


- (IBAction)adjustKeyboardFrame:(id)sender {
    //检测冲突
    [self.view exerciseAmiguityInLayoutRepeatedly:YES];
}

- (IBAction)addImage:(id)sender {
    //ActionSheet选择拍照还是相册
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册",nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
    //必须隐藏键盘否则会出问题。
    [self.inputTextView resignFirstResponder];
    */
    if (SendInfoView == nil) {
        SendInfoView = [[[NSBundle mainBundle] loadNibNamed:@"XCJChatSendInfoView" owner:self options:nil] lastObject];
        SendInfoView.delegate = self;
    }
    
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = SendInfoView;
    [self.inputTextView reloadInputViews];
    

}
- (void)takePhotoClick
{
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        UIImagePickerController *camera = [[UIImagePickerController alloc] init];
//        camera.delegate = self;
//        camera.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:camera animated:YES completion:nil];
//    }
    
    SCNavigationController *nav = [[SCNavigationController alloc] init];
    nav.scNaigationDelegate = self;
    [nav showCameraWithParentController:self];
    
}

-(void) ChatViewSendPhotoSure:(NSNotification *) notify
{
    if (currentImage) {
        [self uploadImage:currentImage token:@""];
    }

}

#pragma mark - SCNavigationController delegate
- (void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image {
    
    //    UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationDefault];
    currentImage = image;
   
}

- (void)choseFromGalleryClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
        photoLibrary.delegate = self;
        photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:photoLibrary animated:YES completion:nil];
    }
}

- (void) postLoactionMsg:(NSDictionary * ) notity
{
    
    UIImage * image =  notity[@"image"];
    NSString * address =  notity[@"strAddresss"];
    NSNumber * lat =  notity[@"lat"];
    NSNumber * log =  notity[@"log"];
    
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getMD4HashWithObj], @".jpg"];
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSData *webData = UIImageJPEGRepresentation(image, 0.5f);
    [webData writeToFile:file atomically:YES];
    
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.wechatid = self.conversation.facebookId;
    msg.sentDate = [NSDate date];
    msg.imageUrl = file;
    msg.messageType = @(messageType_map);
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageId = @"";
    msg.messageguid = [self getMD4HashWithObj];
    msg.text = address;
    msg.longitude = log;
    msg.latitude = lat;
    self.conversation.lastMessage = @"[位置信息]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self.messageList addObject:msg];
    [self insertTableRow];
    
}

-(void) PostLoacationClick:(NSNotification * ) notity
{
    if (notity.userInfo) {
        //   NSDictionary *dict = @{@"image":image,@"strAddresss",strAddresss,@"lat":@(lat),@"log":@(log)};
        
        UIImage * image =  notity.userInfo[@"image"];
        NSString * address =  notity.userInfo[@"strAddresss"];
        NSNumber * lat =  notity.userInfo[@"lat"];
        NSNumber * log =  notity.userInfo[@"log"];
        NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
        if(token.length > 0){
            [self postLoactionMsg:notity.userInfo];
        }else{
            // token has 1 hour expire
            [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
                if (response) {
                    NSString * token =  response[@"token"];
                    [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                    [self postLoactionMsg:notity.userInfo];
                }
            } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",@"Message",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
        }
        
        return;
        
        
        NSString * postType;
        if (self.gid.length > 0) {
            postType = @"Post";
        }else{
            postType = @"Message";
        }
        
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id responsesssss, NSError *errorsssss) {
            if (responsesssss) {
                NSString * token =  [responsesssss objectForKey:@"token"];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
                [parameters setValue:token forKey:@"token"];
                [parameters setValue:@"1" forKey:@"x:filetype"];
                [parameters setValue:@"" forKey:@"x:content"];
                [parameters setValue:@"" forKey:@"x:length"];
                if (self.gid.length > 0) {
                    [parameters setValue:self.gid forKey:@"x:gid"];
                }else{
                    [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
                }
                NSData *imageDatasss  =  [UIImage imageToWebP:image quality:75.0];
                //imageDatasss = UIImageJPEGRepresentation(image, 0.5);
                
                operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    //        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
                    [formData appendPartWithFileData:imageDatasss name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
                    SLLog(@"responseObject %@",responseObject);
                    if (responseObject) {
                        NSDictionary * result =  responseObject[@"result"];
                        if (result) {
                            if (self.gid.length > 0) {
                                
                                NSString *msgID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                                [self SendImageWithMeImageurl:url withMsgID:msgID];
                            } else {
                                // update lastmessage id index
                                NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                                
                                NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                if (messageIndex < indexMsgID) {
                                    [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                                    [USER_DEFAULT synchronize];
                                }
                                
                                NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                                NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
//                                [self SendImageWithMeImageurl:url withMsgID:msgID];
                                
                                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                FCMessage *msg = [FCMessage MR_createInContext:localContext];
                                msg.wechatid = self.conversation.facebookId;
                                msg.sentDate = [NSDate date];
                                msg.messageType = @(messageType_map);
                                
                                msg.imageUrl = url;
                                // message did not come, this will be on rigth
                                msg.messageStatus = @(NO);
                                msg.messageId = msgID;
                                msg.text = address;
                                msg.longitude = log;
                                msg.latitude = lat;
                                
                                self.conversation.lastMessage = @"[位置信息]";
                                self.conversation.lastMessageDate = [NSDate date];
                                self.conversation.badgeNumber = @0;
                                self.conversation.messageStutes = @(messageStutes_outcoming);    
                                [self.conversation addMessagesObject:msg];
                                [self.messageList addObject:msg];
                                [localContext MR_saveToPersistentStoreAndWait];
                                [self insertTableRow];
                            }
                        }
                        [SVProgressHUD dismiss];
                        //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    SLLog(@"error :%@",error.userInfo);
                    [SVProgressHUD dismiss];
                }];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
}

- (void)choseLocationClick
{

    XCJWholeNaviController * navi = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJWholeNaviController"];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)sendMyfriendsClick
{
    
}

- (void)moreClick
{
}
 

#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2) {
        switch (buttonIndex) {
            case 0:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIImagePickerController *camera = [[UIImagePickerController alloc] init];
                    camera.delegate = self;
                    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:camera animated:YES completion:nil];
                }
            }
                break;
            case 1:{
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIImagePickerController *photoLibrary = [[UIImagePickerController alloc] init];
                    photoLibrary.delegate = self;
                    photoLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentViewController:photoLibrary animated:YES completion:nil];
                }
            }
                break;
            default:
                break;
        }
    }
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
            {
                if (PasteboardStr) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    [pasteboard setString:PasteboardStr];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    if (actionSheet.tag == 3) {

            if (buttonIndex == 0) {
                
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:[NSString stringWithFormat:@"%@",CurrentUrl]];
            }else if(buttonIndex == 1)
            {
                NSString * title = [actionSheet buttonTitleAtIndex:buttonIndex];
                if (![ title  isEqualToString:@"取消"]) {
                    
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:CurrentUrl]])
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:CurrentUrl]];
                    }else{
                        [UIAlertView showAlertViewWithMessage:@"打开失败"];
                    }
                }
                
            }
        
    }

}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)theInfo
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    
//    UIImage *postImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
    //upload image
    [self performSelector:@selector(uploadContent:) withObject:theInfo];
    
}

/**
 *  send image
 *
 *  @param url <#url description#>
 *  @param key <#key description#>
 */
- (void) SendImageURL:(UIImage * ) url  withKey:(NSString *) key
{
//    [SVProgressHUD showWithStatus:@"正在发送..."];
//    [self uploadFile:url  key:key];
    [self uploadImage:url token:key];
    
}

- (void)uploadContent:(NSDictionary *)theInfo {
    XCJChatSendImgViewController * chatImgView = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJChatSendImgViewController"];
    UIImage *image = theInfo[UIImagePickerControllerOriginalImage];
//    int Wasy = image.size.width/APP_SCREEN_WIDTH;
//    int Hasy = image.size.height/APP_SCREEN_HEIGHT;
//    int quality = Wasy/2;
//    UIImage * newimage = [image resizedImage:CGSizeMake(APP_SCREEN_WIDTH*Wasy/quality, APP_SCREEN_HEIGHT*Hasy/quality) interpolationQuality:kCGInterpolationDefault];
     UIImage * newimage = [image resizedImage:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationDefault];
    if (!newimage) {
        chatImgView.imageviewSource = image;
    }else{
        chatImgView.imageviewSource = newimage;
    }
    
    chatImgView.delegate = self;
    [self presentViewController:chatImgView animated:YES completion:^{
    }];
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
//    //Optionally for time zone conversions
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
//    
//    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
////        NSString * namefile =  [self getMd5_32Bit_String:[NSString stringWithFormat:@"%@%@",timeDesc,self.conversation.facebookId]];
////        NSString *key = [NSString stringWithFormat:@"%@%@", namefile, @".jpg"];
////        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
////        SLLog(@"Upload Path: %@", filePath);
////        NSData *webData = UIImageJPEGRepresentation([theInfo objectForKey:UIImagePickerControllerOriginalImage], 1);
////        [webData writeToFile:filePath atomically:YES];
////        [self uploadFile:filePath  key:key];
//        
//    }
}

- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

- (void) SendImageWithMeImageurl:(NSString * ) url withMsgID:(NSString *) msgid
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = @"";
    msg.wechatid = self.conversation.facebookId;
    msg.sentDate = [NSDate date];
    msg.messageType = @(messageType_image);
    
    msg.imageUrl = url;
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageId = msgid;
    if (self.gid.length > 0) {
        self.conversation.lastMessage = [NSString stringWithFormat:@"%@:[图片]",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick]];
    }else{

        self.conversation.lastMessage = @"[图片]";
    }
    
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);    
    [self.conversation addMessagesObject:msg];
    [self.messageList addObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
    [button defaultStyle];
    [self insertTableRow];
    
   /* NSDictionary * parames = @{@"uid":self.conversation.facebookId};
    [[MLNetworkingManager sharedManager] sendWithAction:@"message.send"  parameters:parames success:^(MLRequest *request, id responseObject) {
        //"result":{"msgid":3,"url":"http://kidswant.u.qiniudn.com/FtkabSm4a4iXzHOfI7GO01jQ27LB"}
        NSDictionary * dic = [responseObject objectForKey:@"result"];
        if (dic) {
           
        }
        
    } failure:^(MLRequest *request, NSError *error) {
    }];*/
}


- (void)uploadFile:(UIImage *)filePath  key:(NSString *)key {
    // setup 1: frist get token
    //http://service.xianchangjia.com/upload/Message?sessionid=YtcS7pKQSydYPnJ
    NSString * postType;
    if (self.gid.length > 0) {
        postType = @"Post";
    }else{
        postType = @"Message";
    }
    
    NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
    if(token.length > 0){
         [self uploadImage:filePath token:token];
    }else{
        // token has 1 hour expire
        [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestGetURLWithCompletion:^(id response, NSError *error) {
            if (response) {
                NSString * token =  response[@"token"];
                [[EGOCache globalCache] setString:token forKey:@"uploadtoken" withTimeoutInterval:60*60];
                TokenAPP = token;
                ImageFile = filePath;
                [self uploadImage:filePath token:token];
            }
        } withParems:[NSString stringWithFormat:@"upload/%@?sessionid=%@",postType,[USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid]]];
    }
    
}

-(void) uploadImage:(UIImage *)filePath  token:(NSString *)token
{
//    UIImageView * img = (UIImageView *) [self.view subviewWithTag:2];
//    [img setImage:[UIImage imageWithContentsOfFile:filePath]];
//    [img showIndicatorViewBlue];
    // setup 2: upload image
    //method="post" action="http://up.qiniu.com/" enctype="multipart/form-data"
    
    SLog(@"start uploading....");
    
    NSString *key = [NSString stringWithFormat:@"%@%@", [self getMD4HashWithObj], @".jpg"];
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
    NSData *webData = UIImageJPEGRepresentation(filePath, 0.5f);
    [webData writeToFile:file atomically:YES];    
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    FCMessage *msg = [FCMessage MR_createInContext:localContext];
    msg.text = @"";
    msg.sentDate = [NSDate date];
    msg.imageUrl = file;
    msg.wechatid = self.conversation.facebookId;
    msg.messageType = @(messageType_image);
    // message did not come, this will be on rigth
    msg.messageStatus = @(NO);
    msg.messageSendStatus = @(4); // ready to send
    msg.messageId = [self getMD4HashWithObj];
    msg.messageguid = [self getMD4HashWithObj];
    self.conversation.lastMessage = @"[图片]";
    self.conversation.lastMessageDate = [NSDate date];
    self.conversation.badgeNumber = @0;
    self.conversation.messageStutes = @(messageStutes_outcoming);
    [self.conversation addMessagesObject:msg];
    [localContext MR_saveToPersistentStoreAndWait];
    [self.messageList addObject:msg];
    [self insertTableRow];
    
    return;
    
    
    /**
     *  <#Description#>
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters=[[NSMutableDictionary alloc] init];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"1" forKey:@"x:filetype"];
    [parameters setValue:@"" forKey:@"x:content"];
    [parameters setValue:@"" forKey:@"x:length"];
    if (self.gid.length > 0) {
        [parameters setValue:self.gid forKey:@"x:gid"];
    }else{
        [parameters setValue:self.conversation.facebookId forKey:@"x:toid"];
    }
    
    NSData *imageDatasss  =  [UIImage imageToWebP:filePath quality:75.0];
    //NSData * imageDatasss = UIImageJPEGRepresentation(imageSend, 0.5);
    SLog(@"imageDatasss : %.2f KB ",(double)imageDatasss.length/audioLengthDefine);
    operation  = [manager POST:@"http://up.qiniu.com/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil ];
        [formData appendPartWithFileData:imageDatasss name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //{"errno":0,"error":"Success","url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}
        SLLog(@"responseObject %@",responseObject);
        if (responseObject) {
            NSDictionary * result =  responseObject[@"result"];
            if (result) {
                
                if (self.gid.length > 0) {
                    
                    NSString *msgID = [tools getStringValue:result[@"postid"] defaultValue:@""];
                    NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                    [self SendImageWithMeImageurl:url withMsgID:msgID];
                }else{
                    // update lastmessage id index
                    NSInteger indexMsgID = [DataHelper getIntegerValue:result[@"msgid"] defaultValue:0];
                    
                    NSInteger messageIndex = [USER_DEFAULT integerForKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                    if (messageIndex < indexMsgID) {
                        [USER_DEFAULT setInteger:indexMsgID forKey:KeyChain_Laixin_message_PrivateUnreadIndex];
                        [USER_DEFAULT synchronize];
                    }
                    NSString *msgID = [tools getStringValue:result[@"msgid"] defaultValue:@""];
                    NSString *url = [tools getStringValue:result[@"url"] defaultValue:@""];
                    [self SendImageWithMeImageurl:url withMsgID:msgID];
                }
            }
               [SVProgressHUD dismiss];
          //{"errno":0,"error":"Success","result":{"msgid":80,"url":"http://kidswant.u.qiniudn.com/FlVY_hfxn077gaDZejW0uJSWglk3"}}
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        SLLog(@"error :%@",error.userInfo);
          [SVProgressHUD dismiss];
//        [img hideIndicatorViewBlueOrGary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"上传失败,是否重新上传?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新上传", nil];
        alert.tag = 1;
        [alert show];
    }];
}

#pragma mark - TextView delegate
/*
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        if (![self.inputTextView.text isNilOrEmpty]) {
            
            Message *message = [[Message alloc]init];
            message.name = @"天王盖地虎";
            message.content = self.inputTextView.text;
            message.time = [[NSDate date] timeIntervalSince1970];
            message.avatarURL = [NSURL URLWithString:@"http://tp2.sinaimg.cn/3900241153/50/5679138377/1"];
            //添加到列表
            [self.messageCellHeights addObject:@0];
            [self.messageList addObject:message];
            self.inputTextView.text = @"";
        }
        return NO;
    };
    return YES;
}
*/

- (void) insertTableRow
{
    
    /*[self.tableView beginUpdates];
    
    NSArray *insertion = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.messageList.count inSection:0]];
    
    [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView endUpdates];*/
    
    [self.tableView reloadData];
    [self scrollToBottonWithAnimation:YES];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
   /* if ([keyPath isEqualToString:@"contentSize"]){
        //高度最大为80
        static CGFloat maxHeight = 80;
        
        CGFloat origHeight = _inputTextView.frameHeight;
        _inputTextView.frameHeight = (_inputTextView.contentSize.height<=maxHeight)?_inputTextView.contentSize.height:maxHeight;
        
        CGFloat offset = _inputTextView.frameHeight - origHeight;
//        UIImageView * image = (UIImageView *) [self.inputContainerView subviewWithTag:2];
//        image.frameHeight +=offset;
        
        UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
        imageBg.frameHeight += offset;
        
        self.inputContainerView.frameHeight += offset;
        self.inputContainerView.frameY -= (offset);
        
        //tableView的位置也修正下
        _tableView.contentOffset = CGPointMake(0, _tableView.contentOffset.y+offset);
    }
    */
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    
    //元素位置的改变
    BOOL isPrior = [((NSNumber *)[change objectForKey:NSKeyValueChangeNotificationIsPriorKey]) boolValue];//是否是改变之前进来的
    if (isPrior&&[kind integerValue] != NSKeyValueChangeRemoval) {
        return; //改变之前进来却不是Removal操作就忽略
    }
    
    //获取变化值
    NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
    if (indices == nil){
        return;
    }
    
    NSUInteger indexCount = [indices count];
    NSUInteger buffer[indexCount];
    [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
    
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (int i = 0; i < indexCount; i++) {
        NSUInteger indexPathIndices[2];
        indexPathIndices[0] = 0;
        indexPathIndices[1] = buffer[i];
        NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
        [indexPathArray addObject:newPath];
    }
    //判断值变化是insert、delete、(replace被忽略不需要)。
    if ([kind integerValue] == NSKeyValueChangeInsertion){
        //		//添加对应的Observer
        //		for (NSIndexPath *path in indexPathArray) {
        //			[self addObserverOfChat:self.messageList[path.row]];
        //		}
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        [self scrollToBottonWithAnimation:YES];
    }
    else if ([kind integerValue] == NSKeyValueChangeRemoval){
        //改变之前清除Observer，改变之后剔除TableView里数据，其实用old去获取也可以，但是总觉得没这种方法好
        if (isPrior) {
            //删除对应的Observer
            //			for (NSIndexPath *path in indexPathArray) {
            //				[self removeObserverOfChat:self.chatList[path.row]];
            //			}
        }else{
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
    }
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messageList.count;
}


-(float) heightforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.height + 15 );
}

-(float) widthforsystem14:(NSString * ) text withWidth:(float) width
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return   fmaxf(20.0f, sizeToFit.width + 10 );
}

- (CGSize)heightForCellWithPost:(NSString *)post withWidth:(float) width{
    
//    NSString *osversion = [UIDevice currentDevice].systemVersion;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
        return  sizeToFit;// fmaxf(20.0f, sizeToFit.width + 10 );
    }else{
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0f],NSFontAttributeName,nil];
        
        [post sizeWithAttributes:tdic];
        //ios7方法，获取文本需要的size，限制宽度
        CGSize  actualsize = [post boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        return actualsize;// fmaxf(20.0f, actualsize.height );
    }
}

#pragma mark  cellfor

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  两种信息,   1: 用户间聊天信息    2: 系统公告
     */
    FCMessage *message = self.messageList[indexPath.row];
//    SLog(@"message ID :%@",message.messageId);
    if ([message.messageType intValue] == messageType_SystemAD) {
        //系统公告
        static NSString *CellIdentifier = @"SystemCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * label_text =  (UILabel * )[cell.contentView subviewWithTag:1];
        label_text.text = message.text;
        label_text.layer.cornerRadius = 4.0;
        label_text.layer.masksToBounds = YES;
        float width =  APP_SCREEN_WIDTH * .7;
        float widthtext = [self widthforsystem14:message.text withWidth:width];
        float height = [self heightforsystem14:message.text withWidth:width];
        [label_text sizeToFit];
        [label_text setHeight:height];
        [label_text setWidth:widthtext];
        [label_text setLeft:(APP_SCREEN_WIDTH/2-widthtext/2)];
        return cell;
    }
    
    NSString *CellIdentifier;
    if ([message.messageStatus boolValue])
        CellIdentifier = @"XCJChatMessageCell";
    else
        CellIdentifier = @"XCJMyChatMessageCell";
    
    XCJChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setCurrentMessage:message];
    [cell setConversation:self.conversation];
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    
    imageview.layer.cornerRadius = 4;
    imageview.layer.masksToBounds = YES;
    
    UILabel * labelName = (UILabel *) [cell.contentView subviewWithTag:2];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    int ssinde = indexPath.row%3;
    if (ssinde == 0) {
        labelTime.layer.cornerRadius = 4.0;
        labelTime.layer.masksToBounds = YES;
        labelTime.hidden = NO;
    }else{
        
        labelTime.hidden = YES;
    }
    
//    UILabel * labelContensst = (UILabel *) [cell.contentView subviewWithTag:4];
    UILabel * address = (UILabel *) [cell.contentView subviewWithTag:8];
    UIActivityIndicatorView * indictorView = (UIActivityIndicatorView *) [cell.contentView subviewWithTag:9];
    UIButton * retryButton = (UIButton *) [cell.contentView subviewWithTag:10];
    UIButton * audioButton = (UIButton *) [cell.contentView subviewWithTag:11];
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    UIImageView * Image_playImg = (UIImageView*)[cell.contentView subviewWithTag:13];
    
    OHAttributedLabel* labelContent = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    if (labelContent == nil) {
        labelContent = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        labelContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        labelContent.centerVertically = YES;
        labelContent.automaticallyAddLinksForType = NSTextCheckingAllTypes;
        labelContent.delegate = self;
        labelContent.backgroundColor = [UIColor clearColor];
        labelContent.highlightedTextColor = [UIColor whiteColor];
        labelContent.tag = kAttributedLabelTag;
        [cell addSubview:labelContent];
//        labelContent.backgroundColor = [UIColor colorWithRed:0.142 green:1.000 blue:0.622 alpha:0.210];
    }
    if ([message.messageSendStatus intValue] == 1) //sending
    {
//        if (message.messageId && message.messageId.length > 0) ;
        
        [indictorView startAnimating];
        indictorView.hidden = NO;
        retryButton.hidden = YES;
    }else if ([message.messageSendStatus intValue] == 2) //error
    {
        [indictorView stopAnimating];
        indictorView.hidden = YES;
        retryButton.hidden = NO;
    }
    else  if ([message.messageSendStatus intValue] == 0){ //sended
    {
            [indictorView stopAnimating];
            indictorView.hidden = YES;
            retryButton.hidden = YES;
    }
    }else if([message.messageSendStatus intValue] == 4) // will sending
    {
        [indictorView startAnimating];
        indictorView.hidden = NO;
        retryButton.hidden = YES;
        message.messageSendStatus = @(1);
        NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] init];
        //          create guid
        dictionary[@"MESSAGE_GUID"]  =  message.messageguid;
        dictionary[@"text"]  =  message.text;
        dictionary[@"userid"]  =  self.conversation.facebookId;
        dictionary[@"messagetype"]  = message.messageType;// @(messageType_text);
        NSString  *token =  [[EGOCache globalCache] stringForKey:@"uploadtoken"];
        dictionary[@"token"]  =  token;
        switch ([message.messageType intValue]) {
            case messageType_image:
            case messageType_map:
            {
                dictionary[@"fileSrc"] = message.imageUrl;
            }
                break;
            case messageType_audio:
            {
                dictionary[@"fileSrc"] = message.audioUrl;
                dictionary[@"length"]  = @([self getFileSize:message.audioUrl]);
            }
                break;
            default:
                break;
        }
        [audioButton.layer setValue:message.audioUrl forKey:@"audiourl"];
        [cell SendMessageRemoteImgOper:_objImgListOper WithMessage:dictionary type:messageType_text];
    }
    
    UIImageView * imageview_Img = (UIImageView *)[cell.contentView subviewWithTag:5];
    UIImageView * imageview_BG = (UIImageView *)[cell.contentView subviewWithTag:6];
    
    if ([message.messageStatus boolValue]) {
            //Incoming
            [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByYQImageUrl:self.conversation.facebookavatar]]];
            labelName.text = self.conversation.facebookName;
        labelContent.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
       
    }else{
        //Outcoming
//        cell.backgroundColor = [UIColor whiteColorWithAlpha:.1];
//        imageview_BG.image = [UIImage imageNamed:@"bubbleRightTail-1"];
        [imageview setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_headpic] Size:100]]];
        labelName.text = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_user_nick];
        labelContent.textColor = [UIColor whiteColor];
    }
    
    
    NSString * timeStr = [tools FormatStringForDate:message.sentDate];
//    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12.0f],NSFontAttributeName,nil];
//    CGSize sizetime = [timeStr sizeWithAttributes:tdic];
    
    CGSize sizetime  = [self heightForCellWithPost:timeStr withWidth:300];
    labelTime.text = timeStr ;
    sizetime.width +=6;
    sizetime.height +=6;
    [labelTime setSize:sizetime];
    labelTime.left = (APP_SCREEN_WIDTH - labelTime.width)/2;
    
    
    audioButton.left = 400.0f;
    if ([message.messageType intValue] == messageType_image) {
        Image_playImg.hidden = YES;
        //display image  115 108
        labelContent.text  = @"";
        // /private/var/mobile/Applications/8703284D-476D-40A3-AE21-3BD108796AB5/tmp/5b87a4c4e8a4113611b9a1e77a38f1e5.jpg
        
        if ([message.imageUrl containString:@"private/var/mobile"]) {
            UIImage * imageviewLocal = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",message.imageUrl]];
            UIImage * imageviewLocalNew = [imageviewLocal imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
            [imageview_Img setImage:imageviewLocalNew];
        }else{
            [imageview_Img setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:message.imageUrl Size:160]] placeholderImage:[UIImage imageNamed:@"aio_image_default"]];
            //        imageview_Img.fullScreenImageURL = [NSURL URLWithString:message.imageUrl];

        }
        imageview_Img.userInteractionEnabled = YES;
        UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SeeBigImageviewClick:)];
        [imageview_Img addGestureRecognizer:ges];
        
        imageview_Img.hidden = NO;
        
        [imageview_BG setHeight:121.0f];
        [imageview_BG setWidth:125.0f];
        
        if ([message.messageStatus boolValue])
        {
            [imageview_BG setLeft:55.0f];
            [imageview_Img setLeft:70.0f];
            
            
            indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = imageview_BG.left + imageview_BG.width  ;
            retryButton.top = imageview_BG.height/2  + 10;
            
        }
        else
        {
            [imageview_BG setLeft:137.0f ];
            [imageview_Img setLeft:147.0f];
            
            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -10 ;
            retryButton.top = imageview_BG.height/2  + 10;
        }
        
        [imageview_Img setHeight:100.0f];
        [imageview_Img setWidth:100.0f];
        
        imageview_BG.hidden = NO;

        address.text = @"";
        address.hidden = YES;
        
        labelContent.frame = CGRectMake(0, 0, 0, 0);
        labelContent.attributedText = nil;
    }else if ([message.messageType intValue] == messageType_text) {
        Image_playImg.hidden = YES;
        NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:message.text];
        [mas setFont:[UIFont systemFontOfSize: 17.0f]];
        [mas setTextColor:[UIColor blackColor]];        
        [mas setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping];
        [OHASBasicMarkupParser processMarkupInAttributedString:mas];
        
        labelContent.attributedText = mas;
         imageview_Img.hidden = YES;
//        labelContent.text = message.text;
        //    [self creatAttributedLabel:message.content Label:labelContent];
        /*build test frame */
//        [labelContent sizeToFit];
        
        
        CGSize sizeToFit = [mas sizeConstrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX)];
        
        [labelContent setWidth:sizeToFit.width];
        [labelContent setHeight:sizeToFit.height]; // set label content frame with tinkl
//        CGSize sizeToFitNew = [labelContent sizeThatFits:sizeToFit];        
//        SLLogSize(sizeToFit); SLLogSize(sizeToFitNew);
        
        
//        float xx = [message.messageStatus boolValue] ? 55.0f : APP_SCREEN_WIDTH - (imageview_BG.width + 55);
//        CGRect bgRect = CGRectIntegral(CGRectMake(xx,  kMarginTop, sizeToFit.width + kPaddingTop, sizeToFit.height + kMarginBottom));
        
        //min height and width  is 35.0f
        //    fmaxf(35.0f, sizeToFit.height + 5.0f ) ,fmaxf(35.0f, sizeToFit.width + 10.0f )
        
        sizeToFit.width +=65/2;
        sizeToFit.height+=54/2;  //fit to bgview
        [imageview_BG setHeight:fmaxf(54.0f, sizeToFit.height )];
        [imageview_BG setWidth:fmaxf(65.0f, sizeToFit.width )];
        
        if ([message.messageStatus boolValue])  //me
        {
            [imageview_BG setLeft:55.0f];
            [labelContent setLeft:68.0f];
            labelContent.center = CGPointMake(imageview_BG.center.x+3, imageview_BG.center.y-5);
            
            indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = imageview_BG.left + imageview_BG.width  ;
            retryButton.top = imageview_BG.height/2  + 10;
        }
        else
        {
            [imageview_BG setLeft: APP_SCREEN_WIDTH - (imageview_BG.width + 55)];
            [labelContent setLeft: APP_SCREEN_WIDTH - (labelContent.width + 77 -10 )  ];
            labelContent.center = CGPointMake(imageview_BG.center.x-2, imageview_BG.center.y-3);
            
            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 ;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -5 ;
            retryButton.top = imageview_BG.height/2  + 5;
        }

        imageview_BG.hidden = NO;
        address.text = @"";
        address.hidden = YES;
        
    }else if([message.messageType intValue] == messageType_emj)
    {
        Image_playImg.hidden = YES;
        labelContent.text  = @"";
        //display image  115 108
        [imageview_Img setImage:[UIImage imageNamed:message.text]];
//        imageview_Img.fullScreenImageURL = nil;
        imageview_Img.hidden = NO;
        imageview_Img.userInteractionEnabled = NO;
        [imageview_BG setHeight:108.0f];
        [imageview_BG setWidth:115.0f];
        
        
        [imageview_Img setHeight:100.0f];
        [imageview_Img setWidth:100.0f];
        
        
        if ([message.messageStatus boolValue])
        {
            [imageview_BG setLeft:55.0f];
            [imageview_Img setLeft:65.0f];
            
            indictorView.left = imageview_Img.left + imageview_Img.width  + 5;
            indictorView.top = imageview_Img.height/2  + 20;
            
            retryButton.left = imageview_Img.left + imageview_Img.width  ;
            retryButton.top = imageview_Img.height/2  + 10;
        }
        else
        {
            [imageview_BG setLeft:147 ];
            [imageview_Img setLeft:152.0f];
            
            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10  -10;
            retryButton.top = imageview_BG.height/2  + 10;
            
        }
        
        imageview_BG.hidden = YES;
        address.text = @"";
        address.hidden = YES;
        
        
    }else if([message.messageType intValue] == messageType_map)
    {
        Image_playImg.hidden = YES;
        //display image  115 108
        labelContent.text  = @"";
        [imageview_Img setImageWithURL:[NSURL URLWithString:[tools getUrlByImageUrl:message.imageUrl Size:320]] placeholderImage:[UIImage imageNamed:@"messages_map_image_default"]];
//        imageview_Img.fullScreenImageURL = [NSURL URLWithString:message.imageUrl];
        imageview_Img.hidden = NO;
        [imageview_BG setWidth:174.0f];
        [imageview_BG setHeight:168.0f];
        
        if ([message.messageStatus boolValue])
        {
            [imageview_BG setLeft:55.0f];
            [imageview_Img setLeft:65.0f];
            
            
            indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = imageview_BG.left + imageview_BG.width  ;
            retryButton.top = imageview_BG.height/2  + 10;
            
        }
        else
        {
            [imageview_BG setLeft:88 ];
            [imageview_Img setLeft:92.0f];
            
            
            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
            indictorView.top = imageview_BG.height/2  + 20;
            
            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -10 ;
            retryButton.top = imageview_BG.height/2  + 10;
            
        }
        
        [imageview_Img setHeight:160.0f];
        [imageview_Img setWidth:160.0f];
        
        imageview_BG.hidden = NO;
        imageview_Img.userInteractionEnabled = YES;
        address.text = message.text;
        address.hidden = NO;
        
    }else if([message.messageType intValue] == messageType_audio)
    {

        Image_playImg.hidden = NO;
        labelContent.frame = CGRectMake(0, 0, 0, 0);
        labelContent.attributedText = nil;
        
//      labelContent.text = @"";
//      [self creatAttributedLabel:message.content Label:labelContent];

        /*build test frame */
        [labelContent sizeToFit];
        imageview_Img.hidden = YES;
        //min height and width  is 35.0f
        //    fmaxf(35.0f, sizeToFit.height + 5.0f ) ,fmaxf(35.0f, sizeToFit.width + 10.0f )
        [imageview_BG setHeight:54.0f];
        [imageview_BG setWidth:90.0f];
        
        imageview_BG.hidden = NO;
        address.text = @"";
        address.hidden = YES;
        [audioButton setWidth:100];

        [audioButton.layer setValue:message.audioUrl forKey:@"audiourl"];
        //SLog(@"message.audioLength %@",message.audioLength);
        
        int displayLength = 0;
        if ([message.audioLength intValue] > 1000) {
            int len =[message.audioLength intValue];
            displayLength = len/audioLengthDefine;
        }else{
            if ([message.audioLength intValue] < 0) {
                int leng = [message.audioLength intValue];
                leng = -leng;
                displayLength = leng/audioLengthDefine;
            }else{
                displayLength = [message.audioLength intValue];
               
            }
        }
        
        if (displayLength <= 0) {
            // length for local path
            int  localLength = [self getFileSize:message.audioUrl];
            displayLength = localLength/audioLengthDefine;
        }
        if (displayLength > 0) {
            [audioButton setTitle:[NSString stringWithFormat:@"%d''",displayLength] forState:UIControlStateNormal];
        }else{
            [audioButton setTitle:@" " forState:UIControlStateNormal];
        }
        
        [audioButton addTarget:self action:@selector(playaudioClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([message.messageStatus boolValue])
        {
            [imageview_BG setLeft:55.0f];
            audioButton.left = 60.0f;
            Image_playing.left = audioButton.left + 5.5;//imageview_BG.left + imageview_BG.width + 10;
            
            indictorView.left = imageview_BG.left + imageview_BG.width  + 5;
            indictorView.top = imageview_BG.height/2  + 18;
            
            retryButton.left = imageview_BG.left + imageview_BG.width;
            retryButton.top = imageview_BG.height/2  + 8;
            
//            UIImage * image = [UIImage imageNamed:@"chat_my_bottom_voice_press"];
//            audioButton.imageEdgeInsets = UIEdgeInsetsMake(0.,0., 0., audioButton.frame.size.width - (image.size.width + 5));
//            audioButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., image.size.width);
        }
        else
        {
            [audioButton setWidth:95];
            [imageview_BG setLeft:APP_SCREEN_WIDTH -  imageview_BG.width - 55.0f ];
            audioButton.left = APP_SCREEN_WIDTH -  50.0f -  55.0f -50;
            Image_playing.left =  APP_SCREEN_WIDTH -  imageview_BG.width - 5;// - 55.0f;// - 25;
//            UIImage * image = [UIImage imageNamed:@"chat_my_bottom_voice_press"];
//            audioButton.imageEdgeInsets = UIEdgeInsetsMake(0., audioButton.frame.size.width - (image.size.width + 5.), 0., 0.);
//            audioButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., image.size.width);
            
            indictorView.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 - 5;
            indictorView.top = imageview_BG.height/2  + 18;
            
            retryButton.left = APP_SCREEN_WIDTH - 70 - imageview_BG.width - 10 -10 ;
            retryButton.top = imageview_BG.height/2  + 8;
        }
        Image_playing.top = 40;// imageview_BG.height/2 + 17 ;
         if ([message.messageStatus boolValue])
         {
             //other
             [audioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         }else {
             //self
             [audioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         }
    }
    
    return cell;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Method
/////////////////////////////////////////////////////////////////////////////

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    
//    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
//        return YES;
//        else
//        // Unsupported link type (especially phone links are not supported on Simulator, only on device)
//        return NO;
    CurrentUrl =  [NSString stringWithFormat:@"%@",linkInfo.extendedURL];
    if (linkInfo.extendedURL ) {
        NSString * url = CurrentUrl;
        NSString * toastText;
        if ([url isHttpUrl]) {
            toastText = @"浏览器打开";
        }else if([url isValidPhone])
        {
            toastText = @"电话打开";
        }else{
            toastText = url;
        }
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消 " destructiveButtonTitle:@"复制" otherButtonTitles:toastText, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }else{
        NSAttributedString * newStr = [attributedLabel.attributedText  attributedSubstringFromRange:linkInfo.range];
        CurrentUrl = newStr.string;
        UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"复制" otherButtonTitles:nil, nil];
        alert.tag = 3;
        [alert showInView:self.view];
    }
    
    return NO;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
        if (buttonIndex == 1) {
            [self uploadImage:ImageFile token:TokenAPP];
        }
    }else if(alertView.tag == 2)
    {
        //opden extenturl
        //
    }
}


#pragma mark SeeBigImageviewClick
-(void) SeeBigImageviewClick:(id) sender
{
    UITapGestureRecognizer * ges = sender;
    UIImageView *buttonSender = (UIImageView *)ges.view;
    UIView * uiview =  buttonSender.superview.superview;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        XCJChatMessageCell * cell = (XCJChatMessageCell* ) uiview;
//        if ([cell.currentMessage.messageType  intValue] == messageType_image) {
//            
//            //    UIImageView *buttonSender = (UIImageView*)sender;
//            IDMPhoto * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:cell.currentMessage.imageUrl]];
//            // Create and setup browser
//            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
//            [self presentViewController:browser animated:YES completion:nil];
//        }
        
        [SJAvatarBrowser showImage:buttonSender withURL:cell.currentMessage.imageUrl];
        
    }else{
    
        XCJChatMessageCell * cell = (XCJChatMessageCell* ) uiview.superview;
        if ([cell.currentMessage.messageType  intValue] == messageType_image) {
            
            //    UIImageView *buttonSender = (UIImageView*)sender;
            IDMPhoto * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:cell.currentMessage.imageUrl]];
            // Create and setup browser
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            [self presentViewController:browser animated:YES completion:nil];
        }
    }
    
}

-(IBAction)playaudioClick:(id)sender
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        return;
    }
    
    /*!
     *  隐藏播放图标
     */
    //初始化播放器
    if(player == nil)
    player = [[AVAudioPlayer alloc]init];
    
    UIButton * button = (UIButton*)sender;
    NSString * audiourl = [button.layer valueForKey:@"audiourl"];
    //close or stop other audio
    //[self.tableView reloadData];
    XCJChatMessageCell *cell;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
    {
        cell = (XCJChatMessageCell *)button.superview.superview;
    }else
    {
        cell = (XCJChatMessageCell *)button.superview.superview.superview;
    }
    if (playingCell && cell != playingCell &&  playingCell.isplayingAudio) {
        if (playingURL) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
            [player stop];
        }
        [self StopPlayingimgArray:playingCell];
        playingCell.isplayingAudio = NO;
        
    }
    
//    UIButton * audioButton = (UIButton *) [cell.contentView subviewWithTag:11];
//    audioButton.imageView.image = nil;
    
    if (cell.isplayingAudio) {
        if (playingURL) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
            [player stop];
        }
//        [self.tableView reloadData];
        [self StopPlayingimgArray:cell];
        cell.isplayingAudio = NO;
    }else{
        
        playingCell = cell;
        cell.isplayingAudio = YES;
        //self.messageList[[self.tableView indexPathForCell:cell].row];
        if (audiourl) {
            NSArray *SeparatedArray = [[NSArray alloc]init];
            SeparatedArray =[audiourl componentsSeparatedByString:@"/"];
            NSString * filename = [SeparatedArray  lastObject];
            NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
            //        NSURL * url =  [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",filename]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString * strFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString * fileNameWhole;
            if ([audiourl containString:@".amr"]) {
                if ([audiourl containString:@"wavToAmr"]) {
                    //from local
                    fileNameWhole = [NSString stringWithFormat:@"%@/%@",strFile,filename];
                }else{
                    fileNameWhole = [NSString stringWithFormat:@"%@/%@.amr",strFile,filename];
                }
                
            }else{
                fileNameWhole = [NSString stringWithFormat:@"%@/%@.amr",strFile,filename];
            }
            
            if(![fileManager fileExistsAtPath:fileNameWhole]) //如果不存在
            {
                button.userInteractionEnabled = NO;
                [button showIndicatorView];
                //download audio and play
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                NSURL *URL = [NSURL URLWithString:audiourl];
                NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    SLLog(@"response type : %@",[response MIMEType]);
                    NSString * filename = [response suggestedFilename];
                    return [documentsDirectoryPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",filename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    if(filePath)
                    {
                        NSLog(@"File downloaded to: %@", filePath);
                        [button hideIndicatorView];
                        button.userInteractionEnabled = YES;
                        int leng = [self getFileSize:[NSString stringWithFormat:@"%@",fileNameWhole]];
                        //                [button setTitle:[NSString stringWithFormat:@"%d''",leng/1000] forState:UIControlStateNormal];
                        [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                        
                        //初始化播放器的时候如下设置
                        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                                sizeof(sessionCategory),&sessionCategory);
                        
                        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                                 sizeof (audioRouteOverride), &audioRouteOverride);
                        
                        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                        //默认情况下扬声器播放
                        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                        [audioSession setActive:YES error:nil];
                        playingURL = [NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                        player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
                        [player prepareToPlay];
                        [player play];
                        [self ShowPlayingimgArray:cell withTime:(int) leng/1024];
                    }else{
                        player = nil;
                        [button hideIndicatorView];
                        [self StopPlayingimgArray:playingCell];
                        [button hideIndicatorView];
                        playingCell.isplayingAudio = NO;
                        [UIAlertView showAlertViewWithMessage:@"播放失败,录音文件不存在"];
                    }
                }];
                [downloadTask resume];
            }else{
                button.userInteractionEnabled = YES;
                
                int leng = [self getFileSize:[NSString stringWithFormat:@"%@",fileNameWhole]];
                
                [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:fileNameWhole ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                
                //初始化播放器的时候如下设置
                UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                        sizeof(sessionCategory),&sessionCategory);
                
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                         sizeof (audioRouteOverride), &audioRouteOverride);
                
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                //默认情况下扬声器播放
                [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                [audioSession setActive:YES error:nil];
                
                if ([filename containString:@"wavToAmr.amr"]) {
                    filename = [filename stringByReplacingOccurrencesOfString:@"wavToAmr.amr" withString:@""];
                }
                playingURL = [NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:filename ofType:@"wav"]];
                
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:playingURL error:nil];
                [player prepareToPlay];
                [player play];
                [self ShowPlayingimgArray:cell withTime:(int) leng/audioLengthDefine];
            }
            
        }else
        {
            [self StopPlayingimgArray:playingCell];
            [button hideIndicatorView];
            playingCell.isplayingAudio = NO;
            [UIAlertView showAlertViewWithMessage:@"播放失败,录音文件不存在"];
        }
    }
    
}


-(void) StopPlayingimgArray:(UITableViewCell*) cell
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    [Image_playing stopAnimating];
    [Image_playing.layer removeAllAnimations];
    UIImageView * Image_playImg = (UIImageView*)[cell.contentView subviewWithTag:13];
    Image_playImg.hidden = NO;
 
}

- (void) ShowPlayingimgArray:(UITableViewCell * ) cell withTime:(int) timer
{
    
    
    UIImageView * Image_playImg = (UIImageView*)[cell.contentView subviewWithTag:13];
    Image_playImg.hidden = YES;
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    NSString * string = cell.reuseIdentifier;
    NSArray * gifArray;
    if (![string isEqualToString:@"XCJMyChatMessageCell"]) {
        gifArray = [NSArray arrayWithObjects:
                              [UIImage imageNamedTwo:@"ReceiverVoiceNodePlaying000_ios7"],
                              [UIImage imageNamedTwo:@"ReceiverVoiceNodePlaying001_ios7"],
                              [UIImage imageNamedTwo:@"ReceiverVoiceNodePlaying002_ios7"],
                              [UIImage imageNamedTwo:@"ReceiverVoiceNodePlaying003_ios7"], nil];
    }else{
        gifArray = [NSArray arrayWithObjects:
                              [UIImage imageNamedTwo:@"SenderVoiceNodePlaying000_ios7"],
                              [UIImage imageNamedTwo:@"SenderVoiceNodePlaying001_ios7"],
                              [UIImage imageNamedTwo:@"SenderVoiceNodePlaying002_ios7"],
                    [UIImage imageNamedTwo:@"SenderVoiceNodePlaying003_ios7"],nil];
    }
    
    UIImageView * Image_playing = (UIImageView*)[cell.contentView subviewWithTag:12];
    
    
    Image_playing.animationImages = gifArray; //动画图片数组
	Image_playing.animationDuration = 1; //执行一次完整动画所需的时长
	//    self.Image_playing.animationRepeatCount = 1;  //动画重复次数
	[Image_playing startAnimating];
    
    [self performSelector:@selector(removeImageAnimation:) withObject:cell afterDelay:timer];
}
-(void) removeImageAnimation:(id) cell
{
    UITableViewCell * cellself = cell;
    UIImageView * Image_playing = (UIImageView*)[cellself.contentView subviewWithTag:12];
    [Image_playing stopAnimating];
    Image_playing.image = nil;
     [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    UIImageView * Image_playImg = (UIImageView*)[cellself.contentView subviewWithTag:13];
    Image_playImg.hidden = NO;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCJChatMessageCell * msgcell =(XCJChatMessageCell*) cell;
    UILabel * labelContent = (UILabel *) [msgcell.contentView subviewWithTag:4];
    [labelContent sizeToFit];
    
    /*   Message *message = self.messageList[indexPath.row];
    UILabel * labelTime = (UILabel *) [cell.contentView subviewWithTag:3];
    labelTime.text = [tools timeLabelTextOfTime:message.time];*/
}

- (CGFloat)heightForCellWithPost:(NSString *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return  fmaxf(35.0f, sizeToFit.height + 35.0f );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([self.inputTextView isFirstResponder]) {
        self.inputTextView.inputView = nil;
        [self.inputTextView resignFirstResponder];
        [self.inputTextView reloadInputViews];
    }else
    {
        FCMessage *message = self.messageList[indexPath.row];
        if ([message.messageType intValue] == messageType_text || [message.messageType intValue] == messageType_audio || [message.messageType intValue] == messageType_image) {
            
            if ([message.messageType intValue] == messageType_text && message.text && message.text.length > 0) {
                PasteboardStr = message.text;
            }else{
                PasteboardStr = @"";
            }
            
//            if (message.imageUrl && message.imageUrl.length > 0) {
//                PasteboardStr = message.imageUrl;
//            }
//            if (message.audioUrl && message.audioUrl.length > 0) {
//                PasteboardStr = message.audioUrl;
//            }
            
            UIActionSheet * actionview = [[UIActionSheet alloc] initWithTitle:F(@"%@",PasteboardStr) cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
                
            }] destructiveButtonItem:[RIButtonItem itemWithLabel:@"复制" action:^{
                
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:PasteboardStr];
                [UIAlertView showAlertViewWithMessage:@"已经复制到剪切板"];
                
            }] otherButtonItems:[RIButtonItem itemWithLabel:@"删除" action:^{
                
                [self.messageList removeObject:message];
                [self.tableView reloadData];
                
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                
                [message MR_deleteInContext:localContext];
                
                [localContext MR_saveToPersistentStoreAndWait];// MR_saveOnlySelfAndWait];
                

            }], nil];
            
            [actionview showInView:self.view];
            
            
//            UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:message.text delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"复制", nil];
//             action.tag = 1;
//              PasteboardStr = message.text;
//              [action showInView:self.view];
            
            
        }else if([message.messageType intValue] == messageType_map)
        {
            XCJSendMapViewController *mapview = [self.storyboard instantiateViewControllerWithIdentifier:@"XCJSendMapViewController"];
            CLLocationCoordinate2D mylocation = CLLocationCoordinate2DMake([message.latitude doubleValue], [message.longitude doubleValue]) ;
            mapview.isSeeTaMap = YES;
            mapview.TCoordinate = mylocation;
            mapview.title = message.text;
            mapview.subtitle = @"";
            [self.navigationController pushViewController:mapview animated:YES];
            
        }
    }
}

#pragma mark  heigth for cell

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCMessage *message = self.messageList[indexPath.row];
    
    if ([message.messageType intValue] == messageType_SystemAD) {
        //系统公告
        float width =  APP_SCREEN_WIDTH * .7;
        float height = [self heightforsystem14:message.text withWidth:width];
        return  height + 10.0f;
    }
    
    if ([message.messageType intValue] == messageType_image || [message.messageType intValue] == messageType_emj ) {
        return 148.0f;
    }
    if ([message.messageType intValue] == messageType_map) {
        return 206.0f;
    }
    
    if ([message.messageType intValue] == messageType_text) {
        
        NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:message.text];
        [mas setFont:[UIFont systemFontOfSize: 17.0f]];
        [mas setTextColor:[UIColor blackColor]];
        [mas setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping];
        [OHASBasicMarkupParser processMarkupInAttributedString:mas];
        CGSize sizeToFit = [mas sizeConstrainedToSize:CGSizeMake(222.0f, CGFLOAT_MAX)];
        return sizeToFit.height + 60;
    }
    if ([message.messageType intValue] == messageType_audio) {
        return 80.0f;
    }
    
    return 0.0f;
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
 
    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableView.height = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
        
        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    }];
    
    
    //tableView滚动到底部
    [self scrollToBottonWithAnimation:YES];
    
    
    //    if (self.keyboardView&&self.keyboardView.frameY<self.keyboardView.window.frameHeight) {
    //        //到这里说明其不是第一次推出来的，而且中间变化，无需动画直接变
    ////        self.inputContainerViewBottomConstraint.top = keyboardFrame.size.height;
    //        self.inputContainerView.top = self.view.height - keyboardFrame.size.height - self.inputContainerView.height;
    ////        [self.view setNeedsUpdateConstraints];
    //        return;
    //    }
    
//    [self animateChangeWithConstant:keyboardFrame.size.height withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    //晚一小会获取。
//   [self performSelector:@selector(resetKeyboardView) withObject:nil afterDelay:0.001];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
        
    
     [UIView animateWithDuration:0.3 animations:^{
         
//         self.inputContainerView.height  = 44.0f;
//         UIImageView * imageBg = (UIImageView *) [self.inputContainerView subviewWithTag:6];
//         imageBg.height = 44.0f;
//        ((UIImageView *) [self.inputContainerView subviewWithTag:2]).height = 33.0f;
//         self.inputTextView.height = 33;
         
         self.inputContainerView.top = self.view.height - self.inputContainerView.height;
         self.tableView.height  = self.view.height - self.inputContainerView.height;
     }];
    
    if(self.inputContainerView)
    {
        ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
        ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
        
    }
    
//    [self animateChangeWithConstant:0. withDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue] andCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    self.keyboardView = nil;
}

- (void)animateChangeWithConstant:(CGFloat)constant withDuration:(NSTimeInterval)duration andCurve:(UIViewAnimationCurve)curve
{
    //self.inputContainerViewBottomConstraint.constant = constant;
    [self.view setNeedsUpdateConstraints];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)resetKeyboardView {
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    if (!keyboardWindow||![[keyboardWindow description] hasPrefix:@"<UITextEffectsWindow"]) return;
    self.keyboardView = keyboardWindow.subviews[0];
//#warning 以上只适用于IOS7，其他的系统需要测试。
}

#pragma mark  textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

{
    if([text isEqualToString:@"\n"])  {
        
//        [self SendTextMsgClick:nil];
        return NO;
    }
    
//    UIButton * button = (UIButton *) [self.inputContainerView subviewWithTag:1];
//    if (![text isNilOrEmpty]) { //range.location >= 0 &&
//        button.enabled = YES;
//       [button infoStyle];
//       
//
//        
//    }
//    if (range.location == 0 && [text isNilOrEmpty]) {
//        [button defaultStyle];
//    }
    return YES;
}

#pragma mark UIPanGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.inputTextView isFirstResponder];
}

//这里不会让原本的触摸事件失效
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
#define kKeyboardBaseDuration .25f
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGFloat keyboardOrigY = self.keyboardView.window.frameHeight - self.keyboardView.frameHeight;
        static BOOL shouldDisplayKeyWindow = NO;
        static CGFloat lastVelocityY = 1;
        static BOOL isTouchedInputView = NO;
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            //初始化静态变量
            shouldDisplayKeyWindow = NO;
            lastVelocityY = 1;
            isTouchedInputView = NO;
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            //新的键盘位置
            CGFloat newKeyFrameY  = self.keyboardView.frameY + [panRecognizer locationInView:self.inputContainerView].y;
            //键盘所在window的高度
            CGFloat keyboardWindowFrameHeight = self.keyboardView.window.frameHeight;
            
            //修正最底和最高的位置
            if (newKeyFrameY < keyboardOrigY) {
                newKeyFrameY = keyboardOrigY;
            }else if (newKeyFrameY > keyboardWindowFrameHeight){
                newKeyFrameY = keyboardWindowFrameHeight;
            }
            
            //如果数值未变就不处理
            if (newKeyFrameY == self.keyboardView.frameY) {
                return;
            }else if (!isTouchedInputView) {
                //位置变动过说明动过输入框
                isTouchedInputView = YES;
                self.keyboardView.userInteractionEnabled = NO;
            }
            
            //移动到当前触摸位置
//            self.inputContainerViewBottomConstraint.constant = keyboardWindowFrameHeight - newKeyFrameY;
            [self.view setNeedsUpdateConstraints];
            
            //键盘位置
            self.keyboardView.frameY = newKeyFrameY;
            
            //根据方向判断是否隐藏键盘
            CGPoint velocity = [recognizer velocityInView:self.inputContainerView];
            if (velocity.y<0) {
                shouldDisplayKeyWindow = YES;
            }else{
                shouldDisplayKeyWindow = NO;
            }
            lastVelocityY = velocity.y;
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (!isTouchedInputView) {
                return;
            }
            //修正到适合的数值。
            CGFloat adjustVelocity = fabs(lastVelocityY)/750;
            adjustVelocity = adjustVelocity<1?1:adjustVelocity;
            CGFloat duration = kKeyboardBaseDuration/adjustVelocity;
            
            if (shouldDisplayKeyWindow) {
                //移动到原位置
//                self.inputContainerViewBottomConstraint.constant = self.keyboardView.frameHeight;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    //原键盘位置
                    self.keyboardView.frameY = keyboardOrigY;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                }];
            }else{
                //移动到原位置
//                self.inputContainerViewBottomConstraint.constant = 0;
                [self.view setNeedsUpdateConstraints];
                [UIView animateWithDuration:duration animations:^{
                    [self.view layoutIfNeeded];
                    self.keyboardView.frameY = self.keyboardView.window.frameHeight;
                } completion:^(BOOL finished) {
                    self.keyboardView.userInteractionEnabled = YES;
                    //这样可以把原生的动画给覆盖掉，不显示
                    [UIView animateWithDuration:0. animations:^{
                        [self.inputTextView resignFirstResponder];
                    }];
                }];
            }
            
        }
    }
}


#pragma mark other common
- (void)scrollToVisibleRow:(NSInteger )index
{
    if (self.messageList.count<=0) {
        return;
    }
    
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]  atScrollPosition:UITableViewScrollPositionNone
                                      animated:NO];
    }
    
    
    
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
}


#pragma mark other common
- (void)scrollToBottonWithAnimation:(BOOL)animation
{
    if (self.messageList.count<=0) {
        return;
    }
    
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        id lastOject = [self.messageList lastObject];
        int indexOfLastRow = [self.messageList indexOfObject:lastOject];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLastRow inSection:0]  atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animation];
    }
    
 
    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
}

- (IBAction)EmjViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = YES;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = NO;
    if(!self.inputTextView.isFirstResponder)
    {
        [self.inputTextView becomeFirstResponder];
    }
        
    self.inputTextView.inputView = nil;
    self.inputTextView.inputView = EmjView;
    EmjView.top = self.view.height - keyboardHeight;
    [self.inputTextView reloadInputViews];
    
}

- (IBAction)KeyBoradViewShow:(id)sender {
    
    ( (UIButton*) [self.inputContainerView subviewWithTag:4]).hidden = NO;
    ( (UIButton*) [self.inputContainerView subviewWithTag:5]).hidden = YES;
    self.inputTextView.inputView = nil;
    EmjView.top = self.view.height;
    [self.inputTextView becomeFirstResponder];
    [self.inputTextView reloadInputViews];
    
}




@end
