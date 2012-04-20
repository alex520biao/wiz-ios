//
//  WizAbstractCache.h
//  Wiz
//
//  Created by MagicStudio on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WizAbstractData : NSObject
{
    NSAttributedString* text;
    UIImage*            image;
}
@property (nonatomic, retain) NSAttributedString* text;
@property (nonatomic, retain) UIImage*              image;
@end
@interface WizAbstractCache : NSObject
- (WizAbstractData*) documentAbstractForIphone:(NSString*)documentGUID;
+ (id) shareCache;
- (void) didReceivedMenoryWarning;

- (WizAbstractData*) folderAbstractForIpad:(NSString*)folderKey     userID:(NSString*)userId;
@end
