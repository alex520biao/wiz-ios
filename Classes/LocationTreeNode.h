//
//  LocationTreeNode.h
//  Wiz
//
//  Created by dong zhao on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocationTreeNode : NSObject {
    LocationTreeNode *parentLocationNode;
    NSMutableArray *children;
    NSString* title;
    NSString* locationKey;
    NSIndexPath* indexPath;
    BOOL expanded;
    BOOL hidden;
    int deep;
    int row;
}
@property (nonatomic, retain) LocationTreeNode* parentLocationNode;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, retain)NSString* title;
@property (nonatomic, retain)NSString* locationKey;

@property (assign)BOOL expanded;
@property (assign)BOOL hidden;
@property int deep;
@property int row;
-(void) setDeep:(int) value ;
-(int) deep;

-(BOOL) hasChildren;
-(void) addChild:(LocationTreeNode*) child;
-(int) childrenCount;
- (void) removeChild:(LocationTreeNode*)childNode;
+(LocationTreeNode*) findNodeByKey:(NSString*)_key :(LocationTreeNode*) node;
+(void) getLocationNodes:(LocationTreeNode*) root: (NSMutableArray*) array;
+(void) childrenHidden:(LocationTreeNode*) root;
+(BOOL) isChildToNode:(LocationTreeNode*) root:(LocationTreeNode*) child;
@end
