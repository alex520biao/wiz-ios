#import "WizAbstractCache.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
@interface WizAbstractCache()
{
    NSMutableDictionary* data;
    NSMutableArray* needGenAbstractDocuments;
    NSString* currentDocument;
    BOOL isChangedUser;
}
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain) NSMutableArray* needGenAbstractDocuments;
@property (atomic) BOOL isChangedUser;
@property (atomic, retain) NSString* currentDocument;
- (void) genAbstract;
@end
@implementation WizAbstractCache
@synthesize data;
@synthesize needGenAbstractDocuments;
@synthesize isChangedUser;
@synthesize currentDocument;
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
    
    @synchronized(dbManager)
    
    {
        
        if (nil == dbManager) {
            
            dbManager = [[[WizDbManager alloc] init] autorelease];
            
        }
        
        while(1)
            
        {
            
            if (self.isChangedUser) {
                
//                if ([dbManager isTempDbOpen]) {
//                    
//                    [dbManager closeTempDb];
//                    
//                }
                
                NSLog(@"documentDbpath is %@",[[WizFileManager shareManager] tempDbPath]);
                
                if ([dbManager openTempDb:[[WizFileManager shareManager] tempDbPath]]) {
                    
                    NSLog(@"opened");
                    
                    self.isChangedUser = NO;
                    
                }
                
            }
            
            NSString* documentGuid = [self popNeedGenAbstrctDocument];
            
            if(nil != documentGuid)
                
            {
                
                WizAbstract* abstract = [dbManager abstractOfDocument:documentGuid];
                
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:documentGuid,@"documentGuid",abstract,@"abstract", nil];
                
                [self performSelectorOnMainThread:@selector(didGenDocumentAbstract:) withObject:dic waitUntilDone:YES];
                
            }
            
            else {
                
                [NSThread sleepForTimeInterval:1];
                
            }
            
        }
        
    }
    
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
        
        [NSThread detachNewThreadSelector:@selector(genAbstract) toTarget:self withObject:nil];
        
        [WizNotificationCenter addObserverForChangeAccount:self selector:@selector(didChangedAccountUser)];
        
    }
    
    return self;
    
}

- (NSString*) popNeedGenAbstrctDocument

{
    
//    NSLog(@"pop needGenAbstractDocuments count is %d ",[self.needGenAbstractDocuments count]);
    
    NSString* guid =[self.needGenAbstractDocuments lastObject];
    
    //对当前使用的Guid进行加锁
    
    self.currentDocument = guid;
    
    [self.needGenAbstractDocuments removeLastObject];
    
    return self.currentDocument;
    
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
    
    [self.needGenAbstractDocuments addObject:documentGuid];
    
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