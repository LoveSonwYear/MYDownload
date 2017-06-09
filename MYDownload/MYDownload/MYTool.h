//
//  MYTool.h
//  MYDownload
//
//  Created by ifly on 2017/6/7.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYTool : NSObject


/**
 检查是否有效的http或者https链接
 */
+ (BOOL)checkUrlIsUserfulString:(NSString *)url;


/**
 检查对象是否为空
 */
+ (BOOL)checkIeEmptyObjective:(id)objective;


/**
 编码文件名
 */
+ (NSString *)encodeFileName:(NSString *)fileName;


/**
 解码文件名
 */
+ (NSString *)decodeFileName:(NSString *)fileName;





@end
