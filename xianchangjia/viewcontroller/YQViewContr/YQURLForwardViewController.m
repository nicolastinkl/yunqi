//
//  YQURLForwardViewController.m
//  yunqi
//
//  Created by apple on 4/3/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQURLForwardViewController.h"
#import "XCAlbumAdditions.h"
#import "Conversation.h"
#import "CoreData+MagicalRecord.h"

@interface YQURLForwardViewController ()<UIAlertViewDelegate>
{
    NSMutableArray * datasource;
    Conversation * currentVer;
}
@end

@implementation YQURLForwardViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)closeViewClick:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [tools setnavigationBarbg:self.navigationController];
    
    [self _init];
    
    
    //fill data
    datasource = [NSMutableArray arrayWithArray: [Conversation MR_findAll]];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) _init
{
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    datasource = array;
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
    return datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    UIImageView * imageview = (UIImageView *) [cell.contentView subviewWithTag:1];
    
    UILabel * label = (UILabel *) [cell.contentView subviewWithTag:2];
    
    Conversation * conver = datasource[indexPath.row];
    [imageview setImageWithURL:[NSURL URLWithString:conver.facebookavatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
//    imageview.layer.cornerRadius = 5;
//    imageview.layer.masksToBounds = YES;
    label.text = conver.facebookName;
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self closeViewClick:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SENDURLTOUSER" object:currentVer];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentVer = datasource[indexPath.row];
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否转发当前网址给买家" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"转发", nil] show];
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
