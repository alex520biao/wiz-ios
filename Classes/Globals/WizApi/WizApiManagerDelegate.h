//
//  WizApiManagerDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizApi;
@protocol WizApiManagerDelegate <NSObject>
- (void) didApiSyncDone:(WizApi*)api;
- (void) didApiSyncError:(WizApi*)api error:(NSError*)error   ;
- (void) didChangedSyncDescriptorMessage:(NSString*)descriptorMessage;
- (void) didChangedStatue:(WizApi*)api statue:(NSInteger)statue;
@end
