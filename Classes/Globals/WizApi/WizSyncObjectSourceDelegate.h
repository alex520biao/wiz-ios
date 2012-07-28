//
//  WizSyncObjectSourceDelegate.h
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import <Foundation/Foundation.h>

@protocol WizSyncObjectSourceDelegate <NSObject>
- (WizObject*) nextWizObjectForDownload;
- (WizObject*) nextWizObjectForUpload;
- (BOOL) willDownloandNext;
- (BOOL) willUploadNext;
@end
