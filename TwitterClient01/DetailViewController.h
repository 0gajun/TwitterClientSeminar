//
//  DetailViewController.h
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/18.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TweetSheetViewController.h"
#import "TimeLineCell.h"

@interface DetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property NSString *name;
@property NSString *text;
@property UIImage *image;
@property NSString *identifier;
@property NSString *idStr;
@property NSString *recallIdStr;
@property BOOL replyFlag;

@property (weak, nonatomic) IBOutlet UIButton *favoriteIcon;

@property (weak, nonatomic) IBOutlet UILabel *conversationsLabel;

@property (weak, nonatomic) IBOutlet UITableView *ReplyTableView;

@end
