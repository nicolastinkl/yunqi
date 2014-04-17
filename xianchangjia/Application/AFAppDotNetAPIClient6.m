//
//  AFAppDotNetAPIClient6.m
//  AFNetworking iOS Example
//
//  Created by apple on 4/17/14.
//  Copyright (c) 2014 Gowalla. All rights reserved.
//

#import "AFAppDotNetAPIClient6.h"
#import "XCAlbumDefines.h"
#import "AFNetworkActivityIndicatorManager.h"
@implementation AFAppDotNetAPIClient6

+ (AFAppDotNetAPIClient6 *)sharedClient {
    NSString * kAPIBaseURLString =[USER_DEFAULT valueForKey:KeyChain_yunqi_account_notifyServerhostName];
    
    //@"http://cool1.cloud7.com.cn/";
    //[USER_DEFAULT valueForKey:KeyChain_yunqi_account_notifyServerhostName];
    SLog(@"kAPIBaseURLString : %@",kAPIBaseURLString);
    if ([kAPIBaseURLString length]  > 5) {        
        static AFAppDotNetAPIClient6 *_sharedClient = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedClient = [[AFAppDotNetAPIClient6 alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
            [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
        });
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        return _sharedClient;
    }
    return nil;
}

@end
