//
//  TagDocumentListView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TagDocumentListView.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
@implementation TagDocumentListView
@synthesize tag;

-(void) dealloc
{
    [tag release];
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
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) reloadDocuments
{
    WizIndex* index = [WizIndex activeIndex];
    self.sourceArray = [NSMutableArray arrayWithArray:[index documentsByTag:tag.guid]];
    if([self.sourceArray count] == 0)
    {
        self.tableView.backgroundView = [WizGlobals noNotesRemindFor:NSLocalizedString(@"There is no note in this tag",nil)];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
- (void) onSyncEnd
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
    [self stopLoading];
    [self reloadAllData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	if( buttonIndex == 0 ) //Edit
//	{
//		return;
//	}else
//    {
//        WizSyncByTag* syncByTag = [[WizGlobalData sharedData] syncByTagData:self.accountUserID];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[syncByTag notificationName:WizGlobalStopSync] object: nil userInfo:nil];
//    }
//    self.assertAlerView = nil;
}

- (void) displayProcessInfo
{
//    WizSyncByTag* syncByTag = [[WizGlobalData sharedData] syncByTagData:self.accountUserID];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[syncByTag notificationName:WizGlobalSyncProcessInfo] object:nil];
}
- (void) refresh
{
//    WizSyncByTag* syncByTag = [[WizGlobalData sharedData] syncByTagData:self.accountUserID];
//    syncByTag.tag = self.tag.guid;
//    if( ![syncByTag startSync])
//    {
//        return;
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[syncByTag notificationName:WizSyncEndNotificationPrefix] object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[syncByTag notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
//    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
//        WizSyncByTag* syncByTag = [[WizGlobalData sharedData] syncByTagData:self.accountUserID];
//        if(syncByTag.busy)
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:[syncByTag notificationName:WizGlobalStopSync] object: nil userInfo:nil];
//        }
//    }
}
@end
