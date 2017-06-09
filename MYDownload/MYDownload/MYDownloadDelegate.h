//
//  MYDownloadDelegate.h
//  MYDownload
//
//  Created by ifly on 2017/6/8.
//  Copyright © 2017年 Meiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYHttpRequest.h"

@protocol MYDownloadDelegate <NSObject>

@optional
- (void)startDownload:(MYHttpRequest *)request;
- (void)updateCellProgress:(MYHttpRequest *)request;
- (void)finishedDownload:(MYHttpRequest *)request;

// 处理一个窗口内联系下载多个文件且重复下载的情况
- (void)allowNextRequest;
@end
