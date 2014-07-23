//
//  TKSignalWebScoket.h
//  yunqi
//
//  Created by tinkl on 5/6/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKSignalWebScoket : NSObject

+ (instancetype)sharedTKSignalWebScoket;


-(void) start;

-(void) stop;

-(bool) isconnect;

-(void) sendBackMessageID:(NSString *) msgID;

@end
