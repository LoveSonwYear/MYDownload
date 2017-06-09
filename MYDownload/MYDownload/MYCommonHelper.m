//
//  MYCommonHelper.m
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "MYCommonHelper.h"

@implementation MYCommonHelper

// 转换文件大小单位M/KB
+ (NSString *)getFileSizeString:(NSString *)size {
    if ([size floatValue] >= 1024 * 1024) {
        // 大于1M 转换成M单位字符串
        return [NSString stringWithFormat:@"%1.2fM", [size floatValue] / 1024 / 1024];
    } else if ([size floatValue] >= 1024 && [size floatValue] < 1024 * 1024) {
        // 不到1M 但超过了1KB 转化成KB单位字符串
        return [NSString stringWithFormat:@"%1.2fK", [size floatValue] / 1024];
    } else {
        // 剩下的都是小于1K的 则转化成B单位
        return [NSString stringWithFormat:@"%1.2fB", [size floatValue]];
    }
}

// 将文件大小转化成不带单位的数字
+ (float)getFileSizeNumber:(NSString *)size {
    NSInteger indexM = [size rangeOfString:@"M"].location;
    NSInteger indexK = [size rangeOfString:@"K"].location;
    NSInteger indexB = [size rangeOfString:@"B"].location;
    if (indexM != NSNotFound) { // 是M单位字符串
        float m = [[size substringToIndex:indexM] floatValue] * 1024 * 1024;
        if (indexK != NSNotFound) { // 是K单位的字符串
            float k = [[size substringWithRange:NSMakeRange(indexM + 1, indexK - indexM - 1)] floatValue] * 1024;
            if (indexB != NSNotFound) { // 是B单位的字符串
                float b = [[size substringWithRange:NSMakeRange(indexK + 1, indexB - indexK - 1)] floatValue];
                return m + k + b;
            } else {
                return m + k;
            }
        } else {
            if (indexB != NSNotFound) {
                float b = [[size substringWithRange:NSMakeRange(indexK + 1, indexB - indexK - 1)] floatValue];
                return m + b;
            } else {
                return m;
            }
        }
    } else { // 没有任何单位的数字字符串
        return [size floatValue];
    }
}

// 字符串格式化日期
+ (NSDate *)makeData:(NSString *)birthday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:birthday];
    return date;
}

// 日期格式化字符串
+ (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

// 检查文件名是否存在
+ (BOOL)isExistFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

// 创建文件目录
+ (NSString *)createFolder:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            NSLog(@"%@",[error description]);
        }
    }
    return path;
}


+ (CGFloat)calculateFileSizeInUnit:(unsigned long long)contentLength {
    if (contentLength >= pow(1024, 3)) {
        return (CGFloat)(contentLength / (CGFloat)pow(1024, 3));
    } else if (contentLength >= pow(1024, 2)) {
        return (CGFloat)(contentLength / (CGFloat)pow(1024, 2));
    } else if (contentLength >= 1024) {
        return (CGFloat)(contentLength / (CGFloat)1024);
    } else {
        return (CGFloat)(contentLength);
    }
}

+ (NSString *)calculateUnit:(unsigned long long)contentLength {
    if (contentLength >= pow(1024, 3)) {
        return @"GB";
    } else if (contentLength >= pow(1024, 2)) {
        return @"MB";
    } else if (contentLength >= 1023) {
        return @"KB";
    } else {
        return @"B";
    }
}






@end
