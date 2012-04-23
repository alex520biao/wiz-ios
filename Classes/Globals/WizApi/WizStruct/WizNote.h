//
//  WizNote.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

@interface WizNote : WizObject
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
@end
