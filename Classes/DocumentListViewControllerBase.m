//
//  DocumentListViewControllerBase.m
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "DocumentListViewControllerBase.h"
#import "DocumentViewController.h"
#import "CommonString.h"


#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizGlobals.h"

#import "Globals/WizDocumentsByLocation.h"
#import "WizDownloadObject.h"
#import "Globals/ZipArchive.h"
#import "AttachmentView.h"
#import "NewNoteView.h"
#import "AccountViewController.h"
#import "DocumentViewCtrollerBase.h"
//wiz-dzpqzb test
#import "WizSync.h"
#import "TagSelectView.h"

@implementation DocumentListViewControllerBase

@synthesize accountUserId;
@synthesize documents;
@synthesize currentDocument;
@synthesize waitAlertView;
@synthesize syncButton;
@synthesize activeButton;

- (NSArray*) reloadDocuments
{
	return [NSArray array];
}
- (BOOL) isBusy
{
	return NO;
}
- (BOOL) canSync
{
	return YES;
}
- (NSString*) titleForView
{
	return WizStrDocuments;
}
- (void) syncDocuments
{
}
- (NSString*) syncDocumentsXmlRpcMethod
{
	return [NSString stringWithString:@""];
}

- (void) initSyncButton
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:WizStrRefresh style:UIBarButtonItemStyleDone target:self action:@selector(onSyncDocuments:)];
	self.syncButton = button;
	[button release];
}

- (void)initActiveButton
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aiv];
	[aiv startAnimating]; 
	[aiv release];
	
	self.activeButton = activityButtonItem;
	[activityButtonItem release];
	[apool release];
}


//wiz-dzpqzb test
-(void) tagsSelectView
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:[sync notificationName:WizGlobalStopSync] object: nil userInfo:nil];
}

- (void) viewDidLoad
{
	[self initSyncButton];
	[self initActiveButton];
	//
	if ([self canSync])
	{
		self.navigationItem.rightBarButtonItem = [self isBusy] ? self.activeButton : self.syncButton;
	}
	//
	self.title = [self titleForView];
	//
    
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
    [tools setTintColor:[self.navigationController.navigationBar tintColor]]; 
    [tools setAlpha:[self.navigationController.navigationBar alpha]]; 
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                   target:self action:@selector(newNote)];
    UIBarButtonItem *anotherButton1 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain 
                                                                      target:self action:@selector(tagsSelectView)]; 
    [buttons addObject:anotherButton]; 
    [anotherButton release]; 
    [buttons addObject:anotherButton1]; 
    [anotherButton1 release]; 
    [tools setItems:buttons animated:NO]; 
    [buttons release]; 
    UIBarButtonItem *myBtn = [[UIBarButtonItem alloc] initWithCustomView:tools]; 
    self.navigationItem.rightBarButtonItem = myBtn;
    [myBtn release]; 
    [tools release];
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	self.activeButton = nil;
	self.syncButton = nil;
	[super viewDidUnload];
}

- (void) reloadAllData
{
	self.documents = [NSMutableArray arrayWithArray:[self reloadDocuments]];
	
	[self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self reloadAllData];
	//
	[super viewWillAppear:animated];
}
- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//
	self.documents = nil;
}

- (void) dealloc
{
	self.accountUserId = nil;
	self.documents = nil;
	//
	[super dealloc];
}


- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	if (0 == section)
		return [self.documents count];
	return 0;
}


- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	static NSString* CellId = @"DocumentCell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleSubtitle
				 reuseIdentifier:CellId] autorelease];
	}
	//
	if (0 == indexPath.section)
	{
		if (indexPath.row < [self.documents count])
		{
			
			//
			WizDocument* doc = [self.documents objectAtIndex:indexPath.row];
			cell.textLabel.text = doc.title;
			cell.detailTextLabel.text = [WizGlobals sqlTimeStringToToLocalString:doc.dateCreated];
			
			//cell.imageView.image = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
		}
	}
	//
	return cell;
}
- (void) viewDocument
{
	if (!self.currentDocument)
		return;
	//
	DocumentViewCtrollerBase* docView = [[DocumentViewCtrollerBase alloc] initWithNibName:@"DocumentViewCtrollerBase" bundle:nil];
	docView.accountUserID = self.accountUserId;
	docView.doc = self.currentDocument;
	//
    docView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:docView animated:YES];
	[docView release];
}
- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (indexPath.row < [self.documents count])
		{
			WizDocument* doc = [self.documents objectAtIndex:indexPath.row];
			if (doc)
			{
				self.currentDocument = doc;
                [self viewDocument];

			}
		}
	}
}

-(void) processGoing:(NSNotification*)ncc
{
    NSDictionary* userInfo = [ncc userInfo];
    NSNumber* totalProcess = [userInfo valueForKey:@"totalProcess"];
    NSNumber* currentProcess = [userInfo valueForKey:@"currentProcess"];
    //

    NSNumber* percent = [NSNumber numberWithFloat:[currentProcess floatValue]/[totalProcess floatValue]];
    self.waitAlertView.message =[NSString stringWithFormat: @"current download %d %%",(int)([percent floatValue]*100)];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    //
   
    //wiz-dzpqzb test
    [nc addObserver:self selector:@selector(processGoing:) name:[NSString stringWithFormat:@"%@-%@",SyncMethod_DownloadProcessPartBeginWithGuid,self.currentDocument.guid] object:nil];
    
    if([totalProcess intValue] == [currentProcess intValue])
    {
        WizDownloadObject* downloader = [[WizGlobalData sharedData] downloadObjectData:self.accountUserId];
        NSString* notificationName = [downloader notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix];
        [nc addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
    }
    
}
- (void) tableView: (UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (indexPath.row < [self.documents count])
		{
			WizDocument* doc = [self.documents objectAtIndex:indexPath.row];
			if (doc)
			{
				WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
				[index deleteDocument:doc.guid];
				[index addDeletedGUIDRecord:doc.guid type:@"document"];
				//
				[self.documents removeObjectAtIndex:indexPath.row];
				//
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
	}	
}

#pragma mark -
- (void) xmlrpcDone: (NSNotification*)nc
{
	NSDictionary* userInfo = [nc userInfo];
	//
	NSString* method = [userInfo valueForKey:@"method"];
	if (method == nil)
		return;
	//
	BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
	//
	if (succeeded)
	{
		if ([method isEqualToString:[self syncDocumentsXmlRpcMethod]])
		{
			[self reloadAllData];
			//
			if ([self canSync])
			{
				self.navigationItem.rightBarButtonItem = self.syncButton;
			}
		}
		else if([method isEqualToString:SyncMethod_DownloadObject])
		{
			id obj = [userInfo valueForKey:@"ret"];
			if ([obj isKindOfClass:[NSDictionary class]])
			{
				NSDictionary* dict = obj;
				NSString* documentGUID = [dict valueForKey:@"document_guid"];
				//
				if ([documentGUID isEqualToString:self.currentDocument.guid])
				{
					NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
					[nc removeObserver:self];
					//
					if (self.waitAlertView)
					{
						[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
						self.waitAlertView = nil;
					}
					//
					if (self.currentDocument)
					{
						WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
						[index setDocumentServerChanged:self.currentDocument.guid changed:NO];
					}
					//
					[self viewDocument];
                    
                    //wiz-dzpqzb test
                                      
				}
			}
		}
	}
	else 
	{
		self.navigationItem.rightBarButtonItem = self.syncButton;
		//
		if (self.waitAlertView)
		{
			[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
			self.waitAlertView = nil;
		}
	}
}

- (void) onSyncDocuments:(id)sender
{
	self.navigationItem.rightBarButtonItem = self.activeButton;
	//
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	//
	NSString* notificationName = [WizApi notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix accountUserId:self.accountUserId];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	[self syncDocuments];
}
- (void) onSyncEnd
{
    [self stopLoading];
    WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
    sync.isStopByUser = YES;
    [self reloadAllData];
}

-(void) syncGoing:(NSNotification*) nc
{
    return;
}

- (void) displayProcessInfo
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
}


-(void) refresh
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
    sync.isStopByUser = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
    [sync startSync];
}
@end
