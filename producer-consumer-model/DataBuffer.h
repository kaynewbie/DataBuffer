//
//  DataBuffer.h
//  test-NSOperation
//
//  Created by Kai on 2021/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DataBufferDelegate <NSObject>

/// 向消费者传递缓冲区数据，主线程调用
/// @param data 待处理数据
- (void)dataBufferReceiveNewData:(NSArray *)data;

@end

@interface DataBuffer : NSObject

/// 消费者当前是否可处理数据，YES：可以，NO：不可
/// NO时，DataBuffer 不会回调 dataBufferReceiveNewData: 方法
@property (atomic, assign) BOOL readable;

/// 数据消费者
- (instancetype)initWithConsumer:(id<DataBufferDelegate>)Consumer;

/// 数据存到缓冲区，子线程操作
- (void)writeDataIntoBuffer:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END
