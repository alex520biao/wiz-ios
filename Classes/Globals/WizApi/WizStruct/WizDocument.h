//
//  WizDocument.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

typedef NSUInteger WizTableOrder;
//%2 is reverse
enum
{
     kOrderDate=1,
     kOrderReverseDate=2,
     kOrderFirstLetter=3,
     kOrderReverseFirstLetter=4,
     kOrderCreatedDate=5,
     kOrderReverseCreatedDate=6
};
@interface WizDocument : WizObject
{
	NSString* location;
	NSString* url;
	NSDate* dateCreated;
	NSDate* dateModified;
	NSString* type;
	NSString* fileType;
    NSString* tagGuids;
    NSString* dataMd5;
    BOOL protected_;
    BOOL serverChanged;
    BOOL localChanged;
	int attachmentCount;
}
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
@property (assign) BOOL protected_;
@property int attachmentCount;
- (NSComparisonResult) compareDate:(WizDocument*) doc;
- (NSComparisonResult) compareReverseDate:(WizDocument*) doc;
- (NSComparisonResult) compareWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc;
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc;

- (NSString*) documentIndexFilesPath;
- (NSString*) documentIndexFile;
- (NSString*) documentMobileFile;
- (NSString*) documentAbstractFile;
- (NSString*) documentFullFile;

@end
