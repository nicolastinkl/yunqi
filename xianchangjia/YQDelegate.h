//
//  YQDelegate.h
//  yunqi
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CustomWindow.h"

@interface YQDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) CustomWindow                  *window;
@property (nonatomic,strong) NSDictionary                   *launchingWithAps;
@property (nonatomic,strong) UITabBarController             *tabBarController;

+(BOOL) hasLogin;

@end
