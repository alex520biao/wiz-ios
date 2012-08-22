//
//  WizPadAllNotesViewController.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//


#import "WizPadAllNotesViewController.h"
#import "WizPadTreeTableHeaderView.h"

#import "WizDbManager.h"
#import "TreeNode.h"
#import "WizPadTreeTableCell.h"
#import "WizPadListCell.h"

#import "WizSettings.h"
#import "NSMutableArray+WizDocuments.h"
#import "WizNotification.h"

enum WizPadTreeKeyIndex
{
    WizPadTreeTagIndex = 1,
    WizpadTreeFolderIndex = 0
};
@interface WizPadAllNotesViewController () <WizPadTableHeaderDeleage, WizPadTreeTableCellDelegate, WizPadCellSelectedDocumentDelegate>
{
    NSMutableArray*  rootNodes;
    NSMutableArray*  needDisplayNodes;
    
    NSMutableArray* documentsMutableArray;
    
    TreeNode*  lastSelectedTreeNode;
}
@property (nonatomic, retain)  NSMutableArray* documentsMutableArray;
@property (nonatomic, retain) TreeNode*  lastSelectedTreeNode;

- (void) reloadFolderTootNode;
- (void) reloadTagRootNode;
@end

@implementation WizPadAllNotesViewController
@synthesize documentsMutableArray;
@synthesize masterTableView;
@synthesize detailTableView;
@synthesize lastSelectedTreeNode;
@synthesize checkDocuementDelegate;
- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    checkDocuementDelegate = nil;
    [lastSelectedTreeNode release];
    [documentsMutableArray release];
    [rootNodes release];
    [needDisplayNodes release];
    [masterTableView release];
    [detailTableView release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadFolderTootNode) name:MessageTypeOfUpdateFolderTable];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadTagRootNode) name:MessageTypeOfUpdateTagTable];
        rootNodes = [[NSMutableArray alloc] init];
        needDisplayNodes = [[NSMutableArray alloc] init];
        
        [needDisplayNodes addObject:[NSMutableArray array]];
        [needDisplayNodes addObject:[NSMutableArray array]];
        
        TreeNode* tagRootNode = [[[TreeNode alloc] init] autorelease];
        tagRootNode.title   = WizStrTags;
        tagRootNode.keyString = WizTreeViewTagKeyString;
        tagRootNode.isExpanded = YES;
        [rootNodes addObject:tagRootNode];
        
        TreeNode* folderRootNode = [[[TreeNode alloc] init] autorelease];
        folderRootNode.title   = WizStrFolders;
        folderRootNode.keyString = WizTreeViewFolderKeyString;
        folderRootNode.isExpanded = YES;
        [rootNodes addObject:folderRootNode];
        
        documentsMutableArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}
- (TreeNode*) findRootNode:(NSString*)keyString
{
    if ([rootNodes count] == 0) {
        return nil;
    }
    for (TreeNode* each in rootNodes) {
        if ([each.keyString isEqualToString:keyString]) {
            return each;
        }
    }
    return nil;
}
- (void) addTagTreeNodeToParent:(WizTag*)tag   rootNode:(TreeNode*)root  allTags:(NSArray*)allTags
{
    TreeNode* node = [[TreeNode alloc] init];
    node.title = getTagDisplayName(tag.title);
    node.keyString = tag.guid;
    node.isExpanded = NO;
    node.strType = WizTreeViewTagKeyString;
    if (tag.parentGUID == nil || [tag.parentGUID isEqual:@""]) {
        [root addChildTreeNode:node];
    }
    else
    {
        TreeNode* parentNode = [root childNodeFromKeyString:tag.parentGUID];
        if(nil != parentNode)
        {
            [parentNode addChildTreeNode:node];
        }
        else
        {
            WizTag* parent = nil;
            for (WizTag* each in allTags) {
                if ([each.guid isEqualToString:tag.parentGUID]) {
                    parent = each;
                }
            }
            [self addTagTreeNodeToParent:parent rootNode:root allTags:allTags];
            parentNode = [root childNodeFromKeyString:parent.parentGUID];
            [parentNode addChildTreeNode:node];
        }
    }
    [node release];
}

- (void) reloadTagRootNode
{
    NSArray* tagArray = [[[WizDbManager shareDbManager] shareDataBase] allTagsForTree];
    TreeNode* tagRootNode = [self findRootNode:WizTreeViewTagKeyString];
    
    [tagRootNode removeAllChildrenNodes];
    
    for (WizTag* each in tagArray) {
        [self addTagTreeNodeToParent:each rootNode:tagRootNode allTags:tagArray];
    }
    NSMutableArray* tagsArray = [needDisplayNodes objectAtIndex:WizPadTreeTagIndex];
    [tagsArray removeAllObjects];
    [tagsArray addObjectsFromArray:[tagRootNode allExpandedChildrenNodes]];
    [self.masterTableView beginUpdates];
    [self.masterTableView reloadSections:[NSIndexSet indexSetWithIndex:WizPadTreeTagIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.masterTableView endUpdates];
}
- (NSString*) restructLoactionKey:(NSArray*)locationArray  maxIndex:(int)index
{
    NSMutableString* key = [NSMutableString string];
    [key appendString:@"/"];
    for (int i =1; i <= index; i++) {
        [key appendFormat:@"%@/",[locationArray objectAtIndex:i]];
    }
    return key;
}

- (void) makeSureParentExisted:(NSArray*)locationArray  rootNode:(TreeNode*)rootNode
{
    for (int i = 1; i < (NSInteger)[locationArray count] -1 ; i++) {
        NSString* key = [self restructLoactionKey:locationArray maxIndex:i];
        NSString* title = [locationArray objectAtIndex:i];
        TreeNode* currentNode = [rootNode childNodeFromKeyString:key];
        if (nil == currentNode) {
            currentNode = [[TreeNode alloc] init];
            currentNode.title = title;
            currentNode.keyString = key;
            currentNode.strType = WizTreeViewFolderKeyString;
            if (1 == i) {
                [rootNode addChildTreeNode:currentNode];
            }
            else
            {
                NSString* parentKey = [self restructLoactionKey:locationArray maxIndex:i-1];
                TreeNode* parentNode = [rootNode childNodeFromKeyString:parentKey];
                [parentNode addChildTreeNode:currentNode];
            }
            [currentNode release];
        }
    }
}
- (void) reloadFolderTootNode
{
    NSArray* allFolders = [[[WizDbManager shareDbManager] shareDataBase] allLocationsForTree];
    TreeNode* folderRootNode = [self findRootNode:WizTreeViewFolderKeyString];
    
    for (NSString* folderString in allFolders) {
        if ([folderString isEqualToString:@"/Deleted Items/"]) {
            continue;
        }
        NSArray* breakLocation = [folderString componentsSeparatedByString:@"/"];
        [self makeSureParentExisted:breakLocation rootNode:folderRootNode];
    }
    NSMutableArray* folderArray = [needDisplayNodes objectAtIndex:WizpadTreeFolderIndex];
    [folderArray removeAllObjects];
    [folderArray addObjectsFromArray:[folderRootNode allExpandedChildrenNodes]];
    [folderRootNode displayDescription];

    [self.masterTableView reloadSections:[NSIndexSet indexSetWithIndex:WizpadTreeFolderIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadTagRootNode];
    [self reloadFolderTootNode];
    detailTableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
//
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:masterTableView]) {
        return [needDisplayNodes count];
    }
    else
    {
        NSLog(@"))))))section count is %d",[self.documentsMutableArray count]);
        return [self.documentsMutableArray count];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:masterTableView]) {
        return [[needDisplayNodes objectAtIndex:section] count];
    }
    else
    {
        
        if (0 ==  [self.documentsMutableArray count]) {
            return 0;
        }
        NSArray* sectionArray = [self.documentsMutableArray objectAtIndex:section];
        if ([sectionArray count]%3>0) {
            return  [sectionArray count]/3+1;
        }
        else {
            return [sectionArray count]/3  ;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:detailTableView]) {
        return PADABSTRACTVELLHEIGTH;
    }
    else
    {
        return 44;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:masterTableView]) {
        static NSString *CellIdentifier = @"WizPadTreeTableCell";
        WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (nil == cell) {
            cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.delegate = self;
        }
        TreeNode* node = [[needDisplayNodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.treeNode = node;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"WizPadAbstractCell";
        WizPadListCell *cell = (WizPadListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            static CGSize detailSize;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                detailSize = CGSizeMake(185, 280);
            });
            cell = [[[WizPadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier detailViewSize:detailSize] autorelease];
            cell.selectedDelegate = self;
        }
        NSUInteger documentsCount=3;
        NSUInteger needLength = documentsCount*(indexPath.row+1);
        NSArray* sectionArray = [self.documentsMutableArray objectAtIndex:indexPath.section];
        NSArray* cellArray=nil;
        NSRange docRange;
        if ([sectionArray count] < needLength) {
            docRange =  NSMakeRange(documentsCount*indexPath.row, (NSInteger)[sectionArray count]-documentsCount*indexPath.row);
        }
        else {
            docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
        }
        NSLog(@"document count is %d  docRange %d %d  row is %d",[sectionArray count], docRange.location, docRange.length, indexPath.row);
        
        cellArray = [sectionArray subarrayWithRange:docRange];
        cell.documents = cellArray;
        [cell updateDoc];
        return cell;
    }
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:masterTableView]) {
        [cell setNeedsDisplay];
    }

}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:masterTableView])
    {
        switch (section) {
            case WizpadTreeFolderIndex:
                return [[self findRootNode:WizTreeViewFolderKeyString] title];
            case WizPadTreeTagIndex:
                return [[self findRootNode:WizTreeViewTagKeyString] title];
            default:
                return @"";
        }
    }
    else
    {
        return  [[self.documentsMutableArray objectAtIndex:section]  arrayTitle];
    }
}
- (void) didSelectedHeader:(WizPadTreeTableHeaderView *)header  forTreeNode:(TreeNode *)node
{
    [self onExpandedNode:node];
}
- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:masterTableView])
    {
        TreeNode* treeNode = nil;
        switch (section) {
            case WizpadTreeFolderIndex:
                treeNode = [self findRootNode:WizTreeViewFolderKeyString];
                break;
                
            default:
                treeNode = [self findRootNode:WizTreeViewTagKeyString];
                break;
        }
        WizPadTreeTableHeaderView* titleView = [[WizPadTreeTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 30)];
        titleView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        titleView.delegate = self;
        titleView.treeNode = treeNode;
        

        
        return [titleView autorelease];
    }
    else
    {
        return nil;
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:masterTableView]) {
        return 30;
    }
    else
    {
        return 30;
    }
}

- (void) reloadDetailData:(NSArray*)sourceArray
{
    
    NSLog(@"source count is %d",[sourceArray count]);
    
    NSInteger kOrderIndex = [[WizSettings defaultSettings] userTablelistViewOption];
    [self.documentsMutableArray removeAllObjects];
    [self.documentsMutableArray addObject:sourceArray];
    [self.documentsMutableArray performSelector:@selector(sortDocumentByOrder:) withObject:(id)kOrderIndex];
    [self.detailTableView reloadData];
}

- (void) reloadTagData:(NSString*)tagGuid
{
    [self reloadDetailData:[WizDocument documentsByTag:tagGuid]];
}

- (void) reloadFolderData:(NSString*)folderKey
{
    [self reloadDetailData:[WizDocument documentsByLocation:folderKey]];
}

- (void) onExpandedNode:(TreeNode *)node
{
    NSInteger section = NSNotFound;
    NSInteger row = NSNotFound;
    for (int i = 0 ; i < [needDisplayNodes count]; i++) {
        NSArray* array = [needDisplayNodes objectAtIndex:i];
        BOOL willBreak = NO;
        for (int j = 0; j < [array count]; j++) {
            TreeNode* eachNode = [array objectAtIndex:j];
            if ([eachNode.keyString isEqualToString:node.keyString]) {
                section = i;
                row = j;
                willBreak = YES;
                break;
            }
        }
        if (willBreak) {
            break;
        }
        NSLog(@"sdfsdf");
    }
    if (section == NSNotFound) {
        row = 0;
        if ([node.keyString isEqualToString:WizTreeViewTagKeyString]) {
            section = WizPadTreeTagIndex;
        }
        else if ([node.keyString isEqualToString:WizTreeViewFolderKeyString])
        {
            section = WizpadTreeFolderIndex;
        }
    }
    
    NSLog(@"section %d row %d",section, row);
    
    [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
{
    NSMutableArray* tags = [needDisplayNodes objectAtIndex:indexPath.section];
    
    if (!node.isExpanded) {
        node.isExpanded = YES;
        NSArray*array = [node allExpandedChildrenNodes];
        
        NSInteger startPostion = [tags count] == 0? 0: indexPath.row+1;
        
        NSMutableArray* rows = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++) {
            NSInteger  positionRow = startPostion+ i;
            
            TreeNode* node = [array objectAtIndex:i];
            [tags insertObject:node atIndex:positionRow];
            
            [rows addObject:[NSIndexPath indexPathForRow:positionRow inSection:indexPath.section]];
        }
        
        [masterTableView beginUpdates];
        [masterTableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationAutomatic];
        [masterTableView endUpdates];
    }
    else
    {
        node.isExpanded = NO;
        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
        NSMutableArray* deletedNodes = [NSMutableArray array];
        for (int i = indexPath.row; i < [tags count]; i++) {
            TreeNode* displayedNode = [tags objectAtIndex:i];
            if ([node childNodeFromKeyString:displayedNode.keyString]) {
                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [deletedNodes addObject:displayedNode];
            }
        }
        
        for (TreeNode* each in deletedNodes) {
            [tags removeObject:each];
        }
        
        [masterTableView beginUpdates];
        [masterTableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [masterTableView endUpdates];
    }

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:masterTableView]) {
        TreeNode* node = [[needDisplayNodes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        self.lastSelectedTreeNode = node;
        NSLog(@"node %@ %@",node.keyString, node.keyPath);
        
        switch (indexPath.section) {
            case WizPadTreeTagIndex:
                [self reloadTagData:node.keyString];
                break;
            case WizpadTreeFolderIndex:
                [self reloadFolderData:node.keyString];
                break;
            default:
                break;
        }
    }
    else
    {
        
    }
}

- (void) didPadCellDidSelectedDocument:(WizDocument *)doc
{
    NSLog(@"selected node type is %@",self.lastSelectedTreeNode.strType);
    NSInteger checkType = WizPadCheckDocumentSourceTypeOfRecent;
    if ([self.lastSelectedTreeNode.strType isEqualToString:WizTreeViewFolderKeyString]) {
        checkType = WizPadCheckDocumentSourceTypeOfFolder;
    }
    else if ([self.lastSelectedTreeNode.strType isEqualToString:WizTreeViewTagKeyString])
    {
        checkType = WizPadCheckDocumentSourceTypeOfTag;
    }
    
    [self.checkDocuementDelegate checkDocument:checkType keyWords:self.lastSelectedTreeNode.keyString selectedDocument:doc];
}

@end
