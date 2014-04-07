//
//  YQMakeSendMetaViewcontroller.m
//  yunqi
//
//  Created by apple on 4/3/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQMakeSendMetaViewcontroller.h"
#import "YQListOrderInfo.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"

@interface YQMakeSendMetaViewcontroller ()
@property (weak, nonatomic) IBOutlet UITextField *wuliuName;
@property (weak, nonatomic) IBOutlet UITextField *wuliuNumber;

@end

@implementation YQMakeSendMetaViewcontroller

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
    
//    UIButton * buttonComplete = (UIButton * )self.navigationItem.rightBarButtonItem.customView;
//    [buttonComplete infoStyle];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(IBAction)complete:(id)sender
{
    [self.wuliuName resignFirstResponder];
    [self.wuliuNumber resignFirstResponder];
    [SVProgressHUD showWithStatus:@"正在处理发货..."];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:@(self.orderpro.orderid) forKey:@"orderId"];
    [params setValue:self.wuliuName.text forKey:@"shipping"];
    [params setValue:self.wuliuNumber.text forKey:@"shippingTrackId"];
    
    //orderpro
    [[DAHttpClient sharedDAHttpClient] postRequestWithParameters:params Action:@"AdminApi/OrderManager/OrderShipped" success:^(id obj) {
        int code = [DataHelper getIntegerValue: obj[@"code"] defaultValue:0];
        if (code == 200) {
            self.orderpro.orderStatus = 30;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCellWITHCHANGEORDER" object:nil];
            [UIAlertView showAlertViewWithMessage:@"标记发货成功"];
        }else
        {
            [UIAlertView showAlertViewWithMessage:@"标记发货失败"];
        }
    } error:^(NSInteger index) {
        SLog(@"error : %d",index);
        [UIAlertView showAlertViewWithMessage:@"标记发货失败"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 
 #pragma mark - Table view data source
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
 #warning Potentially incomplete method implementation.
 // Return the number of sections.
 return 0;
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
 #warning Incomplete method implementation.
 // Return the number of rows in the section.
 return 0;
 }

 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
