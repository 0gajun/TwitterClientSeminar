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

@property UIImage *favoriteImage;
@property Boolean isFavorited;
@property NSMutableArray *replyText;
@property NSMutableArray *replyImageUrl;
@property NSMutableArray *replyUserName;
@property int arraySize;

@property dispatch_queue_t mainQueue;
@property dispatch_queue_t imageQueue;
@property NSString *httpErrorMessage;


@property BOOL createArrayFlag;

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
    
    self.createArrayFlag = false;
    self.replyFlag = false;
    
    [self.ReplyTableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"ConversationsCell"];
    
    self.ReplyTableView.delegate = self;
    self.ReplyTableView.dataSource = self;
    
    [self checkFavorited];
    [self checkReply];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mineReply:(NSString *) replyId
{
    if (replyId == NULL) {
        return;
    }
    NSLog(@"mineReply");
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSDictionary *params = @{@"id" : replyId};
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/show.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodGET URL:url parameters:params];
    [request setAccount:account];
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponce,
                                         NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
        if (responseData) {
            NSInteger statusCode = urlResponce.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *ResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                NSString *existReply = ResponseData[@"in_reply_to_screen_name"];
                NSLog(@"exist reply:%@",existReply);
                if (existReply){
                    NSString *reply_id =[NSString stringWithFormat:@"%@", ResponseData[@"in_reply_to_status_id_str"] ];
                    [self mineReply: reply_id];
                    self.replyFlag = true;
                    [self.replyUserName addObject:ResponseData[@"screen_name"]];
                    [self.replyText addObject: ResponseData[@"text"]];
                    [self.replyImageUrl addObject: ResponseData[@"profile_image_url_https"]];
                    NSLog(@"recall...");
                } else {
                    
                }
                
                NSLog(@"[SUCCESS!] Checked Tweet with ID: %@ \n Data:%@", ResponseData[@"id_str"], ResponseData);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        } else {
            NSLog(@"[ERROR] An error occured while posting: %@", [error localizedDescription]);
        }
        });
    }];


}

-(void)checkReply
{
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSDictionary *params = @{@"id" : self.idStr};
    NSLog(@"idStr:%@",self.idStr);
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/show.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodGET URL:url parameters:params];
    [request setAccount:account];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponce,
                                         NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponce.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *ResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                NSString *existReply = ResponseData[@"in_reply_to_screen_name"];
                NSLog(@"exist reply:%@",existReply);
                if (existReply != 0){
                    self.arraySize = 0;
                    NSLog(@"minereply%@",ResponseData[@"in_reply_to_status_id"]);
                    NSString *reply_id =[NSString stringWithFormat:@"%@", ResponseData[@"in_reply_to_status_id_str"] ];
                    [self mineReply:reply_id];
                    NSLog(@"back to checkreply");
                } else {
                    
                }
                
                NSLog(@"[SUCCESS!] Checked Tweet with ID: %@ \n Data:%@", ResponseData[@"id_str"], ResponseData);
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

-(void)checkFavorited
{
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSDictionary *params = @{@"id" : self.idStr};
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/show.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodGET URL:url parameters:params];
    [request setAccount:account];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponce,
                                         NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponce.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *ResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                self.isFavorited = [ResponseData[@"favorited"] intValue];
                NSLog(@"favorited:%d",self.isFavorited);
                if (self.isFavorited){
                    self.favoriteImage = [UIImage imageNamed:@"favorited.png"];
                } else {
                    self.favoriteImage = [UIImage imageNamed:@"notfavorited.png"];
                }
                
                NSLog(@"[SUCCESS!] Checked Tweet with ID: %@ \n Data:%@", ResponseData[@"id_str"], ResponseData);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        } else {
            NSLog(@"[ERROR] An error occured while posting: %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            [self.favoriteIcon setImage:self.favoriteImage forState:UIControlStateNormal];
            
        });
    }];
}

- (IBAction)retweetAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認" message:@"リツイートします" delegate:self cancelButtonTitle:@"しない" otherButtonTitles:@"リツイート", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0:
            return;
            break;
        case 1:
            if ([alertView.message isEqualToString:@"リツイートします"]) {
                [self postRetweet];
            }
            break;
        default:
            break;
    }

}


-(void)postRetweet
{
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

- (IBAction)favoriteAction:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    NSURL *url ;
    if (self.isFavorited) {
        url = [NSURL URLWithString:@"https://api.twitter.com/1.1/favorites/destroy.json"];
        NSLog(@"destroy favorite");
    } else {
        url = [NSURL URLWithString:@"https://api.twitter.com/1.1/favorites/create.json"];
        NSLog(@"create favorite");
    }
    
    
    
    NSDictionary *params = @{@"id" : self.idStr};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter  requestMethod:SLRequestMethodPOST URL:url parameters:params];
    
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
                
                NSLog(@"[SUCCESS!] Favorited Tweet with ID: %@", postResponseData[@"id_str"]);
            } else {
                NSLog(@"[Error] Server responded: status code %d %@", statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        } else {
            NSLog(@"[ERROR] An error occured while posting: %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            [self checkFavorited];
        });
    }];
}

- (IBAction)replyAction:(id)sender {
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



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (!self.replyFlag) {
        return 0;//何か返さないと落ちてしまうためⅠつ返す
    } else {
        NSLog(@"replyText count:%d",[self.replyText count]);
        return [self.replyText count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationsCell"];
    NSLog(@"tableView");
    // Configure the cell...
    
    if (self.httpErrorMessage) {
        cell.tweetTextLabel.text = self.httpErrorMessage;
        cell.tweetTextLabelHeight = 24;
    } else if (!self.replyText) {
        cell.tweetTextLabel.text = @"Loading...";
        cell.tweetTextLabelHeight = 24;
    } else {
        //NSString *name = [[self.timeLineData[indexPath.row] objectForKey:@"user"] objectForKey:@"screen_name"];
        //NSString *text = [self.timeLineData[indexPath.row] objectForKey:@"text"];
        
        NSString *name = self.replyUserName[[self.replyUserName count]-  indexPath.row];
        NSString *text = self.replyText[[self.replyUserName count]-  indexPath.row];
        
        //UITableViewの高さ計算方法
        cell.tweetTextLabelHeight = [self labelHeight:text];
        cell.tweetTextLabel.text = text;
        
        cell.nameLabel.text = name;
        
        cell.profileImageView.image = [UIImage imageNamed:@"blank.png"];
        //NSLog(@"%@,%@",cell.tweetTextLabel.text,cell.nameLabel.text);
        
        UIApplication *application = [UIApplication sharedApplication];
        application.networkActivityIndicatorVisible = YES;
        
        dispatch_async(self.imageQueue, ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.replyImageUrl[[self.replyImageUrl count] - indexPath.row]]];
            dispatch_async(self.mainQueue, ^{
                UIApplication *application = [UIApplication sharedApplication];
                application.networkActivityIndicatorVisible = NO;
                UIImage *image = [[UIImage alloc] initWithData:data];
                cell.profileImageView.image = image;
                [cell setNeedsLayout];
            });
            
        });
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tweetText = self.replyText[[self.replyText count]-indexPath.row];
    CGFloat tweetTextLabelHeight = [self labelHeight:tweetText];
    return tweetTextLabelHeight + 50;
}

-(CGFloat) labelHeight: (NSString *)labelText
{
    UILabel *aLabel = [[UILabel alloc] init];
    CGFloat lineHeight = 18.0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    
    NSString *text = (labelText == nil) ? @"":labelText;
    UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyle,
                                 NSFontAttributeName: font};
    NSAttributedString *aText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    aLabel.attributedText = aText;
    
    CGFloat aHeight = [aLabel.attributedText boundingRectWithSize:CGSizeMake(257,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    return aHeight;
}


- (IBAction)showConversations:(id)sender {
    
    [self.ReplyTableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"TweetSheetSegueReply"]) {
        TweetSheetViewController *tweetSheetViewController = segue.destinationViewController;
        if ([tweetSheetViewController isKindOfClass:[tweetSheetViewController class] ]) {
            tweetSheetViewController.identifier = self.identifier;
            tweetSheetViewController.reply = [NSString stringWithFormat:@"@%@ ",self.name];
        }
    }
}

@end
