//
//  WizDbDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WizDeletedGUID.h"
@class WizAttachment;
@class WizTag;
@class WizDocument;

@protocol WizDbDelegate <NSObject>
// version
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
//
- (BOOL) setDeletedGUIDVersion:(int64_t)ver;
- (int64_t) deletedGUIDVersion;
//
- (int64_t) tagVersion;
- (BOOL) setTagVersion:(int64_t)ver;
//
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
//
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
- (BOOL) deleteAttachment:(NSString *)attachGuid;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteLocalTag:(NSString*)tagGuid;

- (BOOL) deleteDocument:(NSString*)documentGUID;

//document
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL) updateDocument:(NSDictionary*) doc;
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentForUpload;
- (NSArray*) documentsForCache:(NSInteger)duration;
- (WizDocument*) documentForClearCacheNext;
- (WizDocument*) documentForDownloadNext;

- (BOOL) setDocumentServerChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) setDocumentLocalChanged:(NSString*)guid  changed:(WizEditDocumentType)changed;
- (BOOL) changedDocumentTags:(NSString*)documentGuid  tags:(NSString*)tags;
//tag
- (NSArray*) allTagsForTree;
- (BOOL) updateTag: (NSDictionary*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (NSArray*) tagsForUpload;
- (int) fileCountOfTag:(NSString *)tagGUID;
- (WizTag*) tagFromGuid:(NSString *)guid;
- (NSString*) tagAbstractString:(NSString*)guid;
- (BOOL) setTagLocalChanged:(NSString*)guid changed:(BOOL)changed;
//attachment
-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) updateAttachment:(NSDictionary *)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;
- (WizAttachment*) attachmentFromGUID:(NSString *)guid;
//
- (NSArray*) deletedGUIDsForUpload;
- (BOOL) clearDeletedGUIDs;

//folder
- (BOOL) updateLocations:(NSArray*) locations;
- (NSArray*) allLocationsForTree;
- (int) fileCountOfLocation:(NSString *)location;
- (int) filecountWithChildOfLocation:(NSString*) location;
- (NSString*) folderAbstractString:(NSString*)folderKey;
- (BOOL) updateLocalFolder:(NSString*)folder;
- (BOOL) deleteLocalFolder:(NSString*)folder;
@end
