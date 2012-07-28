//
//  LocationTreeNode.m
//  Wiz
//
//  Created by dong zhao on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocationTreeNode.h"


@implementation LocationTreeNode
@synthesize parentLocationNode, title, locationKey, expanded, hidden, children, row;
-(id) init {
    if(self = [super init]) {
        parentLocationNode = nil;
        children = nil;
        locationKey = nil;
    }
    return  self;
}

-(void)addChild:(LocationTreeNode *)child {
    if(children ==nil) {
        children = [[NSMutableArray alloc]init];
    }
    child.parentLocationNode = self;
    [children addObject:child];
}
-(int)childrenCount {
    return children==nil?0:[children count];
}
-(int) deep {
    return parentLocationNode==nil?0:parentLocationNode.deep+1;
}
-(void) setDeep:(int)value {
    deep = value;
}
-(BOOL) hasChildren {
    if(children == nil || children.count ==0) 
        return NO;
    else
        return YES;
}

- (int) indexOfChild:(LocationTreeNode*)child
{
    for (int i = 0; i < [child.parentLocationNode.children count] ; i++) {
        LocationTreeNode* each = [child.parentLocationNode.children objectAtIndex:i];
        if ([each.locationKey isEqualToString:child.locationKey]) {
            return i;
        }
    }
    return -1;
}

- (void) removeChild:(LocationTreeNode*)childNode 
{
    int index = [self indexOfChild:childNode];
    if (index == -1) {
        return;
    }
    [self.children removeObjectAtIndex:index];

}

+(LocationTreeNode*) findNodeByKey:(NSString *)_key :(LocationTreeNode *)node{
    if([_key isEqualToString:[node locationKey]] ){
        return node;
    } else 
        if([node hasChildren]) {
            for(LocationTreeNode* each in [node children]) {
                LocationTreeNode* temp = [LocationTreeNode findNodeByKey:_key :each];
                if(temp!=nil) 
                    return  temp;
            }
        }
    return nil;
}

+(void)getLocationNodes:(LocationTreeNode *)root :(NSMutableArray *)array{
    if(![root hidden])
    [array addObject:root];
    if([root hasChildren] &&[root expanded] ) {
        for(LocationTreeNode* each in [root children])
            [LocationTreeNode getLocationNodes:each :array];
    }
    return;
}
+(void) childrenHidden:(LocationTreeNode *)root{
    if([root hasChildren] ) {
        for(LocationTreeNode* each in [root children])
            root.hidden = !root.hidden;
    }
    return;
}
+(BOOL)isChildToNode:(LocationTreeNode *)root :(LocationTreeNode *)child {
    for(LocationTreeNode* each in root.children) {
       if(each == child) return YES;
        if([each hasChildren]) {
            if([LocationTreeNode isChildToNode:each :child]) return YES;
            else continue;
    }
    else
        continue;
    }
    return NO;
}

@end
