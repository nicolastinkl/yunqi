//
//  AFAppAPIClient.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "AFAppAPIClient.h"

static NSString * const AFAppDotNetAPIBaseURLString =@"https://www.cloud7.com.cn/Cloud7/WebApp";

@implementation AFAppAPIClient

+ (instancetype)sharedClient {
    static AFAppAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFAppAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
//        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
    });
    
    return _sharedClient;
}

@end
