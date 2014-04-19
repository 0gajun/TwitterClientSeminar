//
//  DetailViewController.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/18.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *nameView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//名前変更するには、一旦削除後、storyboardにおいてconnectionなんたらで接続を切ってからもう一度！

@end

@implementation DetailViewController

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
    self.navigationItem.title = @"Tweet Detail View";
    self.nameView.text = self.name;
    self.imageView.image = self.image;
    self.textView.text = self.text;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)retweetAction:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.twitter.com/1.1/statuses/retweet/%@.json", self.idStr];
    
    NSURL *url = [NSURL URLWithString:urlString];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodPOST URL:url parameters:nil];
    
    [request setAccount:account];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                        NSHTTPURLResponse *urlResponce,
                                        NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponce.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        } else {
            NSLog(@"[ERROR] An error occured while posting: %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
        });
    }];
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
