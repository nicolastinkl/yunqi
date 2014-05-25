//
//  AFAppAPIClient.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "AFAppAPIClient.h"
#import "XCAlbumDefines.h"
#import "NSString+Addition.h"
#import "AFNetworkActivityIndicatorManager.h"

//static NSString * const AFAppDotNetAPIBaseURLString =@"http://api.xianchangjia.com/";
//@"http://app.kidswant.com.cn/";

@implementation AFAppAPIClient

+ (instancetype)sharedClient {
    static AFAppAPIClient *_sharedClient = nil;
    NSString * kAPIBaseURLString =[USER_DEFAULT valueForKey:KeyChain_yunqi_account_notifyServerhostName];
    
    //@"http://cool1.cloud7.com.cn/";
    //[USER_DEFAULT valueForKey:KeyChain_yunqi_account_notifyServerhostName];
    SLog(@"kAPIBaseURLString : %@",kAPIBaseURLString);
    if ([kAPIBaseURLString length]  > 5) {
      
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedClient = [[AFAppAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
            [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
        });
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    } 
    return _sharedClient;
}

@end
