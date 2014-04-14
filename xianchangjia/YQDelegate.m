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
#import "XCJLoginViewController.h"
#import "MLNetworkingManager.h"
#import "LXAPIController.h"
#import "CoreData+MagicalRecord.h"
#import "LXChatDBStoreManager.h"
#import "UIAlertViewAddition.h"
#import "XCJLoginNaviController.h"
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
        [[DAHttpClient sharedDAHttpClient] postRequestWithParameters:nil Action:@"AdminApi/Web7.Cloud7Tenant/RegActiveTarget" success:^(id obj) {
        } error:^(NSInteger index) {
        }];
        
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
    
    
    /* receive websocket message
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(webSocketDidReceivePushMessage:)
     name:MLNetworkingManagerDidReceivePushMessageNotification
     object:nil];
     */
    
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
    SLLog(@"devtokenstring : %@",devtokenstring);
    
    [USER_DEFAULT setValue:devtokenstring forKey:KeyChain_Laixin_account_devtokenstring];
    [USER_DEFAULT synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    SLLog(@"error : %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
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
   
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

@end
