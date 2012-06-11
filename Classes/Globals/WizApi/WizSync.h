//
//  WizSync.h
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import <Foundation/Foundation.h>
#import "WizSyncDescriptionDelegate.h"
#import "WizRefreshDelegate.h"
#import "WizSyncSearchDelegate.h"
#import "WizApiManagerDelegate.h"
#import "WizSyncObjectSourceDelegate.h"

@interface WizSync : NSObject <WizSyncObjectSourceDelegate>
{
    NSURL* apiUrl;
    NSString* token;
    NSString* kbGuid;
}
@property (nonatomic, retain) NSURL* apiUrl;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, assign) id<WizSyncDescriptionDelegate> displayDelegate;
//upload
- (BOOL) isUploadingWizObject:(WizObject*)wizobject;
- (BOOL) uploadWizObject:(WizObject*)object;
//download
- (BOOL) isDownloadingWizobject:(WizObject*)object;
- (void) downloadWizObject:(WizObject*)object;
//
- (BOOL) startSyncInfo;
//
- (void) resignActive;
//
- (BOOL) isSyncing;
- (void) stopSync;
//
- (void) searchKeywords:(NSString*)keywords  searchDelegate:(id<WizSyncSearchDelegate>)searchDelegate;

- (void) uploadAllObject;
@end

