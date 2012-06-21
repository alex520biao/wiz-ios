//
//  WizAccountDdateBase.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountDataBase.h"
#import "WizFileManager.h"
@interface WizAccountDataBase()

@property (readonly, retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation WizAccountDataBase
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WizModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSString* path = [WizFileManager documentsPath];
    path = [path stringByAppendingPathComponent:@"ddd.db"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"accounts.sqlite"];
    NSLog(@"%@  %@",storeURL,[[WizFileManager shareManager] accountsDbPath]);
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

- (WizAccount*) accountFromDataBaseById:(NSString*)userId
{
    NSFetchRequest* fectchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WizAccount"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
    [fectchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:fectchRequest error:&error];
    if (error) {
        [WizGlobals reportError:error];
        return nil;
    }
    return [result objectAtIndex:0];
}

- (BOOL) isAccountExist:(NSString*)userId
{
    WizAccount* account = [self accountFromDataBaseById:userId];
    if (account) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void) updateWizAccount:(WizAccount*)account
{
    WizAccount* exist = [self accountFromDataBaseById:account.userId];
    if (!exist) {
        exist = [NSEntityDescription insertNewObjectForEntityForName:@"WizAccount" inManagedObjectContext:self.managedObjectContext];
    }
    exist.userId = account.userId;
    exist.password = account.password;
    
}

@end
