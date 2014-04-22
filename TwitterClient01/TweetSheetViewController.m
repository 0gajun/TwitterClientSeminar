//
//  TweetSheetViewController.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/19.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "TweetSheetViewController.h"

@interface TweetSheetViewController ()

@end

@implementation TweetSheetViewController

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
    [self getProfile];
    self.tweetTextView.text = self.reply;
    
}

-(void)getProfile
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    self.nameLabel.text = account.username;
    
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
            [self.tweetTextView resignFirstResponder];
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            self.profileImageView.image = [[UIImage alloc] initWithData:data];
        });
    }];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)postTweet {
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSString *tweetString = self.tweetTextView.text;
    
    if ([tweetString isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tweet Error!" message:@"ツイート内容が記入されていません！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSDictionary *params = @{@"status" : tweetString};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];
    
    [request setAccount:account];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tweetTextView resignFirstResponder];
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Tweet Sheet has been dismissed.");
            }];
        });
    }];

}

- (IBAction)tweetAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"確認" message:@"ツイート送信します" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK！", nil];
    [alert show];
    
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Tweet Sheet has been dismissed.");
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0:
            return;
            break;
        case 1:
            if ([alertView.message isEqualToString:@"ツイート送信します"]) {
                [self postTweet];
            }
            break;
        default:
            break;
    }
}




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
