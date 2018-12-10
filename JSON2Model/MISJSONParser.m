//
//  MISJSONParser.m
//  JSON2Model
//
//  Created by Mao on 2018/12/7.
//  Copyright © 2018 mao. All rights reserved.
//

#import "MISJSONParser.h"
#import "MISFileWriter.h"

@interface MISJSONParser()
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, copy) NSString* classPrefix;
@property (nonatomic, copy) NSString* rootClassName;
@property (nonatomic, copy) NSString* outputPath;
@property (nonatomic, copy) NSDictionary* JSONObject;
@end

@implementation MISJSONParser

+ (MISJSONParser *)parserWithJSONFilePath:(NSString *)filePath
							  classPrefix:(NSString *)classPrefix
							rootClassName:(NSString *)rootClassName
							   outputPath:(NSString *)outputPath {
	MISJSONParser* parse = MISJSONParser.new;
	parse.classPrefix = classPrefix;
	parse.filePath = filePath;
	parse.rootClassName = rootClassName;
	parse.outputPath = outputPath;
	return parse;
}

+ (MISJSONParser *)parserWithJSONObject:(NSDictionary *)JSONObject
							classPrefix:(NSString *)classPrefix
						  rootClassName:(NSString *)rootClassName
							 outputPath:(NSString *)outputPath {
	MISJSONParser* parse = MISJSONParser.new;
	parse.JSONObject = JSONObject;
	parse.classPrefix = classPrefix;
	parse.rootClassName = rootClassName;
	parse.outputPath = outputPath;
	return parse;
}


- (void)startParse {
	if (!self.JSONObject) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
			NSLog(@"** Error %@ is not exist. **", self.filePath);
			return;
		}
		NSData* data = [NSData dataWithContentsOfFile:self.filePath];
		if (data.length == 0) {
			NSLog(@"** Error %@ is empty file. **", self.filePath);
			return;
		}
		NSError* error = nil;
		NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
		if (dict == nil) {
			NSLog(@"** Error %@ is not a valid JSON file. **", self.filePath);
			return;
		}
		
		self.JSONObject = dict;
	}

	if (!self.JSONObject) {
		NSLog(@"** Error JSONObject is nil. **");
	}
	
	[self writeHeaderFile];
	[self writeSourceFile];
}

- (void)writeHeaderFile {
	MISFileWriter* writer = [MISFileWriter writerWithClassPrefix:self.classPrefix className:self.rootClassName outputPath:self.outputPath];
	//header comment
	[writer writeHeaderFileHeader];
	[writer writeLine];
	[writer writeFoundationImport];
	[writer writeLine];
	[writer writeInterface];
	[writer writeLine];

	//sort keys frist
	NSArray* keys = [self.JSONObject.allKeys sortedArrayUsingSelector:@selector(compare:)];
	
	for (NSString* originKey in keys) {
		id obj = self.JSONObject[originKey];
		NSString* key = originKey;
		//key works not use
		if ([originKey isEqualToString:@"id"]) {
			key = [self.rootClassName stringByAppendingString:@"Id"];
		}else if ([originKey isEqualToString:@"description"]) {
			key = @"desc";
		}
		if ([obj isKindOfClass:NSString.class] || [obj isKindOfClass:NSNull.class]) {
			[writer writePropertyCopyReadonly];
			[writer writeNSStringWithName:key];
		} else if ([obj isKindOfClass:NSArray.class]) {
			[writer writePropertyCopyReadonly];
			//array
			NSDictionary* subObj = [(NSArray *)obj firstObject];
			NSString* templateName = @"";
			if ([subObj isKindOfClass:NSDictionary.class]) {
				templateName = [self.classPrefix stringByAppendingString:key];
				
				//parse sub obj
				MISJSONParser* parser = [MISJSONParser parserWithJSONObject:subObj classPrefix:self.classPrefix rootClassName:key outputPath:self.outputPath];
				[parser startParse];
			}else if ([subObj isKindOfClass:NSString.class]) {
				templateName = @"NSString";
			}
			[writer writeNSArrayWithName:key templateName:templateName];
		} else if ([obj isKindOfClass:NSNumber.class]) {
			[writer writePropertyAssignReadonly];
			[writer writeIntegerWithName:key];
		}
	}
	
	[writer writeLine];
	[writer writeEnd];
	[writer finishOutputToHeaderFile];
}

- (void)writeSourceFile {
	MISFileWriter* writer = [MISFileWriter writerWithClassPrefix:self.classPrefix className:self.rootClassName outputPath:self.outputPath];
	//header comment
	[writer writeSourceFileHeader];
	[writer writeLine];
	[writer writeSelfImport];
	[writer writeLine];
	[writer writePrivateInterface];
	[writer writeLine];

	//sort keys frist
	NSArray* keys = [self.JSONObject.allKeys sortedArrayUsingSelector:@selector(compare:)];
	
	
	NSMutableDictionary* containerKeyValues = NSMutableDictionary.dictionary;
	NSMutableDictionary* maperKeyValues = NSMutableDictionary.dictionary;

	for (NSString* originKey in keys) {
		id obj = self.JSONObject[originKey];
		NSString* key = originKey;
		//key works not use
		if ([originKey isEqualToString:@"id"]) {
			key = [self.rootClassName stringByAppendingString:@"Id"];
			maperKeyValues[key] = originKey;
		}else if ([originKey isEqualToString:@"description"]) {
			key = @"desc";
			maperKeyValues[key] = originKey;
		}
		
		if ([obj isKindOfClass:NSString.class] || [obj isKindOfClass:NSNull.class]) {
			[writer writePropertyCopy];
			[writer writeNSStringWithName:key];
		} else if ([obj isKindOfClass:NSArray.class]) {
			[writer writePropertyCopy];
			//array
			NSDictionary* subObj = [(NSArray *)obj firstObject];
			NSString* templateName = @"";
			if ([subObj isKindOfClass:NSDictionary.class]) {
				templateName = [self.classPrefix stringByAppendingString:key];
				containerKeyValues[templateName] = [templateName stringByAppendingString:@".class"];
			}else if ([subObj isKindOfClass:NSString.class]) {
				templateName = @"NSString";
			}
			[writer writeNSArrayWithName:key templateName:templateName];
		} else if ([obj isKindOfClass:NSNumber.class]) {
			[writer writePropertyAssign];
			[writer writeIntegerWithName:key];
		}
	}
	
	[writer writeLine];
	[writer writeEnd];
	
	[writer writeLine];
	[writer writeImplementation];
	
	if (maperKeyValues.count > 0) {
		[writer writeLine];
		[writer writeYYModelCustomPropertyMapper];
		[writer writeReturnAtParentheses];
		NSArray* keys = [maperKeyValues.allKeys sortedArrayUsingSelector:@selector(compare:)];
		for (NSString* key in keys) {
			[writer writeDictLineWithKey:key value:maperKeyValues[key]];
		}
		[writer writeEndParentheses];
		[writer writeLine];
	}
	
	if (containerKeyValues.count > 0) {
		[writer writeLine];
		[writer writeYYModelContainerPropertyGenericClassLine];
		[writer writeReturnAtParentheses];
		NSArray* keys = [containerKeyValues.allKeys sortedArrayUsingSelector:@selector(compare:)];
		for (NSString* key in keys) {
			[writer writeDictLineWithKey:key value:containerKeyValues[key]];
		}
		[writer writeEndParentheses];
		[writer writeLine];
	}
	
	[writer writeLine];
	[writer writeEnd];

	[writer finishOutputToSourceFile];
}

@end
