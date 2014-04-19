//
//  TweetSheetViewController.h
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/19.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TweetSheetViewController : UIViewController

@property NSString *identifier;

@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property ACAccountStore *accountStore;

-(IBAction)tweetActoin :(id)sender;

@end
