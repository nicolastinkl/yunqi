//
//  DAHttpClient.m
//  Kidswant
//
//  Created by apple on 13-10-14.
//  Copyright (c) 2013年 xianchangjia. All rights reserved.
//

#import "DAHttpClient.h"
#import "SINGLETONGCD.h"
#import "AFAppAPIClient.h"
#import "GlobalData.h"
#import "JSONKit.h"
#import "XCAlbumDefines.h"
#import "MyMD5.h"
#import "OpenUDID.h"
#import "NSString+Addition.h"
#import "NSDataAddition.h"
#import "tools.h"
#import "AFAppDotNetAPIClient6.h"

@implementation DAHttpClient

SINGLETON_GCD(DAHttpClient);

- (NSURLSessionDataTask *)getRequestWithParameters:(NSMutableDictionary *) parames Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error
{
    if (parames == nil) {
        parames = [[NSMutableDictionary alloc] init];
    }
    [tools addAuthMD5:parames];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [[AFAppDotNetAPIClient6 sharedClient] GET:action parameters:parames success:^(AFHTTPRequestOperation *operation, id JSON) {
            if(JSON){
                SLog(@"json : %@",JSON);
                success(JSON);
            }else{
                error(0);           //0  failure
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *errossr) {
                error(1);               //1 error
        }];
    }else{
        
        return [[AFAppAPIClient sharedClient] GET:action parameters:parames success:^(NSURLSessionDataTask * __unused task, id JSON) {
            if(JSON){
                SLog(@"json : %@",JSON);
                success(JSON);
            }else{
                error(0);           //0  failure
            }
        } failure:^(NSURLSessionDataTask *__unused task, NSError *err) {
            error(1);               //1 error
        }];
    }
    return nil;
}

- (NSURLSessionDataTask *) postRequestWithParameters:(NSMutableDictionary *) parames Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error
{
    if (parames == nil) {
        parames = [[NSMutableDictionary alloc] init];
    }
    [tools addAuthMD5:parames];
    SLog(@"parames : %@",parames);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [[AFAppDotNetAPIClient6 sharedClient] POST:action parameters:parames success:^(AFHTTPRequestOperation *operation, id JSON) {
            if(JSON){
                SLog(@"json : %@",JSON);
                success(JSON);
            }else{
                error(0);           //0  failure
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *errossr) {
            error(1);               //1 error
        }];
    }else{
        return [[AFAppAPIClient sharedClient] POST:action parameters:parames success:^(NSURLSessionDataTask * __unused task, id JSON) {
            if(JSON){
                SLog(@"json : %@",JSON);
                success(JSON);
            }else{
                error(0);           //0  failure
            }
        } failure:^(NSURLSessionDataTask *__unused task, NSError *err) {
            error(1);               //1 error
        }];
    }
    return  nil;
}
/**
 *  所有网络请求接口
 *
 *  @param parames    json参数
 *  @param controller string
 *  @param action     string
 *  @param success    成功后处理
 *  @param error      失败后处理
 *
 *  @return URL TASK
 */
- (NSURLSessionDataTask *)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error
{
    //这里加入session id
    //parames[@"session"] = @"??????";
    [[GlobalData sharedGlobalData] addCommentCommandInfo:parames];
    SLLog(@"json : %@",[parames JSONString]);
    return [[AFAppAPIClient sharedClient] POST:[NSString stringWithFormat:@"/%@/%@",controller,action] parameters:parames success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
       NSInteger r = [[JSON valueForKeyPath:@"response_code"] intValue];
        if(JSON && r == 1){
            success(JSON);
        }else{
			error(0);           //0  failure
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *err) {
        error(1);               //1 error
    }];
    
}


- (NSURLSessionDataTask *)defautlRequestWithParameters:(NSMutableDictionary *) parames controller:(NSString *) controller Action:(NSString *) action success:(SLObjectBlock)success error:(SLIndexBlock)error failure:(SLErrorBlock)failure
{
    return  [self defautlRequestWithParameters:parames controller:controller Action:action success:success error:error];
}

@end
