//
//  SearchViewController.h
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface SearchViewController : UITableViewController {
	NSString* accountUserId;
	NSString* accountPassword;	
	//
	UITableViewCell *searchTextTableViewCell;
	UITableViewCell *searchLocalTableViewCell;
	UITableViewCell *searchNowTableViewCell;
	
	UITextField* searchTextField;
	UISwitch* searchLocalSwitch;
	//
	UIAlertView* waitAlertView;
	//
	DetailViewController* detailViewController;
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;

@property (nonatomic, retain) IBOutlet UITableViewCell* searchTextTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* searchLocalTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* searchNowTableViewCell;
@property (nonatomic, retain) IBOutlet UITextField* searchTextField;
@property (nonatomic, retain) IBOutlet UISwitch* searchLocalSwitch;

@property (nonatomic, retain) UIAlertView* waitAlertView;

@property (nonatomic, retain) DetailViewController* detailViewController;

- (IBAction) search: (id)sender;
- (IBAction) cancel: (id)sender;


- (void) xmlrpcDone: (NSNotification*)nc;

@end
