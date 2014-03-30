//
//  YQListOrderInfo.m
//  yunqi
//
//  Created by apple on 3/30/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQListOrderInfo.h"
#import "DataHelper.h"

/*
 
 {
 cancelDateUtc = "<null>";
 createdUtc = "2014-03-22T12:47:18.000Z";
 deliveryDateUtc = "<null>";
 id = 11;
 orderNo = 140322204718141;
 orderProducts =                 (
 {

 );
 orderStatus = 10;
 orderTotal = "200.00";
 paidDateUtc = "<null>";
 paymentMethodDisplayName = "\U5728\U7ebf\U652f\U4ed8";
 paymentMethodName = WeChatPayment;
 paymentMethodType = 20;
 
 paymentStatus = 10;
 receiptDateUtc = "<null>";
 transactionId = "<null>";
 },
 */
@implementation YQListOrderInfo
+ (instancetype)turnObject:(NSDictionary*)dict
{
    YQListOrderInfo * orderinfo = [[self alloc] init];
    NSArray * orderpros = dict[@"orderProducts"];
    NSMutableArray * array =[[NSMutableArray alloc] init];

    [orderpros enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YQOrderProducts * pro = [YQOrderProducts turnObject:obj];
        [array addObject:pro];
    }];
    orderinfo.orderProducts  = array;
    orderinfo.orderid = [DataHelper getIntegerValue:dict[@"id"] defaultValue:0];
    orderinfo.cancelDateUtc = [DataHelper getStringValue:dict[@"cancelDateUtc"] defaultValue:@""];
    orderinfo.createdUtc = [DataHelper getStringValue:dict[@"createdUtc"] defaultValue:@""];
    orderinfo.deliveryDateUtc = [DataHelper getStringValue:dict[@"deliveryDateUtc"] defaultValue:@""];
    orderinfo.orderTotal = [DataHelper getStringValue:dict[@"orderTotal"] defaultValue:@""];
    orderinfo.paidDateUtc = [DataHelper getStringValue:dict[@"paidDateUtc"] defaultValue:@""];
    orderinfo.paymentMethodDisplayName = [DataHelper getStringValue:dict[@"paymentMethodDisplayName"] defaultValue:@""];
    orderinfo.paymentMethodName = [DataHelper getStringValue:dict[@"paymentMethodName"] defaultValue:@""];
    orderinfo.receiptDateUtc = [DataHelper getStringValue:dict[@"receiptDateUtc"] defaultValue:@""];
    orderinfo.transactionId = [DataHelper getStringValue:dict[@"transactionId"] defaultValue:@""];
     
    orderinfo.orderNo = [DataHelper getIntegerValue:dict[@"orderNo"] defaultValue:0];
    orderinfo.orderStatus = [DataHelper getIntegerValue:dict[@"orderStatus"] defaultValue:0];
    orderinfo.paymentMethodType = [DataHelper getIntegerValue:dict[@"paymentMethodType"] defaultValue:0];
    orderinfo.paymentStatus = [DataHelper getIntegerValue:dict[@"paymentStatus"] defaultValue:0];
    return orderinfo;
}
@end


/* count = 1;
 id = 11;
 price = "200.00";
 productDesc = "";
 productId = 14;
 productImageUrl = "/Media/apiservicetest/Pics/2014322202253066CJNR.jpg";
 productName = "\U5730\U74dc\U62ff\U94c1";
 total = "200.00";
 }*/
@implementation YQOrderProducts
+ (instancetype)turnObject:(NSDictionary*)dict
{
    YQOrderProducts * orderPro = [[self alloc] init];
    orderPro.orderid = [DataHelper getIntegerValue:dict[@"id"] defaultValue:0];
    orderPro.count = [DataHelper getIntegerValue:dict[@"count"] defaultValue:0];
    orderPro.productId = [DataHelper getIntegerValue:dict[@"productId"] defaultValue:0];
    orderPro.productImageUrl = [DataHelper getStringValue:dict[@"productImageUrl"] defaultValue:@""];
    orderPro.productName = [DataHelper getStringValue:dict[@"productName"] defaultValue:@""];
    orderPro.total = [DataHelper getStringValue:dict[@"total"] defaultValue:@""];
    orderPro.price = [DataHelper getStringValue:dict[@"price"] defaultValue:@""];
    orderPro.productDesc = [DataHelper getStringValue:dict[@"productDesc"] defaultValue:@""];
    return  orderPro;
}

@end