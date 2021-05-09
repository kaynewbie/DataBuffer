//
//  DataBuffer.m
//  test-NSOperation
//
//  Created by Kai on 2021/5/9.
//

#import "DataBuffer.h"
#import <pthread.h>


@interface DataBuffer ()
@property (nonatomic, weak) id<DataBufferDelegate> consumer;
@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, assign) pthread_cond_t condition;
@end

@implementation DataBuffer

/// 数据消费者
- (instancetype)initWithConsumer:(id<DataBufferDelegate>)consumer {
    if (self = [super init]) {
        _consumer = consumer;
        _data = [NSMutableArray array];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        pthread_mutex_init(&_lock, NULL);
        pthread_cond_init(&_condition, NULL);
        
        [NSThread detachNewThreadSelector:@selector(readDataFromBuffer) toTarget:self withObject:nil];
    }
    return self;
}

/// 数据存到缓冲区，子线程操作
- (void)writeDataIntoBuffer:(NSArray *)data {
    if (data.count == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    /// 这样不行，因为 blockOperation 是同步的
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        typeof(self) self = weakSelf;
        pthread_mutex_lock(&self->_lock);
        
        NSLog(@"writeDataIntoBuffer, thread=%@", [NSThread currentThread]);
        [self.data addObjectsFromArray:data];
        
        pthread_cond_signal(&self->_condition);
        pthread_mutex_unlock(&self->_lock);
    }];
    [self.operationQueue addOperation:op];
}

/// 启动子线程，循环读取缓冲数据
- (void)readDataFromBuffer {
    while (1)
    {
        pthread_mutex_lock(&self->_lock);
        /// 缓冲区内没有数据，等待写入
        while (self.data.count == 0)
        {
            pthread_cond_wait(&self->_condition, &self->_lock);
        }
        /// 如果有数据，则需要判断消费者是否已经能开始消费数据
        if (self.readable && [self.consumer respondsToSelector:@selector(dataBufferReceiveNewData:)]) {
            NSArray *tmp = [self.data copy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.consumer dataBufferReceiveNewData:tmp];
            });
            
            NSLog(@"%@, thread=%@, data=%ld", NSStringFromSelector(_cmd), [NSThread currentThread], tmp.count);
            
            [self.data removeAllObjects];
        }
        
        pthread_mutex_unlock(&self->_lock);
    }
}

@end
