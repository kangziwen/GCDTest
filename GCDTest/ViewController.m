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
    [self disptachGroup];
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
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"group 追加的block全部执行完，执行这个block done");

    });
}

@end
