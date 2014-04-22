//
//  YurutterTimeLineTableViewController.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/21.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "YurutterTimeLineTableViewController.h"

@interface YurutterTimeLineTableViewController ()

@property dispatch_queue_t mainQueue;
@property dispatch_queue_t imageQueue;

@property NSString *httpErrorMessage;
@property NSMutableArray *timeLineData;

@end

@implementation YurutterTimeLineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[TimeLineCell class] forCellReuseIdentifier:@"TimeLineCell"];
    
    [self getTweet];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (!self.timeLineData) {
        return 1;//何か返さないと落ちてしまうためⅠつ返す
    } else {
        return [self.timeLineData count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeLineCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (self.httpErrorMessage) {
        cell.tweetTextLabel.text = self.httpErrorMessage;
        cell.tweetTextLabelHeight = 24;
    } else if (!self.timeLineData) {
        cell.tweetTextLabel.text = @"Loading...";
        cell.tweetTextLabelHeight = 24;
    } else {
        //NSString *name = [[self.timeLineData[indexPath.row] objectForKey:@"user"] objectForKey:@"screen_name"];
        //NSString *text = [self.timeLineData[indexPath.row] objectForKey:@"text"];
        
        NSString *name = self.timeLineData[indexPath.row][@"user"][@"screen_name"];
        NSString *text = self.timeLineData[indexPath.row][@"text"];
        
        
        //UITableViewの高さ計算方法
        cell.tweetTextLabelHeight = [self labelHeight:text];
        cell.tweetTextLabel.text = text;
        
        cell.nameLabel.text = name;
        
        cell.profileImageView.image = [UIImage imageNamed:@"blank.png"];
        //NSLog(@"%@,%@",cell.tweetTextLabel.text,cell.nameLabel.text);
        
        UIApplication *application = [UIApplication sharedApplication];
        application.networkActivityIndicatorVisible = YES;
        
        dispatch_async(self.imageQueue, ^{
            NSString *url;
            NSDictionary *tweetDictionary = self.timeLineData[indexPath.row];
            
            if ([[tweetDictionary allKeys] containsObject:@"retweeted_status"]) {
                url = tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"];
            } else {
                url = tweetDictionary[@"user"][@"profile_image_url"];
            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
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
    NSString *tweetText = self.timeLineData[indexPath.row][@"text"];
    CGFloat tweetTextLabelHeight = [self labelHeight:tweetText];
    return tweetTextLabelHeight + 50;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeLineCell *cell = (TimeLineCell *)[tableView cellForRowAtIndexPath:indexPath];
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    detailViewController.name = cell.nameLabel.text;
    detailViewController.text = cell.tweetTextLabel.text;
    detailViewController.image = cell.profileImageView.image;
    detailViewController.identifier = self.identifier;
    detailViewController.idStr = self.timeLineData[indexPath.row][@"id_str"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}


-(void)getTweet
{
    self.mainQueue = dispatch_get_main_queue();
    self.imageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccount *account = [accountStore accountWithIdentifier:self.identifier];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *params = @{@"count": @"200",
                             @"trim_user" : @"0",
                             @"include_entities" : @"0"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    
    [request setAccount:account];
    
    //network indicatorの表示
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if (responseData) {
            self.httpErrorMessage = nil;
            if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                NSError *jsonError;
                self.timeLineData =
                [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
                
                if (self.timeLineData) {
                    //NSLog(@"Timeline Responce: %@\n", self.timeLineData);
                    dispatch_async(self.mainQueue, ^{
                        [self yurutterAlgo];
                        [self.tableView reloadData];
                    });
                } else {
                    NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                }
            } else {
                self.httpErrorMessage = [NSString stringWithFormat:@"The response status code is %d", urlResponse.statusCode];
                NSLog(@"HTTP Error!: %@", self.httpErrorMessage);
            }
        }
        dispatch_async(self.mainQueue, ^{
            UIApplication *application = [UIApplication sharedApplication];
            application.networkActivityIndicatorVisible = NO;
            
        });
    }];
}

-(void)yurutterAlgo
{
    NSLog(@"Before YurutterAlgo:number of timelinedataObjects%d",self.timeLineData.count);
    int number = self.timeLineData.count;
    if (number <= 25) {
        return;
    }
    srand((unsigned)time(NULL));
    for (int i = 1; i <= number - 25; i++) {
        int j = rand() % (number + 1 - i);
        [self.timeLineData removeObjectAtIndex:j];
    }
    NSLog(@"After YurutterAlgo:number of timelinedataObjects%d",self.timeLineData.count);
    
}

-(void)onRefresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    
    [self getTweet];
    
    [self.refreshControl endRefreshing];
}


@end
