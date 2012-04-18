//
//  WizDocumentsByLocation.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizDocumentsByLocation.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizDownloadObject.h"
@implementation WizDocumentsByLocation

@synthesize busy;
@synthesize location;
@synthesize downloadArray;
@synthesize isStopByUser;
-(void) dealloc
{
    [downloadArray release];
    [location release];
	[super dealloc];
}

-(void) onError: (id)retObject
{
	[super onError:retObject];
     NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
	busy = NO;
}

-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
	[self callDocumentsByCategory:self.location];
}
-(void) stopSync
{
   
    self.isStopByUser = YES;
}
-(void) downAllDocument
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    
    if([self.downloadArray count] == 0) 
    {
        [self callClientLogout];
        return;
    }
    WizDocument* each = [self.downloadArray lastObject];
    WizDownloadDocument* downloader = [[WizGlobalData sharedData] downloadDocumentData:self.accountUserId];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
    NSString* notificationName = [downloader notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix];
    [nc addObserver:self selector:@selector(downAllDocument) name:notificationName object:nil];
    [self.downloadArray removeLastObject];
}

-(void) onDocumentsByCategory:(id)retObject
{
	[super onDocumentsByCategory:retObject];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
    if ([index downloadDocumentData]) {
        NSArray* dic = [index documentsByLocation:self.location] ;
        if (nil == self.downloadArray) {
            self.downloadArray = [NSMutableArray array];
        }
        for (WizDocument* each in dic) {
            if (each.serverChanged) {
                [self.downloadArray addObject:each];
            }
        }
        [self downAllDocument];
    }
    else
    {
        [self callClientLogout];
    }
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncEndNotificationPrefix] object: nil];
	busy = NO;
}


- (BOOL) downloadDocumentList
{
	if (self.busy)
		return NO;
	busy = YES;
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
	return [self callClientLogin];
}

@end
