# 1、压入栈

``` java
   public static void main(String[] args) {
        int i = 1; // i 局部变量 1 
        i = i++; // i++ -> 局部变量i =2 操作数栈 i = 1 后面需要将操作数栈的值赋值给局部变量i 所以 i= 1
        int j = i++; // i=1 压入 i = 1 == j =1 

        int k = i + ++i * i++; // 先将i=2 压入栈 局部变量 i =4   3 * 3 + 2 =11

        System.out.println(i); // 
        System.out.println(j); // 
        System.out.println(k); // 
    }
```

# 2、SingleTon

```多线程 java
1.饿汉式 直接创建对象，不存在线程安全问题
  	（1）直接实例化饿汉式
  	（2）枚举式（最简洁）
  	（3）静态代码块饿汉式（适合复杂实例化）
2.饱汉式 延迟创建对象
  	（1）线程不安全（适用于单线程）
  	（2）线程安全（适用于多线程）
  	（3）静态内部类形式（适用于于多线程）
  
/**
 * 饿汉式 ：直接创建对象，不管是否需要
 * 构造器私有化
 * 自行创建，并且用静态变量保存
 * 向外提供这个实例
 * 强调这是一个单例，使用final
 */
public class SingleTon {
    public static final SingleTon INSTANCE = new SingleTon();
    private SingleTon() {
        
    }
}
```

