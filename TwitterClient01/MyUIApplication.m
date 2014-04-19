//
//  MyUIApplication.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/19.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "MyUIApplication.h"

@implementation MyUIApplication


-(BOOL)openURL:(NSURL *)url
{
    if (!url) {
        return NO;
    }
    
    self.MyOpenURL = url;
    AppDelegate *appDelegate = (AppDelegate *)[self delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

    
    WebViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.openURL = self.MyOpenURL;
    webViewController.title = @"Web View";
    
    [appDelegate.navigationController pushViewController:webViewController animated:YES];
    self.MyOpenURL = nil;
    
    return YES;
}
@end
