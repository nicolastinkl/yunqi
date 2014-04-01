//
//  XCJOrderTableViewController.m
//  yunqi
//
//  Created by apple on 3/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "XCJOrderTableViewController.h"
#import "XCAlbumAdditions.h"
#import "YQListOrderInfo.h"
#import "UIButton+Bootstrap.h"
#import "YQOrderMetaViewcontroller.h"

@interface XCJOrderTableViewController ()
{
    NSMutableArray * onlinePayOrderList;
    NSMutableArray * offlinePayOrderList;
    NSMutableArray * AllOrderList;
    int currentSelectedSegmentIndex;
}
@end

@implementation XCJOrderTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /**
     *  MARK: dosomething init... with tinkl
     */
    [self _init];
    
    /**
     *  MARK: init 0..
     */
    currentSelectedSegmentIndex = 0;
    
    /**
     * MARK: init net data.
     */
    [self initDatawithNet];
}

-(void) initDatawithNet{
    [self.view showIndicatorViewLargeBlue];
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:nil Action:@"AdminApi/OrderManager/ListOrders" success:^(id obj) {
        
        NSDictionary * dataDict = obj[@"data"];
        int cashOnDeliveryCount = [DataHelper getIntegerValue:dataDict[@"cashOnDeliveryCount"] defaultValue:0];
        int onlinePaymentCount = [DataHelper getIntegerValue:dataDict[@"onlinePaymentCount"] defaultValue:0];
        int allNoProcessCount = [DataHelper getIntegerValue:dataDict[@"allNoProcessCount"] defaultValue:0];
        NSArray * array = dataDict[@"orders"];
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj) {
                if(idx < 1)
                {
                    SLog(@"obj ^^ %@",obj);
                }
                YQListOrderInfo * orderinfo = [YQListOrderInfo turnObject:obj];
                [AllOrderList addObject:orderinfo];
            }
        }];
        [self.view hideIndicatorViewBlueOrGary];
        if ([array count] > 0) {
            [self reloadArrays];
        }
        
    } error:^(NSInteger index) {
        [self.view hideIndicatorViewBlueOrGary];
        [self showErrorInfoWithRetry];
        SLog(@"error : %d",index);
    }];
}

-(void) reloadArrays{
{
//        NSPredicate * preonLine = [NSPredicate predicateWithFormat:@" orderStatus = %@ and paymentStatus=%@",@"10",@"10"];
         NSPredicate * preonLine = [NSPredicate predicateWithFormat:@"orderStatus = 10 AND paymentStatus = 30"];
         onlinePayOrderList = [AllOrderList filteredArrayUsingPredicate:preonLine];
        
    }
    
    {
        NSPredicate * preonLine = [NSPredicate predicateWithFormat:@"orderStatus = 10 AND paymentStatus < 30"];
        offlinePayOrderList = [AllOrderList filteredArrayUsingPredicate:preonLine];
        
    }
    
    [self.tableView reloadData];
}

-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        onlinePayOrderList = _init_array;
    }
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        offlinePayOrderList = _init_array;
    }
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        AllOrderList = _init_array;
    }
}
- (IBAction)valuechangeSegment:(id)sender {

    UISegmentedControl *control = sender;
    currentSelectedSegmentIndex = control.selectedSegmentIndex;
    switch (control.selectedSegmentIndex) {
        case 0:
            //在线支付待发货
            break;
        case 1:
            //货到付款待发货
            break;
        case 2:
            //全部订单
            break;
            
        default:
            break;
    }
    
    [self reloadArrays];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {

     if (currentSelectedSegmentIndex == 0) {
//         if(onlinePayOrderList.count == 0)
//            [self showErrorText:@"没有相关订单"];
//         else
//            [self showErrorText:@""];
         
         return onlinePayOrderList.count;
     }
     
     if (currentSelectedSegmentIndex == 1) {
//         if(offlinePayOrderList.count == 0)
//             [self showErrorText:@"没有相关订单"];
//         else
//             [self showErrorText:@""];
         return offlinePayOrderList.count;
     }
     
     if (currentSelectedSegmentIndex == 2) {
//         if(AllOrderList.count == 0)
////             [self showErrorText:@"没有相关订单"];
//         else
//             [self showErrorText:@""];
         return AllOrderList.count;
     }
     
     // Return the number of sections.
     return 0;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
     
     if (currentSelectedSegmentIndex == 0) {
         YQListOrderInfo *orderInfo = onlinePayOrderList[section];
         return  orderInfo.orderProducts.count + 1;

     }
     
     if (currentSelectedSegmentIndex == 1) {
         YQListOrderInfo *orderInfo = offlinePayOrderList[section];
         return  orderInfo.orderProducts.count + 1;
     }
     
     if (currentSelectedSegmentIndex == 2) {
         YQListOrderInfo *orderInfo = AllOrderList[section];
         return  orderInfo.orderProducts.count + 1;
     }
     
     // Return the number of rows in the section.
     return 0;
 }


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray * currentArray;
    switch (currentSelectedSegmentIndex) {
        case 0:
            currentArray = onlinePayOrderList;
            break;
        case 1:
            currentArray = offlinePayOrderList;
            break;
        case 2:
            currentArray = AllOrderList;
            break;
            
        default:
            break;
    }
    UITableViewCell *cell;
    YQListOrderInfo *orderInfo = currentArray[indexPath.section];
    //indexPath.row  productCell   OrderPayCell
    if (indexPath.row <= orderInfo.orderProducts.count - 1 ) {
        cell  = [tableView dequeueReusableCellWithIdentifier:@"productCell" forIndexPath:indexPath];
        UIImageView * imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
        UILabel * label_name = (UILabel*) [cell.contentView subviewWithTag:2];
        UILabel * label_des = (UILabel*) [cell.contentView subviewWithTag:3];
        UILabel * label_price = (UILabel*) [cell.contentView subviewWithTag:4];
        UILabel * label_number = (UILabel*) [cell.contentView subviewWithTag:5];
        YQOrderProducts * product =  orderInfo.orderProducts[indexPath.row];
        [imageview setImageWithURL:[NSURL URLWithString:product.productImageUrl] placeholderImage:[UIImage imageNamed:@"aio_ogactivity_default"]];
        label_name.text = product.productName;
        label_des.text = product.productDesc;
        label_price.text = product.price;
        label_number.text = [NSString stringWithFormat:@"x%d",product.count];
        
    }else{
        cell  = [tableView dequeueReusableCellWithIdentifier:@"OrderPayCell" forIndexPath:indexPath];
        UILabel * label_price = (UILabel*) [cell.contentView subviewWithTag:1];
        UILabel * label_number = (UILabel*) [cell.contentView subviewWithTag:2];
        UIButton * button = (UIButton*) [cell.contentView subviewWithTag:3];
        
        label_price.text = orderInfo.orderTotal;
        label_number.text = [NSString stringWithFormat:@"x%d",orderInfo.orderProducts.count];
        
        if (orderInfo.orderStatus == 10) {
            [button setTitle:@"标记已发货" forState:UIControlStateNormal];
            [button infoStyle];
            button.enabled = YES;
        }else if (orderInfo.orderStatus == 20) {
            [button setTitle:@"已发货" forState:UIControlStateNormal];
            [button sendMessageStyle];
            button.enabled = YES;
        }else if (orderInfo.orderStatus == 30) {
            button.enabled = NO;
            [button labelphotoStyle];
            [button setTitle:@"交易完成" forState:UIControlStateNormal];
        }else if (orderInfo.orderStatus == 40) {
            button.enabled = NO;
            [button dangerStyle];
            [button setTitle:@"交易关闭/取消" forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * currentArray;
    switch (currentSelectedSegmentIndex) {
        case 0:
            currentArray = onlinePayOrderList;
            break;
        case 1:
            currentArray = offlinePayOrderList;
            break;
        case 2:
            currentArray = AllOrderList;
            break;
            
        default:
            break;
    }
    YQListOrderInfo *orderInfo = currentArray[indexPath.section];
    if (indexPath.row <= orderInfo.orderProducts.count - 1 ) {
        return 102.0f;
    }
    return 47.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray * currentArray;
    switch (currentSelectedSegmentIndex) {
        case 0:
            currentArray = onlinePayOrderList;
            break;
        case 1:
            currentArray = offlinePayOrderList;
            break;
        case 2:
            currentArray = AllOrderList;
            break;
            
        default:
            break;
    }
    YQListOrderInfo *orderInfo = currentArray[indexPath.section];
    YQOrderMetaViewcontroller * ordrmeta = [self.storyboard instantiateViewControllerWithIdentifier:@"YQOrderMetaViewcontroller"];
    ordrmeta.orderpro = orderInfo;
    if (currentSelectedSegmentIndex == 0) {
        ordrmeta.title = @"在线支付详情";
    }else     if (currentSelectedSegmentIndex == 1) {
        ordrmeta.title = @"货到付款详情";
    }else     if (currentSelectedSegmentIndex == 2) {
        ordrmeta.title = @"全部订单详情";
    }
    [self.navigationController pushViewController:ordrmeta animated:YES];
    // goto next pageview
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
