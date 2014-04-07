//
//  LXRequestFacebookManager.m
//  laixin
//
//  Created by apple on 13-12-26.
//  Copyright (c) 2013年 jijia. All rights reserved.
//

#import "LXRequestFacebookManager.h"
#import "IQSocialRequestBaseClient.h"
#import "MLNetworkingManager.h"
#import "LXUser.h"
#import "LXAPIController.h"
#import "LXChatDBStoreManager.h"
#import "FCAccount.h"
#import "XCAlbumDefines.h"
#import "MyMD5.h"
#import "OpenUDID.h"
@implementation LXRequestFacebookManager


- (void)requestPostActionWithCompletion:(CompletionBlock)completion withParems:(NSMutableDictionary * ) parems withAction:(NSString * ) action
{
    SLog(@"parems %@",parems);
    
//    [parems  setValue:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_token] forKey:@"token"];
//    [parems  setValue:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_tokenExpire] forKey:@"timestamp"];
//    //签名值，生成方法：将DeviceId、已登录的用户名和时间戳三个值的字符串形式拼接后，对整体进行MD5加密（小写值）
//    
//    NSString * stringmd5 = [MyMD5 md5:[NSString stringWithFormat:@"%@%@%@",[OpenUDID value],[USER_DEFAULT stringForKey:KeyChain_yunqi_account_name],[USER_DEFAULT stringForKey:KeyChain_yunqi_account_tokenExpire]]];
//    [parems  setValue:stringmd5 forKey:@"sign"];
    
    
    [[IQSocialRequestBaseClient sharedClient] POST:action parameters:parems success:^(NSURLSessionDataTask *task, id responseObject) {
        SLog(@"%@",responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        SLog(@"%@",error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)requestGetURLWithCompletion:(CompletionBlock)completion withDict:(NSMutableDictionary*)dict withParems:(NSString * ) action
{
    
    [[IQSocialRequestBaseClient sharedClient] GET:action parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        SLog(@"responseObject : %@",responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        SLog(@" error : %@",error);
        if (completion) {
            completion(nil, error);
        }
    }];
    
}

- (void)requestGetURLWithCompletion:(CompletionBlock)completion withParems:(NSString * ) parems
{
    /*[[IQSocialRequestBaseClient sharedClient] getPath:parems
                                           parameters:nil
                                              success:^(AFHTTPRequestOperation *opertaion, id response){
                                                  NSLog(@"%@",response);
                                                  if (completion) {
                                                      completion(response, nil);
                                                  }
                                              }
                                              failure:^(AFHTTPRequestOperation *opertaion, NSError *error){
                                                  NSLog(@"%@",error);
                                                  if (completion) {
                                                      completion(nil, error);
                                                  }
                                              }];*/
    SLog(@"parems get token : %@",parems);
    
    [[IQSocialRequestBaseClient sharedClient] GET:parems parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject : %@",responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@" error : %@",error);
        if (completion) {
            completion(nil, error);
        }
    }];
}


/**
 *  根据UID数组获取用户 保存到本地
 *
 *  @param uids <#uids description#>
 *
 *  @return <#return value description#>
 */
-(void ) fetchAlAccountsByArray:(NSArray * ) uids
{
    NSDictionary * parames = @{@"uid":uids};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
        // "users":[....]
        NSDictionary * userinfo = responseObject[@"result"];
        NSArray * userArray = userinfo[@"users"];
        [userArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LXUser *currentUser = [[LXUser alloc] initWithDict:obj];
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError *error) {
            }];
        }];
    } failure:^(MLRequest *request, NSError *error) {
    }];
}

/**
 *  通过用户UID获取用户信息   没有就从网络请求保存到本地
 *
 *  @param completion <#completion description#>
 *  @param uid        <#uid description#>
 */
-(void) getUserDesPtionCompletion:(CompletionBlock)completion withuid:(NSString * ) uid
{
    if (uid==nil || [uid isEqualToString:@""]) {
        completion(nil,nil);
    }else{
        //MARK Base fbid to find userdesp object,, if userdesp is nil, will select from networking
        FCUserDescription * localdespObject  =[[[LXAPIController sharedLXAPIController] chatDataStoreManager] fetchFCUserDescriptionByUID:uid];
        if (localdespObject) {
            completion(localdespObject,nil);
        }else{
            //from networking by ID
            NSDictionary * parames = @{@"uid":@[uid]};
            [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
                // "users":[....]
                NSDictionary * userinfo = responseObject[@"result"];
                NSArray * userArray = userinfo[@"users"];
                if (userArray && userArray.count > 0) {
                    NSDictionary * dict = userArray[0];
                    LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
                    [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
                        completion(response,nil);
                    }];
                }
            } failure:^(MLRequest *request, NSError *error) {
            }];
        }
    }
    
}
-(void) getUserDesByNetCompletion:(CompletionBlock)completion withuid:(NSString * ) uid
{
    //from networking by ID
    NSDictionary * parames = @{@"uid":@[uid]};
    [[MLNetworkingManager sharedManager] sendWithAction:@"user.info" parameters:parames success:^(MLRequest *request, id responseObject) {
        // "users":[....]
        NSDictionary * userinfo = responseObject[@"result"];
        NSArray * userArray = userinfo[@"users"];
        if (userArray && userArray.count > 0) {
            NSDictionary * dict = userArray[0];
            LXUser *currentUser = [[LXUser alloc] initWithDict:dict];
            [[[LXAPIController sharedLXAPIController] chatDataStoreManager] setFCUserObject:currentUser withCompletion:^(id response, NSError * error) {
                completion(response,nil);
            }];
        }
    } failure:^(MLRequest *request, NSError *error) {
    }];
}
@end
