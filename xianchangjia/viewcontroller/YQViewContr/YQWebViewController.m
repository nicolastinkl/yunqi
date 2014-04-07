//
//  YQWebViewController.m
//  yunqi
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQWebViewController.h"
#import "XCAlbumAdditions.h"
#import "UINavigationController+SGProgress.h"
#import "ChatViewController.h"
#import "CoreData+MagicalRecord.h"
#import "FCMessage.h"
#import "Conversation.h"


@interface YQWebViewController ()<UIWebViewDelegate>

@end

@implementation YQWebViewController

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
	// Do any additional setup after loading the view.
    UIWebView * webview = (UIWebView*) [self.view subviewWithTag:1];
    webview.delegate = self;
    webview.backgroundColor = [UIColor clearColor];
//    [webview setHeight:APP_SCREEN_HEIGHT];
//    [self followScrollView:webview];
    [self.view showIndicatorViewLargeBlue];
    [webview loadRequest:
     [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://m.xmato.com/"]]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendurltouser:) name:@"SENDURLTOUSER" object:nil];
}


-(NSString * ) getMD4HashWithObj
{
    NSTimeInterval doub = [[NSDate date] timeIntervalSinceNow];
    int x = arc4random() % 1000000;
    NSString * guid = [[NSString stringWithFormat:@"%f%d",doub, x] md5Hash];
    SLLog(@"gener guid: %@",guid);
    return guid;
}

-(void)sendurltouser :(NSNotification * ) notify
{
    UIWebView * webview = (UIWebView*) [self.view subviewWithTag:1];
    NSString * string = [NSString stringWithFormat:@"%@", webview.request.URL];
    
    if ([string isNilOrEmpty]) {
        [UIAlertView showAlertViewWithMessage:@"没有网址信息"];
        return;
    }
    Conversation * wechat = notify.object;
    
    [SVProgressHUD showWithStatus:@"正在转发消息..."];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:wechat.facebookId forKey:@"weChatId"];
    [params setValue:@{@"content":string,@"msgType":@"text"} forKey:@"message"];
    [params setValue:[self getMD4HashWithObj] forKey:@"messageId"];
    
    [[DAHttpClient sharedDAHttpClient] postRequestWithParameters:params Action:@"AdminApi/WeChat/SendMessage" success:^(id obj) {
        
        int errorCode  = [DataHelper getIntegerValue:obj[@"code"] defaultValue:-1];
        if (errorCode == 200) {
            [SVProgressHUD dismiss];
            // target to chat view
            NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",wechat.facebookId];
            Conversation * conversation =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
            ChatViewController * chatview = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            if (conversation) {
                
                // create new
                conversation.lastMessage = string;
                conversation.lastMessageDate = [NSDate date];
                conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
                conversation.messageStutes = @(messageStutes_incoming);
                
                conversation.facebookId = wechat.facebookId;
                conversation.badgeNumber = @0;
                
                {
                    //系统消息公告
                    FCMessage * msg = [FCMessage MR_createInContext:localContext];
                    msg.messageType = @(messageType_text);
                    msg.wechatid = wechat.facebookId;
                    msg.text = string;
                    msg.sentDate = [NSDate date];
                    msg.audioUrl = @"";
                    // message did not come, this will be on rigth
                    msg.messageStatus = @(NO);
                    msg.messageId =  [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,@"0"];
                    msg.messageguid = @"";
                    msg.messageSendStatus = @0;
                    msg.read = @YES;
                    conversation.lastMessage = msg.text;
                    [conversation addMessagesObject:msg];
                    
                    [localContext MR_saveOnlySelfAndWait];
                    chatview.conversation = conversation;
                    chatview.title = conversation.facebookName;
                    [self.navigationController pushViewController:chatview animated:YES];
                }
            }
        }else
        {
            [UIAlertView showAlertViewWithMessage:@"消息转发失败"];
        }
    } error:^(NSInteger index) {
        [UIAlertView showAlertViewWithMessage:@"消息转发失败"];
    }];

        

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationController showSGProgressWithDuration:3 andTintColor:ios7BlueColor];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideIndicatorViewBlueOrGary];
    [self.navigationController finishSGProgress];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view hideIndicatorViewBlueOrGary];
    [self showErrorInfoWithRetry];
    [self.navigationController finishSGProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
