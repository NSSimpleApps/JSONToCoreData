//
//  CoreDataManager.h
//  JSONToCoreData
//
//  Created by NSSimpleApps on 20.11.15.
//  Copyright © 2015 NSSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface CoreDataManager : NSObject

+ (instancetype)sharedManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end
