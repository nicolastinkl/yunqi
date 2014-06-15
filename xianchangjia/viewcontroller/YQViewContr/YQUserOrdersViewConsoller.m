//
//  YQUserOrdersViewConsoller.m
//  yunqi
//
//  Created by apple on 4/1/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQUserOrdersViewConsoller.h"
#import "XCAlbumAdditions.h"
#import "YQListOrderInfo.h"
#import "UIButton+Bootstrap.h"
#import "YQOrderMetaViewcontroller.h"
#import "YQMakeSendMetaViewcontroller.h"

#import "PWLoadMoreTableFooterView.h"

@interface YQUserOrdersViewConsoller ()<PWLoadMoreTableFooterDelegate>
{
    PWLoadMoreTableFooterView *_loadMoreFooterView;
	BOOL _datasourceIsLoading;
    bool _allLoaded;
    NSMutableArray * AllOrderList;
}
@end

@implementation YQUserOrdersViewConsoller

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
    [self.view setBackgroundColor:SystembackgroundColor];
    //config the load more view
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    
    self.tableView.tableFooterView = _loadMoreFooterView;
    
    [self _init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;    
    
    _allLoaded = NO;
    _datasourceIsLoading = YES;
    
    [self loadOrdersWithlastid:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell) name:@"updateCellWITHCHANGEORDER" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateCellWITHCHANGEORDER" object:nil];
}

-(void) updateCell
{
    [self.tableView reloadData];
}

-(void) _init
{
    {
        NSMutableArray * _init_array = [[NSMutableArray alloc] init];
        AllOrderList = _init_array;
    }
}

-(void) loadOrdersWithlastid:(NSInteger) lastOrderid
{
    [self hiddeErrorText];
    
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.wechatId forKey:@"wechatId"];
    if (lastOrderid > 0) {
        [params setValue:@(lastOrderid) forKey:@"lastOrderId"];
    }

    //orderpro
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/ConsumerOrders" success:^(id obj) {
        SLog(@"JSON :%@",obj);
        int code = [DataHelper getIntegerValue: obj[@"code"] defaultValue:0];
        if (code == 200) {
            NSArray * dataDict = obj[@"data"];
            [dataDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    YQListOrderInfo * orderinfo = [YQListOrderInfo turnObject:obj];
                    [AllOrderList addObject:orderinfo];
                }
            }];
            if (dataDict.count >= 30) {
                _allLoaded = NO;
            }else{
                _allLoaded = YES;
            }
        }else if (code == 404) {
            [self hiddeErrorText];
             [self showErrorText:@"该用户没有下过单"];
        }else{
            if (lastOrderid == 0) {
                //init
                [self showErrorText:@"加载订单失败"];
            }else{
                //load more
                [UIAlertView showAlertViewWithMessage:@"加载失败"];
            }
        }
        
        _datasourceIsLoading = NO;
        [self doneLoadingTableViewData];
        
    } error:^(NSInteger index) {
        SLog(@"error : %d",index);
        _datasourceIsLoading = NO;
        [self doneLoadingTableViewData];
        [UIAlertView showAlertViewWithMessage:@"加载失败，请检查网络设置"];
    }];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQListOrderInfo *orderInfo = AllOrderList[indexPath.section];
    if (indexPath.row <= orderInfo.orderProducts.count - 1 ) {
        return 98.0f;
    }
    return 71.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    YQListOrderInfo *orderInfo = AllOrderList[indexPath.section];
    YQOrderMetaViewcontroller * ordrmeta = [self.storyboard instantiateViewControllerWithIdentifier:@"YQOrderMetaViewcontroller"];
    ordrmeta.orderpro = orderInfo;
    ordrmeta.title = @"订单详情";
    [self.navigationController pushViewController:ordrmeta animated:YES];
    // goto next pageview
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData {
	//  model should call this when its done loading
	[_loadMoreFooterView pwLoadMoreTableDataSourceDidFinishedLoading];
    [self.tableView reloadData];
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
    [self loadOrdersWithlastid:orderInfo.orderid];
    
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _datasourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return AllOrderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YQListOrderInfo *orderInfo = AllOrderList[section];
    return  orderInfo.orderProducts.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    YQListOrderInfo *orderInfo = AllOrderList[indexPath.section];
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
        
        
        UIImageView * imageviewTop = (UIImageView*) [cell.contentView subviewWithTag:8];
        UIImageView * imageviewMid = (UIImageView*) [cell.contentView subviewWithTag:7];
        
        if (indexPath.row  == 0) {
            imageviewTop.image = [UIImage imageNamed:@"bubble_upside_normal"];
            imageviewMid.image = nil; //bubble_middle_normal
        }else{
            imageviewTop.image = nil;//[UIImage imageNamed:@"bubble_upside_normal"];
            imageviewMid.image = [UIImage imageNamed:@"bubble_middle_normal"];
        }
        
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(IBAction)signSendMetaClick:(id)sender
{
    UITableViewCell * cell = (UITableViewCell *) ((UIButton *) sender).superview.superview.superview;
    NSUInteger index = [self.tableView indexPathForCell:cell].section;
    YQListOrderInfo *orderInfo = AllOrderList[index];
    YQMakeSendMetaViewcontroller * viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"YQMakeSendMetaViewcontroller"];
    viewcon.orderpro = orderInfo;
    [self.navigationController pushViewController:viewcon animated:YES];
}

@end
