//
//  WizDocumentsByTag.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@interface WizDocumentsByTag : WizApi {
	BOOL busy;
	//
	NSString* tag_guid;
}

@property (readonly) BOOL busy;
@property (nonatomic, retain) NSString* tag_guid;

-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(void) onDocumentsByTag:(id)retObject;

-(BOOL) downloadDocumentList;

@end
