//
//  MYTool.m
//  MYDownload
//
//  Created by ifly on 2017/6/7.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "MYTool.h"

@implementation MYTool

// 检测http/https是否有效
+ (BOOL)checkUrlIsUserfulString:(NSString *)url {
    
    NSString *pattern = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *regexArray = [regex matchesInString:url options:0 range:NSMakeRange(0, url.length)];
    if (regexArray.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

// 检测对象是否有效
+ (BOOL)checkIeEmptyObjective:(id)objective {
    if (objective == nil || [objective isEqual:[NSNull null]] || [[NSString stringWithFormat:@"%@", objective] isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

// 编码文件名
+ (NSString *)encodeFileName:(NSString *)fileName {
    NSData *data = [fileName dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeFileName = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodeFileName;
}

// 解码文件名
+ (NSString *)decodeFileName:(NSString *)fileName {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:fileName options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeFileName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return decodeFileName;
}















@end
