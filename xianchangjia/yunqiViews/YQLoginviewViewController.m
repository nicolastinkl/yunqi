//
//  YQLoginviewViewController.m
//  yunqi
//
//  Created by apple on 2/19/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQLoginviewViewController.h"
#import "XCAlbumAdditions.h"
#import "UIButton+Bootstrap.h"
#include "OpenUDID.h"

@interface YQLoginviewViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *Text_LoginName;
@property (weak, nonatomic) IBOutlet UITextField *Text_LoginPwd;
@property (weak, nonatomic) IBOutlet UIButton *Button_login;
@property (weak, nonatomic) IBOutlet UIView *view_bg;
@end

@implementation YQLoginviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.Button_login infoStyle];
    
    
}
- (IBAction)hiddenKeyboardClick:(id)sender {
    
    [self.Text_LoginName resignFirstResponder];
    [self.Text_LoginPwd resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        // default top is 70  when keyboard show ... 0
        self.view_bg.top = 160;
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.Text_LoginName)
    {
        [self.Text_LoginPwd becomeFirstResponder];
        return YES;
    }
    

    if(textField == self.Text_LoginPwd){
    
        [self.Text_LoginPwd resignFirstResponder];
            return YES;
    }

    return NO;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view_bg.top = 60;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        // default top is 70  when keyboard show ... 0
        
        self.view_bg.top = 160;
    }];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}



- (IBAction)loginClick:(id)sender {
    [SVProgressHUD showWithStatus:@"正在登录..."];
    
    [self.Text_LoginName resignFirstResponder];
    [self.Text_LoginPwd resignFirstResponder];
    
    NSString * username = [self.Text_LoginName text];
    NSString * pwd = [self.Text_LoginPwd text];
    NSString* openUDID = [OpenUDID value];
    NSMutableDictionary * mutaDict = [[NSMutableDictionary alloc] init];
    [mutaDict setValue:@"iPhone" forKey:@"devicetype"];
    [mutaDict setValue:openUDID forKey:@"deviceid"];
    [mutaDict setValue:[NSString stringWithFormat:@"%@.cloud7.com.cn",username] forKey:@"domain"];
    [mutaDict setValue:username forKey:@"username"];
    [mutaDict setValue:pwd forKey:@"password"];
    [[[LXAPIController sharedLXAPIController] requestLaixinManager] requestPostActionWithCompletion:^(id response, NSError *error) {
        if (response) {
            /*token	令牌
             tokenExpire	令牌过期的时间
             notifyTargetId	用于连接推送平台的 targetId
             notifyServerUrl	推送通知服务器的URL位置*/
            
            [SVProgressHUD dismiss];
        }
        else{
            [UIAlertView showAlertViewWithMessage:@"登录失败"];
            [SVProgressHUD dismiss];
        }
        
        
    } withAction:@"DeviceSignin" withParems:mutaDict];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
