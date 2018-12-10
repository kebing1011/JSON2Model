//
//  MISFileWriter.m
//  JSON2Model
//
//  Created by Mao on 2018/12/7.
//  Copyright © 2018 mao. All rights reserved.
//

#import "MISFileWriter.h"

@interface MISFileWriter()
@property (nonatomic, strong) NSMutableString* bufferString;
@property (nonatomic, copy) NSString* classPrefix;
@property (nonatomic, copy) NSString* className;
@property (nonatomic, copy) NSString* outputPath;
@end

@implementation MISFileWriter

+ (MISFileWriter *) writerWithClassPrefix:(NSString *)classPrefix
								className:(NSString *)className
							   outputPath:(NSString *)outputPath {
	MISFileWriter* writer = MISFileWriter.new;
	writer.classPrefix = classPrefix;
	writer.className = [classPrefix stringByAppendingString:className];
	writer.outputPath = outputPath;
	writer.bufferString = NSMutableString.string;
	return writer;
}

- (void)writeHeaderFileHeader {
	NSString* fmt = @"//\n//  %@.h\n//  JSON2Model\n//\n//  Created by Mao on 2018/12/7.\n//  Copyright © 2018 mao. All rights reserved.\n";
	[self.bufferString appendFormat:fmt, self.className];
}
- (void)writeSourceFileHeader {
	NSString* fmt = @"//\n//  %@.m\n//  JSON2Model\n//\n//  Created by Mao on 2018/12/7.\n//  Copyright © 2018 mao. All rights reserved.\n";
	[self.bufferString appendFormat:fmt, self.className];
}

- (void)writeFoundationImport {
	[self.bufferString appendString:@"#import <Foundation/Foundation.h>\n"];
}

- (void)writeSelfImport{
	[self.bufferString appendFormat:@"#import \"%@.h\"\n", self.className];
}

- (void)writeLine {
	[self.bufferString appendString:@"\n"];
}
- (void)writeEnd {
	[self.bufferString appendString:@"@end\n"];
}
- (void)writeInterface {
	[self.bufferString appendFormat:@"@interface %@ : NSObject\n", self.className];
}
- (void)writePrivateInterface {
	[self.bufferString appendFormat:@"@interface %@()\n", self.className];
}
- (void)writeImplementation {
	[self.bufferString appendFormat:@"@implementation %@\n", self.className];
}

- (void)writePropertyStrong {
	[self.bufferString appendString:@"@property (nonatomic, strong) "];
}
- (void)writePropertyCopy {
	[self.bufferString appendString:@"@property (nonatomic, copy) "];
}
- (void)writePropertyAssign {
	[self.bufferString appendString:@"@property (nonatomic, assign) "];
}

- (void)writePropertyStrongReadonly {
	[self.bufferString appendString:@"@property (nonatomic, strong, readonly) "];
}

- (void)writePropertyCopyReadonly {
	[self.bufferString appendString:@"@property (nonatomic, copy, readonly) "];
}

- (void)writePropertyAssignReadonly {
	[self.bufferString appendString:@"@property (nonatomic, assign, readonly) "];
}


- (void)writeNSStringWithName:(NSString *)name {
	[self.bufferString appendFormat:@"NSString *%@;\n", name];
}
- (void)writeNSArrayWithName:(NSString *)name
				templateName:(NSString *)templateName {
	if (templateName.length > 0) {
		[self.bufferString appendFormat:@"NSArray<%@ *> *%@;\n", templateName, name];
	}else {
		[self.bufferString appendFormat:@"NSArray *%@;\n", name];
	}
}
- (void)writeIntegerWithName:(NSString *)name {
	[self.bufferString appendFormat:@"NSInteger %@;\n", name];
}

- (void)writeYYModelContainerPropertyGenericClassLine {
	[self.bufferString appendString:@"+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {\n"];
}

- (void)writeYYModelCustomPropertyMapper {
	[self.bufferString appendString:@"+ (NSDictionary *)modelCustomPropertyMapper {\n"];
}

- (void)writeReturnAtParentheses {
	[self.bufferString appendString:@"    return @{\n"];
}

- (void)writeDictLineWithKey:(NSString *)key value:(NSString *)value {
	[self.bufferString appendFormat:@"             @\"%@\" : \"%@\",\n", key, value];
}

- (void)writeEndParentheses {
	[self.bufferString appendFormat:@"             }\n;"];
}


//+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
//	return @{
//			 @"inspectContentModel" : MISInspectTemplateItemContent.class
//			 };
//}
//
//+ (NSDictionary *)modelCustomPropertyMapper {
//	return @{
//			 @"desc"      : @"description",
//			 @"contentId" : @"id"
//			 };
//}


- (void)finishOutputToHeaderFile {
	NSString* filePath = [self.outputPath stringByAppendingPathComponent:[self.className stringByAppendingString:@".h"]];
	[self.bufferString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)finishOutputToSourceFile {
	NSString* filePath = [self.outputPath stringByAppendingPathComponent:[self.className stringByAppendingString:@".m"]];
	[self.bufferString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
