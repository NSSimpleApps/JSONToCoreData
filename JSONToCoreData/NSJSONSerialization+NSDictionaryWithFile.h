//
//  NSJSONSerialization+NSDictionaryWithFile.h
//  JSONToCoreData
//
//  Created by NSSimpleApps on 06.02.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (NSDictionaryWithFile)

+ (NSDictionary*)dictionaryWithFile:(NSString*)pathForResource;

@end
