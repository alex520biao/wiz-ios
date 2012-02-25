//
//  WizDocumentsByLocation.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WizApi.h"

@interface WizDocumentsByLocation : WizApi {
	BOOL busy;
	NSString* location;
    NSMutableArray* downloadArray;
    BOOL isStopByUser;
}

@property (readonly) BOOL busy;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSMutableArray* downloadArray;
@property (assign)     BOOL isStopByUser;
-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(void) onDocumentsByCategory:(id)retObject;
-(BOOL) downloadDocumentList;
@end
