//
//  AttachmentView.m
//  Wiz
//
//  Created by dong zhao on 11-11-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AttachmentView.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizGlobals.h"

#import "Globals/WizDocumentsByLocation.h"
#import "WizDownloadObject.h"
#import "Globals/ZipArchive.h"

@implementation AttachmentView
@synthesize delegate,attachGUID,delegatrue;
@synthesize accountID;
@synthesize name;

-(void) dealloc
{
    self.delegate = nil;
    self.accountID = nil;
    self.attachGUID =nil;
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) 
    {
        [self setUserInteractionEnabled:YES];
        self.delegatrue=YES;
    }
    return  self;
}
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (delegatrue)
    {
        [delegate imageTouch:touches withEvent:event whichView:self];
    }
    WizDownloadObject* downloader = [[WizGlobalData sharedData] downloadObjectData:self.accountID];
    downloader.objType = @"attachment";
    downloader.objGuid = self.attachGUID;
    downloader.currentPos = 0;
    [downloader downloadObject];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(self.name, nil)
                                                    message:NSLocalizedString(@"Device does not support a photo library", nil)
                                                   delegate:nil 
                                          cancelButtonTitle:@"ok" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
    
}



@end
