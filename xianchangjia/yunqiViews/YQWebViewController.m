//
//  YQWebViewController.m
//  yunqi
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 jijia. All rights reserved.
//

#import "YQWebViewController.h"
#import "XCAlbumAdditions.h"
#import "UINavigationController+SGProgress.h"

@interface YQWebViewController ()<UIWebViewDelegate>

@end

@implementation YQWebViewController

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
    UIWebView * webview = (UIWebView*) [self.view subviewWithTag:1];
    webview.delegate = self;
    webview.backgroundColor = [UIColor clearColor];
//    [webview setHeight:APP_SCREEN_HEIGHT];
//    [self followScrollView:webview];

    [webview loadRequest:
     [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://m.xmato.com/"]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationController showSGProgressWithDuration:3 andTintColor:ios7BlueColor];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationController finishSGProgress];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.navigationController finishSGProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
