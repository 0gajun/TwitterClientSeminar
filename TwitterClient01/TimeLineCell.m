//
//  TImeLineCell.m
//  TwitterClient01
//
//  Created by OGA-Mac on 2014/04/12.
//  Copyright (c) 2014年 ogasawara.com. All rights reserved.
//

#import "TimeLineCell.h"

@implementation TimeLineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor darkGrayColor];
        self.view = [[UIView alloc]init];
        UIColor *color = [UIColor whiteColor];
        UIColor *acolor = [color colorWithAlphaComponent:0.1];
        self.view.backgroundColor = acolor;
        [self.contentView addSubview:self.view];
        
        _tweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tweetTextLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12.0f];
        _tweetTextLabel.textColor = [UIColor whiteColor];
        _tweetTextLabel.numberOfLines = 0;
        //self.tweetTextLabel.highlightedTextColor = [UIColor blueColor];
        [self.view addSubview:_tweetTextLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = [UIFont systemFontOfSize:10.0f];
        self.nameLabel.textColor = [UIColor blackColor];
        //self.nameLabel.highlightedTextColor = [UIColor blueColor];
        [self.view addSubview:self.nameLabel];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.profileImageView.image = self.image;
        [self.view addSubview:self.profileImageView];
        
        
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.view.frame = CGRectMake(5, 5, 310, self.tweetTextLabelHeight + 40);
    self.profileImageView.frame = CGRectMake(5, 5, 48, 48);
    self.tweetTextLabel.frame = CGRectMake(58, 5, 247, self.tweetTextLabelHeight);
    self.nameLabel.frame = CGRectMake(58, self.tweetTextLabelHeight + 15, 257, 12);
    
    NSLog(@"%@ layout", self.tweetTextLabel);

}



- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
