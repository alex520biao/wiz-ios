//
//  WizPadEditNoteController.h
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizEditNoteBase.h"
@class UIBadgeView;
@interface WizPadEditNoteController : WizEditNoteBase <UIScrollViewDelegate,UIPopoverControllerDelegate,UITextFieldDelegate>
{
    @private
    UITextView* bodyInputTextView;
    UITextField* titleInputTextField;
    UITextField* tagTextField;
    UITextField* folderTextField;
    UIScrollView* backgroudScrollView;
    CGFloat  bodyInputViewHeigth;
    UIPopoverController* currentPopoverController;
    NSMutableString* documentFloder;
    NSMutableArray* selectedTags;
    UIImageView* timerView;
    BOOL isNewDocument;
    UIBadgeView* attachmentsCountView;
    @public
    NSString* documentGUID;
}
@property (nonatomic, retain) UIImageView* timerView;
@property (nonatomic, retain) UITextView* bodyInputTextView;
@property (nonatomic, retain)UITextField* titleInputTextField;
@property (nonatomic, retain)    UITextField* tagTextField;
@property (nonatomic, retain)  UITextField* folderTextField;
@property (nonatomic, retain) UIScrollView* backgroudScrollView;
@property (nonatomic, retain) NSMutableString* documentFloder;
@property (nonatomic, retain)  NSMutableArray* selectedTags;
@property (nonatomic, retain) UIBadgeView* attachmentsCountView;
@property CGFloat  bodyInputViewHeigth;
@property (nonatomic, retain) NSString* documentGUID;
@property (nonatomic, retain) UIPopoverController* currentPopoverController;
@property BOOL isNewDocument;
- (void) prepareEditingData:(NSDictionary*)data;
- (void) prepareNewDocumentData:(NSDictionary*)data;
- (void) startRecorder:(id)sender;
@end
