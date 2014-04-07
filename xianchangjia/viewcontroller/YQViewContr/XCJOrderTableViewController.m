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
#import "YQMakeSendMetaViewcontroller.h"
#import "YQSearchOrderViewController.h"
#import "PWLoadMoreTableFooterView.h"
#import "YQDelegate.h"
@interface XCJOrderTableViewController ()<UIScrollViewDelegate,UISearchBarDelegate,PWLoadMoreTableFooterDelegate>
{
    NSMutableArray * onlinePayOrderList;
    NSMutableArray * offlinePayOrderList;
    NSMutableArray * AllOrderList;
    int currentSelectedSegmentIndex;
    
    PWLoadMoreTableFooterView *_loadMoreFooterView;
    BOOL _datasourceIsLoading;
    bool _allLoaded;
    
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segementbar;

@property (weak, nonatomic) IBOutlet UISearchBar *seachbar;

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
    
    //config the load more view
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    self.tableView.tableFooterView = _loadMoreFooterView;
    
    /**
     *  MARK: init 0..
     */
    currentSelectedSegmentIndex = 0;
    
    _allLoaded = NO;
    _datasourceIsLoading = YES;
    
    /**
     * MARK: init net data.
     */
//    [self.view showIndicatorViewLargeBlue];
    [self initDatawithNet:0];    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollViewDat
{
    if ([scrollViewDat isKindOfClass:[UITableView class]]) {
//        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        if ([self.seachbar isFirstResponder]) {
            [self.seachbar resignFirstResponder];
        }
    }
}

-(void) initDatawithNet :(NSInteger) lastOrderid
{
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    if (lastOrderid > 0) {
        [params setValue:@(lastOrderid) forKey:@"lastOrderId"];
    }
    
    [params setValue:@"30" forKey:@"max"];
    
    __block  int countPays = 0;
    
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/ListOrders" success:^(id obj) {
        if([DataHelper getIntegerValue:obj[@"code"] defaultValue:-1] == 200)
        {
            NSDictionary * dataDict = obj[@"data"];
            int cashOnDeliveryCount = [DataHelper getIntegerValue:dataDict[@"cashOnDeliveryCount"] defaultValue:0];
            int onlinePaymentCount = [DataHelper getIntegerValue:dataDict[@"onlinePaymentCount"] defaultValue:0];
            int allNoProcessCount = [DataHelper getIntegerValue:dataDict[@"allNoProcessCount"] defaultValue:0];
            countPays = allNoProcessCount;
            [self.segementbar setTitle:[NSString stringWithFormat:@"在线支付(%d)",onlinePaymentCount] forSegmentAtIndex:0];
            [self.segementbar setTitle:[NSString stringWithFormat:@"货到付款(%d)",cashOnDeliveryCount]  forSegmentAtIndex:1];
            [self.segementbar setTitle:[NSString stringWithFormat:@"全部订单(%d)",allNoProcessCount]  forSegmentAtIndex:2];
            
            NSArray * array = dataDict[@"orders"];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    YQListOrderInfo * orderinfo = [YQListOrderInfo turnObject:obj];
                    [AllOrderList addObject:orderinfo];
                }
            }];
            [self.view hideIndicatorViewBlueOrGary];
            if ([array count] > 0) {
                [self reloadArrays];
            }
            
            if (array.count >= 30) {
                _allLoaded = NO;
            }else{
                _allLoaded = YES;
            }
            
            YQDelegate *delegate = (YQDelegate *)[UIApplication sharedApplication].delegate;
            if (countPays > 0) {
                [delegate.tabBarController.tabBar.items[1] setBadgeValue:[NSString stringWithFormat:@"%d",countPays]];
            }else{
                [delegate.tabBarController.tabBar.items[1] setBadgeValue:nil];
            }
        }
        _datasourceIsLoading = NO;
        [self doneLoadingTableViewData];
        
        
    } error:^(NSInteger index) {
        [UIAlertView showAlertViewWithMessage:@"请求失败，请检查您的网络设置" ];
        
//        [self.view hideIndicatorViewBlueOrGary];
//        [self showErrorInfoWithRetry];
        _datasourceIsLoading = NO;
        [self doneLoadingTableViewData];
        SLog(@"error : %d",index);
    }];
}


#pragma mark -
#pragma mark PWLoadMoreTableFooterDelegate Methods

- (void)pwLoadMore {
    //just make sure when loading more, DO NOT try to refresh your data
    //Especially when you do your work asynchronously
    //Unless you are pretty sure what you are doing
    //When you are refreshing your data, you will not be able to load more if you have pwLoadMoreTableDataSourceIsLoading and config it right
    //disable the navigationItem is only demo purpose
    
    _datasourceIsLoading = YES;
    YQListOrderInfo *orderInfo = [AllOrderList lastObject];
    [self initDatawithNet:orderInfo.orderid];
    
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData {
	//  model should call this when its done loading
	[_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
    [self.tableView reloadData];
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _datasourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}


-(void) reloadArrays{
{
    //AND paymentStatus = 30
         NSPredicate * preonLine = [NSPredicate predicateWithFormat:@"paymentMethodType = 20"];
         onlinePayOrderList = [AllOrderList filteredArrayUsingPredicate:preonLine];
        
    }
    
    {
        //AND paymentStatus < 30
        NSPredicate * preonLine = [NSPredicate predicateWithFormat:@"paymentMethodType = 10"];
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
    YQListOrderInfo *orderInfo = currentArray[index];
    YQMakeSendMetaViewcontroller * viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"YQMakeSendMetaViewcontroller"];
    viewcon.orderpro = orderInfo;
    [self.navigationController pushViewController:viewcon animated:YES];
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
