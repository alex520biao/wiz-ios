//
//  WizDataBaseBase.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import <UIKit/UIKit.h>
#import "FMDataBase.h"
@interface WizDataBaseBase : NSObject
{
    FMDatabase* dataBase;
}
@property (nonatomic, readonly) FMDatabase* dataBase;
- (WizDataBaseBase*) initWithPath:(NSString*)dbPath modelName:(NSString*)modelName;
@end
