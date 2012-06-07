//
//  WizGroup.m
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGroup.h"
#import "WizAccountManager.h"
#define KeyOfKbKbguid               @"kb_guid"
#define KeyOfKbType                 @"KeyOfKbType"
#define KeyOfKbImage                @"KeyOfKbImage"
#define KeyOfKbAbstractString       @"KeyOfKbAbstractString"
#define KeyOfKbName                 @"kb_name"
@implementation WizGroup
@synthesize type;
@synthesize abstractImage;
@synthesize abstractText;
- (void) dealloc
{
    [abstractImage release];
    abstractImage = nil;
    [abstractText release];
    abstractText = nil;
    [super dealloc];
}
- (NSDictionary*) dictionaryWithGropuData
{
    NSData* imageData = nil;
    if (self.abstractImage) {
        imageData = [self.abstractImage compressedData];
    }
    else {
        imageData = [[UIImage imageNamed:@"edit"] compressedData];
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObjectNotNull:self.guid forKey:KeyOfKbKbguid];
    [dic setObjectNotNull:self.title forKey:KeyOfKbName];
    [dic setObjectNotNull:imageData forKey:KeyOfKbImage];
    [dic setObjectNotNull:[NSNumber numberWithInt:self.type] forKey:KeyOfKbType];
    [dic setObjectNotNull:self.abstractText forKey:KeyOfKbAbstractString];

    NSLog(@"dic is %@",dic);
    NSLog(@"%@ %@ %d",self.guid,self.title,self.type);
    return dic;
}
- (BOOL) save
{
    return NO;
}

- (WizGroup*)groupFromDicionary:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        NSString* string = [dic valueForKey:KeyOfKbKbguid];
        if (string == nil || [string isBlock]) {
            return nil;
        }
        self.guid = string;
        self.title = [dic valueForKey:KeyOfKbName];
        self.abstractText = [dic valueForKey:KeyOfKbAbstractString];
        NSData* data = [dic valueForKey:KeyOfKbImage];
        self.abstractImage = [UIImage imageWithData:data];
        NSNumber* kbType = [dic valueForKey:KeyOfKbType];
        if (kbType) {
            self.type = [kbType intValue];
        }
        NSLog(@"      %d",self.type);
    }
    return self;
}
- (BOOL) isEqualToDictionary:(NSDictionary*)dic
{
    NSString* kbguid = [dic valueForKey:KeyOfKbKbguid];
    NSLog(@"kbguid%@  dic %@",kbguid, self.guid);
    if (!kbguid) {
        return NO;
    }
    else {
        if ([kbguid isEqual:self.guid]) {
            return YES;
        }
    }
    return NO;
}

+ (WizGroup*) groupFromGuid:(NSString*)guid
{
    NSArray* array = [[[WizAccountManager defaultManager] activeAccount] groups];
    for (NSDictionary* each in array) {
        WizGroup* g = [[WizGroup alloc] groupFromDicionary:each];
        if ([guid isEqualToString:g.guid]) {
            return g;
        }
    [g release];
    }
    return nil;
}

@end
