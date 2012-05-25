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
    NSMutableDictionary* folderTagData;
    NSMutableArray* needGenAbstractDocuments;
    NSString* currentDocument;
    NSConditionLock* cacheConditon;
    BOOL isChangedUser;
    NSThread* thread;
}
@property (atomic, retain) NSMutableDictionary* folderTagData;
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
@synthesize folderTagData;
@synthesize needGenAbstractDocuments;
@synthesize isChangedUser;
@synthesize currentDocument;
@synthesize cacheConditon;
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
    static WizDbManager* dbManager = nil;
    if (nil == dbManager) {
        dbManager = [[WizDbManager alloc] init];
    }
    while (true) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        if (self.isChangedUser) {
            if ([[[WizAccountManager defaultManager] activeAccountUserId] isBlock]) {
                return;
            }
            if ([dbManager openTempDb:[[WizFileManager shareManager] tempDbPath]]) {
                self.isChangedUser = NO;
            }
        }
        [self.cacheConditon lockWhenCondition:HAS_DATA];
        NSString* documentGuid = [self.needGenAbstractDocuments lastObject];
        BOOL isImpty = [self.needGenAbstractDocuments count] == 0? YES:NO;
        [self.cacheConditon unlockWithCondition:(isImpty?NO_DATA:HAS_DATA)];
        if(nil != documentGuid)
        {
            WizAbstract* abstract = [dbManager abstractOfDocument:documentGuid];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:documentGuid,@"documentGuid",abstract,@"abstract", nil];
            [self performSelectorOnMainThread:@selector(didGenDocumentAbstract:) withObject:dic waitUntilDone:YES];
            [self.needGenAbstractDocuments removeLastObject];
        }
        [pool drain];
    }
}
//
- (void) didChangedAccountUser
{
    self.isChangedUser = YES;
    [NSThread detachNewThreadSelector:@selector(genFoldersAndTagsAbstract) toTarget:self withObject:nil];
}
- (NSString*) getFolderAbstract:(NSString*)key
{
    return [self.folderTagData objectForKey:key];
}
- (NSString*) getTagAbstract:(NSString*)tagGuid
{
    return [self.folderTagData objectForKey:tagGuid];
}
- (void) genFoldersAndTagsAbstract
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    WizDbManager* dbManager = [[WizDbManager alloc] init];
    [dbManager openDb:[[WizFileManager shareManager] dbPath]];
    NSArray* allLocations = [dbManager allLocationsForTree];
    for (NSString* folderKey in allLocations) {
        NSString* abstract = [dbManager folderAbstractString:folderKey];
        if (abstract != nil) {
            [self.folderTagData setObject:abstract forKey:folderKey];
        }
        else {
            [self.folderTagData setObject:@"" forKey:folderKey];
        }
    }
    
    NSArray* allTags = [dbManager allTagsForTree];
    for (WizTag* tag in allTags) {
        NSString* abstract = [dbManager tagAbstractString:tag.guid];
        if (nil != abstract) {
            [self.folderTagData setObject:abstract forKey:tag.guid];
        }
        else {
            [self.folderTagData setObject:@"" forKey:tag.guid];
        }
    }
    
    [pool release];
}

- (id) init
{
    self = [super init];
    if (self) {
        self.folderTagData = [NSMutableDictionary dictionary];
        self.data = [NSMutableDictionary dictionary];
        self.needGenAbstractDocuments = [NSMutableArray array];
        self.isChangedUser = YES;
        self.cacheConditon = [[[NSConditionLock alloc] initWithCondition:NO_DATA] autorelease];
        [WizNotificationCenter addObserverForChangeAccount:self selector:@selector(didChangedAccountUser)];
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(genAbstract) object:nil];
        [thread start];
        
        [NSThread detachNewThreadSelector:@selector(genFoldersAndTagsAbstract) toTarget:self withObject:nil];
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
    [self.needGenAbstractDocuments addObject:documentGuid];
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