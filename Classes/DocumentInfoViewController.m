//
//  DocumentInfoViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "SelectFloderView.h"
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizPadNotificationMessage.h"
#import "WizSelectTagViewController.h"
@interface DocumentInfoCell : UITableViewCell {
    UILabel* nameLabel;
    UILabel* valueLabel;
}
@property (nonatomic, retain)     UILabel* nameLabel;
@property (nonatomic, retain)    UILabel* valueLabel;
@end

@implementation DocumentInfoCell
@synthesize nameLabel;
@synthesize valueLabel;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.nameLabel= [[[UILabel alloc] initWithFrame:CGRectMake(14, 0.0, 70, 40)] autorelease];
    [self addSubview:self.nameLabel];
    self.nameLabel.textAlignment = UITextAlignmentLeft;
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.nameLabel setFont:[UIFont systemFontOfSize:15.0]];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.valueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(64, 0.0, 240, 40)] autorelease];
    [self addSubview:self.valueLabel];
    valueLabel.textAlignment = UITextAlignmentRight;
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.textColor = [UIColor grayColor];
    [valueLabel setFont:[UIFont systemFontOfSize:13.0]];
    return self;
}
@end

@implementation DocumentInfoViewController
@synthesize doc;
@synthesize accountUserId;
@synthesize fontSlider;
@synthesize documentTags;
@synthesize documentFloder;
@synthesize lastIndexPath;
-(void) dealloc
{
    self.doc = nil;
    self.accountUserId = nil;
    [super dealloc];
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) addTag:(NSNotification*)nc
{
    NSDictionary* dic = [nc userInfo];
    WizTag* tag = [dic valueForKey:TypeOfTagKey];
    [self.documentTags addObject:tag];
}

- (NSUInteger) tagIndexAtSlectedArray:(WizTag*)tag
{
    for (int i = 0; i < [self.documentTags count]; i++) {
        if ([[[self.documentTags objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
            return i;
        }
    }
    return -1;
}

- (void) removeTag:(NSNotification*)nc
{
    NSDictionary* dic = [nc userInfo];
    WizTag* tag = [dic valueForKey:TypeOfTagKey];
    [self.documentTags removeObjectAtIndex:[self tagIndexAtSlectedArray:tag]];
}
#pragma mark - View lifecycle
-(void) tagViewSelect
{
    WizSelectTagViewController* tagView = [[WizSelectTagViewController alloc]initWithStyle:UITableViewStyleGrouped];
    tagView.accountUserId = self.accountUserId;
    tagView.initSelectedTags = self.documentTags;
    [self.navigationController pushViewController:tagView animated:YES];
    [tagView release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTag:) name:TypeOfSelectedTag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTag:) name:TypeOfUnSelectedTag object:nil];
}

-(void) floderViewSelected
{
    SelectFloderView*  floderView = [[SelectFloderView alloc] initWithStyle:UITableViewStyleGrouped];
    floderView.accountUserID = self.accountUserId;
    floderView.selectedFloderString = self.documentFloder;
    [self.navigationController pushViewController:floderView animated:YES];
    [floderView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.documentTags = [NSMutableArray arrayWithArray:[index tagsByDocumentGuid:self.doc.guid]];
    if (self.documentTags == nil) {
        self.documentTags = [NSMutableArray array];
    }
    self.tableView.scrollEnabled = NO;
    self.lastIndexPath = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (self.documentFloder == nil) {
        self.documentFloder = [[self.doc.location mutableCopy] autorelease];
    }
    if (self.documentTags == nil) {
        self.documentTags = [[self.doc.tagGuids mutableCopy] autorelease];
    }
    if (![self.documentFloder isEqualToString: doc.location]) {
        [index setDocumentLocation:doc.guid location:self.documentFloder];
        [index setDocumentLocalChanged:doc.guid changed:YES];
    }
    if (nil !=self.lastIndexPath) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.lastIndexPath ] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView endUpdates];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    BOOL tagChenged = NO;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSMutableString* tagGuids = [NSMutableString string];
    for (WizTag* each in documentTags) {

        [tagGuids appendFormat:@"%@*",each.guid];
        if ([doc.tagGuids rangeOfString:each.guid].length == 0) {
            NSLog(@"changed ");
            tagChenged = YES;
        }
    }
    if ([documentTags count] != [[index tagsByDocumentGuid:self.doc.guid] count]) {
        tagChenged = YES;
    }
    if (tagChenged == YES) {
        NSString* tags = [tagGuids substringToIndex:tagGuids.length-1];

        [index setDocumentTags:self.doc.guid tags:tags];
        [index setDocumentLocalChanged:self.doc.guid changed:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (WizDeviceIsPad()) {
        return 5;
    }
    else
    {
        return 6;
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Detail", nil);
}
-(void) fontChanged
{
    WizIndex * index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setWebFontSize:fontSlider.value];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.row == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(14, 0.0, 90, 40)];
        name.textAlignment = UITextAlignmentLeft;
        name.backgroundColor = [UIColor clearColor];
        name.text = NSLocalizedString(@"Font Size", nil);
        [name setFont:[UIFont systemFontOfSize:15.0]];
        name.adjustsFontSizeToFitWidth = YES;
        self.fontSlider = [[[UISlider alloc] initWithFrame:CGRectMake(110, 0.0, 200, 40)] autorelease];
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];

        [fontSlider addTarget:self action:@selector(fontChanged) forControlEvents:UIControlEventValueChanged];
        fontSlider.maximumValue =600;
        fontSlider.minimumValue =60;
        fontSlider.value =[index webFontSize];
        [cell addSubview:fontSlider];
        [cell addSubview:name];
        [name release];
        return cell;
    }
    DocumentInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[DocumentInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if (0 == indexPath.row) {
        cell.nameLabel.text = NSLocalizedString(@"Name", nil);
        cell.valueLabel.text = doc.title;
    }
    
    if (1 == indexPath.row) {
        cell.nameLabel.text = NSLocalizedString(@"Tags", nil);
        NSMutableString* tagNames = [NSMutableString string];
        for (WizTag* each in self.documentTags) {
            [tagNames appendFormat:@"|%@",getTagDisplayName(each.name)];
        }
        cell.valueLabel.text = tagNames;
    }
    else if (2 == indexPath.row) {
        cell.nameLabel.text = NSLocalizedString(@"Folders", nil);
        cell.valueLabel.text = [WizGlobals folderStringToLocal:self.documentFloder];
    }
    
    else if (3 == indexPath.row) {
        cell.nameLabel.text =  NSLocalizedString(@"Date modified", nil);
        cell.valueLabel.text = doc.dateModified;
    }
    else if (4 == indexPath.row) {
        cell.nameLabel.text = NSLocalizedString(@"Date created", nil);
        cell.valueLabel.text = doc.dateCreated;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == indexPath.row) {
        self.lastIndexPath = indexPath;
        [self tagViewSelect];
    }
    else if ( 2 == indexPath.row)
    {
        self.lastIndexPath = indexPath;
        [self floderViewSelected];
    }
}

@end
