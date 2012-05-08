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
    NSMutableArray* needGenAbstractDocuments;
    NSString* currentDocument;
    NSConditionLock* cacheConditon;
    BOOL isChangedUser;
}
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain) NSMutableArray* needGenAbstractDocuments;
@property (atomic) BOOL isChangedUser;
@property (atomic, retain) NSString* currentDocument;
@property (atomic, retain) NSConditionLock* cacheConditon;
- (void) genAbstract;
@end
@implementation WizAbstractCache
@synthesize data;
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
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    static WizDbManager* dbManager = nil;
    @synchronized(dbManager)
    {
        if (nil == dbManager) {
            dbManager = [[WizDbManager alloc] init];
        }
        while (true) {
            if (self.isChangedUser) {
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
        }
    }
    [pool release];
}
//
- (void) didChangedAccountUser
{
    self.isChangedUser = YES;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableDictionary dictionary];
        self.needGenAbstractDocuments = [NSMutableArray array];
        self.isChangedUser = YES;
        self.cacheConditon = [[[NSConditionLock alloc] initWithCondition:NO_DATA] autorelease];
        [NSThread detachNewThreadSelector:@selector(genAbstract) toTarget:self withObject:nil];
        [WizNotificationCenter addObserverForChangeAccount:self selector:@selector(didChangedAccountUser)];
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