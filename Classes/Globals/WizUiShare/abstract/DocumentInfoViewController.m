//
//  DocumentInfoViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "WizGlobalData.h"
#import "SelectFloderView.h"
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizPadNotificationMessage.h"
#import "WizSelectTagViewController.h"
#import "WizPhoneNotificationMessage.h"
#import "WizDbManager.h"
#import "WizMapViewController.h"

#import "WizNotification.h"
@interface DocumentInfoViewController()
{
    BOOL docChanged;
}
@end

@implementation DocumentInfoViewController
@synthesize doc;
-(void) dealloc
{
    if (!self.isEditTheDoc) {
        if (docChanged) {
            self.doc.localChanged = WizEditDocumentTypeInfoChanged;
            [self.doc saveInfo];
            [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
            [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
            docChanged = NO;
        }
    }
    [doc release];
    [super dealloc];
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

#pragma mark - View lifecycle
- (void) didSelectedTags:(NSArray *)tags
{
    [self.doc setTagWithArray:tags];
    docChanged = YES;
}
- (void) didSelectedFolderString:(NSString *)folderString
{
    self.doc.location = folderString;
    docChanged = YES;
}
- (NSArray*) selectedTagsOld
{
    return [self.doc tagDatas];
}
-(void) tagViewSelect
{
    WizSelectTagViewController* tagView = [[WizSelectTagViewController alloc]initWithStyle:UITableViewStyleGrouped];
    tagView.selectDelegate = self;
    [self.navigationController pushViewController:tagView animated:YES];
    [tagView release];
}
- (NSString*) selectedFolderOld
{
    return self.doc.location;
}
-(void) floderViewSelected
{
    SelectFloderView*  folderView = [[SelectFloderView alloc] initWithStyle:UITableViewStyleGrouped];
    folderView.selectDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedFloder:) name:TypeOfSelectedFolder object:nil];
    [self.navigationController pushViewController:folderView animated:YES];
    [folderView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Detail", nil);
}
-(void) fontChanged
{
//    WizIndex * index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    [index setWebFontSize:fontSlider.value];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    if (0 == indexPath.row) {
        cell.textLabel.text = WizStrTitle;
        cell.detailTextLabel.text = doc.title;
    }
    
    if (1 == indexPath.row) {
        cell.textLabel.text = WizStrTags;
        NSMutableString* tagNames = [NSMutableString string];
        for (WizTag* each in [self.doc tagDatas]) {
            [tagNames appendFormat:@"|%@",getTagDisplayName(each.title)];
        }
        cell.detailTextLabel.text = tagNames;
    }
    else if (2 == indexPath.row) {
        cell.textLabel.text = WizStrFolders;
        cell.detailTextLabel.text = [WizGlobals folderStringToLocal:self.doc.location];
    }
    
    else if (3 == indexPath.row) {
        cell.textLabel.text =  WizStrDateModified;
        cell.detailTextLabel.text =[doc.dateModified stringLocal];
    }
    else if (4 == indexPath.row) {
        cell.textLabel.text = WizStrDateCreated;
        cell.detailTextLabel.text = [doc.dateCreated stringLocal];
    }
//    else if (5 == indexPath.row) {
//        cell.textLabel.text = WizStrLocation;
//        cell.detailTextLabel.text = self.doc.gpsDescription;
//    }
    return cell;
}
- (void) showMap
{
    WizMapViewController* map = [[WizMapViewController alloc] init];
    map.doc = self.doc;
    [self.navigationController pushViewController:map animated:YES];
    
    [map release];
}
- (void) changeTitle
{
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row)
    {
        if (!self.isEditTheDoc)
        {
            [self changeTitle];
        }
    }
    else if (1 == indexPath.row) {
        [self tagViewSelect];
    }
    else if ( 2 == indexPath.row)
    {
        [self floderViewSelected];
    }
    else if (5 == indexPath.row)
    {
        [self showMap];
    }
}

@end
