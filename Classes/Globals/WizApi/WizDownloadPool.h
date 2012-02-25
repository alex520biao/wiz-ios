//
//  WizDownloadPool.h
//  Wiz
//
//  Created by wiz on 12-2-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizDownloadPool : NSObject
{
    NSMutableDictionary* processPool;
    NSString* accountUserId;
}
@property (nonatomic,retain) NSMutableDictionary* processPool;
@property (nonatomic, retain) NSString* accountUserId;
- (id) getDownloadProcess:(NSString*)objectGUID  type:(NSString*)objectType;
- (void) removeDownloadProcess:(NSString*)objectGUID  type:(NSString*)objectType;
- (BOOL) documentIsDownloading:(NSString*)documentGUID;
- (BOOL) attachmentIsDownloading:(NSString*)attachmentGUID;
- (void) removeDownloadData:(NSNotification*)nc;
@end
