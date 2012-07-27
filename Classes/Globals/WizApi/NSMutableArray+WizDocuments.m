//
//  NSMutableArray+WizDocuments.m
//  Wiz
//
//  Created by 朝 董 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+WizDocuments.h"
#import "WizSettings.h"
NSComparisonResult ReverseComparisonResult(NSComparisonResult result)
{
    if (result > 0) {
        return -1;
    }
    else if (result < 0) {
        return 1;
    }
    else {
        return 0;
    }
}
@interface WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocument:(WizDocument*)doc mask:(WizTableOrder)mask;
-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask;
@end

@implementation WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocumentOrder:(WizDocument*)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
        case kOrderReverseDate:
            return  [self compareModifiedDate:doc];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            return [self compareCreateDate:doc];
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return  [self.title compareFirstCharacter:doc.title];
        default:
            break;
    }
    return -NSUIntegerMax;
}
-(NSComparisonResult) compareDocument:(WizDocument *)doc mask:(WizTableOrder)mask
{
    return ReverseComparisonResult([self compareDocumentOrder:doc mask:mask]);
}
- (NSComparisonResult) reverseDateGroup:(NSDate*)d1 date2:(NSDate*)d2
{
    if ([d1 isToday]) {
        if ([d2 isToday]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isYesterday])
    {
        if ([d2 isYesterday]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]]) 
    {
        if ([d2 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isLaterThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d1 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:2]]) {
        if ([d2 isLaterThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d2 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:2]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else {
        if ([d1 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d2 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:7]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
}

-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
            return [[self.dateModified stringYearAndMounth] compare:[self.dateModified stringYearAndMounth] ];
        case kOrderReverseDate:
            return [self reverseDateGroup:self.dateModified date2:doc.dateModified];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            return [[self.dateCreated stringYearAndMounth] compare:[self.dateCreated stringYearAndMounth]];
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return [self.title compareFirstCharacter:doc.title];
        default:
            break;
    }
    return 0;
}
@end

@interface NSMutableArray (WizSortDocument)
- (void) sortDocuments:(WizTableOrder)mask;
@end
@implementation NSMutableArray (WizSortDocument)

- (void) sortDocuments:(WizTableOrder)mask
{
    [self sortUsingComparator:(NSComparator)^(WizDocument* doc1, WizDocument* doc2)
     {
         return [doc1 compareDocument:doc2 mask:mask];
     }];
}
@end
@implementation NSMutableArray (WizDocuments)
- (NSMutableArray*) sourceArray
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSArray* each in self) {
        [array addObjectsFromArray:each];
    }
    return array;
}
- (NSString*) description
{
    if ([self count] > 0 && [[self lastObject] isKindOfClass:[WizDocument class]]) {
        WizDocument* doc = (WizDocument*)[self objectAtIndex:0];
        switch ([[WizSettings defaultSettings] userTablelistViewOption]) {
            case kOrderCreatedDate:
            case kOrderReverseCreatedDate:
            {
                if (doc.dateCreated != nil) {
                    return [doc.dateCreated  stringYearAndMounth];
                }
                else {
                    return @"dd";
                }
            }
                
            case kOrderDate:
            {
                if (doc.dateModified != nil ) {
                    return [doc.dateModified stringYearAndMounth];
                }
                else {
                    return @"dddd";
                }
            }
            case kOrderFirstLetter:
            case kOrderReverseFirstLetter:
                return [WizGlobals pinyinFirstLetter:doc.title];
            case kOrderReverseDate:
            {
                NSDate* todayStart = [NSDate dateAtStartOfToday];
                float timeInterval = [todayStart timeIntervalSinceDate:doc.dateModified];
                
                if (timeInterval < 0) {
                    return WizStrToday;
                }
                else if (timeInterval < D_DAY)
                {
                    return WizStrYesterday;
                }
                else if (timeInterval < D_2DAY)
                {
                    return WizStrThedaybeforeyesterday;
                }
                else if (timeInterval < D_6DAY)
                {
                    return WizStrWithInAWeek;
                }
                else 
                {
                    return WizStrOneWeekAgo;
                }
            }
            default:
                break;
        }
        return @"No Title";
 
    }
    return @"No Title";
}
- (void) groupSourceArrayByReverseModifiedDate:(NSMutableArray*)sourceArray
{

    NSMutableArray* todyArr = [NSMutableArray array];
    NSMutableArray* yestodyArr = [NSMutableArray array];
    NSMutableArray* theDayBeforeYestodyArr = [NSMutableArray array];
    NSMutableArray* inWeekArr   = [NSMutableArray array];
    NSMutableArray* outWeekArr  = [NSMutableArray array];
    
    NSDate* todayStart = [NSDate dateAtStartOfToday];
    
    for (int docIndex = 0; docIndex < [sourceArray count] ; docIndex++) {
        WizDocument* doc = [sourceArray objectAtIndex:docIndex];
        float timeInterval = [todayStart timeIntervalSinceDate:doc.dateModified];
        if (timeInterval < 0) {
            [todyArr addObject:doc];
        }
        else if (timeInterval < D_DAY)
        {
            [yestodyArr addObject:doc];
        }
        else if (timeInterval < D_2DAY)
        {
            [theDayBeforeYestodyArr addObject:doc];
        }
        else if (timeInterval < D_6DAY)
        {
            [inWeekArr addObject:doc];
        }
        else 
        {
            NSRange range = NSMakeRange(docIndex, (NSInteger)[sourceArray count] - docIndex);
            [outWeekArr addObjectsFromArray:[sourceArray subarrayWithRange:range]];
            break;
        }
    }
    if ([todyArr count])
    {
        [self addObject:todyArr];
    }
    if ([yestodyArr count])
    {
        [self addObject:yestodyArr];
    }
    if ([theDayBeforeYestodyArr count])
    {
        [self addObject:theDayBeforeYestodyArr];
    }
    if ([inWeekArr count])
    {
        [self addObject:inWeekArr];
    }
    if ([outWeekArr count])
    {
        [self addObject:outWeekArr];
    }
}
- (void) sortDocumentByOrder:(NSInteger)indexOrder
{
    NSMutableArray* sourceArray = [self sourceArray];
    [sourceArray sortDocuments:indexOrder];
    [self  removeAllObjects];
    if ([sourceArray count] == 1) {
        [self addObject:[NSMutableArray arrayWithObject:[sourceArray lastObject]]];
        return;
    }
    if (kOrderReverseDate == indexOrder) {
        [self groupSourceArrayByReverseModifiedDate:sourceArray];
        return;
    }
    NSMutableArray* currentSection= [NSMutableArray array];

    for (int docIndex = 0; docIndex < (NSInteger)[sourceArray count] -1; docIndex++) {
        WizDocument* doc1 = [sourceArray objectAtIndex:docIndex];
        WizDocument* doc2 = [sourceArray objectAtIndex:docIndex+1];
        [doc1 compareToGroup:doc2 mask:indexOrder];
        if ([doc1 compareToGroup:doc2 mask:indexOrder] != 0) {
            [currentSection addObject:doc1];
            [self addObject:currentSection];
            currentSection = [NSMutableArray array];
        }
        else {
            [currentSection addObject:doc1];
        }
    }
    [self addObject:currentSection];
//    for (int docIndx = 0; docIndx < [sourceArray count];) {
//        @try {
//            WizDocument* doc1 = [sourceArray objectAtIndex:docIndx];
//            WizDocument* doc2 = [sourceArray objectAtIndex:docIndx+1];
//            if ([doc1 compareToGroup:doc2 mask:indexOrder] != 0) {
//                NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
//                NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
//                [self addObject:arr];
//                count = docIndx+1;
//            }
//            docIndx++;
//        }
//        @catch (NSException *exception) {
//            if (docIndx == [sourceArray count]-1) {
//                WizDocument* doc1= [sourceArray objectAtIndex:[sourceArray count]-2];
//                WizDocument* doc2 = [sourceArray lastObject];
//                if ([doc1 compareToGroup:doc2 mask:indexOrder] != 0) {
//                    NSMutableArray* arr = [NSMutableArray arrayWithObject:doc2];
//                    [self addObject:arr];
//                }
//                else {
//                    NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
//                    NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
//                    [self addObject:arr];
//                }
//            }
//            docIndx++;
//            count = docIndx;
//            continue;
//        }
//        @finally {
//        }
//    }
}

- (NSIndexPath*) indexPathOfWizDocument:(WizDocument*) doc
{
    NSInteger order = [[WizSettings defaultSettings] userTablelistViewOption];
    NSLog(@"table older is %d",order);
    for (int i = 0 ; i < [self count] ; i++) {
        NSMutableArray* section = [self objectAtIndex:i];
        NSLog(@"section count is %d",[section count]);
        for (int j=0; j < [section count]; j ++) {
            WizDocument* comparedDoc = [section objectAtIndex:j];
            if ([doc.guid isEqualToString:comparedDoc.guid])
            {
                return [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
}

- (NSIndexPath*) updateDocument:(WizDocument*)doc
{
    NSIndexPath* indexPath = [self indexPathOfWizDocument:doc];
    NSLog(@"edit doc location is %@",doc.location);
    if(indexPath.row != NSNotFound && indexPath.section != NSNotFound)
    {
        WizDocument* docOld = [[self objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (![docOld.guid isEqualToString:doc.guid]) {
            
            NSLog(@"******************************  download done object is not qual to the replaced! old%@ new%@",docOld.guid, doc.guid);
        }
        [[self objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:doc];
        return indexPath;
    }
    return nil;
}

- (NSIndexPath*) removeDocument:(WizDocument*)doc
{
    NSIndexPath* indexPath = [self indexPathOfWizDocument:doc];
    if(indexPath.row != NSNotFound && indexPath.section != NSNotFound)
    {
        if ([[self objectAtIndex:indexPath.section] count] == 1) {
            [self removeObjectAtIndex:indexPath.section];
            return [NSIndexPath indexPathForRow:WizDeletedSectionIndex inSection:indexPath.section];
        }
        else {
            [[self objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
            return indexPath;
        }
    }
    return nil;
}

- (NSIndexPath*) insertDocument:(WizDocument*)doc
{
    @try {
        if (doc == nil) {
            return nil;
        }
        if ([self count]) {
            if ([[self  lastObject] count]) {
                WizDocument* lastDoc = [[self lastObject] lastObject];
                if ([doc.dateModified isEarlierThanDate:lastDoc.dateModified]) {
                    return nil;
                }
            }
        }
        NSInteger order = [[WizSettings defaultSettings] userTablelistViewOption];
        NSInteger section = NSNotFound;
        for (int i = 0; i < [self count]; i++) {
            NSMutableArray* array  = [self objectAtIndex:i];
            WizDocument* doc1 = [array objectAtIndex:0];
            if (![doc compareToGroup:doc1 mask:order]) {
                section = i;
            }
        }
        if (NSNotFound != section) {
            NSMutableArray* arr = [self objectAtIndex:section];
            [arr insertObject:doc atIndex:0];
            return [NSIndexPath indexPathForRow:0 inSection:section];
        }
        else {
            NSMutableArray* arr = [NSMutableArray array];
            [arr addObject:doc];
            [self insertObject:arr atIndex:0];
            return [NSIndexPath indexPathForRow:0 inSection:WizNewSectionIndex];
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}
@end
