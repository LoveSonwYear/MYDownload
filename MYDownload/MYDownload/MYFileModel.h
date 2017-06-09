//
//  MYFileModel.h
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MYDownLoadState) {
    // 等待下载
    MYDownLoadState_Loading  = 0,
    // 正在下载
    MYDownLoadstate_Downing  = 1,
    // 停止下载
    MYDownLoadState_Stoping  = 2,
};


@interface MYFileModel : NSObject

/**文件名*/
@property (nonatomic, copy  ) NSString *fileName;
/**文件总长度*/
@property (nonatomic, copy  ) NSString *fileSize;
/**文件类型*/
@property (nonatomic, copy  ) NSString *fileType;
/**是否第一次下载数据 是继续下载 不是重新下载*/
@property (nonatomic, assign) BOOL isFirstReceived;
/**文件已下载长度*/
@property (nonatomic, copy  ) NSString *fileReceivedSize;
/**已下载的数据*/
@property (nonatomic, strong) NSMutableData *fileReceivedData;
/**下载文件的URL*/
@property (nonatomic, copy  ) NSString *fileUrl;
/**下载时间*/
@property (nonatomic, copy  ) NSString *time;
/**临时文件路径*/
@property (nonatomic, copy  ) NSString *tempPath;
/**下载速度*/
@property (nonatomic, copy  ) NSString *speed;
/**开始下载时间*/
@property (nonatomic, strong) NSDate *startTime;
/**剩余下载时间*/
@property (nonatomic, copy  ) NSString *remainingTiem;

/**
 * 当超过最大下载数时 继续添加下载任务会进入等待状态
 * 当同时下载数少于最大下载数时会自动开始下载处于等待状态的任务
 * 可以主动切换下载状态
 * 所有任务以添加时间排序
 */
// 下载状态
@property (nonatomic, assign) MYDownLoadState downloadState;
// 下载是否出错
@property (nonatomic, assign) BOOL error;
// md5 加密
@property (nonatomic, copy  ) NSString *MD5;
// 文件的附属照片
@property (nonatomic, strong) UIImage *fileImage;


@end
