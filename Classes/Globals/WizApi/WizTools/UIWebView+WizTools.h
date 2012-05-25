//
//  UIWebView+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (WizTools)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;
- (BOOL) containImages;
- (NSString*) bodyText;
- (void) loadIphoneReadScript:(NSString*)width;
@end
