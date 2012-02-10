//
//  WizDocumentsByKey.h
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WizApi.h"

@interface WizDocumentsByKey : WizApi {
	BOOL busy;
	//
	NSString* keywords;
   
}

@property (readonly) BOOL busy;
@property (nonatomic, retain) NSString* keywords;

-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(void) onDocumentsByKey:(id)retObject;

-(BOOL) searchDocuments;

@end
