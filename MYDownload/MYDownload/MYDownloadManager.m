//
//  MYDownloadManager.m
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import "MYDownloadManager.h"

static MYDownloadManager *shareDownloadManager = nil;

@interface MYDownloadManager ()
// 本地临时文件夹文件的个数
@property (nonatomic, assign) NSInteger count;
// 已下载完成的文件列表(文件对象)
@property (strong) NSMutableArray *finishedList;
// 正在下载的文件列表(ASIHttpRequest对象)
@property (strong) NSMutableArray *downingList;
// 未下载完成的临时文件数组(文件对象)
@property (strong) NSMutableArray *fileList;
// 下载文件的模型
@property (nonatomic, strong) MYFileModel *fileInfo;
@end


@implementation MYDownloadManager

#pragma mark -- init methods
+ (MYDownloadManager *)shareDownloadManager {
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        shareDownloadManager = [[self alloc] init];
    });
    return shareDownloadManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *max = [userDefaults valueForKey:kMaxRequestCount];
        if (max == nil) {
            [userDefaults setObject:@"3" forKey:kMaxRequestCount];
            max = @"3";
        }
        [userDefaults synchronize];
        _maxCount     = [max integerValue];
        _fileList     = [NSMutableArray new];
        _downingList  = [NSMutableArray new];
        _finishedList = [NSMutableArray new];
        _count = 0;
        [self loadFinishedFiles];
        [self loadTempFile];
    }
    return self;
}


- (void)cleanLastInfo {
    for (MYHttpRequest *request in _downingList) {
        if ([request isExecuting]) {
            [request cancel];
        }
        [self saveFinishedFile];
        [_downingList removeAllObjects];
        [_finishedList removeAllObjects];
        [_fileList removeAllObjects];
    }
}

#pragma mark -- 创建一个下载任务
- (void)downFileUrl:(NSString *)url fileName:(NSString *)name fileImage:(UIImage *)image {
    // 如果是重新下载 则说明肯定该文件已经下载完了 或者有临时文件正在留着 所以检查一下这两个地方如果有则删除
    _fileInfo = [[MYFileModel alloc] init];
    if (!name) {
        name = [url lastPathComponent];
    }
    _fileInfo.fileName = name;
    _fileInfo.fileUrl  = url;
    NSDate *myDate = [NSDate date];
    _fileInfo.time = [MYCommonHelper dateToString:myDate];
    _fileInfo.fileType = [name pathExtension];
    _fileInfo.fileImage = image;
    _fileInfo.downloadState = MYDownLoadstate_Downing;
    _fileInfo.error = NO;
    _fileInfo.tempPath = TEMP_PATH(name);
    if ([MYCommonHelper isExistFile:FILE_PATH(name)]) {
        // 已经下载过
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"文件已下载,是否重新下载?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    // 存在于临时文件夹中
    NSString *tempFilePath = [TEMP_PATH(name) stringByAppendingString:@".plist"];
    if ([MYCommonHelper isExistFile:tempFilePath]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"文件已经在下载列表中,是否重新下载?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    // 若不存在文件和临时文件 则是新添加任务下载
    [self.fileList addObject:_fileInfo];
    // 开始下载
    [self startLoad];
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(allowNextRequest)]) {
        [self.vcDelegate allowNextRequest];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"文件成功添加到下载队列" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    return;
}

#pragma mark - 已完成的下载任务在这里处理
/**
 将本地已经下载完成的文件加载到已下载列表里
 */
- (void)loadFinishedFiles {
    if ([[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc] initWithContentsOfFile:PLIST_PATH];
        for (NSDictionary *dict in finishArr) {
            MYFileModel *file = [[MYFileModel alloc] init];
            file.fileName  = [dict objectForKey:@"fileName"];
            file.fileType  = [file.fileName pathExtension];
            file.fileSize  = [dict objectForKey:@"fileSize"];
            file.time      = [dict objectForKey:@"time"];
            file.fileImage = [UIImage imageWithData:[dict objectForKey:@"fileImage"]];
            [_finishedList addObject:file];
        }
    }
}

#pragma mark - 从这里获取上次未完成下载的信息
/**
 将本地未完成下载的临时文件加载到正在下载列表里 不重新下载
 */
- (void)loadTempFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:TEMP_FOLDER error:&error];
    if (!error) {
        NSLog(@"%@", [error description]);
    }
    NSMutableArray *fileArr = [[NSMutableArray alloc] init];
    for (NSString *file in fileList) {
        NSString *fileType = [file pathExtension];
        if ([fileType isEqualToString:@"plist"]) {
            [fileArr addObject:[self getTempFile:TEMP_PATH(file)]];
        }
    }
    NSArray *arr = [self sortbyTime:(NSArray *)fileArr];
    [_fileList addObjectsFromArray:arr];
    
    [self startLoad];
}


- (MYFileModel *)getTempFile:(NSString *)path {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    MYFileModel *file  = [[MYFileModel alloc] init];
    file.fileName      = [dict objectForKey:@"fileName"];
    file.fileType      = [file.fileName pathExtension];
    file.fileUrl       = [dict objectForKey:@"fileUrl"];
    file.fileSize      = [dict objectForKey:@"fileSize"];
    file.fileReceivedSize = [dict objectForKey:@"fileReceiveSize"];
    file.tempPath      = TEMP_PATH(file.fileName);
    file.time          = [dict objectForKey:@"time"];
    file.fileImage     = [UIImage imageWithData:[dict objectForKey:@"fileImage"]];
    file.downloadState = MYDownLoadState_Stoping;
    file.error         = NO;
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength = [fileData length];
    file.fileReceivedSize = [NSString stringWithFormat:@"%zd",receivedDataLength];
    return  file;
}


- (NSArray *)sortbyTime:(NSArray *)array {
    NSArray *soreteArr = [array sortedArrayUsingComparator:^NSComparisonResult(MYFileModel *  _Nonnull obj1, MYFileModel *  _Nonnull obj2) {
        NSDate *date1 = [MYCommonHelper makeData:obj1.time];
        NSDate *date2 = [MYCommonHelper makeData:obj2.time];
        if ([[date1 earlierDate:date2] isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([[date1 earlierDate:date2] isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
        
    }];
    return soreteArr;
}


#pragma mark -- 自动出来下载状态的算法
/**
 *下载状态逻辑 下载中 等待下载 停止下载
 *当超过最大下载数时 继续添加的自动进入等待下载状态 当同时下载数少于最大限制是等待下载会自动进入下载状态
 *所有任务以添加时间排序
 */

- (void)startLoad {
    NSInteger num = 0;
    NSInteger max = _maxCount;
    for (MYFileModel *file in _fileList) {
        if (!file.error) {
            if (file.downloadState == MYDownLoadstate_Downing) {
                if (num >= max) {
                    file.downloadState = MYDownLoadState_Loading;
                } else {
                    num ++;
                }
            }
        }
    }
    if (num < max) {
        for (MYFileModel *file in _fileList) {
            if (!file.error) {
                if (file.downloadState == MYDownLoadState_Loading) {
                    num++;
                    if (num > max) {
                        break;
                    }
                    file.downloadState = MYDownLoadState_Loading;
                }
            }
        }
    }
    for (MYFileModel *file in _fileList) {
        if (!file.error) {
            if (file.downloadState == MYDownLoadState_Loading) {
                [self beginRequest:file isBeginDwon:YES];
                file.startTime = [NSDate date];
            } else {
                [self beginRequest:file isBeginDwon:NO];
            }
        }
    }
    self.count = [_fileList count];
}

#pragma mark -- 下载开始
- (void)beginRequest:(MYFileModel *)fileInfo isBeginDwon:(BOOL)isBeginDwon {
    for (MYHttpRequest *tempRequest in self.downingList) {
        /**
         *注意这里判断是否是同一下载的方法 asihttpRequest有三种url: url, originalUrl, rediretUrl
         *经过实践 应该使用originalUrl 就是最先获得到的原下载地址
         */
        if ([[[tempRequest.url absoluteString] lastPathComponent] isEqualToString:[fileInfo.fileUrl lastPathComponent]]) {
            if ([tempRequest isExecuting] && isBeginDwon) {
                return;
            } else if ([tempRequest isExecuting] && !isBeginDwon) {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest cancel];
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            }
        }
    }
    [self saveDownloadFile:fileInfo];
    // 按获取的文件名获取临时文件大小 即已下载的大小
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *fileData = [fileManager contentsAtPath:fileInfo.tempPath];
    NSInteger receivedDataLength = [fileData length];
    fileInfo.fileReceivedSize = [NSString stringWithFormat:@"%zd",receivedDataLength];
    NSLog(@"start down:已经下载 %@",fileInfo.fileReceivedSize);
    MYHttpRequest *midRequest = [[MYHttpRequest alloc] initWithUrl:[NSURL URLWithString:fileInfo.fileUrl]];
    midRequest.downloadDestrnationPath = FILE_PATH(fileInfo.fileName);
    midRequest.temporaryFileDownloadPath = fileInfo.tempPath;
    midRequest.delegate = self;
    // 设置上下文的文件基本信息
    [midRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
    if (isBeginDwon) {
        [midRequest startAsynchronous];
    }
    // 如果文件重复下载或者暂停 继续 则把队列中的请求删除 重新添加
    BOOL exit = NO;
    for (MYHttpRequest *tempRequest in self.downingList) {
        if ([[[tempRequest.url absoluteString] lastPathComponent] isEqualToString:[fileInfo.fileUrl lastPathComponent]]) {
            [self.downingList replaceObjectAtIndex:[_downingList indexOfObject:tempRequest] withObject:midRequest];
            exit = YES;
            break;
        }
    }
    if (!exit) {
        [self.downingList addObject:midRequest];
    }
    [self.downloadDelegate updateCellProgress:midRequest];
}

#pragma mark -- 恢复下载
- (void)resumeRequest:(MYHttpRequest *)request {
    NSInteger max = _maxCount;
    MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    NSInteger downimgCount = 0;
    NSInteger indexMax     = -1;
    for (MYFileModel *file in _fileList) {
        if (file.downloadState == MYDownLoadstate_Downing) {
            downimgCount++;
            if (downimgCount == max) {
                indexMax = [_fileList indexOfObject:file];
            }
        }
    }
    // 此时下载中数目是否是最大 并获得最大的位置Index
    if (downimgCount == max) {
        MYFileModel *file = [_fileList objectAtIndex:indexMax];
        if (file.downloadState == MYDownLoadstate_Downing) {
            file.downloadState = MYDownLoadState_Loading;
        }
    }
    // 中止一个进程使其进入等待
    for (MYFileModel *file in _fileList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.downloadState = MYDownLoadstate_Downing;
            file.error = NO;
        }
    }
    // 重新开始下载
    [self startLoad];
}

#pragma mark -- 暂停下载
- (void)stopRequest:(MYHttpRequest *)request {
    NSInteger max = self.maxCount;
    if ([request isExecuting]) {
        [request cancel];
    }
    MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    for (MYFileModel *file in _fileList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.downloadState = MYDownLoadState_Stoping;
            break;
        }
    }
    NSInteger downingCount = 0;
    for (MYFileModel *file in _fileList) {
        if (file.downloadState == MYDownLoadstate_Downing) {
            downingCount++;
        }
    }
    if (downingCount < max) {
        for (MYFileModel *file in _fileList) {
            if (file.downloadState == MYDownLoadState_Loading) {
                file.downloadState = MYDownLoadstate_Downing;
                break;
            }
        }
    }
    [self startLoad];
}

#pragma mark -- 删除下载
- (void)deleteRequest:(MYHttpRequest *)request {
    BOOL isExecuting = NO;
    if ([request isExecuting]) {
        [request cancel];
        isExecuting = YES;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    MYFileModel *fileInfo = (MYFileModel *)[request.userInfo objectForKey:@"File"];
    NSString *path = fileInfo.tempPath;
    NSString *confogPath = [NSString stringWithFormat:@"%@.plist",path];
    [fileManager removeItemAtPath:path error:&error];
    [fileManager removeItemAtPath:confogPath error:&error];
    if (!error) {
        NSLog(@"%@", [error description]);
    }
    NSInteger delindex = -1;
    for (MYFileModel *file in _fileList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [_fileList indexOfObject:file];
            break;
        }
    }
    if (delindex != NSNotFound) {
        [_fileList removeObjectAtIndex:delindex];
    }
    [_downingList removeObject:request];
    if (isExecuting) {
        [self startLoad];
    }
    self.count = [_fileList count];
}


#pragma mark -- 可能的UI操作接口
- (void)clearAllFinished {
    [_finishedList removeAllObjects];
}

- (void)clearAllRequest {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for (MYHttpRequest *request in _downingList) {
        if ([request isExecuting]) {
            [request cancel];
        }
        MYFileModel *fileInfo = (MYFileModel *)[request.userInfo objectForKey:@"File"];
        NSString *path = fileInfo.tempPath;
        NSString *configPath = [NSString stringWithFormat:@"%@.plist",path];
        [fileManager removeItemAtPath:path error:&error];
        [fileManager removeItemAtPath:configPath error:&error];
        if (!error) {
            NSLog(@"%@",[error description]);
        }
    }
    [_downingList removeAllObjects];
    [_fileList removeAllObjects];
}


/**
 开始所有请求
 */
- (void)startAllDownloads {
    for (MYHttpRequest *request in _downingList) {
        if ([request isExecuting]) {
            [request cancel];
        }
        MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        fileInfo.downloadState = MYDownLoadstate_Downing;
    }
    [self startLoad];
}

/**
 暂停所有请求
 */
- (void)pauseAllDownloads {
    for (MYHttpRequest *request in _downingList) {
        if ([request isExecuting]) {
            [request cancel];
        }
        MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        fileInfo.downloadState = MYDownLoadState_Stoping;
    }
    [self startLoad];
}

#pragma mark -- 储存下载信息到一个Plist文件
- (void)saveDownloadFile:(MYFileModel *)fileInfo {
    NSData *imageData = UIImagePNGRepresentation(fileInfo.fileImage);
    NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:fileInfo.fileName,@"fileName",
                             fileInfo.fileUrl,@"fileUrl",
                             fileInfo.time,@"time",
                             fileInfo.fileSize,@"fileSize",
                             fileInfo.fileReceivedSize,@"fileReceiveSize",
                             imageData,@"fileImage",nil];
    NSString *plistPath = [fileInfo.tempPath stringByAppendingPathExtension:@"plist"];
    if (![fileDic writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}

- (void)saveFinishedFile {
    if (_finishedList == nil) {
        return;
    }
    NSMutableArray *finishInfo = [[NSMutableArray alloc] init];
    for (MYFileModel *fileInfo in _finishedList) {
        NSData *imageData = UIImagePNGRepresentation(fileInfo.fileImage);
        NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:fileInfo.fileName,@"fileName",
                                 fileInfo.time,@"time",
                                 fileInfo.fileSize,@"fileSize",
                                 imageData,@"fileImage", nil];
        [finishInfo addObject:fileDic];
    }
    if (![finishInfo writeToFile:PLIST_PATH atomically:YES]) {
        NSLog(@"Write Plist Fial");
    }
}

- (void)deleteFinishFile:(MYFileModel *)selectFile {
    [_finishedList removeObject:selectFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = FILE_PATH(selectFile.fileName);
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    [self saveFinishedFile];
}


#pragma mark -- ASIHttoRequest 回调委托
/**
 *请求错误 如果是等待超时 则继续下载
 */
- (void)requestFailed:(MYHttpRequest *)request {
    NSError *error = [request error];
    NSLog(@"ASIHttpRequest出错了 %@",error);
    if (error.code == 4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    fileInfo.downloadState = MYDownLoadState_Stoping;
    fileInfo.error = YES;
    for (MYFileModel *file in _finishedList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.downloadState = MYDownLoadState_Stoping;
            file.error = YES;
        }
    }
    [self.downloadDelegate updateCellProgress:request];
}

- (void)requestStarted:(MYHttpRequest *)request {
    NSLog(@"开始了");
}

- (void)request:(MYHttpRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    NSLog(@"收到回复了");
    
    MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    fileInfo.isFirstReceived = YES;
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];
    // 这个信息头 首次收到的为总大小 后来续传是收到的大小 肯定小于或者等于首次大小 则忽略
    if ([fileInfo.fileSize longLongValue] > [len longLongValue]) {
        return;
    }
    fileInfo.fileSize = [NSString stringWithFormat:@"%lld",[len longLongValue]];
    [self saveDownloadFile:fileInfo];
}

- (void)request:(MYHttpRequest *)request didReceiveBytes:(long long)bytes {
    MYFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived = NO;
        fileInfo.fileReceivedSize = [NSString stringWithFormat:@"%lld",bytes];
    } else if (!fileInfo.isFirstReceived) {
        fileInfo.fileReceivedSize = [NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue] + bytes];
    }
    NSUInteger receivedSize = [fileInfo.fileReceivedSize longLongValue];
    NSUInteger expectedSize = [fileInfo.fileSize longLongValue];
    // 每秒下载速度
    NSTimeInterval downloadTime = -1 * [fileInfo.startTime timeIntervalSinceNow];
    CGFloat speed = (CGFloat)receivedSize / (CGFloat)downloadTime;
    if (speed == 0) {
        return;
    }
    CGFloat speedSec = [MYCommonHelper calculateFileSizeInUnit:(unsigned long long)speed];
    NSString *unit   = [MYCommonHelper calculateUnit:(unsigned long long)speed];
    NSString *speedStr = [NSString stringWithFormat:@"%.2f%@/s",speedSec,unit];
    fileInfo.speed = speedStr;
    // 剩余下载时间
    NSMutableString *remainingTimeStr = [[NSMutableString alloc] init];
    NSUInteger remainingContentLength = expectedSize -receivedSize;
    CGFloat remainingTime = (CGFloat)(remainingContentLength / speed);
    NSInteger hours = remainingTime / 3600;
    NSInteger minutes = (remainingTime - hours * 3600) / 60;
    CGFloat seconds = remainingTime - hours * 3600 - minutes * 60;
    if (hours > 0) {
        [remainingTimeStr appendFormat:@"%zd小时",hours];
    }
    if (minutes > 0) {
        [remainingTimeStr appendFormat:@"%zd分",minutes];
    }
    if ( seconds > 0) {
        [remainingTimeStr appendFormat:@"%.f秒",seconds];
    }
    if ([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)]) {
        [self.downloadDelegate updateCellProgress:request];
    }
}

/**
 *将正在下载的文件请求ASIHttpRequest从队列中移除 并将其配置文件删除 然后想已下载列表里添加该文件对象
 */
- (void)requestFinished:(MYHttpRequest *)request {
    
    
    
    
}












@end
