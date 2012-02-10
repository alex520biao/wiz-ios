//
//  WelcomeViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WelcomeViewController : UITableViewController {
	UIImage* imgAccount;
	UIImage* imgAddAccount;
	UIImage* imgCreateAccount;
	UIImage* imgAboutSmall;
	//
	NSString* currentAccountUserId;

}

@property (nonatomic, retain) UIImage* imgAccount;
@property (nonatomic, retain) UIImage* imgAddAccount;
@property (nonatomic, retain) UIImage* imgCreateAccount;
@property (nonatomic, retain) UIImage* imgAboutSmall;

@property (nonatomic, retain) NSString* currentAccountUserId;


-(void) onAutoSelectAccount;
-(void) selectAccount:(int)accountIndex;

- (IBAction) cancel: (id)sender;

@end
