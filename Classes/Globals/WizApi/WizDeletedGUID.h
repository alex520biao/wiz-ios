//
//  WizDeletedGUID.h
//  Wiz
//
//  Created by wiz on 12-6-15.
//
//

#import <UIKit/UIKit.h>

@interface WizDeletedGUID : NSObject
{
	NSString* guid;
	NSString* type;
	NSString* dateDeleted;
}
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain)NSString* type;
@property (nonatomic, retain)NSString* dateDeleted;
@end
