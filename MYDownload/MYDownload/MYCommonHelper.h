//
//  MYCommonHelper.h
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 下载文件总文件夹
#define BASE   @"MYDownLoad"
// 完整文件路劲
#define TARGET @"CacheList"
// 临时文件夹名称
#define TEMP   @"Temp"
// 缓存主目录
#define CACHES_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
// 临时文件夹路劲
#define TEMP_FOLDER      [NSString stringWithFormat:@"%@/%@/%@",CACHES_DIRECTORY,BASE,TEMP]
// 临时文件的路劲
#define TEMP_PATH(name)  [NSString stringWithFormat:@"%@/%@",[MYCommonHelper createFolder:TEMP_FOLDER],name]
// 下载文件夹路劲
#define FILE_FOLDER      [NSString stringWithFormat:@"%@/%@/%@",CACHES_DIRECTORY,BASE,TARGET]
// 下载文件路劲
#define FILE_PATH(name)  [NSString stringWithFormat:@"%@/%@",[MYCommonHelper createFolder:FILE_FOLDER],name]
// 文件信息的Plist路劲
#define PLIST_PATH       [NSString stringWithFormat:@"%@/%@/FinishedPlist.plist",CACHES_DIRECTORY,BASE]



@interface MYCommonHelper : NSObject

/**
 将文件大小转化成M单位或者B单位
 */
+ (NSString *)getFileSizeString:(NSString *)size;

/**
 将文件大小转化成不带单位的数字
 */
+ (float)getFileSizeNumber:(NSString *)size;

/**
 字符串格式转化日期
 */
+ (NSDate *)makeData:(NSString *)birthday;

/**
 日期格式转化字符串
 */
+ (NSString *)dateToString:(NSDate *)date;

/**
 检查文件名是否存在
 */
+ (BOOL)isExistFile:(NSString *)fileName;

/**
 创建文件路径
 */
+ (NSString *)createFolder:(NSString *)path;

+ (CGFloat)calculateFileSizeInUnit:(unsigned long long)contentLength;
+ (NSString *)calculateUnit:(unsigned long long)contentLength;


@end
