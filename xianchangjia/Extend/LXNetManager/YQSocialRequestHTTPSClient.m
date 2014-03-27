//
//  YQSocialRequestHTTPSClient.m
//  yunqi
//
//  Created by apple on 2/20/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQSocialRequestHTTPSClient.h"
#import "AFNetworkActivityIndicatorManager.h"

//static NSString * const kAPIBaseURLString = @"https://www.cloud7.com.cn/";
static NSString * const kAPIBaseURLString = @"http://terry.cloud7.com.cn/";
/**
 *  云起 https 安全登录验证   "SINGLETONGCD"
 */

@implementation YQSocialRequestHTTPSClient
+ (YQSocialRequestHTTPSClient *)sharedClient {
    static  YQSocialRequestHTTPSClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[YQSocialRequestHTTPSClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
//        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    return _sharedClient;
}
@end

