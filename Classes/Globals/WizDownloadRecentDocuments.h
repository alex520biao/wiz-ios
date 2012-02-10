//
//  WizDownloadRecentDocuments.h
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WizApi.h"

@interface WizDownloadRecentDocuments : WizApi {
	BOOL busy;
}

@property (readonly) BOOL busy;

-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(void) onDownloadDocumentList:(id)retObject;

-(BOOL) downloadDocumentList;
@end
