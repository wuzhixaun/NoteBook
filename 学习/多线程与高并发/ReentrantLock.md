## 一、简介

+ `synchronized`是独占锁，加锁和解锁的过程自动进行，易于操作，但不够灵活。`ReentrantLock`也是独占锁，加锁和解锁的过程需要手动进行，不易操作，但非常灵活。
+ `synchronized`可重入，因为加锁和解锁自动进行，不必担心最后是否释放锁；`ReentrantLock`也可重入，但加锁和解锁需要手动进行，且次数需一样，否则其他线程无法获得锁
+ `synchronized`不可响应中断，一个线程获取不到锁就一直等着；`ReentrantLock`可以相应中断。

`ReentrantLock`好像比`synchronized`关键字没好太多，我们再去看看`synchronized`所没有的，一个最主要的就是ReentrantLock还可以实现公平锁机制。什么叫公平锁呢？也就是在锁上等待时间最长的线程将获得锁的使用权。通俗的理解就是谁排队时间最长谁先执行获取锁



ReentrantLock可以进行尝试获取琐，如果没有所以活着在指定的时间没有锁定，则抛异常

```
    public static void m2() {
        try {

            lock.tryLock(3,TimeUnit.SECONDS);
            System.out.println("m2");
        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            lock.unlock();
        }
    }
```



## 二、ReentrantLock获取锁定与三种方式

 

+ lock(), 如果获取了锁立即返回，如果别的线程持有锁，当前线程则一直处于休眠状态，直到获取锁

+ tryLock(), 如果获取了锁立即返回true，如果别的线程正持有锁，立即返回false；

+ **tryLock**(long timeout,[TimeUnit](http://houlinyan.iteye.com/java/util/concurrent/TimeUnit.html) unit)，  如果获取了锁定立即返回true，如果别的线程正持有锁，会等待参数给定的时间，在等待的过程中，如果获取了锁定，就返回true，如果等待超时，返回false；

+ 
+ lockInterruptibly:如果获取了锁定立即返回，如果没有获取锁定，当前线程处于休眠状态，直到或者锁定，或者当前线程被别的线程中断