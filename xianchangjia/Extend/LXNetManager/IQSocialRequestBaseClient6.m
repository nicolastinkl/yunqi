//
//  IQSocialRequestBaseClient6.m
//  yunqi
//
//  Created by apple on 4/17/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "IQSocialRequestBaseClient6.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString * const kAPIBaseURLString = @"https://www.cloud7.com.cn";
//static NSString * const kAPIBaseURLString = @"http://terry.cloud7.com.cn";

@implementation IQSocialRequestBaseClient6
+ (IQSocialRequestBaseClient6 *)sharedClient {
    static  IQSocialRequestBaseClient6 *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[IQSocialRequestBaseClient6 alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
        // policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    
    return _sharedClient;
}

@end
