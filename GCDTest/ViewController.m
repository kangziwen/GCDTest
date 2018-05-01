//
//  ViewController.m
//  GCDTest
//
//  Created by 康子文 on 2018/4/29.
//  Copyright © 2018年 康子文. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self serialOrConcurrentQueue];
//    [self MianOrGlobalDispatchQueue];
//    [self setTargetQueue];
//    [self disptachGroup];
//    [self dispatchBarrier];
//    [self dispatchSync];
//    [self dispatchApply];
//    [self dispatchSemaphore];
    [self dispatchSource];
}
#pragma mark  并行队列与串行队列
-(void)serialOrConcurrentQueue{
    #pragma mark 串行 一个serial队列，只开启一个线程,多个serial队列，就会开多个线程
    dispatch_queue_t serial =  dispatch_queue_create("com.kzw.serial", NULL);
    dispatch_block_t blc1 =^{
        ;
        NSLog(@"serial  1 %@",[NSThread currentThread]);

        NSLog(@"serial  1 before....");
        sleep(1);
        NSLog(@"serial  1 after....");
    };
    dispatch_block_t blc2 = ^{
        NSLog(@"serial  2 ....");
        NSLog(@"serial  2 %@",[NSThread currentThread]);

    };
   #pragma mark blc1 blc2 串行执行
    dispatch_async(serial,blc1);
    dispatch_async(serial,blc2);
    #pragma mark serial与 serial1 并行执行
    dispatch_queue_t serial1 =  dispatch_queue_create("com.kzw.serial", NULL);
    dispatch_block_t blc11 =^{
        NSLog(@"serial  11 %@",[NSThread currentThread]);

        NSLog(@"serial  11 before....");
        sleep(1);
        NSLog(@"serial  11 after....");
    };
    dispatch_block_t blc12 = ^{
        NSLog(@"serial  12 ....");
    };
    dispatch_async(serial1,blc11);
    dispatch_async(serial1,blc12);
#pragma mark 并行队列 DISPATCH_QUEUE_CONCURRENT 添加几个block就有几个线程
    dispatch_queue_t concurren = dispatch_queue_create("com.kzw.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurren, ^{
        NSLog(@"concurren  1 %@",[NSThread currentThread]);

        NSLog(@"concurren  1 before ....");
        sleep(1);
        NSLog(@"concurren  1 after ....");

    });
    dispatch_async(concurren, ^{
        NSLog(@"concurren  2 %@",[NSThread currentThread]);
        NSLog(@"concurren  2 ....");

    });
    //释放队列，ARC不能自动释放队列 ，不过现在已经自动释放了
//    dispatch_release(serial);
//    dispatch_release(serial1);
//    dispatch_release(concurren);

}

#pragma mark Mian Dispatch Queue 与 Global Dispatch Queue
-(void)MianOrGlobalDispatchQueue{
//    [self performSelectorOnMainThread:<#(nonnull SEL)#> withObject:<#(nullable id)#> waitUntilDone:<#(BOOL)#>]; 与  Mian Dispatch Queue 相同
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t globalDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t globalLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_queue_t globalBackgroud = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_queue_t globalHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(mainQueue, ^{
        NSLog(@"mainQueue %@",[NSThread currentThread]);
    });
    dispatch_async(globalDefault, ^{
        NSLog(@"globalDefault %@",[NSThread currentThread]);
    });
    dispatch_async(globalLow, ^{
        NSLog(@"globalLow %@",[NSThread currentThread]);
    });
    dispatch_async(globalBackgroud, ^{
        NSLog(@"globalBackgroud %@",[NSThread currentThread]);
    });
    dispatch_async(globalHigh, ^{
        NSLog(@"globalHigh %@",[NSThread currentThread]);
    });
    
}
#pragma mark  disppatch_queue_create生成的queue（serial或concurent）都与默认优先级Global queue 优先级相同，set_target 切换优先级 main与global 设置优先级结果是未知的
-(void)setTargetQueue{
    //1 修改优先级
    dispatch_queue_t serialQueue = dispatch_queue_create("com.kzw.priority.serial", NULL);
    dispatch_queue_t globalHight = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //
    dispatch_set_target_queue(serialQueue, globalHight);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_get_main_queue....");
    });
    // serialQueue 优先于dispatch_get_main_queue执行
    dispatch_async(serialQueue, ^{
        NSLog(@"PRIORITY_HIG serialQueue before....");
        sleep(1);
        NSLog(@"PRIORITY_HIG serialQueue after....");
    });

#pragma mark 2 并行执行的serial queue 变串行执行queue ，并行队列变串行队列
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.kzw.priority.serial2", NULL);
      dispatch_queue_t serial3=dispatch_queue_create("com.kzw.priority.serial3", NULL);
    dispatch_queue_t serial4=dispatch_queue_create("com.kzw.priority.serial4", NULL);
    dispatch_set_target_queue(serialQueue2, serial4);
    dispatch_set_target_queue(serial3, serial4);

    dispatch_async(serialQueue2, ^{
        NSLog(@" serialQueue2 before....");
        sleep(1);
        NSLog(@" serialQueue2 after....");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@" serialQueue2 async2 before....");
        sleep(1);
        NSLog(@" serialQueue2  async2 after....");
    });
    dispatch_async(serial3, ^{
        NSLog(@" serial3 before....");
        sleep(1);
        NSLog(@" serial3 after....");
    });
    dispatch_async(serial3, ^{
        NSLog(@" serial3 async2 before....");
        sleep(1);
        NSLog(@" serial3  async2 after....");
    });
}

#pragma mark dispatch_after
-(void)dispatchAfter{
    //大致3秒后执行，不精确 与3秒后 用async函数追加到block到main queue相同
    //dispatch_time 计算相对值 dispatch_walltime计算绝对的值，某个具体时间
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"3 sencond ...");
    });
}
static dispatch_time_t getDispatchTimeByDate( NSDate *date){
    NSTimeInterval interval;
    double second,subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval =[date timeIntervalSince1970];
    //返回值为小数部分（小数点后的部分），并设置 第二个参数 为整数部分
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    
    milestone = dispatch_walltime(&time, 0);
    
    return milestone;
}

#pragma mark dispatch Group
-(void)disptachGroup{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"group  queue 1 before...");
        sleep(1);
        NSLog(@"group  queue 1 after...");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"group  queue 2 before...");
        sleep(2);
        NSLog(@"group  queue 2 after...");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"group  queue 3 before...");
        sleep(1);
        NSLog(@"group  queue 3 after...");
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"group  queue1 1 before...");
        sleep(1);
        NSLog(@"group  queue1 1 after...");
    });
    
    //1 等待group中的block全部执行完，不会阻塞当前线程 推荐使用dispatch_group_notify
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"group 追加的block全部执行完，执行这个block done");
//    });
//    //2 等待group中的block全部执行完，会阻塞当前线程
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    //3 等待x时间，再返回结果，会阻塞当前线程，返回值为0，group全部处理完，否则还有线程在处理
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC);
    long result = dispatch_group_wait(group, time);
    NSLog(@"result %ld",result);
    //立即返回
//    dispatch_group_wait(group, DISPATCH_TIME_NOW);
    
    NSLog(@"------------");
}

#pragma mark dispatch_barrier_async
-(void)dispatchBarrier{
    /*
     dispatch_barrier_async函数会等待追加到concurent dispatch queue上的并行执行的处理
     全部结束之后，再将指定的处理追加到该concurent dispatch queue中。然后在由dispatch_barrier_async
     函数追加的处理执行完毕后，concurent才恢复为一般的动作，追加到该concurent的处理才又开始并行执行.
     */
    
    dispatch_queue_t cqueue = dispatch_queue_create("com.kzw.dispatchBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(cqueue, ^{
        NSLog(@"cqueue async1 before...");
        sleep(1);
        NSLog(@"cqueue async1 after...");

    });
    dispatch_async(cqueue, ^{
        NSLog(@"cqueue async2 before...");
        sleep(2);
        NSLog(@"cqueue async2 after...");
    });
    dispatch_async(cqueue, ^{
        NSLog(@"cqueue async3 before...");
        sleep(3);
        NSLog(@"cqueue async3 after...");
    });
    dispatch_barrier_async(cqueue, ^{
        NSLog(@"cqueue barrier_async before...");
        sleep(1);
        NSLog(@"cqueue barrier_async after...");
    });
    dispatch_async(cqueue, ^{
        NSLog(@"cqueue async4 before...");
        sleep(1);
        NSLog(@"cqueue async4 after...");
        
    });
    dispatch_async(cqueue, ^{
        NSLog(@"cqueue async5 before...");
        sleep(1);
        NSLog(@"cqueue async5 after...");
        
    });

}
#pragma mark dispatch_sync
-(void)dispatchSync{
    //串行执行
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSLog(@"queue sync1 before...");
        sleep(1);
        NSLog(@"queue sync1 after...");
    });
    dispatch_sync(queue, ^{
        NSLog(@"queue sync2 before...");
        sleep(1);
        NSLog(@"queue sync2 after...");
    });
    /*
     一旦调用dispatch_sync函数，那么在指定的处理执行结束之前，该函数不会反悔。
     sync函数可简化源代码，也可说是简化版的dispatch_group_wait函数
     容易死锁， 主线程执行sync就会死锁。
     sync在main线程中执行指定block，并等待其执行结束。而其实在
     主线中正在执行这些sync的代码，所以无法执行追加到main的block
     */
}
#pragma mark dispatch_apply
-(void)dispatchApply{
    /*
     apply 函数是sync函数和group的关联api。该函数按指定的次数
     将指定的block追加到指定的queue中，并等待全部处理执行结束。
     
     */
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_apply(10, queue, ^(size_t index) {
//        NSLog(@"index %ld",index);
//    });
//    NSLog(@"dispatch_apply done....");
    
    /*
      由于dispatch_apply函数与dispatch_sync函数相同，会等待处理执行结束，
     因此推荐在dispatch_async函数中非同步执行dispatch_apply函数
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSArray * arr = @[@1,@2,@3,@4];
    /*
     在Global Dispatch Queue中非同步执行
     */
    dispatch_async(queue, ^{
        NSLog(@"async before : %@",[NSThread currentThread]);

        /*
          Global Dispatch Queue
         等待dispatch_apply 函数中全部处理执行结束
         */
        dispatch_apply([arr count], queue, ^(size_t index) {
            NSLog(@"thread : %@ %zu : %@",[NSThread currentThread],index,arr[index]);
            
        });
        NSLog(@"async after : %@",[NSThread currentThread]);

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"main done : %@",[NSThread currentThread]);
        });
        
    });
}
#pragma mark dispatch_suspend/dispatch_resume
/*
   当追加大量处理到 dispatch queue时，在追加处理的过程中，有时希望不执行已追加的
 处理。例如演算结果被block截获时，一些处理会对这个演算结果造成影响。
 dispatch_suspend 函数挂起指定dipatch queue。
 dispatch_suspend(queue);
 dispatch_resume函数恢复指定的 dispatch queue
 dispatch_resume(queue);
 这些函数对已经执行的处理没有影响。挂起后，追加到 dispatch queue中但尚未执行的处理
 在此之后停止执行。而恢复则使得这些处理能够继续执行。
 */

#pragma mark Dispatch Semaphore
-(void)dispatchSemaphore{
    /*
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray  *array = [NSMutableArray array];
    for (int i=0; i<100000; ++i) {
        dispatch_async(queue, ^{
            [array addObject:@(i)];
        });
    }
     因为该源码使用global dispatch queue 更新NSMutableArray类对象，所以执行后由内存
     错误导致应用程序异常结束的概率很高。此时应使用Dispatch Semaphore
     */
    /*
     Dispatch Semaphore 是持有计数的信号。该计数是多线程编程中的计数类型信号。所谓信号，
     类似于过马路时常用的手旗，可以通过时举起手旗，不可通过时放下手旗。而在Dispatch Semaphore
     中，使用计数来实现该功能。计数为0时等待，计数为1或大于1时，减去1而不等待。
     
     */
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /*
       生成Dispatch Semaphore。
     Dispatch Semaphore的计数初始值设定为“1”
     保证可访问NSMutableArray类对象的线程同时只能有1个
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray  *arr = [NSMutableArray array];
    for (int i=0; i<100; i++) {
        dispatch_async(queue, ^{
            /*
                等待 Dispatch Semaphore
             一直等待，知道Dispatch Semaphore的计数达到大于等于1
             */
           long semwait = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            NSLog(@"semwait: %ld",semwait);
            if(semwait==0){
                /*
                 由于Dispatch Semaphore的计数值达到大于等于1
                 或者在等待中的指定时间内Dispatch Semaphore的计数达到大于等于1
                 所有Dispatch Semaphore的计数值减去1
                 
                 可执行需要进行排他控制的处理
                 */
            }else{
                /*
                 由于Dispatch Semaphore的计数值为0
                 因此在达到指定时间为止待机
                 */
            }
            
            /*
               由于Dispatch Semaphore的计数值达到大于等于1
             所以将Dispatch Semaphore的计数值减去1
             dispatch_semaphore_wait函数执行返回。
             
             即执行到此时的Dispatch Semaphore的计数值恒为‘0’
             
             由于可访问NSMutabArray类对象的线程只有一个因此可安全的进行更新
             */
            [arr addObject:@(i)];
            
            /*
               排他控制处理结束，所以通过dispatch_semaphore_signal函数将Dispatch Semaphore
             的计数值增加的线程，就由最先等待的线程执行。
             */
            dispatch_semaphore_signal(semaphore);
            
        });
    }
}
#pragma mark dispatch_once
/*
 static dispatch_once_t pred;
 dispatch_once(pred, ^{
 //初始化
 });
 */
#pragma mark  Dispatch I/O
/*
  分割读取大文件
  dispatch_io_create
 dispatch_io_set_low_water
 ....

 */
#pragma mark Dispatch source
-(void)dispatchSource{
    /*
     Dispatch source 可处理事件
      定时器例子
     */
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    /*
       将定时器设定为15秒后
     不指定为重复
     允许延迟1秒
     */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 2ull*NSEC_PER_SEC),DISPATCH_TIME_FOREVER , 1ull*NSEC_PER_SEC);//
    
    /*
      指定定时器指定时间内执行的处理
     */
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"dingshiqi qidongle ....");
        /*
          取消 Dispatch source
         */
        dispatch_source_cancel(timer);
    });
    
    /*
       指定取消  Dispatch source时的处理
     */
    
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"cannel...");


    });
    dispatch_resume(timer);
}
@end
