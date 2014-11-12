//
//  ChatViewController.h
//  ISClone
//
//  Created by Molon on 13-12-4.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZBMessageInputView.h"
#import "ZBMessageShareMenuView.h"
#import "ZBMessageManagerFaceView.h"


typedef NS_ENUM(NSInteger,ZBMessageViewState) {
    ZBMessageViewStateShowFace,
    ZBMessageViewStateShowShare,
    ZBMessageViewStateShowNone,
};

@class Conversation,FCUserDescription;
@interface ChatViewController : UIViewController


@property (nonatomic,strong) ZBMessageInputView *messageToolView;

@property (nonatomic,strong) ZBMessageManagerFaceView *faceView;

@property (nonatomic,strong) ZBMessageShareMenuView *shareMenuView;

@property (nonatomic,assign) CGFloat previousTextViewContentHeight;

- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state;

@property (readwrite, nonatomic, strong) Conversation *conversation;

@property (readwrite, nonatomic, strong) FCUserDescription *userinfo;

@property (nonatomic, strong) NSString * gid;

- (void) fetchNewDataWithLastID;

-(IBAction)SeeUserOrdersClick:(id)sender;

@end
