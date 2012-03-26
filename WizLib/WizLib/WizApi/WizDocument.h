//
//  WizDocument.h
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
@interface WizDocument : WizObject 
{
	NSString* title;
	NSString* location;
	NSString* url;
	NSString* dateCreated;
	NSString* dateModified;
	NSString* type;
	NSString* fileType;
    NSString* tagGuids;
    BOOL serverChanged;
    BOOL localChanged;
	int attachmentCount;
}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* dateCreated;
@property (nonatomic, retain) NSString* dateModified;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* fileType;
@property (nonatomic, retain) NSString* tagGuids;
@property (assign) BOOL serverChanged;
@property (assign) BOOL localChanged;
@property int attachmentCount;
- (NSComparisonResult) compareDate:(WizDocument*) doc;
- (NSComparisonResult) compareReverseDate:(WizDocument*) doc;
- (NSComparisonResult) compareWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc;
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc;
@end