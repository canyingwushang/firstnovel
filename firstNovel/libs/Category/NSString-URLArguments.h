//
//  NSString-URLArguments.h
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 12-5-12.
//  Copyright (c) 2012年 baidu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// Utilities for encoding and decoding URL arguments.
@interface NSString (NSStringURLArgumentsAdditions)

// Returns a string that is escaped properly to be a URL argument.
//
// This differs from stringByAddingPercentEscapesUsingEncoding: in that it
// will escape all the reserved characters (per RFC 3986
// <http://www.ietf.org/rfc/rfc3986.txt>) which
// stringByAddingPercentEscapesUsingEncoding would leave.
//
// This will also escape '%', so this should not be used on a string that has
// already been escaped unless double-escaping is the desired result.
- (NSString*)stringByEscapingForURLArgument;

// Returns the unescaped version of a URL argument
//
// This has the same behavior as stringByReplacingPercentEscapesUsingEncoding:,
// except that it will also convert '+' to space.
- (NSString*)stringByUnescapingFromURLArgument;

@end
