//
//  YQOrderMetaViewcontroller.m
//  yunqi
//
//  Created by apple on 4/1/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQOrderMetaViewcontroller.h"
#import "XCAlbumDefines.h"
#import "XCAlbumAdditions.h"
#import "YQListOrderInfo.h"
#import "UIButton+Bootstrap.h"
#import "YQMakeSendMetaViewcontroller.h"


@interface YQOrderMetaViewcontroller ()
{
    NSMutableArray * dateArray;
    YQListOrderInfo * CurrentInfo;
}
@end

@implementation YQOrderMetaViewcontroller

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
    NSMutableArray * array = [[NSMutableArray alloc] init];
    dateArray = array;
    [self.view setBackgroundColor:SystembackgroundColor];
    if (self.orderpro) {
        
        CurrentInfo = self.orderpro;
        [self overReloadtableview];
        
        [self.view showIndicatorViewLargeBlue];
        NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
        [params setValue:@(self.orderpro.orderid) forKey:@"orderId"];
        [params setValue:self.orderpro.orderNo forKey:@"orderNo"];
        //orderpro
        [[DAHttpClient sharedDAHttpClient] getRequestWithParameters:params Action:@"AdminApi/OrderManager/ConsumerOrder" success:^(id obj) {
            SLog(@"JSON :%@",obj);
            int code = [DataHelper getIntegerValue: obj[@"code"] defaultValue:0];
            if (code == 200) {
                NSDictionary * dataDict = obj[@"data"];
                YQListOrderInfo * info = [YQListOrderInfo turnObject:dataDict];
                CurrentInfo = info;
                [self overReloadtableview];
            }
            
            [self.view hideIndicatorViewBlueOrGary];
        } error:^(NSInteger index) {
            [self.view hideIndicatorViewBlueOrGary];
            [self showErrorInfoWithRetry];
            SLog(@"error : %d",index);
            
            CurrentInfo = self.orderpro;
            [self overReloadtableview];
        }];
        
    }else{
        [self showErrorText:@"加载订单失败"];
    }
    
}

-(void) stringbyJson:(NSString *) idstr wityType:(NSString * ) stype
{
    if (!idstr || [idstr isEmpty]) {

    }else{
        NSString *newstr = [NSString stringWithFormat:@"%@: %@",stype,[tools datebyStrByYQQQ:idstr]];
        [dateArray addObject:newstr];
    }
}

-(void) overReloadtableview
{
    
    if (CurrentInfo) {
        [dateArray removeAllObjects];
        [self stringbyJson:CurrentInfo.createdUtc wityType:@"创建时间"];
        [self stringbyJson:CurrentInfo.paidDateUtc wityType:@"支付时间"];
        [self stringbyJson:CurrentInfo.deliveryDateUtc wityType:@"发货时间"];
        [self stringbyJson:CurrentInfo.cancelDateUtc wityType:@"取消订单时间"];
        [self stringbyJson:CurrentInfo.receiptDateUtc wityType:@"发货时间"];
        
    }
    
    ((UILabel * ) [self.tableView.tableHeaderView subviewWithTag:1]).text = [NSString stringWithFormat:@"%@%@",@"收货人：",CurrentInfo.consingee.name == nil?@"正在加载":CurrentInfo.consingee.name];
    ((UILabel * ) [self.tableView.tableHeaderView subviewWithTag:2]).text = [NSString stringWithFormat:@"%@%@",@"",CurrentInfo.consingee.tel == nil?@"正在加载":CurrentInfo.consingee.tel];
    ((UILabel * ) [self.tableView.tableHeaderView subviewWithTag:3]).text = [NSString stringWithFormat:@"%@%@",@"收货地址：",CurrentInfo.consingee.address == nil?@"正在加载":CurrentInfo.consingee.address];
    
    UIButton * tel_button = ((UIButton * ) [self.tableView.tableHeaderView subviewWithTag:4]);
    UIButton * sign_button = ((UIButton * ) [self.tableView.tableHeaderView subviewWithTag:5]);
    
    [tel_button setTitle:@"电话联系" forState:UIControlStateNormal];
    [tel_button addTarget:self action:@selector(telClick:) forControlEvents:UIControlEventTouchUpInside];
    [sign_button addTarget:self action:@selector(signSendwuliu:) forControlEvents:UIControlEventTouchUpInside];
    [sign_button setTitle:@"标记发货" forState:UIControlStateNormal];
    
    [tel_button telWhiteStyle];
    [sign_button infoStyle];
    
   
        
    
    /*
     货到付款的订单 会显示拨打电话。
     在线支付的只有标记发货
     */
    if (CurrentInfo.paymentMethodType == 10) {
        //货到付款
        if (CurrentInfo.orderStatus >= 40) {
            // 订单已经完成
            sign_button.hidden = YES;
            [tel_button setWidth:261.0f];
        }
        
    }else if (CurrentInfo.paymentMethodType == 20) {
        //在线支付
        tel_button.hidden = YES;
        sign_button.hidden = NO;
        [sign_button setLeft:30.0f];
        [sign_button setWidth:261.0f];
    }
    
    
    ((UILabel * ) [self.tableView.tableFooterView subviewWithTag:1]).text = [NSString stringWithFormat:@"%@%@",@"实付款：",CurrentInfo.orderTotal];
    
    [self.tableView reloadData];
    
}

-(IBAction)signSendwuliu:(id)sender
{
    YQMakeSendMetaViewcontroller * viewcon = [self.storyboard instantiateViewControllerWithIdentifier:@"YQMakeSendMetaViewcontroller"];
    viewcon.orderpro = self.orderpro;
    [self.navigationController pushViewController:viewcon animated:YES];
}

-(IBAction)telClick:(id)sender
{
    if (CurrentInfo.consingee.tel) {
        
        NSMutableString * strURL = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",CurrentInfo.consingee.tel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return CurrentInfo.orderProducts.count + 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= CurrentInfo.orderProducts.count - 1 ) {
        return 98.0f;
    }else if(indexPath.row == CurrentInfo.orderProducts.count){
        return 84.0f;
    }else if(indexPath.row == CurrentInfo.orderProducts.count+1){
        return 64.0f;
    }else if(indexPath.row == CurrentInfo.orderProducts.count+2){
        return (8+1)*dateArray.count + 21 * dateArray.count + 8;
    }
    return 0.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row <= CurrentInfo.orderProducts.count - 1 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"productCell" forIndexPath:indexPath];
        
        UIImageView * imageview = (UIImageView*) [cell.contentView subviewWithTag:1];
        UILabel * label_name = (UILabel*) [cell.contentView subviewWithTag:2];
        UILabel * label_des = (UILabel*) [cell.contentView subviewWithTag:3];
        UILabel * label_price = (UILabel*) [cell.contentView subviewWithTag:4];
        UILabel * label_number = (UILabel*) [cell.contentView subviewWithTag:5];
        YQOrderProducts * product =  CurrentInfo.orderProducts[indexPath.row];
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
    }else if(indexPath.row == CurrentInfo.orderProducts.count){
        //支付
        cell = [tableView dequeueReusableCellWithIdentifier:@"paytypeCell" forIndexPath:indexPath];

        ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"订单号:" , CurrentInfo.orderNo];
        
         ((UILabel*) [cell.contentView subviewWithTag:2]).text  = [NSString stringWithFormat:@"%@ %@",@"第三方交易号:", CurrentInfo.orderNo];
        
         ((UILabel*) [cell.contentView subviewWithTag:3]).text  = [NSString stringWithFormat:@"%@ %@",@"支付类型:", CurrentInfo.paymentMethodDisplayName];
        
    }else if(indexPath.row == CurrentInfo.orderProducts.count+1){
        //物流
        cell = [tableView dequeueReusableCellWithIdentifier:@"wuliuCell" forIndexPath:indexPath];
        if (!CurrentInfo.shipment.shipping || [CurrentInfo.shipment.shipping isEmpty]) {
            
            ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"物流公司:" , @"无物流信息"];
            ((UILabel*) [cell.contentView subviewWithTag:2]).text  = [NSString stringWithFormat:@"%@ %@",@"物流单号:" , @"无物流单号信息"];
        }else{
            
            ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"物流公司:" , CurrentInfo.shipment.shipping];
            ((UILabel*) [cell.contentView subviewWithTag:2]).text  = [NSString stringWithFormat:@"%@ %@",@"物流单号:" , CurrentInfo.shipment.shippingTrackId];
            
        }
        
    }else if(indexPath.row == CurrentInfo.orderProducts.count+2){
        //订单 时间
        cell = [tableView dequeueReusableCellWithIdentifier:@"timeTypeCell" forIndexPath:indexPath];
        
//         if ((CurrentInfo.paymentStatus == 30 || CurrentInfo.paymentMethodType == 10)  && CurrentInfo.orderStatus == 20 ) {
//             
//             ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"支付时间:" ,[tools datebyStrByYQQQ:  CurrentInfo.paidDateUtc]];
//         }else{
//             ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"创建时间:" ,[tools datebyStrByYQQQ:CurrentInfo.createdUtc]];
//         }
//        ((UILabel*) [cell.contentView subviewWithTag:1]).text  = [NSString stringWithFormat:@"%@ %@",@"创建时间:" ,[tools datebyStrByYQQQ:CurrentInfo.createdUtc]];
        
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
                [((UIView*)obj ) removeFromSuperview];                
            }

        }];
        [cell.contentView layoutIfNeeded];
        [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, (idx)*(8 + 21)+8, 280, 21)];
            // label.font = [UIFont systemFontOfSize:15.0f];
            label.textColor = [UIColor grayColor];
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
            label.text = dateArray[idx];
        }];
        
        UIImageView * imageviewMid = (UIImageView*) [cell.contentView subviewWithTag:7];
        
        [imageviewMid setHeight:cell.contentView.height];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
