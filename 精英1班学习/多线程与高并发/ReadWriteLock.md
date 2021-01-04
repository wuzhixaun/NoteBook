## ReadWriteLock

Java并发包中ReadWriteLock是一个接口，主要有两个方法

```
public interface ReadWriteLock {
    /**
     * 也就是共享琐 
     * Returns the lock used for reading.
     *
     * @return the lock used for reading
     */
    Lock readLock();

    /**
     * 也就是排它锁
     * Returns the lock used for writing.
     *
     * @return the lock used for writing
     */
    Lock writeLock();
}
```

ReadWriteLock管理一组锁，一个是只读的锁，一个是写锁。

