//
//  WizActivityIndicatorTableViewCell.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizActivityIndicatorTableViewCell.h"


@implementation WizActivityIndicatorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIndentifier 
{  
    if (self = [super initWithStyle:style reuseIdentifier:reuseIndentifier])
	{
		activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		CGRect frame = [activityIndicatorView frame];
		frame.origin.x = [self.contentView bounds].size.width - frame.size.width;
		
		frame.origin.y += 15;
		[activityIndicatorView setFrame:frame];
		activityIndicatorView.tag = 1;	
		activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[self.contentView addSubview:activityIndicatorView];
		[self.contentView bringSubviewToFront:activityIndicatorView];
		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	//
	UILabel* label = self.textLabel;
	if (label != nil)
	{
		CGRect rc = label.frame;
		rc.size.width -= 20;
		//
		[label setFrame:rc];
	}
	//
	if (activityIndicatorView != nil)
	{
		CGRect rc = activityIndicatorView.frame;
		CGRect frame = [self.contentView bounds];
		//
		int x = frame.size.width - rc.size.width;
		int y = frame.origin.x + (frame.size.height - rc.size.height) / 2;
		//
		CGPoint pt = {x + rc.size.width / 2, y + rc.size.height / 2};
		[activityIndicatorView setCenter:pt];
	}
	//
	
	//
	
		
}

-(void)reset
{
	if ([activityIndicatorView isAnimating])
		[activityIndicatorView stopAnimating];
}

-(void)startActivityAnimation
{
	[activityIndicatorView startAnimating];
}

-(void)stopActivityAnimation
{
	[activityIndicatorView stopAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
    
	[activityIndicatorView release];
	[super dealloc];
}

@end
