//
//  TKSignalWebScoket.m
//  yunqi
//
//  Created by tinkl on 5/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "TKSignalWebScoket.h"
#import "SignalR.h"
#import "MLNetworkingManager.h"
#import "SINGLETONGCD.h"
#import "XCAlbumDefines.h"
#import "JSONKit.h"

@interface TKSignalWebScoket ()
{
    SRConnection * connection;
}
@end

@implementation TKSignalWebScoket

SINGLETON_GCD(TKSignalWebScoket);

-(void) start
{
    
    NSString * str = [USER_DEFAULT stringForKey:KeyChain_Laixin_account_aliveServerAuthKey];
    CFStringRef  aCFString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, (CFStringRef)@"!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *aNSString = (__bridge NSString *)aCFString;
    
    NSDictionary * dict = @{@"auth":aNSString};
    //http://196.254.169.215:8080/keep-alive/connect
    
//    connection =[SRConnection connectionWithURL:F(@"%@/connect",[USER_DEFAULT stringForKey:KeyChain_Laixin_account_aliveServerUrl]) query:dict];
    
    
     // connect with SRConnection
    connection =[SRConnection connectionWithURL:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_aliveServerUrl] query:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidreceingWithMsg" object:nil];
    
//    __weak __typeof(self)weakSelf = self;
    connection.received = ^(id data) {
        if (data) {
//            NSLog(@"received %@  %@",data,[data class]);
            [[NSNotificationCenter defaultCenter] postNotificationName:MLNetworkingManagerDidReceivePushMessageNotification object:nil userInfo:@{@"message":data}];
            //        __strong __typeof(weakSelf)strongSelf = weakSelf;
           
        }
       
    };
    connection.started =  ^{
        NSLog(@"started");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketDidOpen" object:nil];
        
    };
    connection.closed = ^{
        NSLog(@"close");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
    };
    connection.error = ^(NSError *error){
        NSLog(@"error %@",error.userInfo);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"webSocketdidFailWithError" object:nil];
    };
    [connection start];
    
    /*
    
    //connection with SRHUBconneciton
    __weak __typeof(&*self)weakSelf = self;
    SRHubConnection *_connection = [SRHubConnection connectionWithURL:[USER_DEFAULT stringForKey:KeyChain_Laixin_account_aliveServerUrl] query:dict];
//    _hub = [_connection createHubProxy:@"statushub"];
//    [_hub on:@"joined" perform:self selector:@selector(joined:when:)];
//    [_hub on:@"rejoined" perform:self selector:@selector(rejoined:when:)];
//    [_hub on:@"leave" perform:self selector:@selector(leave:when:)];
    _connection.started = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
         SLog(@"started");
    };
    _connection.received = ^(NSDictionary * data){
        //__strong __typeof(&*weakSelf)strongSelf = weakSelf;
        SLog(@"received");
    };
    _connection.closed = ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        SLog(@"closed");
    };
    _connection.error = ^(NSError *error){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        SLog(@"error");

    };
    [_connection start];
    */
    
    
    CFBridgingRelease(aCFString);
}

-(void) sendBackMessageID:(NSString *) msgID
{
    if (connection) {
        
        NSDictionary * msgDict = @{@"__KeepAliveReceivedId__":msgID};
        SLog(@"back : %@",[msgDict JSONString]);
        [connection send:[msgDict JSONString]];
    }
}

-(bool) isconnect
{
    if (connection) {
        if (connection.state == connected) {
            return YES;
        }
        return NO;
    }
    return NO;
}

-(void) stop
{
    if (connection) {
        [connection stop];
    }
}

@end
