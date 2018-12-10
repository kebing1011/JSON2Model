//
//  MISJSONParser.h
//  JSON2Model
//
//  Created by Mao on 2018/12/7.
//  Copyright © 2018 mao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISJSONParser : NSObject

+ (MISJSONParser *)parserWithJSONFilePath:(NSString *)filePath
							  classPrefix:(NSString *)classPrefix
							rootClassName:(NSString *)rootClassName
							   outputPath:(NSString *)outputPath;

+ (MISJSONParser *)parserWithJSONObject:(NSDictionary *)JSONObject
							classPrefix:(NSString *)classPrefix
						  rootClassName:(NSString *)rootClassName
							 outputPath:(NSString *)outputPath;

- (void)startParse;

@end
