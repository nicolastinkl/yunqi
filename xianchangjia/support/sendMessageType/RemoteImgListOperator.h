//
//  RemoteImgListOperator.h
//  RemoteImgListOperatorDemo
//
//  Created by tinkl on 14-1-7.
//  Copyright (c) 2014年 tinkl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteImgListOperator : NSObject

// 接收 成功/失败 通知的名称
// Notification 的 userInfo 中返回一个字典：key为图片URL，value为图片内容NSData。
@property (nonatomic, readonly) NSString *m_strSuccNotificationName;
@property (nonatomic, readonly) NSString *m_strFailedNotificationName;

// 设置列表最大长度
- (void)resetListSize:(NSInteger)iSize;


/**
 *  message
 *  @param guid     <#guid description#>
 *  @param dict     <#dict description#>
 *  @param progress <#progress description#>
 */
- (void) sendMessageGUID:(NSString *)guid ByDict:(NSMutableDictionary*) dict withProgress:(id)progress;

// 移除正在使用的进度条delegate
- (void)removeProgressDelegate:(id)progress;



@end
