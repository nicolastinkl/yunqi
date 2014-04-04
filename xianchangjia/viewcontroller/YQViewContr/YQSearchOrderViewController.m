//
//  YQSearchOrderViewController.m
//  yunqi
//
//  Created by apple on 4/4/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQSearchOrderViewController.h"
#import "XCAlbumAdditions.h"
#import "YQOrderMetaViewcontroller.h"
#import "YQListOrderInfo.h"
#import "UIButton+Bootstrap.h"
#import "YQMakeSendMetaViewcontroller.h"

@interface YQSearchOrderViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *seachbar;
@end

@implementation YQSearchOrderViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //starting searching
    if ([searchBar.text isEmpty]) {
        return;
    }
    if ([self.seachbar isFirstResponder]) {
        [self.seachbar resignFirstResponder];
    }
    [SVProgressHUD showWithStatus:@"正在搜索..."];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:searchBar.text forKey:@"keyword"];
    
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/SearchOrders" success:^(id obj) {
        
        NSDictionary * dataDict = obj[@"data"];
        NSArray * array = dataDict[@"orders"];
        NSMutableArray * searchList = [[NSMutableArray alloc] init];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj) {
                YQListOrderInfo * orderinfo = [YQListOrderInfo turnObject:obj];
                [searchList addObject:orderinfo];
            }
        }];
        
        if (searchList.count > 0) {
            //target view
            [SVProgressHUD dismiss];
            YQSearchOrderViewController * searchview = [self.storyboard instantiateViewControllerWithIdentifier:@"YQSearchOrderViewController"];
            searchview.AllOrderList = [searchList mutableCopy];
            [self.navigationController pushViewController:searchview animated:YES];
        }else{
            [UIAlertView showAlertViewWithMessage:@"没有相关数据"];
        }
        
        
    } error:^(NSInteger index) {
        SLog(@"error : %d",index);
        [UIAlertView showAlertViewWithMessage:@"搜索失败，请检查您的网络设置"];
    }];
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQListOrderInfo *orderInfo = self.AllOrderList[indexPath.section];
    if (indexPath.row <= orderInfo.orderProducts.count - 1 ) {
        return 102.0f;
    }
    return 47.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YQListOrderInfo *orderInfo = self.AllOrderList[indexPath.section];
    YQOrderMetaViewcontroller * ordrmeta = [self.storyboard instantiateViewControllerWithIdentifier:@"YQOrderMetaViewcontroller"];
    ordrmeta.orderpro = orderInfo;
    ordrmeta.title = @"订单详情";
    [self.navigationController pushViewController:ordrmeta animated:YES];
    // goto next pageview
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.AllOrderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YQListOrderInfo *orderInfo = self.AllOrderList[section];
    return  orderInfo.orderProducts.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    YQListOrderInfo *orderInfo = self.AllOrderList[indexPath.section];
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
        
        //(orderInfo.paymentStatus == 30 || orderInfo.paymentMethodType == 10)  &&
        if (orderInfo.orderStatus == 20 ) {
            // 支付完成 未发货
            [button setTitle:@"标记发货" forState:UIControlStateNormal];
            [button infoStyle];
            button.enabled = YES;
            button.hidden = NO;
        }else{
            button.hidden = YES;
        }
        [button addTarget:self action:@selector(signSendMetaClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(IBAction)signSendMetaClick:(id)sender
{
    UITableViewCell * cell = (UITableViewCell *) ((UIButton *) sender).superview.superview.superview;
    NSUInteger index = [self.tableView indexPathForCell:cell].section;
    YQListOrderInfo *orderInfo = self.AllOrderList[index];
    YQMakeSendMetaViewcontroller * viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"YQMakeSendMetaViewcontroller"];
    viewcon.orderpro = orderInfo;
    [self.navigationController pushViewController:viewcon animated:YES];
}

@end
