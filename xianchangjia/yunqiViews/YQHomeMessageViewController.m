//
//  YQHomeMessageViewController.m
//  yunqi
//
//  Created by apple on 2/19/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQHomeMessageViewController.h"
#import "YQLoginviewViewController.h"
#import "XCJAppDelegate.h"
#import "LXAPIController.h"
#import "XCAlbumAdditions.h"
#import "YQWeChatMoel.h"

@interface YQHomeMessageViewController ()
{
    NSMutableArray * _dataSource;
}
@end

@implementation YQHomeMessageViewController

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

    NSMutableArray * array = [[NSMutableArray alloc] init];
    _dataSource = array;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHex:SystemKidsColor];
    
    if (![XCJAppDelegate hasLogin]) {
        YQLoginviewViewController * loginview = [self.storyboard instantiateViewControllerWithIdentifier:@"YQLoginviewViewController"];
        [self.navigationController presentViewController:loginview animated:NO completion:^{
            
        }];
    }    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TKthefristLogin:) name:@"TKthefristLogin" object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self TKthefristLogin:nil];
}

-(void) TKthefristLogin:(NSNotification * ) notify
{
    
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestPostActionWithYQUAUSLLCompletion:^(id response, NSError *error) {
        if (response) {
            //	{name: "诺普", wechatId: "" lastMessage: "哦，好", newMessageCount: 5,	avatar: "http://sss.jpg"},
            NSArray * responseArray = [DataHelper getArrayValue:response[@"result"] defaultValue:[[NSMutableArray alloc] init]];
            [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                YQWeChatMoel * wechatmodel = [YQWeChatMoel turnObject:obj];
                [_dataSource addObject:wechatmodel];
            }];            
        }
    } withAction:@"WeChat/Api/SessionList" withParems:nil];

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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
//    YQWeChatMoel * wechatmodel = _dataSource[indexPath.row];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
