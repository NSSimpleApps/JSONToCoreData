//
//  State.h
//  JSONToCoreData
//
//  Created by NSSimpleApps on 10.02.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface State : NSManagedObject

@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSString * capital;
@property (nonatomic, retain) NSString * nameOfState;
@property (nonatomic, retain) NSNumber * population;

@end
