//
//  WizActivityIndicatorTableViewCell.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WizActivityIndicatorTableViewCell : UITableViewCell {
	UIActivityIndicatorView *activityIndicatorView;
}

-(void)startActivityAnimation;
-(void)stopActivityAnimation;
-(void)reset;

@end
