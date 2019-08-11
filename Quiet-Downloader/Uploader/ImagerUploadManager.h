//
//  ImagerUploadManager.h
//  Quiet-Downloader
//
//  Created by GeekDuan on 2019/8/8.
//  Copyright © 2019 GeekDuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCheckHelper.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN
// 数据库
/*
 Message:
 id: stirng
 owener_id: string
 media_ids: string
 create_at: string
 success: bool
 
 Media:
 id: string
 image: data
 type: number
 name: string
 success: bool
 
 流程:
 1. 查询某一条 message 所有 media 的状态
 2. 创建队列，循环上传，完成回调
 3. post 自己服务器
 4. 删除 message media 中的内容
 
 多任务的支持
 每一条 message 就是一个任务
 app启动检测
 网络切换检测
 */

@interface ImagerUploadManager : NSObject
+ (void)commitMessageCallback:(void (^)(NSDictionary *))callback;
+ (void)serverRun;
@end

NS_ASSUME_NONNULL_END
