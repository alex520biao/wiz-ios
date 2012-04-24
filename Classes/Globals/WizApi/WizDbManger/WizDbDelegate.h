//
//  WizDbDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizDocument;
@class WizAttachment;
@class WizTag;
@protocol WizDbDelegate <NSObject>
// version
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
//
- (BOOL) setDeletedGUIDVersion:(int64_t)ver;
- (int64_t) deletedGUIDVersion;
//
- (int64_t) tagVersion;
- (BOOL) setTageVersion:(int64_t)ver;
//
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
//
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (WizDocument*) documentFromGUID:(NSString *)guid;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
- (BOOL) deleteAttachment:(NSString *)attachGuid;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteDocument:(NSString*)documentGUID;

//document
- (BOOL) setDocumentServerChanged:(NSString*)documentGUID changed:(BOOL)changed;
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL) updateDocumentAfterEdit:(NSDictionary*)doc;
- (BOOL) updateDocument:(NSDictionary*) doc;
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentForUpload;
//tag
- (BOOL) updateTag: (NSDictionary*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (NSArray*) tagsForUpload;
//attachment
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) updateAttachment:(NSDictionary *)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;
- (WizAttachment*) attachmentFromGUID:(NSString *)guid;
//
- (NSArray*) deletedGUIDsForUpload;
- (BOOL) clearDeletedGUIDs;

//
- (BOOL) updateLocations:(NSArray*) locations;

//abstract
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID;
- (void) extractSummary:(NSString *)documentGUID;
@end
