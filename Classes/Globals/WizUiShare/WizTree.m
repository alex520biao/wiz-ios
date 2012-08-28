//
//  WizTree.m
//  Wiz
//
//  Created by wiz on 12-8-27.
//
//

#import "WizTree.h"

@interface WizTreeNode : NSObject
@property (nonatomic, retain) NSObject* objectContent;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, retain) NSString* strParentKey;
@end
@implementation WizTreeNode
@synthesize objectContent;
@synthesize strParentKey;
- (void) dealloc
{
    [objectContent release];
    [strParentKey release];
    [super dealloc];
}
@end

@interface WizTree ()
{
    NSString* strRootKey;
    NSMutableDictionary*  data;
}
@end

@implementation WizTree
@synthesize rootKey = rootKey_;

- (void) dealloc
{
    [rootKey_ release];
    [data release];
    [super dealloc];
}

- (id) initWithRootKey:(NSString*)root
{
    self = [super init];
    if (self) {
        rootKey_ = [root retain];
        data = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void) addTreeNode:(NSString*)key objectContent:(id)object isExpanded:(BOOL)isExpanded parentKey:(NSString*)parentKey
{
    WizTreeNode* node = [[WizTreeNode alloc] init];
    node.strParentKey = parentKey;
    node.objectContent = object;
    node.isExpanded = isExpanded;
    [data setObject:node forKey:key];
    [node release];
}
- (NSArray*)  childrenTreeNode:(NSString*)key
{
    NSMutableArray* children = [NSMutableArray array];
    
}
- (void) removeTreeNode:(NSString*)key
{
    
}

@end
