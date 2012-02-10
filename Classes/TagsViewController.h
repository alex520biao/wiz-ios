//
//  TagsViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TagsViewController : UITableViewController {
	NSString* accountUserId;
	NSArray* tags;
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSArray* tags;

@end
