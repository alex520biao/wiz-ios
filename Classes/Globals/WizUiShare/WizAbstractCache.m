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
    NSCondition* genCacheCondition;
    BOOL isChangedUser;
    NSThread* thread;
    
    NSCondition* genExtractCondition;
    NSMutableArray* needExtractAbstractArray;
}
@property (atomic, retain) NSMutableDictionary* tagsAbstractData;
@property (atomic, retain) NSMutableDictionary* folderAbstractData;
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain) NSMutableArray* needGenAbstractDocuments;
@property (atomic) BOOL isChangedUser;
@property (atomic, retain) NSString* currentDocument;

@property (atomic, retain) NSThread* thread;
@property (atomic, retain) NSMutableArray* needExtractAbstractArray;

- (void) genAbstract;
@end
@implementation WizAbstractCache
@synthesize data;
@synthesize tagsAbstractData;
@synthesize folderAbstractData;
@synthesize needGenAbstractDocuments;
@synthesize isChangedUser;
@synthesize currentDocument;

@synthesize thread;

//single
- (void) dealloc
{
    [data release];
    [tagsAbstractData release];
    [folderAbstractData release];
    [needGenAbstractDocuments release];
    [currentDocument release];
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

- (void) clearCacheFroDocument:(NSString*)documentGuid
{
    NSLog(@"%@",[self.data objectForKey:documentGuid]);
    [self.data removeObjectForKey:documentGuid];
}

- (void) genAbstract
{
    while (true) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        [genCacheCondition lock];
        [genCacheCondition wait];
        [genCacheCondition unlock];
        NSString* documentGuid = [self.needGenAbstractDocuments lastObject];
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
        NSDictionary* document = [self.needExtractAbstractArray lastObject];
        NSLog(@"get %@",document);
        if(nil != document)
        {
            NSString* documentGuid = [document objectForKey:DocumentGuid];
            NSString* documentKbguid = [document objectForKey:DocumentKbGuid];
            WizTempDataBase* db = [[WizDbManager shareDbManager] getWizTempDataBase:[[WizAccountManager defaultManager] activeAccountUserId]];
            
            NSLog(@"db %@",db);
            [db extractSummary:documentGuid kbGuid:documentKbguid];
            [self.needExtractAbstractArray removeLastObject];
        }
        if (![self.needExtractAbstractArray count]) {
            sleep(1);
        }
        [pool release];
    }
}

- (void) runLoopTest:(NSDictionary*)dic
{
    NSLog(@"%@",dic);
}
- (void) pushNeedExtractAbstractDocument:(NSNotification*)nc
{
    NSString* documentGuid = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    NSString* documentKbguid = [WizNotificationCenter getKbguidFromNc:nc];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:documentGuid,DocumentGuid,documentKbguid,DocumentKbGuid, nil];
    [self performSelector:@selector(runLoopTest:) onThread:thread withObject:dic waitUntilDone:NO];
//    NSLog(@"push dic is %@",dic);
//    [self.needExtractAbstractArray addObject:dic];
//    [self clearCacheFroDocument:documentGuid];
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
    [genCacheCondition lock];
    @try {
        [self.needGenAbstractDocuments addObject:documentGuid];
        [genCacheCondition signal];
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
    }
[genCacheCondition unlock];
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
void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
            //The entrance of the run loop, before entering the event processing loop. 
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
            //Inside the event processing loop before any timers are processed
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before timers");
            break;
            //Inside the event processing loop before any sources are processed
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
            //Inside the event processing loop before the run loop sleeps, waiting for a source or timer to fire. 
            //This activity does not occur if CFRunLoopRunInMode is called with a timeout of 0 seconds. 
            //It also does not occur in a particular iteration of the event processing loop if a version 0 source fires
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
            //Inside the event processing loop after the run loop wakes up, but before processing the event that woke it up. 
            //This activity occurs only if the run loop did in fact go to sleep during the current loop
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
            //The exit of the run loop, after exiting the event processing loop. 
            //This activity occurs once for each call to CFRunLoopRun and CFRunLoopRunInMode
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
            /*
             A combination of all the preceding stages
             case kCFRunLoopAllActivities:
             break;
             */
        default:
            break;
    }
}
- (void) callback
{
    
}
- (void)observerRunLoop {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopObserverContext context = {0, self, NULL, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
    
    CFRunLoopSourceContext  src_context ;  
    NSError * emsg = nil ; 
    // create send source from context
    
    CFRunLoopSourceRef runloopSource ;
    runloopSource = CFRunLoopSourceCreate (NULL, 0, &src_context) ;
    if (observer) {
        CFRunLoopRef cfRunLoop = [myRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cfRunLoop, observer, kCFRunLoopDefaultMode);
    }
    
//    //Creates and returns a new NSTimer object and schedules it on the current run loop in the default mode
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doFireTimer:) userInfo:nil repeats:YES];
    
    NSInteger loopCount = 10;
    
    do {
        //启动当前thread的loop直到所指定的时间到达，在loop运行时，run loop会处理所有来自与该run loop联系的input source的数据
        //对于本例与当前run loop联系的input source只有一个Timer类型的source。
        //该Timer每隔0.1秒发送触发事件给run loop，run loop检测到该事件时会调用相应的处理方法。
        
        //由于在run loop添加了observer且设置observer对所有的run loop行为都感兴趣。
        //当调用runUnitDate方法时，observer检测到run loop启动并进入循环，observer会调用其回调函数，第二个参数所传递的行为是kCFRunLoopEntry。
        //observer检测到run loop的其它行为并调用回调函数的操作与上面的描述相类似。
        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:900.0]];
        //当run loop的运行时间到达时，会退出当前的run loop。observer同样会检测到run loop的退出行为并调用其回调函数，第二个参数所传递的行为是kCFRunLoopExit。
        
        loopCount--;
    } while (loopCount);
    
    //释放自动释放池
    [pool release];
}
- (void) doFireTimer:(id)sender
{
    NSLog(@"sender %@",sender);
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
        genCacheCondition = [[NSCondition alloc] init];
        genExtractCondition = [[NSCondition alloc] init];
//        thread = [[NSThread alloc] initWithTarget:self selector:@selector(genAbstract) object:nil];
//        [thread start];
//        [NSThread detachNewThreadSelector:@selector(extractAbstract) toTarget:self withObject:nil];
        
        [NSThread detachNewThreadSelector:@selector(observerRunLoop) toTarget:self withObject:nil];
        
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(observerRunLoop) object:nil];
    }
    return self;
}


@end