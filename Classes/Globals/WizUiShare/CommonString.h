//
//  CommonString.h
//  Wiz
//
//  Created by Wei Shijun on 3/23/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>


#define WizStrOK		NSLocalizedString(@"OK", nil)
#define WizStrCancel	NSLocalizedString(@"Cancel", nil)
#define WizStrError		NSLocalizedString(@"Error", nil)
#define WizStrSave		NSLocalizedString(@"Save", nil)
#define WizStrLogin		NSLocalizedString(@"Login", nil)
#define WizStrDocuments	NSLocalizedString(@"Documents", nil)
#define WizStrRemove	NSLocalizedString(@"Remove", nil)
#define WizStrSucceed   NSLocalizedString(@"Succeed", nil)
#define WizStrSync		NSLocalizedString(@"Sync", nil)
#define WizStrDelete		NSLocalizedString(@"Delete", nil)
#define WizStrRefresh		NSLocalizedString(@"Refresh", nil)

#define WizStrTags		NSLocalizedString(@"Tags", nil)



#define	WizStrMyDrafts		NSLocalizedString(@"My Drafts", nil)
#define	WizStrMyNotes		NSLocalizedString(@"My Notes", nil)
#define	WizStrMyJournals		NSLocalizedString(@"My Journals", nil)
#define	WizStrMyEvents		NSLocalizedString(@"My Events", nil)
#define	WizStrMyMobiles		NSLocalizedString(@"My Mobiels", nil)

#define	WizStrSearch		NSLocalizedString(@"Search", nil)

#define WizStrAccounts		NSLocalizedString(@"Accounts", nil)

#define WizStrHome			NSLocalizedString(@"Home", nil)
#define WizStrNewNote        NSLocalizedString(@"New note",nil)
#define WizTagPublic			NSLocalizedString(@"Public Notes", nil)
#define WizTagProtected			NSLocalizedString(@"Share with friends", nil)
NSString* getTagDisplayName(NSString* tagName);

