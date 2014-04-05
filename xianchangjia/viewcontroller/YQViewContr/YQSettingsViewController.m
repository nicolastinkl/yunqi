//
//  YQSettingsViewController.m
//  yunqi
//
//  Created by apple on 4/3/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQSettingsViewController.h"
#import "XCAlbumAdditions.h"
#include "OpenUDID.h"
#import "YQDelegate.h"
#import "YQLoginviewViewController.h"
#import <StoreKit/StoreKit.h>

@interface YQSettingsViewController ()<UIActionSheetDelegate,SKStoreProductViewControllerDelegate>

@end

@implementation YQSettingsViewController

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        //评价
        [self presentAppStoreForID:@(541873451) withDelegate:self withURL:[NSURL URLWithString:APP_COMMENT_LINK_iTunes]];
    }else  if (indexPath.section == 1) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
        [action showInView:self.view];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [SVProgressHUD show];
        NSString* openUDID = [OpenUDID value];
        NSMutableDictionary * mutaDict = [[NSMutableDictionary alloc] init];
        [mutaDict setValue:@"iPhone"    forKey:@"devicetype"];
        [mutaDict setValue:openUDID     forKey:@"deviceid"];
        [mutaDict setValue:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_token]     forKey:@"token"];
        [mutaDict setValue:[USER_DEFAULT stringForKey:KeyChain_yunqi_account_notifyServerhostName]     forKey:@"hostname"];
        [[[LXAPIController sharedLXAPIController] requestLaixinManager]  requestPostActionWithCompletion:^(id response, NSError *error) {
            /*
             code = 200;
             data =     {
             hostName = "apiservicetest.cloud7.com.cn";
             token = "x0tMaZQtslIksQGL0sgspnqDW+BtFozy//unzGXdcQvNnaEzT1Al7e6Z56AnzHQG5AVG3MfAUpZXYmuFCSte9085+VgCrBeNnXSFKiXr8LFpl8Dgrq/eNeIk";
             tokenValidDuration = 259200;
             };
             message = OK;
             */
            [SVProgressHUD dismiss];
            int code = [DataHelper getIntegerValue:response[@"code"] defaultValue:0];
            if (code == 200) {
                //success ...
                NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LaixinCloseDBMessageNotification object:nil];
                
                YQDelegate *delegate = (YQDelegate *)[UIApplication sharedApplication].delegate;
                delegate.tabBarController.selectedIndex = 0;
                [SVProgressHUD dismiss];
                YQLoginviewViewController * viewcon =  [self.storyboard instantiateViewControllerWithIdentifier:@"YQLoginviewViewController"];
                [self presentViewController:viewcon animated:NO completion:nil];

            }else{
                //error from server ...
                [UIAlertView showAlertViewWithMessage:@"登录失败"];
            }
        } withParems:mutaDict withAction:@"Cloud7/WebApp/DeviceSignout"];
        
}
}



- (void)presentAppStoreForID:(NSNumber *)appStoreID withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate withURL:(NSURL *)appStoreURL
{
    if(!NSClassFromString(@"SKStoreProductViewController")) { // Checks for iOS 6 feature.
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = delegate; // productViewControllerDidFinish
        
        // Example app_store_id (e.g. for Words With Friends)
        // [NSNumber numberWithInt:322852954];
        
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : appStoreID };
        
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self presentViewController:storeController animated:YES completion:nil];
            } else {
               [UIAlertView showAlertViewWithMessage:@"打开失败"];
            }
        }];
        
        
    } else { // Before iOS 6, we can only open the URL
        [[UIApplication sharedApplication] openURL:appStoreURL];
    }
}

/*
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
