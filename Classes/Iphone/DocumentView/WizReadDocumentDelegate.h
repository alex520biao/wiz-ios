//
//  WizReadDocumentDelegate.h
//  Wiz
//
//  Created by wiz on 12-10-10.
//
//

#import <Foundation/Foundation.h>

@protocol WizReadDocumentDelegate <NSObject>
- (WizDocument*) currentDocument;
- (void) deleteDocument:(WizDocument*)document;
@end
