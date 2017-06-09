//
//  MYDownloadManager.h
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYCommonHelper.h"
#import "MYDownloadDelegate.h"
#import "MYFileModel.h"
#import "MYHttpRequest.h"


#define kMaxRequestCount @"kMaxRequestCount"

@interface MYDownloadManager : NSObject<MYHttpRequestDelegate>

/**
 获得下载事件的VC 用在比如多选图片后批量下载的情况 这时需要配合allowNextRequest 协议方法使用
 */
@property (nonatomic, weak) id<MYDownloadDelegate> vcDelegate;
/**
 下载列表delegate
 */
@property (nonatomic, weak) id<MYDownloadDelegate> downloadDelegate;
/**
 设置最大的并发下载个数
 */
@property (nonatomic, assign) NSInteger maxCount;
/**
 已下载完的文件列表(文件对象)
 */
@property (atomic, strong, readonly) NSMutableArray *finishedList;
/**
 正在下载的文件列表(ASIHttpRequest)
 */
@property (atomic, strong, readonly) NSMutableArray *downingList;
/**
 未下载完成的临时文件数组(文件对象)
 */
@property (atomic, strong, readonly) NSMutableArray *fileList;
/**
 下载文件模型
 */
@property (nonatomic, strong, readonly) MYFileModel *fileInfo;


/**
 单利
 */
+ (MYDownloadManager *)shareDownloadManager;

/**
 清楚所以下载完的文件
 */
- (void)claerAllRequest;

/**
 恢复下载
 */
- (void)resumeRequest:(MYHttpRequest *)request;

/**
 删除这个下载请求
 */
- (void)deleteRequest:(MYHttpRequest *)request;

/**
 停止这个下载请求
 */
- (void)stopRequest:(MYHttpRequest *)request;

/**
 保存下载完成的文件信息到plist
 */
- (void)saveFinishedFile;

/**
 删除某一个下载完成的文件
 */
- (void)deleteFinishFile:(MYFileModel *)selectFile;

/**
 下载视频时候调用
 */
- (void)downFileUrl:(NSString *)url fileName:(NSString *)name fileImage:(UIImage *)image;

/**
 开始任务
 */
- (void)startLoad;

/**
 全部开始 (超过最大下载个数 还是等待下载状态)
 */
- (void)startAllDownloads;

/**
 全部暂停
 */
- (void)pauseAllDownloads;


@end
