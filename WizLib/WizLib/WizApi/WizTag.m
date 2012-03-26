//
//  WizTag.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTag.h"
#import "index.h"
@implementation WizTag

@synthesize name;
@synthesize guid;
@synthesize parentGUID;
@synthesize description;
@synthesize namePath;
@synthesize dtInfoModified;
@synthesize localChanged;

- (void) dealloc
{
	self.name = nil;
	self.guid = nil;
	self.parentGUID = nil;
	self.description = nil;
	self.namePath = nil;
	[super dealloc];
}


- (id) initFromWizTagData: (const WIZTAGDATA&) data
{
	if (self = [super init])
	{
		self.guid = [[[NSString alloc] initWithUTF8String: data.strGUID.c_str()] autorelease];
		self.parentGUID = [[[NSString alloc] initWithUTF8String: data.strParentGUID.c_str()] autorelease];
		self.name = [[[NSString alloc] initWithUTF8String: data.strName.c_str()] autorelease];
		self.description = [[[NSString alloc] initWithUTF8String: data.strDescription.c_str()] autorelease];
		self.namePath = [[[NSString alloc] initWithUTF8String: data.strNamePath.c_str()] autorelease];
        self.localChanged = data.localchanged;
        self.dtInfoModified = [[[NSString alloc] initWithUTF8String:data.strDtInfoModified.c_str()] autorelease];
        
	}
	return self;
}


@end