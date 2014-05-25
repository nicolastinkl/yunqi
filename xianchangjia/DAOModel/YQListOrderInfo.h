//
//  YQListOrderInfo.h
//  yunqi
//
//  Created by apple on 3/30/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

/**
 *  订单列表 信息model
 */
@class YQOrderProducts,YQConsignee,YQShipment;
@interface YQListOrderInfo : NSObject

@property (strong, nonatomic) NSString *cancelDateUtc;
@property (strong, nonatomic) NSString *createdUtc;
@property (strong, nonatomic) NSString *deliveryDateUtc;
@property (assign, nonatomic) NSInteger orderid;  // mapping id
@property (strong, nonatomic) NSString * orderNo;
@property (assign, nonatomic) NSInteger orderStatus;
@property (assign, nonatomic) NSInteger paymentMethodType;
@property (assign, nonatomic) NSInteger paymentStatus;
@property (strong, nonatomic) NSString *orderTotal;
@property (strong, nonatomic) NSString *paidDateUtc;
@property (strong, nonatomic) NSString *paymentMethodDisplayName;
@property (strong, nonatomic) NSString *paymentMethodName;
@property (strong, nonatomic) NSString *receiptDateUtc;
@property (strong, nonatomic) NSString *transactionId;

@property (strong, nonatomic) NSMutableArray *orderProducts;

@property (strong, nonatomic) YQConsignee *consingee;
@property (strong, nonatomic) YQShipment  *shipment;

+ (instancetype)turnObject:(NSDictionary*)dict;
@end


/*
count = 1;
id = 11;
price = "200.00";
productDesc = "";
productId = 14;
productImageUrl = "/Media/apiservicetest/Pics/2014322202253066CJNR.jpg";
productName = "\U5730\U74dc\U62ff\U94c1";
total = "200.00";
*/
/**
 *  产品详情
 */
@interface YQOrderProducts : NSObject

@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *productDesc;
@property (strong, nonatomic) NSString *productImageUrl;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *total;
@property (assign, nonatomic) NSInteger orderid;  // mapping id
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger productId;

+ (instancetype)turnObject:(NSDictionary*)dict;
@end

/**
 *  收货人信息
 */
@interface YQConsignee : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *tel;
@property (strong, nonatomic) NSString *address;
+ (instancetype)turnObject:(NSDictionary*)dict;
@end



/**
 * 该订单的物流信息
 */
@interface YQShipment : NSObject
@property (strong, nonatomic) NSString *Sid;                //mapping id
@property (strong, nonatomic) NSString *shipping;           //物流名称
@property (strong, nonatomic) NSString *shippingTrackId;    //物流查询单号
+ (instancetype)turnObject:(NSDictionary*)dict;
@end
