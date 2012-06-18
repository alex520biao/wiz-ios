#import "WizAbstractCache.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizDataBase.h"
#import "WizTempDataBase.h"

#define DocumentGuid    @"DocumentGuid"
#define DocumentKbGuid  @"DocumentKbGuid"

#define NO_DATA     5211
#define HAS_DATA    52211

@interface WizAbstractCache()
{
    NSMutableDictionary* data;
    NSMutableDictionary* folderAbstractData;
    NSMutableDictionary* tagsAbstractData;
    NSMutableArray* needGenAbstractDocuments;
    NSString* currentDocument;
    NSConditionLock* cacheConditon;
    BOOL isChangedUser;
    NSThread* thread;
    
    NSConditionLock* extractAbstractCondition;
    NSMutableArray* needExtractAbstractArray;
}
@property (atomic, retain) NSMutableDictionary* tagsAbstractData;
@property (atomic, retain) NSMutableDictionary* folderAbstractData;
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain) NSMutableArray* needGenAbstractDocuments;
@property (atomic) BOOL isChangedUser;
@property (atomic, retain) NSString* currentDocument;
@property (atomic, retain) NSConditionLock* cacheConditon;
@property (atomic, retain) NSThread* thread;
@property (atomic, retain) NSMutableArray* needExtractAbstractArray;
@property (atomic, retain) NSConditionLock* extractAbstractCondition;
- (void) genAbstract;
@end
@implementation WizAbstractCache
@synthesize data;
@synthesize tagsAbstractData;
@synthesize folderAbstractData;
@synthesize needGenAbstractDocuments;
@synthesize isChangedUser;
@synthesize currentDocument;
@synthesize cacheConditon;
@synthesize thread;
@synthesize extractAbstractCondition;
//single
- (void) dealloc
{
    [data release];
    [tagsAbstractData release];
    [folderAbstractData release];
    [needGenAbstractDocuments release];
    [currentDocument release];
    [cacheConditon release];
    [extractAbstractCondition release];
    [thread release];
    [needGenAbstractDocuments release];
    [super dealloc];
}
+ (id) shareCache
{
    static WizAbstractCache* shareCache;
    @synchronized(shareCache)
    {
        if (shareCache == nil) {
            shareCache = [[super allocWithZone:NULL] init];
        }
        return shareCache;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareCache] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}

- (oneway void) release
{
    return;
}
//over

- (void) genAbstract
{
    while (true) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        [self.cacheConditon lockWhenCondition:HAS_DATA];
        NSString* documentGuid = [self.needGenAbstractDocuments lastObject];
        BOOL isImpty = [self.needGenAbstractDocuments count] == 0? YES:NO;
        [self.cacheConditon unlockWithCondition:(isImpty?NO_DATA:HAS_DATA)];
        if(nil != documentGuid)
        {
            id<WizAbstractDbDelegate> dataBase = [[WizDbManager shareDbManager] getWizTempDataBase:[[WizAccountManager defaultManager] activeAccountUserId]];
            WizAbstract* abstract = [dataBase abstractOfDocument:documentGuid];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:documentGuid,@"documentGuid",abstract,@"abstract", nil];
            [self performSelectorOnMainThread:@selector(didGenDocumentAbstract:) withObject:dic waitUntilDone:YES];
            [self.needGenAbstractDocuments removeLastObject];
        }
        [pool drain];
    }
}
//
- (void) genFoldersAbstract
{
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    id<WizDbDelegate> dbManager_ = [WizDbManager shareDbManager] getWizDataBase:<#(NSString *)#> groupId:<#(NSString *)#>
//    NSArray* allLocations = [dbManager_ allLocationsForTree];
//    for (NSString* folderKey in allLocations) {
//        NSString* abstract = [dbManager_ folderAbstractString:folderKey];
//        if (abstract != nil) {
//            [self.folderAbstractData setObject:abstract forKey:folderKey];
//        }
//        else {
//            [self.folderAbstractData setObject:@"" forKey:folderKey];
//        }
//    }
//    [dbManager_ release];
//    [pool drain];
}
- (void) genTagsAbstract
{
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    id<WizDbDelegate> dbManager_ = [[WizDataBase alloc] init];
//    [dbManager_ openDb:[[WizFileManager shareManager] dbPath]];
//    NSArray* allTags = [dbManager_ allTagsForTree];
//    for (WizTag* tag in allTags) {
//        NSString* abstract = [dbManager_ tagAbstractString:tag.guid];
//        if (nil != abstract) {
//            [self.tagsAbstractData setObject:abstract forKey:tag.guid];
//        }
//        else {
//            [self.tagsAbstractData setObject:@"" forKey:tag.guid];
//        }
//    }
//    [dbManager_ release];
//    [pool drain];
}
- (void) willGenFoldersAbstract
{
    if ([WizGlobals WizDeviceIsPad]) {
        [NSThread detachNewThreadSelector:@selector(genFoldersAbstract) toTarget:self withObject:nil];
    }
}

- (void) willGenTagsAbstract
{
    if ([WizGlobals WizDeviceIsPad]) {
        [NSThread detachNewThreadSelector:@selector(genTagsAbstract) toTarget:self withObject:nil];
    }
}
- (void) didChangedAccountUser
{
    self.isChangedUser = YES;
    [data removeAllObjects];
    [folderAbstractData removeAllObjects];
    [tagsAbstractData removeAllObjects];
    [self willGenTagsAbstract];
    [self willGenFoldersAbstract];
}
- (NSString*) getFolderAbstract:(NSString*)key
{
    return [self.folderAbstractData objectForKey:key];
}
- (NSString*) getTagAbstract:(NSString*)tagGuid
{
    return [self.tagsAbstractData objectForKey:tagGuid];
}


- (void) extractAbstract
{
    while (YES) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        [self.extractAbstractCondition lockWhenCondition:HAS_DATA];
        NSDictionary* document = [self.needExtractAbstractArray lastObject];
        if(nil != document)
        {
            NSString* documentGuid = [document objectForKey:DocumentGuid];
            NSString* documentKbguid = [document objectForKey:DocumentKbGuid];
            WizTempDataBase* db = [[WizDbManager shareDbManager] getWizTempDataBase:[[WizAccountManager defaultManager] activeAccountUserId]];
            [db extractSummary:documentGuid kbGuid:documentKbguid];
            [self pushNeedGenAbstractDoument:documentGuid];
            [self.needExtractAbstractArray removeLastObject];
            
        }
        BOOL isImpty = [self.needExtractAbstractArray count] == 0? YES:NO;
        [self.extractAbstractCondition unlockWithCondition:(isImpty?NO_DATA:HAS_DATA)];
        [pool release];
    }
}
- (void) pushNeedExtractAbstractDocument:(NSNotification*)nc
{
    [self.extractAbstractCondition lock];
    NSString* documentGuid = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    NSString* documentKbguid = [WizNotificationCenter getKbguidFromNc:nc];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:documentGuid,DocumentGuid,documentKbguid,DocumentKbGuid, nil];
    [self.needExtractAbstractArray addObject:dic];
    [self.extractAbstractCondition unlockWithCondition:HAS_DATA];
}

- (id) init
{
    self = [super init];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(didReceivedMenoryWarning) name:MessageTypeOfMemeoryWarning];
        [WizNotificationCenter addObserverForExtractDocumentAbstract:self selector:@selector(pushNeedExtractAbstractDocument:)];
        self.folderAbstractData = [NSMutableDictionary dictionary];
        self.tagsAbstractData = [NSMutableDictionary dictionary];
        self.data = [NSMutableDictionary dictionary];
        self.needGenAbstractDocuments = [NSMutableArray array];
        self.needExtractAbstractArray = [[[NSMutableArray alloc] init] autorelease];
        extractAbstractCondition = [[NSConditionLock alloc] initWithCondition:NO_DATA];
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(genAbstract) object:nil];
        [thread start];
        cacheConditon = [[NSConditionLock alloc] initWithCondition:NO_DATA];
        [NSThread detachNewThreadSelector:@selector(extractAbstract) toTarget:self withObject:nil];
    }
    return self;
}



- (void) postUpdateCacheMassage:(NSString*)documentGuid
{
    [WizNotificationCenter postMessageUpdateCache:documentGuid];
}

- (void) didGenDocumentAbstract:(NSDictionary*)dic

{
    NSString* documentguid = [dic valueForKey:@"documentGuid"];
    WizAbstract* abstract = [dic valueForKey:@"abstract"];
    if (nil == abstract)
    {
        return;
    }
    [self.data setObject:abstract forKey:documentguid];
    [self postUpdateCacheMassage:documentguid];
}
- (void) pushNeedGenAbstractDoument:(NSString*)documentGuid

{
    [self.cacheConditon lock];
    @try {
        [self.needGenAbstractDocuments addObject:documentGuid];
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
    }
    [self.cacheConditon unlockWithCondition:HAS_DATA];
}

- (WizAbstract*) documentAbstractForIphone:(WizDocument*)document
{
    WizAbstract* abs = [self.data valueForKey:document.guid];
    if (nil == abs && document.serverChanged != YES) {
        [self pushNeedGenAbstractDoument:document.guid];
    }
    return abs;
}

- (void) didReceivedMenoryWarning
{
    [self.data removeAllObjects];
}

@end