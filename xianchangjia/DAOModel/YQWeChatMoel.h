//
//  YQWeChatMoel.h
//  yunqi
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface YQWeChatMoel : Model

@property (strong, nonatomic) NSString* wechatId;
@property (strong, nonatomic) NSURL *avatar;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *latestMessage;
@property (assign, nonatomic) NSTimeInterval latestTime;
@property (assign, nonatomic) NSUInteger newMessageCount;

@end
