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

#import "PWLoadMoreTableFooterView.h"

@interface YQSearchOrderViewController ()<UISearchBarDelegate,UIScrollViewDelegate,PWLoadMoreTableFooterDelegate>
{
    PWLoadMoreTableFooterView *_loadMoreFooterView;
	BOOL _datasourceIsLoading;
    bool _allLoaded;
}

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
    [self.view setBackgroundColor:SystembackgroundColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.seachbar.hidden = YES;
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"搜索结果";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];         
        [self.navigationItem.titleView addSubview:titleLabel];
    }
    /**
     *  change place holder text color

    for (UIView *subView in self.seachbar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.textColor = [UIColor whiteColor];
                
                break;
            }
        }
    }
     */    
    
    //config the load more view
    if (_loadMoreFooterView == nil) {
		
		PWLoadMoreTableFooterView *view = [[PWLoadMoreTableFooterView alloc] init];
		view.delegate = self;
		_loadMoreFooterView = view;
		
	}
    self.tableView.tableFooterView = _loadMoreFooterView;
    
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.AllOrderList.count >= 30) {
        _allLoaded = NO;
    }else{
        _allLoaded = YES;
    }
    [self doneLoadingTableViewData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell) name:@"updateCellWITHCHANGEORDER" object:nil];
}

-(void) updateCell
{
    [self.tableView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateCellWITHCHANGEORDER" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //starting searching
    if ([searchBar.text isEmpty]) {
        return;
    }
    if ([self.seachbar isFirstResponder]) {
        [self.seachbar resignFirstResponder];
    }
    
    /**
     *  clear data and view status
     */
    [[self AllOrderList] removeAllObjects];
    [self.tableView reloadData];
    [self hiddeErrorText];
    [_loadMoreFooterView resetLoadMore];
    
    [SVProgressHUD showWithStatus:@"正在搜索..."];
 
    [self loaddatawithindex:0];
   
}

-(void) loaddatawithindex:(NSInteger)lastOrderId
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.seachbar.text forKey:@"keyword"];
    if (lastOrderId > 0) {
        [params setValue:@(lastOrderId) forKey:@"lastOrderId"];
    }
    [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/SearchOrders" success:^(id obj) {
        if([DataHelper getIntegerValue:obj[@"code"] defaultValue:-1] == 200)
        {
            NSDictionary * dataDict = obj[@"data"];
            NSArray * array = dataDict[@"orders"];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj) {
                    YQListOrderInfo * orderinfo = [YQListOrderInfo turnObject:obj];
                    [self.AllOrderList addObject:orderinfo];
                }
            }];
            
            if (lastOrderId == 0) {
                //* init _ data*//
                if (array.count > 0) {
                    [self hiddeErrorText];
                    //target view
                    [self.tableView reloadData];
                }else{
                    _allLoaded = YES;
                    [self doneLoadingTableViewData];
                    [self showErrorText:[NSString stringWithFormat:@"没有'%@'相关数据",self.seachbar.text]];
                }
                [SVProgressHUD dismiss];
                
            }else
            {
                //load more data
                _datasourceIsLoading = NO;
                [self doneLoadingTableViewData];
            }
        }else{
           //SLog(@"error : %d",index);
            _datasourceIsLoading = NO;
            [self doneLoadingTableViewData];
            [UIAlertView showAlertViewWithMessage:@"搜索失败，请检查您的网络设置"];
        }
        
    } error:^(NSInteger index) {
        SLog(@"error : %d",index);
        _datasourceIsLoading = NO;
        [self doneLoadingTableViewData];
        [UIAlertView showAlertViewWithMessage:@"搜索失败，请检查您的网络设置"];
    }];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YQListOrderInfo *orderInfo = self.AllOrderList[indexPath.section];
    if (indexPath.row <= orderInfo.orderProducts.count - 1 ) {
        return 98.0f;
    }
    return 71.0f;
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
    YQListOrderInfo *orderInfo = [self.AllOrderList lastObject];
    [self loaddatawithindex:orderInfo.orderid];
    
}


- (BOOL)pwLoadMoreTableDataSourceIsLoading {
    return _datasourceIsLoading;
}
- (BOOL)pwLoadMoreTableDataSourceAllLoaded {
    return _allLoaded;
}


@end
