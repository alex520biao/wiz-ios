//
//  FolderListView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FolderListView.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizDocumentsByLocation.h"
#import "WizSyncByLocation.h"
@implementation FolderListView
@synthesize location;

-(void) dealloc
{
    self.location = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self != nil) {
        textPull= NSLocalizedString(@"Pull down to sync notes...", nil);
        textRelease = NSLocalizedString(@"Release to sync notes...", nil);
        textLoading = NSLocalizedString(@"Loading...", nil);
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) onSyncEnd
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
    [self stopLoading];
    [self reloadAllData];
}
- (void) displayProcessInfo
{
    WizSyncByLocation* syncByLocation = [[WizGlobalData sharedData] syncByLocationData:self.accountUserID];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[syncByLocation notificationName:WizGlobalSyncProcessInfo] object:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 ) //Edit
	{
		return;
	}else
    {
        WizSyncByLocation* syncByLocation = [[WizGlobalData sharedData] syncByLocationData:self.accountUserID];
        [[NSNotificationCenter defaultCenter] postNotificationName:[syncByLocation notificationName:WizGlobalStopSync] object: nil userInfo:nil];
    }
    self.assertAlerView = nil;
}


- (void) refresh
{
    WizSyncByLocation* syncByLocation = [[WizGlobalData sharedData] syncByLocationData:self.accountUserID];
    syncByLocation.location = self.location;
    if( ![syncByLocation startSync])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSyncError
                                                        message:WizStrSyncAlreadyInProcess
                                                       delegate:nil 
                                              cancelButtonTitle:WizStrOK 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self stopLoading];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[syncByLocation notificationName:WizSyncEndNotificationPrefix] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[syncByLocation notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
}

- (void) reloadDocuments
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.sourceArray = [[[index documentsByLocation:self.location] mutableCopy] autorelease];
    if([self.sourceArray count] == 0)
    {
        self.tableView.backgroundView = [WizGlobals noNotesRemindFor:NSLocalizedString(@"There is no note in this folder",nil)];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
   
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        WizSyncByLocation* syncByLocation = [[WizGlobalData sharedData] syncByLocationData:self.accountUserID];
        if(syncByLocation.busy)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:[syncByLocation notificationName:WizGlobalStopSync] object: nil userInfo:nil];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end
