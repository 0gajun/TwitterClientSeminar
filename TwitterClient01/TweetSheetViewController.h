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
@property UIImage *image;
@property NSString *name;

@property NSString *reply;



@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@property ACAccountStore *accountStore;




-(IBAction)tweetAction :(id)sender;
- (IBAction)cancelAction:(id)sender;
@end
