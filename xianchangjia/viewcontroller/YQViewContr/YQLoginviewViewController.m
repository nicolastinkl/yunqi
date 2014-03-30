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

@property (weak, nonatomic) IBOutlet UIImageView *image_line;
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
    
    self.image_line.height = .5f;
    
    self.Text_LoginName.text = @"ciznx@qq.com";
    self.Text_LoginPwd.text = @"111111";
    
}

- (IBAction)hiddenKeyboardClick:(id)sender {
    
    [self.Text_LoginName resignFirstResponder];
    [self.Text_LoginPwd resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        // default top is 70  when keyboard show ... 0
        self.view_bg.top = 0;
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
        self.view_bg.top = -50;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        // default top is 70  when keyboard show ... 0
        
        self.view_bg.top = 0;
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
    [mutaDict setValue:@"iPhone"    forKey:@"devicetype"];
    [mutaDict setValue:openUDID     forKey:@"deviceid"];
    [mutaDict setValue:@""          forKey:@"domain"];    //.cloud7.com.cn
    [mutaDict setValue:username     forKey:@"username"];
    [mutaDict setValue:pwd          forKey:@"password"];
    
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
               NSDictionary * dataDict = response[@"data"];
               NSString * hostname = [DataHelper getStringValue:dataDict[@"hostName"] defaultValue:@""];
               if (![hostname isHttpUrl])
                   hostname = [NSString stringWithFormat:@"http://%@",hostname];
               NSString * token = [DataHelper getStringValue:dataDict[@"token"] defaultValue:@""];
               NSString * tokenValidDuration = [DataHelper getStringValue:dataDict[@"tokenValidDuration"] defaultValue:@""];
               [USER_DEFAULT setValue:hostname forKey:KeyChain_yunqi_account_notifyServerhostName];
               [USER_DEFAULT setValue:tokenValidDuration forKey:KeyChain_yunqi_account_tokenExpire];
               [USER_DEFAULT setValue:token forKey:KeyChain_yunqi_account_token];
               [USER_DEFAULT setValue:token forKey:KeyChain_Laixin_account_sessionid];
               [USER_DEFAULT setBool:YES forKey:KeyChain_Laixin_account_HasLogin];
               [USER_DEFAULT synchronize];
               [[NSNotificationCenter defaultCenter] postNotificationName:LaixinSetupDBMessageNotification object:token];
               [self dismissViewControllerAnimated:YES completion:^{
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"TKthefristLogin" object:nil];
               }];
           }else{
               //error from server ...
               [UIAlertView showAlertViewWithMessage:@"登录失败"];
           }
       } withParems:mutaDict withAction:@"Cloud7/WebApp/DeviceSignin"];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
