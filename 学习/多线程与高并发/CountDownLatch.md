## 一、CountDownLatch

### 1、概念

+ countDownLatch这个类使一个线程等待其他线程各自执行完毕后再执行
+ 是通过一个计数器来实现的，计数器的初始值是线程的数量。每当一个线程执行完毕后，计数器的值就-1，当计数器的值为0时，表示所有线程都执行完毕，然后在闭锁上等待的线程就可以恢复工作了

### 2、源码

+ countDownLatch类中只提供了一个构造器：

```
//参数count为计数值
public CountDownLatch(int count) {  };  
```

- 类中有三个方法是最重要的：

```
//调用await()方法的线程会被挂起，它会等待直到count值为0才继续执行
public void await() throws InterruptedException { };   
//和await()类似，只不过等待一定的时间后count值还没变为0的话就会继续执行
public boolean await(long timeout, TimeUnit unit) throws InterruptedException { };  
//将count值减1
public void countDown() { };  
```

### 3、Demo

```
public class TestCountDownLatch {

    public static void main(String[] args) {
        CountDownLatch latch = new CountDownLatch(100);

        Thread[] threads = new Thread[100];

        for (int i = 0; i < threads.length; i++) {
            threads[i] = new Thread(() -> {
                int result = 0;
                for (int j = 0; j < 1000; j++) {
                    result += j;
                    System.out.println(Thread.currentThread().getName() + "---result=" + result);
                };
                latch.countDown(); // 减去
            });
        }

        for (int i = 0; i < threads.length; i++) {
            threads[i].start();
        }

        try {
            latch.await(); // 门栓
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("end");

    }
```



## 二、CycliBarrier



## 2、使用场景

+ 限流

![CyclicBarrier](/Users/wuzhixuan/NoteBook/精英1班学习/image/CyclicBarrier.png)

+ 复杂操作
  + 数据库
  + 网络
  + 文件
+ 并发执行
  + 线程-操作
  + 

### 3、Demo

```
public class TestCycleBarrier {
    public static void main(String[] args) {
        CyclicBarrier cyclicBarrier = new CyclicBarrier(20, () -> System.out.println("满人，发车"));
        for (int i = 0; i < 100; i++) {
            new Thread(() -> {
                try {
                    cyclicBarrier.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } catch (BrokenBarrierException e) {
                    e.printStackTrace();
                }
            }).start();

        }
    }
}
```





## 三、CountDownLatch和CyclicBarrier区别

+ 1.countDownLatch是一个计数器，线程完成一个记录一个，计数器递减，只能只用一次
+ 2.CyclicBarrier的计数器更像一个阀门，需要所有线程都到达，然后继续执行，计数器递增，提供reset功能，可以多次使用