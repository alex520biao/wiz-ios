#import "WizAbstractCache.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"


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
    
    WizDataBase* dbManager;
}
@property (atomic, retain) WizDataBase* dbManager;
@property (atomic, retain) NSMutableDictionary* tagsAbstractData;
@property (atomic, retain) NSMutableDictionary* folderAbstractData;
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain) NSMutableArray* needGenAbstractDocuments;
@property (atomic) BOOL isChangedUser;
@property (atomic, retain) NSString* currentDocument;
@property (atomic, retain) NSConditionLock* cacheConditon;
@property (atomic, retain) NSThread* thread;
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
@synthesize dbManager;
@synthesize thread;
//single
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
        if (self.isChangedUser) {
            [self.dbManager reloadDb];
            self.isChangedUser = NO;
        }
        NSString* documentGuid = [self.needGenAbstractDocuments lastObject];
        BOOL isImpty = [self.needGenAbstractDocuments count] == 0? YES:NO;
        [self.cacheConditon unlockWithCondition:(isImpty?NO_DATA:HAS_DATA)];
        if(nil != documentGuid)
        {
            WizAbstract* abstract = [self.dbManager abstractOfDocument:documentGuid];
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
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    WizDataBase* dbManager_ = [[WizDataBase alloc] init];
    [dbManager_ reloadDb];
    NSArray* allLocations = [dbManager_ allLocationsForTree];
    for (NSString* folderKey in allLocations) {
        NSString* abstract = [dbManager_ folderAbstractString:folderKey];
        if (abstract != nil) {
            [self.folderAbstractData setObject:abstract forKey:folderKey];
        }
        else {
            [self.folderAbstractData setObject:@"" forKey:folderKey];
        }
    }
    [dbManager_ release];
    [pool drain];
}
- (void) genTagsAbstract
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    WizDataBase* dbManager_ = [[WizDataBase alloc] init];
    [dbManager_ openDb:[[WizFileManager shareManager] dbPath]];
    NSArray* allTags = [dbManager_ allTagsForTree];
    for (WizTag* tag in allTags) {
        NSString* abstract = [dbManager_ tagAbstractString:tag.guid];
        if (nil != abstract) {
            [self.tagsAbstractData setObject:abstract forKey:tag.guid];
        }
        else {
            [self.tagsAbstractData setObject:@"" forKey:tag.guid];
        }
    }
    [dbManager_ release];
    [pool drain];
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


- (id) init
{
    self = [super init];
    if (self) {
        self.folderAbstractData = [NSMutableDictionary dictionary];
        self.tagsAbstractData = [NSMutableDictionary dictionary];
        self.data = [NSMutableDictionary dictionary];
        self.needGenAbstractDocuments = [NSMutableArray array];
        self.cacheConditon = [[[NSConditionLock alloc] initWithCondition:NO_DATA] autorelease];
        WizDataBase* db = [[WizDataBase alloc] init];
        self.dbManager = db;
        [db release];
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(genAbstract) object:nil];
        [thread start];
        
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