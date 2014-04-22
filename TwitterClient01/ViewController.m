//
//  ViewController.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/12.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *tweetActionButton;
@property (weak, nonatomic) IBOutlet UILabel *accountDisplayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property ACAccountStore *accountStore;
@property NSArray *twitterAccounts;
@property NSString *identifier;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterType
            options:NULL
            completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    self.twitterAccounts = [self.accountStore accountsWithAccountType:twitterType];
                    if (self.twitterAccounts.count > 0) {
                        NSLog(@"Twitteraccounts = %@", self.twitterAccounts);
                        
                        ACAccount *account = self.twitterAccounts[0];
                        self.identifier = account.identifier;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self getProfile];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.accountDisplayLabel.text = @"アカウントなし";
                        });
                    }
                } else {
                    NSLog(@"Account Error: %@", [error localizedDescription]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.accountDisplayLabel.text = @"アカウント認証エラー";
                    });
                }
                
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)setAccountAction:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    
    sheet.title = @"選択してください。";
    for (ACAccount *account in self.twitterAccounts) {
        [sheet addButtonWithTitle:account.username];
    }
    [sheet addButtonWithTitle:@"キャンセル"];
    
    sheet.cancelButtonIndex = self.twitterAccounts.count;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.twitterAccounts.count > 0) {
        if (buttonIndex != self.twitterAccounts.count) {
            ACAccount *account = self.twitterAccounts[buttonIndex];
            self.identifier = account.identifier;
            [self getProfile];
            NSLog(@"Account set! %@", account.username);
        } else {
            NSLog(@"cancel!");
        }
    }
}

-(void)getProfile
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    self.accountDisplayLabel.text = account.username;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSDictionary *params = @{@"screen_name" : account.username};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    
    [request setAccount:account];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        NSData *data;
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *jsonData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                NSString *url = jsonData[@"profile_image_url_https"];
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                
                NSLog(@"[SUCCESS!] Got Profile Image!: %@", jsonData[@"profile_image_url_https"]);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            self.profileImageView.image = [[UIImage alloc] initWithData:data];
        });
    }];
    
    
    
}


//segue間での情報の受渡しの常套手段。
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"TimeLineSegue"]) {
        TimeLineTableViewController *timeLineTableViewController = segue.destinationViewController;
        if ([timeLineTableViewController isKindOfClass:[timeLineTableViewController class]]) {
            timeLineTableViewController.identifier = self.identifier;

        }
    } else if ([[segue identifier] isEqualToString:@"TweetSheetSegue"]) {
        TweetSheetViewController *tweetSheetViewController = segue.destinationViewController;
        if ([tweetSheetViewController isKindOfClass:[tweetSheetViewController class] ]) {
            tweetSheetViewController.identifier = self.identifier;
        }
    } else if ([[segue identifier] isEqualToString:@"YurutterTimeLineViewControllerSegue"]) {
        YurutterTimeLineTableViewController *yurutter = segue.destinationViewController;
        if ([yurutter isKindOfClass:[yurutter class] ]) {
            yurutter.identifier = self.identifier;
        }
    }
}

@end
