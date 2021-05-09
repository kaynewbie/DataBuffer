//
//  ViewController.m
//  producer-consumer-model
//
//  Created by Kai on 2021/5/9.
//

#import "ViewController.h"
#import "DataBuffer.h"

@interface ViewController () <DataBufferDelegate>
@property (nonatomic, strong) DataBuffer *buffer;
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableArray array];
    
    self.buffer = [[DataBuffer alloc] initWithConsumer:self];
    self.buffer.readable = YES;
    
    [self startWriteMessage];
}

- (void)startWriteMessage {
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    dispatch_async(q, ^{
        while (1) {
            [self.buffer writeDataIntoBuffer:@[@1]];
            sleep(0.1);
        }
        
    });
}

- (void)dataBufferReceiveNewData:(NSArray *)data {
    [self.data addObjectsFromArray:data];
    NSLog(@"%@, self.data.count=%ld", NSStringFromSelector(_cmd), self.data.count);
}

@end
