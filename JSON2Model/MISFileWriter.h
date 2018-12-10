//
//  MISFileWriter.h
//  JSON2Model
//
//  Created by Mao on 2018/12/7.
//  Copyright © 2018 mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISFileWriter : NSObject

+ (MISFileWriter *) writerWithClassPrefix:(NSString *)classPrefix
								className:(NSString *)className
							   outputPath:(NSString *)outputPath;

- (void)writeHeaderFileHeader;
- (void)writeSourceFileHeader;
- (void)writeLine;
- (void)writeEnd;
- (void)writeInterface;
- (void)writePrivateInterface;
- (void)writeImplementation;
- (void)writeFoundationImport;
- (void)writeSelfImport;


- (void)finishOutputToHeaderFile;
- (void)finishOutputToSourceFile;


- (void)writePropertyStrong;
- (void)writePropertyCopy;
- (void)writePropertyAssign;

- (void)writePropertyStrongReadonly;
- (void)writePropertyCopyReadonly;
- (void)writePropertyAssignReadonly;


- (void)writeNSStringWithName:(NSString *)name;
- (void)writeNSArrayWithName:(NSString *)name
				templateName:(NSString *)templateName;
- (void)writeIntegerWithName:(NSString *)name;


- (void)writeYYModelContainerPropertyGenericClassLine;
- (void)writeYYModelCustomPropertyMapper;
- (void)writeReturnAtParentheses;
- (void)writeEndParentheses;
- (void)writeDictLineWithKey:(NSString *)key value:(NSString *)value;

@end
