//
//  NSMutableArray+WizDocuments.m
//  Wiz
//
//  Created by 朝 董 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+WizDocuments.h"

@implementation NSMutableArray (WizDocuments)
- (void) sortDocumentByOrder:(NSInteger)indexOrder
{
    NSMutableArray* sourceArray = [NSMutableArray arrayWithArray:[self reloadAllDocument]];
    [sourceArray sortDocuments:self.kOrderIndex];
    int count = 0;
    [self.tableSourceArray removeAllObjects];
    if ([sourceArray count] == 1) {
        [self.tableSourceArray addObject:[NSMutableArray arrayWithObject:[sourceArray lastObject]]];
        return;
    }
    
    for (int docIndx = 0; docIndx < [sourceArray count];) {
        @try {
            WizDocument* doc1 = [sourceArray objectAtIndex:docIndx];
            WizDocument* doc2 = [sourceArray objectAtIndex:docIndx+1];
            if ([doc1 compareToGroup:doc2 mask:self.kOrderIndex] != 0) {
                NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
                NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
                [self.tableSourceArray addObject:arr];
                count = docIndx+1;
            }
            docIndx++;
        }
        @catch (NSException *exception) {
            if (docIndx == [sourceArray count]-1) {
                WizDocument* doc1= [sourceArray objectAtIndex:[sourceArray count]-2];
                WizDocument* doc2 = [sourceArray lastObject];
                if ([doc1 compareToGroup:doc2 mask:self.kOrderIndex] != 0) {
                    NSMutableArray* arr = [NSMutableArray arrayWithObject:doc2];
                    [self.tableSourceArray addObject:arr];
                }
                else {
                    NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
                    NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
                    [self.tableSourceArray addObject:arr];
                }
            }
            docIndx++;
            count = docIndx;
            continue;
        }
        @finally {
        }
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
@end
