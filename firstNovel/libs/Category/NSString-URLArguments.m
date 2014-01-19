//
//  NSString-URLArguments.m
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 12-5-12.
//  Copyright (c) 2012年 baidu.com. All rights reserved.
//

#import "NSString-URLArguments.h"

@implementation NSString (NSStringURLArgumentsAdditions)

// Encode all the reserved characters, per RFC 3986 (<http://www.ietf.org/rfc/rfc3986.txt>)
- (NSString*)stringByEscapingForURLArgument 
{
	NSString *newString = 
		[NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																   								(CFStringRef)self, 
																   								NULL, 
																   								CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
																   								kCFStringEncodingUTF8)) autorelease];
	if (newString) 
	{
		return newString;
	}
	return @"";
}

- (NSString*)stringByUnescapingFromURLArgument 
{
  NSMutableString *resultString = [NSMutableString stringWithString:self];
  [resultString replaceOccurrencesOfString:@"+"
                                withString:@" "
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [resultString length])];
  return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end // NSString (NSStringURLArgumentsAdditions)

