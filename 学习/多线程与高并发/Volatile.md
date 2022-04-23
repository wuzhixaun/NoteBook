## 一、Volatile

作用:

+ 保证线程的可见性

  MESI：CPU缓存一致性协议

+ 禁止指令重排序

  + DCL单例--双重检查单例
  + Double Check Lock
  + Mgr06.java

```
public class Mgr06 {
    private static volatile Mgr06 mgr06;
    
    private Mgr06() {}
    public static Mgr06 getInstance() {
        if (null == mgr06) {
            synchronized (Mgr06.class) {
                if (null == mgr06) {
                    mgr06 = new Mgr06();
                }
            }
        }

        return mgr06;
    }
    
    public void m() {
        System.out.println("m");
    }

    public static void main(String[] args) {
        for (int i = 0; i < 100; i++) {
            new Thread(() ->{
                System.out.println(Mgr06.getInstance().hashCode());
            });
        }
    }
}
```

