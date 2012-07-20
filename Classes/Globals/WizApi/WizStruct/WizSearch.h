//
//  WizSearch.h
//  Wiz
//
//  Created by wiz on 12-7-20.
//
//

#import <Foundation/Foundation.h>

@interface WizSearch : NSObject
{
    NSInteger  nNotesNumber;
    BOOL       isSearchLocal;
    NSString* keyWords;
    NSDate*     searchDate;
}
@property (nonatomic, retain) NSString* keyWords;
@property (nonatomic, retain) NSDate* searchDate;
@property (nonatomic, assign) NSInteger  nNotesNumber;
@property (nonatomic, assign) BOOL       isSearchLocal;
@end
