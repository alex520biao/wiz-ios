//
//  WizDataBaseV.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import <Foundation/Foundation.h>
#import "FMDataBase.h"
@interface WizDataBaseV : NSObject
{
    FMDatabase* dataBase;
}
@property (nonatomic, readonly) FMDatabase* dataBase;
@end
