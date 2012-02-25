//
//  DetailViewController.m
//  iPad
//
//  Created by Wei Shijun on 5/19/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizGlobals.h"

#import "WizDocumentsByLocation.h"
#import "WizDownloadRecentDocuments.h"
#import "WizDocumentsByTag.h"
#import "WizDownloadObject.h"


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController

@synthesize toolbar;
@synthesize popoverController;
@synthesize tableView;
@synthesize rootController;

@synthesize accountUserId;
@synthesize documents;
@synthesize currentDocument;
@synthesize waitAlertView;

@synthesize documentsType;
@synthesize documentsTypeData;


-(NSString*) getSyncDocumentsXmlRpcMethod
{
	if (documentsRecent == self.documentsType)
	{
		return SyncMethod_DownloadDocumentList;
	}
	else if (documentsFolder == self.documentsType)
	{
		return SyncMethod_DocumentsByCategory;
	}
	else if (documentsTag == self.documentsType)
	{
		return SyncMethod_DocumentsByTag;
	}
	else
	{
		return [NSString stringWithString:@""];
	}
}

-(void) reloadAllData
{
	NSArray* docs = nil;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	if (documentsRecent == self.documentsType)
	{
		docs = [index recentDocuments];
	}
	else if (documentsFolder == self.documentsType)
	{
		docs = [index documentsByLocation:self.documentsTypeData ];
	}
	else if (documentsTag == self.documentsType)
	{
		docs = [index documentsByTag:self.documentsTypeData ];
	}
	else
	{
		docs = nil;
	}
	//
	if (docs)
	{
		self.documents = [NSMutableArray arrayWithArray:docs];
	}
	//
	[self.tableView reloadData];
	//
	//
    if (self.popoverController != nil) 
	{
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

-(void) listDocuments:(NSString*)userId docType:(int)docType typeData:(NSString*)typeData docs:(NSArray*)docs
{
	self.accountUserId = userId;
	self.documentsType = docType;
	self.documentsTypeData = typeData;
	if (docs)
	{
		self.documents = [NSMutableArray arrayWithArray:docs];
	}
	//
	[self configureView];
}

- (void)configureView 
{
	[self reloadAllData];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = NSLocalizedString(@"Folders", nil);
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//
	self.documentsType = documentsNone;
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewDocument:) name:@"onNewDocument" object:nil];
	//
	//
}

- (void)viewDidUnload {
    self.popoverController = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//
	[super viewDidUnload];
}

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
	
    [super dealloc];
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	if (self.documents == nil)
		return 0;
	//
	return [self.documents count];
}


- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (self.documents == nil)
		 return nil;
	//
	static NSString* CellId = @"DocumentCell";
	
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleSubtitle
				 reuseIdentifier:CellId] autorelease];
	}
	//
	if (indexPath.row < [self.documents count])
	{
		//
		WizDocument* doc = [self.documents objectAtIndex:indexPath.row];
		cell.textLabel.text = doc.title;
		cell.detailTextLabel.text = [WizGlobals sqlTimeStringToToLocalString:doc.dateCreated];
		
		//cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	}
	//
	return cell;
}


- (void) showModalView:(UIViewController*)modalView fullScreen:(BOOL)fullScreen
{
	UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:modalView];
	modalNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	modalNavigationController.modalPresentationStyle = fullScreen ? UIModalPresentationFullScreen : UIModalPresentationFormSheet;
	[self.splitViewController presentModalViewController:modalNavigationController animated:YES];
	[modalNavigationController release];
}	

- (void) viewDocument
{

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
				//
				WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
				
				//
				NSString* fileName = [WizIndex documentFileName:self.accountUserId documentGUID:doc.guid];
				BOOL serverChanged = [index documentServerChanged:doc.guid];
				//
				if (!serverChanged && [WizGlobals pathFileExists:fileName])
				{
					[self viewDocument];
				}
				else 
				{
					
					UIAlertView* alert = nil;
					[WizGlobals showAlertView:NSLocalizedString(@"Download Document", nil) 
									  message:NSLocalizedString(@"Please wait while downloading document...!", nil) 
									 delegate:self 
									  retView:&alert];
					[alert show];
					self.waitAlertView = alert;
					[alert release];
                    WizDownloadObject* downloader = [[WizGlobalData sharedData] downloadObjectData:self.accountUserId];
					downloader.objType = @"document";
                    downloader.objGuid = doc.guid;
                    downloader.currentPos = 0;
					NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
					[nc removeObserver:self];
					NSString* notificationName = [downloader notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix];
					[nc addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
					[downloader downloadObject];

				}
			}
		}
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
				/*
				 NSString* msg = [NSString stringWithFormat:@"Do you want to delete [%@]", doc.title]; 
				 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Delete",@"Cancel", nil];
				 
				 [alert show];
				 [alert release];
				 */
				//
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
		if ([method isEqualToString:[self getSyncDocumentsXmlRpcMethod]]
			|| [method isEqualToString:SyncMethod_DownloadMobileData])
		{
			if (self.waitAlertView)
			{
				[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
				self.waitAlertView = nil;
			}
		}
		//
		if ([method isEqualToString:[self getSyncDocumentsXmlRpcMethod]])
		{
			[self reloadAllData];
		}
		else if([method isEqualToString:SyncMethod_DownloadMobileData])
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
					if (self.currentDocument)
					{
						WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
						[index setDocumentServerChanged:self.currentDocument.guid changed:NO];
					}
					//
					[self viewDocument];
				}
			}
		}
	}
	else 
	{
		if (self.waitAlertView)
		{
			[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
			self.waitAlertView = nil;
		}
	}
}


-(void) refreshDocuments
{
	if (self.accountUserId == nil)
		return;
	//
	if (self.documentsType == documentsNone
		|| self.documentsType == documentsSearchResult)
		return;
	//
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:NSLocalizedString(@"Refresh Documents", nil) 
					  message:NSLocalizedString(@"Please wait while downloading document...!", nil) 
					  delegate:self 
					  retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
	//
	[alert release];
	//
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	//
	NSString* notificationName = [WizApi notificationName:WizSyncXmlRpcDoneNotificationPrefix accountUserId:self.accountUserId];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	
	if (documentsRecent == self.documentsType)
	{
		WizDownloadRecentDocuments* downloader = [[WizGlobalData sharedData] downloadRecentDocumentsData:self.accountUserId];
		[downloader downloadDocumentList];
	}
	else if (documentsFolder == self.documentsType)
	{
		WizDocumentsByLocation* downloader = [[WizGlobalData sharedData] documentsByLocationData:self.accountUserId];
		downloader.location = self.documentsTypeData;
		[downloader downloadDocumentList];
	}
	else if (documentsTag == self.documentsType)
	{
		WizDocumentsByTag* downloader = [[WizGlobalData sharedData] documentsByTagData:self.accountUserId];
		downloader.tag_guid = self.documentsTypeData;
		[downloader downloadDocumentList];
	}
}

-(IBAction) onRefreshDocuments:(id)sender
{
	[self refreshDocuments];
}

-(void) newNote
{

	
}

-(IBAction) onNewNote:(id)sender
{
	[self newNote];
}

-(IBAction) onSearch:(id)sender
{
}

-(void) clearData
{
	self.documentsType = documentsNone;
	self.documentsTypeData = nil;
	self.documents = nil;
	//
	[self configureView];
}


- (void) onNewDocument: (NSNotification*)nc
{
	[self reloadAllData];
	//
	/*
	NSDictionary* userInfo = [nc userInfo];
	//
	NSString* userId = [userInfo objectForKey:@"accountUserId"];
	NSString* guid = [userInfo objectForKey:@"guid"];
	//
	if (!userId)
		return;
	if (!guid)
		return;
	//
	if (![self.accountUserId isEqualToString:self.accountUserId])
		return;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:userId];
	if (!index)
		return;
	//
	WizDocument* doc = [index documentFromGUID:guid];
	if (!doc)
		return;
	//
	*/
	
}



@end
