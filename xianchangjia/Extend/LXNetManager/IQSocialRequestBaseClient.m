//
//  IQSocialRequestBaseClient.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "IQSocialRequestBaseClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "XCAlbumDefines.h"
#import "NSString+Addition.h"

//static NSString * const kAPIBaseURLString = @"https://www.cloud7.com.cn";
static NSString * const kAPIBaseURLString = @"http://terry.cloud7.com.cn";

@implementation IQSocialRequestBaseClient
+ (IQSocialRequestBaseClient *)sharedClient {
    static  IQSocialRequestBaseClient *_sharedClient = nil;

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedClient = [[IQSocialRequestBaseClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
            [_sharedClient setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
            // policyWithPinningMode:AFSSLPinningModePublicKey]];
        });
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
   
    return _sharedClient;
}

@end
