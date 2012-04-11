//
//  Cocoa XML-RPC Client Framework
//  XMLRPCConnection.m
//
//  Created by Eric J. Czarny on Thu Jan 15 2004.
//  Copyright (c) 2004 Divisible by Zero.
//

//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without 
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "XMLRPCResponse.h"
#import "GDataXMLNode.h"

#import "XMLRPCExtensions.h"

#import "WizGlobals.h"
#import "WizFileManager.h"

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end


static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;
{
    if (string == nil)
        return [NSData data];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
	
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64Encoding;
{
    if ([self length] == 0)
        return @"";
	
    char *characters = malloc((([self length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [self length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [self length])
            buffer[bufferLength++] = ((char *)[self bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';    
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

@end


@implementation XMLRPCResponse


@synthesize object;
@synthesize fault;
@synthesize parseError;


-(id) reportParserError
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Parse Error. XML-RPC responsed.", NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:@"come.effigent.iphone.parseerror" code:-1 userInfo:usrInfo] ;
}


-(id) reportCallError: (NSString*)msg
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:WizErrorDomin code:-1 userInfo:usrInfo];
}


-(id) decodeStructNode: (GDataXMLNode*) nodeStruct
{
	NSMutableDictionary* ret = [NSMutableDictionary dictionary];
	//
	NSArray* children = [nodeStruct children];
	//
	for (int i = 0; i < [children count]; i++)
	{
		GDataXMLNode* nodeMember = [children objectAtIndex:i];
		NSString* childNodeNname = [nodeMember name];
		if (![childNodeNname isEqualToString:@"member"])
			return [self reportParserError];
		//
		GDataXMLNode* nodeName = [nodeMember childAtIndex:0];
		if (!nodeName)
			return [self reportParserError];
		GDataXMLNode* nodeValue = [nodeMember childAtIndex:1];
		if (!nodeValue)
			return [self reportParserError];
		//
		id value = [self decodeValueNode: nodeValue];
		if ([value isKindOfClass: [NSError class]])
			return value;
		//
		NSString* memberName = [nodeName stringValue];
		//
		[ret setValue:value forKey:memberName];
	}
	//
	return ret;
}

-(id) decodeArrayNode: (GDataXMLNode*) nodeArray
{
	GDataXMLNode* nodeData = [nodeArray childAtIndex:0];
	if (!nodeData)
	{
		return [self reportParserError];
	}
	//
	NSMutableArray* ret = [NSMutableArray array];
	//
	NSArray* children = [nodeData children];
	//
	for (int i = 0; i < [children count]; i++)
	{
		GDataXMLNode* nodeValue = [children objectAtIndex:i];
		NSString* childNodeNname = [nodeValue name];
		if (![childNodeNname isEqualToString:@"value"])
			return [self reportParserError];
		//
		id value = [self decodeValueNode: nodeValue];
		if ([value isKindOfClass: [NSError class]])
			 return value;
		//
		[ret addObject:value];
	}
	//
	return ret;
}


-(id) decodeValueNode: (GDataXMLNode*) nodeValue
{
	NSString* nodeName = [nodeValue name];
	if (![nodeName isEqualToString:@"value"])
	{
		return [self reportParserError];
	}
	//
	int childCount = [nodeValue childCount];
	if (0 == childCount)
	{
		return [nodeValue stringValue];
	}
	else if (childCount > 1)
	{
		return [self reportParserError];
	}
	//
	GDataXMLNode* nodeData = [nodeValue childAtIndex:0];
	if (!nodeData)
	{
		return [self reportParserError];
	}
	//
	if (GDataXMLTextKind == [nodeData kind] )
	{
		return [nodeData stringValue];
	}
	//
	NSString* valueType = [nodeData name];
	if ([valueType isEqualToString:@"string"])
	{
		return [nodeData stringValue];
	}
	else if ([valueType isEqualToString:@"int"]
			 || [valueType isEqualToString:@"i4"])
	{
		NSString* val = [nodeData stringValue];
		return [NSNumber numberWithInt: [val intValue]];
	}
	else if ([valueType isEqualToString:@"boolean"]
			 || [valueType isEqualToString:@"bool"])
	{
		NSString* val = [nodeData stringValue];
		BOOL b =  ([val isEqualToString:@"true"]
				  || [val isEqualToString:@"1"]) ? YES : NO;
		return [NSNumber numberWithBool:b];
	}
	else if ([valueType isEqualToString:@"double"])
	{
		NSString* val = [nodeData stringValue];
		return [NSNumber numberWithDouble: [val doubleValue]];
	}
	else if ([valueType isEqualToString:@"base64"])
	{
		NSString* val = [nodeData stringValue];
		return [NSData dataWithBase64EncodedString: val];
	}
	else if ([valueType isEqualToString:@"dateTime.iso8601"])
	{
		NSString* val = [nodeData stringValue];
		//
		NSString* sqlTime = [WizGlobals iso8601TimeToStringSqlTimeString:val];
		//
		NSDate* date = [WizGlobals sqlTimeStringToDate:sqlTime];
		//
		return date;
	}
	else if ([valueType isEqualToString:@"array"])
	{
		return [self decodeArrayNode: nodeData];
	}
	else if ([valueType isEqualToString:@"struct"])
	{
		return [self decodeStructNode: nodeData];
	}
	else if ([valueType isEqualToString:@"ex:i8"])
	{
		return [nodeData stringValue];
	}
	else if ([valueType isEqualToString:@"ex:nil"])
	{
		return nil;
	}
	else {
		return [self reportParserError];
	}
	//
	return [self reportParserError];
}

-(id) decodeXML: (NSData*) data fault: (BOOL*)pvbFault
{
	NSString* filename = [[WizFileManager wizAppPath] stringByAppendingPathComponent:@"xml-rpc-response.xml"];
	[data writeToFile:filename atomically:NO];
	//
	*pvbFault = NO;
	//
	NSString* str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	NSError* error;
	GDataXMLDocument* doc = [[[GDataXMLDocument alloc] initWithXMLString:str options:0 error:&error] autorelease];
	[str release];
	//
	
	GDataXMLElement* elem = [doc rootElement];
	//
	GDataXMLNode* nodeChild = [elem childAtIndex:0];
	if (!nodeChild)
	{
		return [self reportParserError];
	}
	NSString* childName = [nodeChild name];
	if ([childName isEqualToString:@"fault"])
	{
		*pvbFault = YES;
		//
		GDataXMLNode* nodeValue = [nodeChild childAtIndex:0];
		if (!nodeValue)
		{
			return [self reportParserError];
		}
		//
		NSDictionary* error = [self decodeValueNode: nodeValue];
		//
		NSString* msg = [error valueForKey:@"faultString"];
		//
		return [self reportCallError:msg];
	}
	else if ([childName isEqualToString:@"params"])
	{
		GDataXMLNode* nodeParam = [nodeChild childAtIndex:0];
		if (!nodeParam)
		{
			return [self reportParserError];
		}
		//
		GDataXMLNode* nodeValue = [nodeParam childAtIndex:0];
		if (!nodeValue)
		{
			return [self reportParserError];
		}
		//
		return [self decodeValueNode: nodeValue];
	}
	doc = nil;
	return nil;

}

- (id)initWithData: (NSData *)data
{
	if (self = [super init])
	{
		parseError = NO;
		fault = NO;
		//
		BOOL isFault = NO;
		//
		self.object = [self decodeXML:data fault:&isFault] ;
		//
		if( [self.object isKindOfClass:[NSError class]] )
		{
			parseError = TRUE;
		}
		//
		fault = isFault;
	}
	
	return self;
}

#pragma mark -

- (NSNumber *)faultCode
{
	if (self.fault)
	{
		return [self.object objectForKey: @"faultCode"];
	}
	
	return nil;
}

- (NSString *)faultString
{
	if (self.fault)
	{
		return [self.object objectForKey: @"faultString"];
	}
	
	return nil;
}


#pragma mark -

- (void)dealloc
{
	self.object = nil;
	
	[super dealloc];
}

@end