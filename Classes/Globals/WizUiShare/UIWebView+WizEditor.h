//
//  UIWebView+WizEditor.h
//  Wiz
//
//  Created by 朝 董 on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define  WizNotCmdChangedText @"changedText"
#define  WizNotCmdChangedImage  @"changedImage"
@interface UIWebView (WizEditor)
- (void) prapareForEdit;
- (void) insertImage:(NSString*)imagePath;
- (BOOL) insertAudio:(NSString*)audioPath;
//
- (void) focusEditor;
- (void)bold;
- (void)italic;
- (void)underline;
- (void)undo;
- (void)redo;
- (NSString*) getDocumentBodyHtml;
- (void) highlightText;
- (void) strikeThrough;
- (void)fontSizeUp;
- (void)fontSizeDown;

//
- (void) prapareForEditLessThan5;

//
- (NSArray*) decodeJsCmd:(NSString*)urlCmd;
//
- (BOOL) deleteImage;
- (BOOL) containImages;
- (void) setHackishlyHidesInputAccessoryView:(BOOL)value;
@end
