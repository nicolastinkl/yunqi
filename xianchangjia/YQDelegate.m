//
//  YQDelegate.m
//  yunqi
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.

#import "YQDelegate.h"
#import "MobClick.h"
#import "CRGradientNavigationBar.h"
#import "XCAlbumAdditions.h"
#import "XCAlbumDefines.h"
#import "SinaWeibo.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "CoreData+MagicalRecord.h"
#import "LXChatDBStoreManager.h"
#import "UIAlertViewAddition.h"
#import <AudioToolbox/AudioToolbox.h>
#import "blocktypedef.h"
#import "XCAlbumDefines.h"
#import "Conversation.h"
#import "FCReplyMessage.h"
#import "LXUser.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "FCBeAddFriend.h"
#import "XCJGroupPost_list.h"
#import "FCBeInviteGroup.h"
#import "FCHomeGroupMsg.h"
#import "ConverReply.h"
#import "CoreData+MagicalRecord.h"
#import "FCContactsPhone.h"
#import "FCUserDescription.h"
#import "FCMessage.h"
#import "Reachability.h"
#import "FDStatusBarNotifierView/FDStatusBarNotifierView.h"
#import "YQOrderMetaViewcontroller.h"
#import "YQListOrderInfo.h"
#import "ChatViewController.h"
#import "TKSignalWebScoket.h"

#import "JSONKit.h"

#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
//#import "TestFlight.h"

static NSString * const kLaixinStoreName = @"YunqiDB";

#define UIColorFromRGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]


@implementation YQDelegate

@synthesize launchingWithAps;

#pragma mark update umeng data
- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:kAppkeyForYoumeng reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    //      [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}


- (void)onlineConfigCallBack:(NSNotification *)note {
    
//    SLLog(@"online config has fininshed and note = %@", note.userInfo);
}


-(void)applicationDidFinishLaunching:(UIApplication *)application
{
//    NSArray *colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0xf16149).CGColor, (id)UIColorFromRGB(0xf14959).CGColor, nil];
//    ///setup 4:
//    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // start of your application:didFinishLaunchingWithOptions // ...
    //[TestFlight takeOff:@"2a29f692-4783-4ad5-b569-0a317d612b60"];
    // The rest of your application:didFinishLaunchingWithOptions method// ...
    
    //  友盟的方法本身是异步执行，所以不需要再异步调用
    [self umengTrack];
    [MobClick checkUpdate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.launchingWithAps=[launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]; 
    [self initAllControlos];
    //注册推送通知
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeNewsstandContentAvailability)];
    
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reach startNotifier];
    
    if ([YQDelegate hasLogin]) {
        [self laixinStepupDB:[USER_DEFAULT valueForKey:KeyChain_yunqi_account_token]];
        
        //retry
        /*[[DAHttpClient sharedDAHttpClient] postRequestWithParameters:nil Action:@"AdminApi/Web7.Cloud7Tenant/RegActiveTarget" success:^(id obj) {
         } error:^(NSInteger index) {
         }];*/
        
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        
        //第一次调用这个方法的时候，系统会提示用户让他同意你的app获取麦克风的数据
        // 其他时候调用方法的时候，则不会提醒用户
        // 而会传递之前的值来要求用户同意
//        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//            if (granted) {
//                // 用户同意获取数据
//            } else {
//                // 可以显示一个提示框告诉用户这个app没有得到允许？
//            }
//        }];
    
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风
                });
            }
        }];
    }

#endif
    //[[UIView appearance] setTintColor:[UIColor colorWithHex:SystemKidsColor]];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:SystemKidsColor]];
    //self.window.tintColor = [UIColor colorWithHex:SystemKidsColor];
    
    
    // receive websocket message
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webSocketDidReceivePushMessage:)
                                                 name:MLNetworkingManagerDidReceivePushMessageNotification
                                               object:nil];
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(laixinCloseNotification:)
                                                 name:LaixinCloseDBMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(laixinStepupNotification:)
                                                 name:LaixinSetupDBMessageNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginInReceivingAllMessage)
                                                 name:@"LoginInReceivingAllMessage"
                                               object:nil];
    
    
    
    
    /*
    YQHomeMessageViewController *vc = [[YQHomeMessageViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    MLNavigationController *nacVC = [[MLNavigationController alloc]initWithRootViewController:vc];
    nacVC.title = @"消息";
    
    YQHomeMessageViewController *vc1 = [[YQHomeMessageViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
    MLNavigationController *nacVC1 = [[MLNavigationController alloc]initWithRootViewController:vc1];
    nacVC.title = @"订单";
    
    YQHomeMessageViewController *vc2 = [[YQHomeMessageViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:2];
    MLNavigationController *nacVC2 = [[MLNavigationController alloc]initWithRootViewController:vc2];
    nacVC.title = @"云起";
    
    YQHomeMessageViewController *vc3 = [[YQHomeMessageViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.tabBarItem = [[UITabBarItem alloc]initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:3];
    MLNavigationController *nacVC3 = [[MLNavigationController alloc]initWithRootViewController:vc3];
    nacVC.title = @"设置";
    
    UITabBarController * tabBar = [[UITabBarController alloc] init];
    [tabBar setViewControllers:@[nacVC,nacVC1,nacVC2,nacVC3]];
    tabBar.selectedIndex = 0;
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];*/
    
    
    // Override point for customization after application launch.
    return YES;
}

-(void) reachabilityChanged: (NSNotification*)note {
    Reachability * reach = [note object];
    if(![reach isReachable])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
        // notify websocket close
//        [UIAlertView showAlertViewWithMessage:@"网络不可用,请检查您的网络设置"];
        
    }else{
        // notify websocket reConntect
//        [self LoginInReceivingAllMessage];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketDidOpen" object:nil];
    }
}

-(void) webSocketDidReceivePushMessage:(NSNotification * ) notify
{
    if (notify.userInfo) {
        /* MessageId = "YunqiQinqinConnection;af67aa246b8f4a12b157e47ccbaca6e2";
         PayLoad =     {
         Content = "\U4e91\U8d77\U4eb2\U4eb2\U6b22\U8fce\U60a8\U52a0\U5165ads";
         Title = "<null>";
         ==================================
         
         PayLoad =     {
         Content = "{\
         
         "title\":null,\
         
         "content\":\"\U8bfa\U666e:\U201c\U4e91\U8d77\U8f7b\U5e94\U7528 Cloud7.com.cn\U201d \U662f\U4e00\U4e2a\U53ef\U4ee5\U5feb\U901f\U5e2e\U52a9\U4e2a\U4eba\U6216\U5546\U6237\U521b\U5efa\U5b98\U65b9\U624b\U673a\U8f7b\U5e94\",\
         "time\":\"2014-06-15T08:47:37.194Z\",\
         "badge\":-1,\
         "appLink\":\"WeChat://Message/ocUAetzTkLjV0wb7ZQkQs-srgvcE\",\
         "data\":\"{\\\"time\\\":\\\"2014-06-15T08:47:37.194Z\\\",\\\"message\\\":{\\\"msgType\\\":\\\"text\\\",\\\"content\\\":\\\"\U201c\U4e91\U8d77\U8f7b\U5e94\U7528 Cloud7.com.cn\U201d \U662f\U4e00\U4e2a\U53ef\U4ee5\U5feb\U901f\U5e2e\U52a9\U4e2a\U4eba\U6216\U5546\U6237\U521b\U5efa\U5b98\U65b9\U624b\U673a\U8f7b\U5e94\\\"},\\\"messageId\\\":\\\"83c94096-9184-418a-bc5a-171f4e5498fd\\\",\\\"from\\\":\\\"ocUAetzTkLjV0wb7ZQkQs-srgvcE\\\",\\\"to\\\":\\\"admin\\\"}\"}";
         Title = "<null>";
         };
         */
        
        id message = notify.userInfo[@"message"];
        
        if ([message isKindOfClass:[NSDictionary class]]) {

            NSDictionary * dict = message[@"PayLoad"];
            
          
            
            if (dict) {
                
                
//                NSString  * title = [DataHelper getStringValue:dict[@"Title"] defaultValue:@""];
                
                id objdata = dict[@"Content"];
                  SLog(@"message %@",[objdata JSONString]);
                /*if ([obj isKindOfClass:[NSString class]]) {
                    
                    NSString  * content = [DataHelper getStringValue:dict[@"Content"] defaultValue:@""];
                    
                    if (title.length > 0) {
                        [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:F(@"%@ %@",title,content)];
                    }else{
                        [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:content];
                    }
                }else if ([obj isKindOfClass:[NSDictionary class]])
                {
                }*/
                
                if ([objdata isKindOfClass:[NSString class]]) {
                    id obj =  [objdata objectFromJSONString];
                    if ([obj isKindOfClass:[NSDictionary class]])
                    {
                        if (obj) {
                            
                            NSString  * applick = [DataHelper getStringValue:obj[@"appLink"] defaultValue:@""];
                            
                            id dataObj = obj[@"data"];
                            NSDictionary * dataDict ;
                            if ([dataObj isKindOfClass:[NSDictionary class]]) {
                                dataDict = dataObj;
                            }else{
                                dataDict=[DataHelper getDictionaryValue:[dataObj objectFromJSONString] defaultValue:[NSMutableDictionary dictionary]];
                            }
                            SLog(@"dataDict %@",dataDict);
                            if ([applick containString:@"WeChat"]) {
                                //  未读消息
                                [self saveLocalDatawithJson:dataDict notify:obj];
                               
                            }else if([applick containString:@"OrderManager"]){
                                // 订单状态
                                if (dataDict) {
                                    
                                    NSInteger orderid = [DataHelper getIntegerValue:dataDict[@"OrderId"] defaultValue:0];
                                    NSString * orderNO =[DataHelper getStringValue:dataDict[@"OrderNo"] defaultValue:@""];
                                    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
                                    [params setValue:@(orderid) forKey:@"orderId"];
                                    [params setValue:orderNO forKey:@"orderNo"];
                                    //orderpro
                                    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/ConsumerOrder" success:^(id obj) {
                                        int code = [DataHelper getIntegerValue: obj[@"code"] defaultValue:0];
                                        if (code == 200) {
                                            [SVProgressHUD dismiss];
                                            NSDictionary * dataDict = obj[@"data"];
                                            YQListOrderInfo * infoDic = [YQListOrderInfo turnObject:dataDict];
                                            if (infoDic) {
                                                [tools playVirate];
                                                
                                                NSString  * contentNotify = [DataHelper getStringValue:obj[@"content"] defaultValue:@""];
                                                [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:contentNotify];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationCenter_RefreshOrderTableView object:infoDic];
                                                [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"查看新订单" cancelButtonItem:[RIButtonItem itemWithLabel:@"取消" action:^{
                                                    
                                                }] otherButtonItems:[RIButtonItem itemWithLabel:@"查看" action:^{
                                                    if (infoDic) {
                                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StoryboardYunQi" bundle:nil];
                                                        YQOrderMetaViewcontroller * ordrmeta  = [storyboard instantiateViewControllerWithIdentifier:@"YQOrderMetaViewcontroller"];
                                                        ordrmeta.orderpro = infoDic;
                                                        ordrmeta.title = @"订单详情";
                                                        
                                                        UINavigationController * navi = self.tabBarController.childViewControllers[self.tabBarController.selectedIndex];
                                                        [navi pushViewController:ordrmeta animated:YES];
                                                    }
                                                    
                                                }], nil] show];
                                            }
                                            
                                        }
                                        
                                    } error:^(NSInteger index) {
                                    }];

                                }
                                
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
}
/*!

 {
 from = ocUAetzPcjvjc7OJOUburCuQ7LNM;
 message =     {
    content = "If if";
    msgType = text;
 };
 messageId = "900d3c77-fa43-4e37-9dfe-5586d60723d9";
 time = "2014-06-16T02:08:57.544Z";
 to = admin;
 }

 *
 *  @param Dict
 */
-(void) saveLocalDatawithJson:(NSDictionary * ) Dict  notify:(id) objDict
{
    NSDictionary * obj  = Dict[@"message"];
    NSString * lastMessageTime = [DataHelper getStringValue:Dict[@"time"] defaultValue:@""];
    lastMessageTime = [tools datebyStrByYQQQ:lastMessageTime];
//    NSString * name = [DataHelper getStringValue:obj[@"name"] defaultValue:@""];
//    NSString * avatar = [DataHelper getStringValue:obj[@"avatar"] defaultValue:@""];
    NSDate * date = [tools datebyStr:lastMessageTime];
    NSString * wechatId = [DataHelper getStringValue:Dict[@"from"] defaultValue:@""];
    if ([wechatId isEqualToString:@"admin"]) {
        //来自同一个人发送 回执处理
        return;
    }
    
    NSString  * contentNotify = [DataHelper getStringValue:objDict[@"content"] defaultValue:@""];
    [[FDStatusBarNotifierView sharedFDStatusBarNotifierView] showInWindowMessage:contentNotify];
    
    [tools playVirate];
//    NSString * to = [DataHelper getStringValue:Dict[@"to"] defaultValue:@""];
    NSString * content = [DataHelper getStringValue:obj[@"content"] defaultValue:@""];
    NSString * lastMessageId = [DataHelper getStringValue:Dict[@"messageId"] defaultValue:@""];
    NSString * typeMessage = [DataHelper getStringValue:obj[@"msgType"] defaultValue:@""];
    { //更新列表信息
        // Build the predicate to find the person sought
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", wechatId];
        Conversation *conversation = [Conversation MR_findFirstWithPredicate:predicate inContext:localContext];
        if(conversation == nil)
        {
            conversation =  [Conversation MR_createInContext:localContext];
        }
        if ([content isNilOrEmpty]) {
            content = @"";
        }
        if ([typeMessage isEqualToString:@"text"]) {
            
        }else if ([typeMessage isEqualToString:@"image"]) {
            //image
            content = @"[图片]";
        }else if ([typeMessage isEqualToString:@"voice"]) {
            content = @"[语音]";
        }
        conversation.messageId = lastMessageId;
        //    conversation.facebookName = name;
        conversation.messageType = @(XCMessageActivity_UserPrivateMessage);
        conversation.lastMessageDate = date;
        //                        conversation.messageId = [NSString stringWithFormat:@"%@_%@",XCMessageActivity_User_privateMessage,[tools getStringValue:obj[@"msgid"] defaultValue:@"0"]];
        conversation.lastMessage = content ;
        conversation.messageStutes = @(messageStutes_incoming);
        conversation.facebookId = wechatId;
        //    conversation.facebookavatar = avatar;
        // increase badge number.
        int badgeNumber = [conversation.badgeNumber intValue];
        badgeNumber += 1;
        conversation.badgeNumber = [NSNumber numberWithInt:badgeNumber];
        [localContext MR_saveToPersistentStoreAndWait];
        
    }
    
    {
        FCMessage * msgOld =  [[FCMessage MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"messageId == %@",lastMessageId]] firstObject];
        if (!msgOld || ![lastMessageId isEqualToString:@""]) {
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            
            FCMessage* msg = [FCMessage MR_createInContext:localContext];
            if ([content isNilOrEmpty]) {
                content = @"";
            }
            SLog(@"content :%@",content);
            msg.text = content;
            msg.sentDate = date;
            msg.wechatid = wechatId;
            msg.messageId = lastMessageId;
            if ([typeMessage isEqualToString:@"text"]) {
                msg.messageType = @(messageType_text);
            }else if ([typeMessage isEqualToString:@"image"]) {
                //image
                msg.messageType = @(messageType_image);
                NSString * publicUrl = [DataHelper getStringValue:obj[@"mediaPath"] defaultValue:@""];
                msg.imageUrl = publicUrl;
            }else if ([typeMessage isEqualToString:@"voice"]) {
                //audio
                NSString * publicUrl = [DataHelper getStringValue:obj[@"mediaPath"] defaultValue:@""];
                msg.audioUrl = publicUrl;
                msg.messageType = @(messageType_audio);
                int length  = 10;//
                msg.audioLength = @(length/1024);
            }else{
                msg.messageType = @(messageType_text);
            }
            msg.messageStatus = @(YES);
            [localContext MR_saveToPersistentStoreAndWait];// MR_saveOnlySelfAndWait];
            
            //最新的数据推送给聊天界面
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationCenter_RefreshChatTableView object:msg];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"messagewithNewRefreshHome" object:wechatId];
        }
        
        
    }
}

- (void) initAllControlos
{
    self.tabBarController = (UITabBarController *)((UIWindow*)[UIApplication sharedApplication].windows[0]).rootViewController;
//    self.tabBarController.delegate = self;
    
    if ([UITabBar instancesRespondToSelector:@selector(setSelectedImageTintColor:)]) {
        [self.tabBarController.tabBar setSelectedImageTintColor:[UIColor colorWithHex:0xff008ccd]];
    }
    
//        [self.tabBarController.tabBar setBarTintColor:[UIColor colorWithHex:0xff008ccd]];
    
    {
        UIImage *musicImage = [UIImage imageNamed:@"msgitem_Click"];
//        musicImage = [musicImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        UITabBarItem * item = self.tabBarController.tabBar.items[0];
        item.selectedImage = musicImage;
    }
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[1];
        item.selectedImage = [UIImage imageNamed:@"orderitem_clickpng"];
    }
  
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[2];
        item.selectedImage = [UIImage imageNamed:@"orderitem_clicked"];
    }
   
    {
        UITabBarItem * item = self.tabBarController.tabBar.items[3];
        item.selectedImage = [UIImage imageNamed:@"meitem_Click"];
    }
}


-(void) LoginInReceivingAllMessage
{
    /*
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if([YQDelegate hasLogin]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidreceingWithMsg" object:nil];
            
            NSString * sessionid = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid];
            NSDictionary * parames = @{@"sessionid":sessionid};
            [[MLNetworkingManager sharedManager] sendWithAction:@"session.start"  parameters:parames success:^(MLRequest *request, id responseObjectsss) {
                
                NSDictionary * userinfo = responseObjectsss[@"result"];
                LXUser *currentUser = [[LXUser alloc] initWithDict:userinfo];
                if (currentUser) {
                    [[LXAPIController sharedLXAPIController] setCurrentUser:currentUser];
                    [self ReceiveAllMessage];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
                }
            } failure:^(MLRequest *request, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
            }];
        }
    });*/
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* devtokenstring=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@" " withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	devtokenstring=[devtokenstring stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //devtokenstring:  d8009e6c8e074d1bbcb592f321367feaef5674a82fc4cf3b78b066b7c8ad59bd
    SLog(@"devtokenstring : %@",devtokenstring);
    
    [USER_DEFAULT setValue:devtokenstring forKey:KeyChain_Laixin_account_devtokenstring];
    [USER_DEFAULT synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    SLog(@"userInfo %@",userInfo);
    //如果程序在前台显示就自动忽略

    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    if (userInfo) {
        // web7Link = "WeChat://Message/ocUAetzPcjvjc7OJOUburCuQ7LNM";
        // web7Link = "OrderManager://ordercreated?orderid=39&orderno=1406202332299";
        NSString * applink =  [DataHelper getStringValue:userInfo[@"web7Link"] defaultValue:@""];
        NSURL * url = [NSURL URLWithString:applink];
        /*if ([applink containString:@"OrderManager"]) {
            //订单管理
        }else if ([applink containString:@"WeChat"]) {
            //个人私信
        }*/
        
        UINavigationController * navi = self.tabBarController.childViewControllers[self.tabBarController.selectedIndex];
        if ([navi.visibleViewController isKindOfClass:[ChatViewController class]]) {
            ChatViewController * chat = (ChatViewController *) navi.visibleViewController;
            [chat fetchNewDataWithLastID];
            return;
        }
        
        if ([[url host] isEqualToString:@"ordercreated"] || [[url host] isEqualToString:@"orderpaid"] || [[url host] isEqualToString:@"ordercanceled"]) {
            // 新订单
            //        NSString * newUrl = [url absoluteString];
            //        NSString * itemId = [newUrl stringByReplacingOccurrencesOfString:@"ordermanager://ordercreated/" withString:@""];
            
            NSString * urlQuery = [url query];
            NSArray *firstSplit = [urlQuery componentsSeparatedByString:@"&"];
            //orderid=91872834&orderno=oqweiruoqr
            NSString * orderid = [firstSplit firstObject];
            NSString * orderno = [firstSplit lastObject];
            orderid = [orderid  stringByReplacingOccurrencesOfString:@"orderid=" withString:@""];
            orderno = [orderno  stringByReplacingOccurrencesOfString:@"orderno=" withString:@""];
            [self queryOrderInfoWithOrderID:orderid orderNo:orderno];
            
        }else if ([[url host] isEqualToString:@"Message"]) {
            
            NSString * itemId = [[url absoluteString] stringByReplacingOccurrencesOfString:@"WeChat://Message/" withString:@""];
            if ([itemId isEqualToString:@"UnRead"]) {
                // 未读消息
                
            }else{
                // 微信消息
                if (itemId && itemId.length > 0) {
                    [self targetWeichatView:itemId];
                }
            }        
        }

        
    }
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    SLLog(@"error : %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    /*
     新订单：OrderManager://ordercreated/<Order>
     订单已付款：OrderManager://orderpaid/<Order>
     订单取消：OrderManager://ordercanceled/<Order>
     
     微信消息：WeChat://WeChat/12
     未读消息：WeChat://WeChat/UnRead
     
     OrderManager://orderpaid?orderid=91872834&orderno=oqweiruoqr
     
    */
    
    NSLog(@"url openURL .......    %@  ....   %@   ",[url query],[url host]);
    
    if ([[url host] isEqualToString:@"ordercreated"] || [[url host] isEqualToString:@"orderpaid"] || [[url host] isEqualToString:@"ordercanceled"]) {
        // 新订单
//        NSString * newUrl = [url absoluteString];
//        NSString * itemId = [newUrl stringByReplacingOccurrencesOfString:@"ordermanager://ordercreated/" withString:@""];
        
        NSString * urlQuery = [url query];
        NSArray *firstSplit = [urlQuery componentsSeparatedByString:@"&"];
        //orderid=91872834&orderno=oqweiruoqr
        NSString * orderid = [firstSplit firstObject];
        NSString * orderno = [firstSplit lastObject];
        orderid = [orderid  stringByReplacingOccurrencesOfString:@"orderid=" withString:@""];
        orderno = [orderno  stringByReplacingOccurrencesOfString:@"orderno=" withString:@""];
        [self queryOrderInfoWithOrderID:orderid orderNo:orderno];
        
    }else if ([[url host] isEqualToString:@"Message"]) {
        
        NSString * itemId = [[url absoluteString] stringByReplacingOccurrencesOfString:@"wechat://Message/" withString:@""];
        if ([itemId isEqualToString:@"UnRead"]) {
            // 未读消息
            
        }else{
            // 微信消息
            if (itemId && itemId.length > 0) {
                [self targetWeichatView:itemId];
            }
        }        
    }
    
    return YES;
}

-(void) targetWeichatView:(NSString *  ) weichatID
{
    if([YQDelegate hasLogin])
    {
        NSManagedObjectContext *localContext  = [NSManagedObjectContext MR_contextForCurrentThread];
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"facebookId == %@",weichatID];
        Conversation * conversation =  [Conversation MR_findFirstWithPredicate:pre inContext:localContext];
        if (conversation) {
            // create new
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StoryboardYunQi" bundle:nil];
            ChatViewController * chatview = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            chatview.conversation = conversation;
            chatview.title = conversation.facebookName;
            
            UINavigationController * navi = self.tabBarController.childViewControllers[self.tabBarController.selectedIndex];
            [navi pushViewController:chatview animated:YES];
            [chatview fetchNewDataWithLastID];            //拉取增量数据
        }
    }
}


-(void) queryOrderInfoWithOrderID:(NSString*)orderID orderNo:(NSString *) orderNO
{
    
    if([YQDelegate hasLogin])
    {
        if (orderID && orderID.length > 0) {
            
            [SVProgressHUD showWithStatus:@"正在加载订单..."];
            NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
            [params setValue:orderID forKey:@"orderId"];
            [params setValue:orderNO forKey:@"orderNo"];
            //orderpro
            [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/ConsumerOrder" success:^(id obj) {
                int code = [DataHelper getIntegerValue: obj[@"code"] defaultValue:0];
                if (code == 200) {
                    [SVProgressHUD dismiss];
                    NSDictionary * dataDict = obj[@"data"];
                    YQListOrderInfo * info = [YQListOrderInfo turnObject:dataDict];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StoryboardYunQi" bundle:nil];
                    YQOrderMetaViewcontroller * ordrmeta  = [storyboard instantiateViewControllerWithIdentifier:@"YQOrderMetaViewcontroller"];
                    ordrmeta.orderpro = info;
                    ordrmeta.title = @"订单详情";
                    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationCenter_RefreshOrderTableView object:info];
                    UINavigationController * navi = self.tabBarController.childViewControllers[self.tabBarController.selectedIndex];
                    [navi pushViewController:ordrmeta animated:YES];
                }else{
                    [UIAlertView showAlertViewWithMessage:@"订单加载失败"];
                }
            } error:^(NSInteger index) {
                [UIAlertView showAlertViewWithMessage:@"订单加载失败"];
            }];
        }else{
            [UIAlertView showAlertViewWithMessage:@"订单不存在"];
        }
    }
   
    
}

- (void)laixinCloseNotification:(NSNotification *)notification
{
    if (notification.object) {
        NSString * userID = [DataHelper getStringValue:notification.object defaultValue:@""];
        if (userID.length > 0) {
            
            NSString * strDBName = [NSString stringWithFormat:@"%@_%@.sqlite",kLaixinStoreName,[userID md5Hash]];
            [self copyDefaultStoreIfNecessary:strDBName];
            [MagicalRecord cleanUp];
        }
    }else{
        [self copyDefaultStoreIfNecessary:kLaixinStoreName];
        [MagicalRecord cleanUp];
    }     
}

-(void) laixinStepupDB:(NSString * ) userID
{
    if (userID.length > 0) {
        NSString * strDBName = [NSString stringWithFormat:@"%@_%@.sqlite",kLaixinStoreName,[userID md5Hash]];
        [self copyDefaultStoreIfNecessary:strDBName];
        [MagicalRecord setupCoreDataStackWithStoreNamed:strDBName];
    }else
    {
        [self copyDefaultStoreIfNecessary:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
        [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"%@.sqlite",kLaixinStoreName]];
    }
}

- (void)laixinStepupNotification:(NSNotification *)notification
{
    if (notification.object) {
        NSString * userID = [DataHelper getStringValue:notification.object defaultValue:@""];
        if (userID.length > 0) {
            [self laixinStepupDB:userID];
        }
    }else{
        [self laixinStepupDB:@""];
    }
}

///bak of the database
- (void) copyDefaultStoreIfNecessary:(NSString * ) laixinDBname;
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:laixinDBname];
    
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:[storeURL path]])
    {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[laixinDBname stringByDeletingPathExtension] ofType:[laixinDBname pathExtension]];
        
		if (defaultStorePath)
        {
            NSError *error;
			BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                SLLog(@"Failed to install default recipe store");
            }
		}
	}
    
}

+(BOOL) hasLogin
{
    if([USER_DEFAULT stringForKey:KeyChain_Laixin_account_sessionid].length > 1 && [USER_DEFAULT boolForKey:KeyChain_Laixin_account_HasLogin]){
        return YES;
    }
    return NO;
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // tell websocket disconnect
    if([YQDelegate hasLogin])
    {
        /*[[MLNetworkingManager sharedManager] sendWithAction:@"session.stop" parameters:@{} success:^(MLRequest *request, id responseObject) {
         
         } failure:^(MLRequest *request, NSError *error) {
         
         }];*/
        SLLog(@"applicationDidEnterBackground webSocket close");
        [[TKSignalWebScoket sharedTKSignalWebScoket] stop];
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // tell websocket disconnect
    if([YQDelegate hasLogin])
    {
        /*[[MLNetworkingManager sharedManager] sendWithAction:@"session.stop" parameters:@{} success:^(MLRequest *request, id responseObject) {
         
         } failure:^(MLRequest *request, NSError *error) {
         
         }];*/
        SLLog(@"applicationDidEnterBackground webSocket close");
        [[TKSignalWebScoket sharedTKSignalWebScoket] start];
    }
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

@end
