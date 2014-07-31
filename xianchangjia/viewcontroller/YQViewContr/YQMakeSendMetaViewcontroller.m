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

@interface YQMakeSendMetaViewcontroller ()<UITextFieldDelegate>
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
    
    [self.view setBackgroundColor:SystembackgroundColor];
    
//    UIButton * buttonComplete = (UIButton * )self.navigationItem.rightBarButtonItem.customView;
//    [buttonComplete infoStyle];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (IOS6) {
         UIImage *buttonImage = [UIImage imageNamed:@"commercialize_payment_icon_success_os7"];
        self.navigationItem.rightBarButtonItem = nil;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 44, 44);
        //[button setTitle:@"完成" forState:UIControlStateNormal];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = customBarItem;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.wuliuName) {
        [self.wuliuNumber becomeFirstResponder];
    }
    
    if (textField == self.wuliuNumber) {
        [self complete:nil];
        [self.wuliuNumber resignFirstResponder];
    }
    
    return YES;
}

-(IBAction)complete:(id)sender
{
    if (self.wuliuName.text.length == 0) {
        [UIAlertView showAlertViewWithMessage:@"物流公司不能为空"];
        return;
    }
    
    if (self.wuliuNumber.text.length == 0) {
        [UIAlertView showAlertViewWithMessage:@"物流单号不能为空"];
        return;
    }
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationCenter_RefreshOrderTableView_MakeSendStatus object:@"Minus"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCellWITHCHANGEORDER" object:@"Minus"];
            [SVProgressHUD  dismiss];
            [self.navigationController popToRootViewControllerAnimated:YES];
//            [self.navigationController popViewControllerAnimated:YES];
           // [UIAlertView showAlertViewWithMessage:@"标记发货成功"];
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

@end
