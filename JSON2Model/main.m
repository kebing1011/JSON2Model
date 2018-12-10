//
//  main.m
//  JSON2Model
//
//  Created by Mao on 2018/12/7.
//  Copyright © 2018 mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MISJSONParser.h"
#include <getopt.h>


void showUsage(const char* cmd)
{
	printf("-------------------------------------------------------------\n");
	printf("json2oc \n");
	printf("JSON file Convert to Objective-C class files\n");
	printf("Author : Maokebing\n");
	printf("Version : 1.0\n");
	printf("-------------------------------------------------------------\n");
	printf("Usage:\n");
	printf("       json2oc [-fonp] [args]\n");
	printf("      -f [json file]\n");
	printf("      -o [output directory]\n");
	printf("      -n [root class name]\n");
	printf("      -p [class prefix]\n");
}

const char *short_opts = "f:o:n:p:";

int main(int argc, const char * argv[]) {
	
	//check args
	if (argc == 1) {
		showUsage(argv[0]);
		return 0;
	}
	
	
	char opt = 0;
	char *arg_output   = NULL;
	char *arg_file     = NULL;
	char *arg_name     = NULL;
	char *arg_prefix   = NULL;
	
	while((opt = getopt(argc, (char *const *)argv, short_opts))!= -1)
	{
		switch(opt)
		{
			case 'f':
				arg_file = optarg;
				break;
			case 'o':
				arg_output = optarg;
				break;
			case 'n':
				arg_name = optarg;
				break;
			case 'p':
				arg_prefix = optarg;
				break;
		}
	}
	
	//must args not null
	if (arg_file == NULL) {
		showUsage(argv[0]);
		return 0;
	}
	
	
	@autoreleasepool {
		//json file
		NSString* filePath = [NSString stringWithUTF8String:arg_file];
		
		//class prefix
		NSString* classPrefix = @"";
		if (arg_prefix != NULL) {
			classPrefix = [NSString stringWithUTF8String:arg_prefix];
		}
		
		//output
		if (arg_output == NULL) {
			char buf[256];
			getcwd(buf,sizeof(buf));
			arg_output = buf;
		}
		
		NSString* outputPath = [NSString stringWithUTF8String:arg_output];
		
		//root class name
		NSString* className = @"Root";
		if (arg_name != NULL) {
			className = [NSString stringWithUTF8String:arg_name];
		}
		
		//start gen files
		MISJSONParser* parser = [MISJSONParser parserWithJSONFilePath:filePath
														  classPrefix:classPrefix
														rootClassName:className
														   outputPath:outputPath];
		[parser startParse];
	}
	return 0;
}
