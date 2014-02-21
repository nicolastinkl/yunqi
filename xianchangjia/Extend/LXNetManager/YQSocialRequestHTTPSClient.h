//
//  YQSocialRequestHTTPSClient.h
//  yunqi
//
//  Created by apple on 2/20/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface YQSocialRequestHTTPSClient : AFHTTPSessionManager

+ (YQSocialRequestHTTPSClient *)sharedClient;

@end
