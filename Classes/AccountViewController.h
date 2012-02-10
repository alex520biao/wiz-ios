//
//  AccountViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountViewController : UITableViewController 
{
	NSString* accountUserId;
	//
	UIImage* imgNewNote;
	UIImage* imgTakePhoto;
	UIImage* imgDocuments;	
	UIImage* imgFolders;	
	UIImage* imgTags;	
	UIImage* imgSync;	
	UIImage* imgEditAccount;	
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) UIImage* imgNewNote;
@property (nonatomic, retain) UIImage* imgTakePhoto;
@property (nonatomic, retain) UIImage* imgDocuments;
@property (nonatomic, retain) UIImage* imgFolders;
@property (nonatomic, retain) UIImage* imgTags;
@property (nonatomic, retain) UIImage* imgSync;
@property (nonatomic, retain) UIImage* imgEditAccount;



-(void) onSyncBegin;
-(void) onSyncEnd;


@end
