//
//  WizDocument.h
//  WizLib
//
//  Created by 朝 董 on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizDocument : NSObject
{
	NSString* guid;
	NSString* title;
	NSString* location;
	NSString* url;
	NSDate* dateCreated;
	NSDate* dateModified;
	NSString* type;
	NSString* fileType;
    NSString* tagGuids;
    NSString* dataMd5;
    BOOL serverChanged;
    BOOL localChanged;
    BOOL protectedB;
	int attachmentCount;
}

@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSDate* dateCreated;
@property (nonatomic, retain) NSDate* dateModified;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* fileType;
@property (nonatomic, retain) NSString* tagGuids;
@property (nonatomic, retain) NSString* dataMd5;
@property (assign) BOOL serverChanged;
@property (assign) BOOL localChanged;
@property (assign) BOOL protectedB;
@property int attachmentCount;
//
- (id) initFromGuid:(NSString*)guid;
- (NSString*) documentFilePath;
- (NSString*) documentMobileFilePath;
- (NSString*) documentFullFilePath;
- (NSString*) documentAbstractFilePath;
@end