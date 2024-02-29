---
layout: post
title: Kotlin Easy-understanding
categories: [android]
description: Kotlin是Jetbrain公司发明的编程语言之一，指在替换java。恰好Google此前和SUN公司因为java闹得打官司，所以Jetbrain机智地将Kotlin推荐给了Google Android。目前来看Kotlin在Android应用开发中起到了不错的效果。
keywords: android, kotlin
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![kotlin](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/kotlin.jpg)

# 通俗理解Kotlin及其30大特性

[TOC]

## 前言

> Kotlin是Jetbrain公司发明的编程语言之一，指在替换java。恰好Google此前和甲骨文公司因为java闹得打官司，所以Jetbrain机智地将Kotlin推荐给了Google Android。目前来看Kotlin在Android应用开发中起到了不错的效果。



### 背景

Kotlin的特色，引用官网说明：



![image-20240218113127156](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240218113127156.png)

### 编译&运行

本质上，kotlin语言经过kotlin编译器也是编译成java字节码，可以运行在JVM虚拟机上。

由于多了一道转化工序，所以一般来说，Kotlin的编译时间会更长一些，产生的编译文件也大一些。

![在这里插入图片描述](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/769db9f9d54e4e02840c5e6840ddc646.png)



### 字节码对比

可以使用Android Studio/IDEA的工具查看Kotlin的字节码：

- 点击菜单栏 -> Tool -> Kotlin -> Show Kotlin Bytecode，查看生成的Java字节码

- 还可以点击顶部的"Decompile"按钮查看翻译后的Java代码

java 源码：

```java
package com.xxxx.java;

public class SDK {
    public static int addSum(int a, int b) {
        System.out.println("run in java sdk!");
        return a+b;
    }
}
```

java 字节码:

```
// class version 65.0 (65)
// access flags 0x21
public class com/xxxx/java/SDK {

  // compiled from: SDK.java

  // access flags 0x1
  public <init>()V
   L0
    LINENUMBER 3 L0
    ALOAD 0
    INVOKESPECIAL java/lang/Object.<init> ()V
    RETURN
   L1
    LOCALVARIABLE this Lcom/xxxx/java/SDK; L0 L1 0
    MAXSTACK = 1
    MAXLOCALS = 1

  // access flags 0x9
  public static addSum(II)I
   L0
    LINENUMBER 5 L0
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    LDC "run in java sdk!"
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/String;)V
   L1
    LINENUMBER 6 L1
    ILOAD 0
    ILOAD 1
    IADD
    IRETURN
   L2
    LOCALVARIABLE a I L0 L2 0
    LOCALVARIABLE b I L0 L2 1
    MAXSTACK = 2
    MAXLOCALS = 2
}

```

kotlin 源码：

```kotlin
package com.xxxx.kotlin

class SDK {

}

fun addSum(a:Int, b:Int):Int {
    println("run in kotlin sdk!")
    return a+b;
}

```

kotlin字节码:

```
// ================com/xxxx/kotlin/SDK.class =================
// class version 52.0 (52)
// access flags 0x31
public final class com/xxxx/kotlin/SDK {

  // compiled from: SDK.kt

  @Lkotlin/Metadata;(mv={1, 9, 0}, k=1, d1={"\u0000\u000c\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0002\u0018\u00002\u00020\u0001B\u0005\u00a2\u0006\u0002\u0010\u0002\u00a8\u0006\u0003"}, d2={"Lcom/xxxx/kotlin/SDK;", "", "()V", "KotlinStudy"})

  // access flags 0x1
  public <init>()V
   L0
    LINENUMBER 3 L0
    ALOAD 0
    INVOKESPECIAL java/lang/Object.<init> ()V
    RETURN
   L1
    LOCALVARIABLE this Lcom/xxxx/kotlin/SDK; L0 L1 0
    MAXSTACK = 1
    MAXLOCALS = 1
}


// ================com/xxxx/kotlin/SDKKt.class =================
// class version 52.0 (52)
// access flags 0x31
public final class com/xxxx/kotlin/SDKKt {

  // compiled from: SDK.kt

  @Lkotlin/Metadata;(mv={1, 9, 0}, k=2, d1={"\u0000\n\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u0003\u001a\u0016\u0010\u0000\u001a\u00020\u00012\u0006\u0010\u0002\u001a\u00020\u00012\u0006\u0010\u0003\u001a\u00020\u0001\u00a8\u0006\u0004"}, d2={"addSum", "", "a", "b", "KotlinStudy"})

  // access flags 0x19
  public final static addSum(II)I
   L0
    LINENUMBER 8 L0
    LDC "run in kotlin sdk!"
    ASTORE 2
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 2
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L1
    LINENUMBER 9 L1
    ILOAD 0
    ILOAD 1
    IADD
    IRETURN
   L2
    LOCALVARIABLE a I L0 L2 0
    LOCALVARIABLE b I L0 L2 1
    MAXSTACK = 2
    MAXLOCALS = 3
}

```



【java字节码  vs kotlin字节码】

![image-20240220170229919](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240220170229919.png)

核心函数的字节码不变，在形式上稍微有调整。



## Java VS Kotlin
### 变量/常量

#### 类型声明

Java：

- 使用关键字 `int`、`String` 等来声明变量类型，例如 `int num = 10;`。

```java
    private static void test1() {
        int num=10;
        System.out.println("what's type of num?"+getType(num));
        String str="Hello, world!";
        System.out.println("what's type of str?"+getType(str));

        final int N=10;
        //N=11;
        System.out.println("N="+N);
    }
```



Kotlin：

- 使用关键字 `var` 或 `val` 来声明变量，例如 `var num: Int = 10` 或 `val name: String = "Kotlin"`。

- 默认支持局部变量类型推断，使用关键字 `val` 或 `var` 声明变量

- `var`是可变变量，val一旦赋值不可再变，相当于`java`的`final`

```kotlin
fun test1(){
    var num = 10
    println("what's type of num?${num::class.java.typeName}")

    var str = "Hello, world!"
    println("what's type of str?" + getType(str))

    val N = 10
    //N = 11
    println("N=$N")

    //const val PI = 3.14

    println(PI)

    val a: Int = 10
    val b: Long = a.toLong()
    println("what's type of b? $b-->" + getType(b))
}
```



Kotlin使用关键字 `const`（只能用于顶层和对象声明）和 `val`（只读变量）来声明常量，

`const` 只能修饰属性（类属性、顶层属性），不能用于局部变量，再编译期间定下来，所以它的类型只能是 `String` 或基本类型。



例如：

```kotlin
const val PI = 3.14
val name: String = "Kotlin"
```



Kotlin数据类型转换方式更为简洁，例如：

```kotlin
val a: Int = 10
val b: Long = a.toLong()
```



#### 变量初始化

`lateinit` 是一种延迟初始化方式，必须在使用前初始化，例如：

```kotlin
lateinit var name: String
fun init() {
    name = "Kotlin"
}
```



`lazy` 是一种懒加载方式，会在第一次访问时初始化，例如：

```kotlin
val name: String by lazy {
    println("Initializing")
    "Kotlin"
}
```



`lateinit var`和`by lazy`都可以推迟初始化。

`lateinit var`只是在编译期忽略对属性未初始化进行检查，何时初始化还需开发者自行决定。

`by lazy`在被第一次调用的时候能自动初始化，做到了真正的延迟初始化的行为。



#### 空安全特性

Java：不支持空安全特性，需要手动判断 null 值。

```java
private static void test2() {
        String str=null;
        System.out.println(str);
        if ( str != null) {
         	System.out.println(str.substring(0,1));
        }
}
```



Kotlin：支持空安全特性，使用 `?` 来标记可为空的类型，例如 `var name: String? = null`。

```kotlin
var str: String? =null;
println(str)
println(str?.substring(0,1))
println(str?.length） // 如果 str 不为 null，返回 str 的长度，否则返回 null
```



此外，Kotlin还支持非空断言，使用 `!!` 运算符，相当于回归java设计，例如：

```kotlin
println(str!!.length) // 如果 str 不为 null，返回 str 的长度，否则抛出 NullPointerException
```

运行时会报错：

```
Exception in thread "main" java.lang.NullPointerException
	at com.xxxx.kotlin.KotlinMainTestKt.test2(KotlinMainTest.kt:163)
	at com.xxxx.kotlin.KotlinMainTestKt.main(KotlinMainTest.kt:16)
```



Elvis 运算符是一种处理空值的方式，可以指定一个默认值，例如

```kotlin
val str: String? = null
val length = str?.length ?: 0 // 如果 str 不为 null，返回 str 的长度，否则返回 0
```



Kotlin：安全类型转换是一种转换类型的方式，可以避免类型转换异常，例如：

```kotlin
val str: Any = "Kotlin"
val length = (str as? String)?.length ?: 0
```



### 函数

#### 函数声明

Java：使用关键字 `void` 来声明函数的返回类型，例如 `public void printName(String name) {}`。

```java
    private static String test3() {
        return "String";
    }
```



Kotlin：使用关键字 `fun` 来声明函数，例如 `fun printName(name: String) {}`。

```kotlin
private fun test3(): String {
    return "String"
}
```



此外，

- Kotlin调用静态方法，无需带上包名，可以直接调用，这一点体现了kotlin的静态性。
- Kotlin函数调用，也无须分号结尾。



#### 函数参数

Java：不支持函数的默认参数。

```java
    private static void test4(String name, Boolean isMale) {
        System.out.println("name="+name+", isMale="+isMale);
    }
```



Kotlin：支持函数的默认参数，例如 `fun printName(name: String, isMale: Boolean = true) {}`。

```kotlin
test4("haha")

fun test4(name: String, isMale: Boolean = true) {
    println("name=$name, isMale=$isMale")
}
```



此外，类的构造函数也支持默认参数：

```kotlin
class Person(val name: String = "Kotlin", val age: Int = 20)
```



Kotlin：具名参数是一种通过名称来指定函数参数的方式，可以提高代码可读性，例如：

```kotlin
fun printPerson(name: String, age: Int) {
    println("Name: $name, Age: $age")
}
printPerson(name = "Kotlin", age = 20)
```



```kotlin
fun main(){
    test4("kotlin",false)
    test4("haha")                         //默认参数
    test4( isMale = false, name="Lucas")  //具名参数
}

fun test4(name: String, isMale: Boolean = true) {
    println("name=$name, isMale=$isMale")
}
```



#### 函数可变参数

Java：使用 `...` 来声明可变参数，例如 `public void printNames(String... names) {}`。

```java
    private static void test5(String... names) {
        for (int i = 0; i < names.length; i++) {
            System.out.println(names[i]);
        }
    }
```



Kotlin：使用关键字 `vararg` 来声明可变参数，例如 `fun printNames(vararg names: String) {}`。

```kotlin
fun test5(vararg names: String) {
    for ( name in names){
        println(name)
    }
}
```



#### 局部函数

函数中仍然可以嵌套函数，对于函数内代码块频繁调用的情况有用。

```kotlin
fun test6() {
    fun sum(a:Int, b:Int): Int {
        fun multiply(c:Int, d:Int): Int{
            return c*d
        }
        return multiply(a, a)+multiply(b, b);
    }
    // 平方和
    println(sum(1,2))
}
```



#### 函数/属性/操作符的扩展

- 扩展函数是一种将函数添加到现有类中的方式
- 扩展属性是一种将属性添加到现有类中的方式

```kotlin
val String.lastChar: Char
    get() = get(length - 1)
val String.pai: String
    get() = "3.1415926"
val String.isEmail: Boolean
    get() = this.matches(Regex("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))

fun test7() {
    fun String.addHello() = this + ", Hello!"

    println("Lucas".addHello());
    println("Lucas".lastChar);
    println(String().pai);
    println("lucas.deng@xxxx.com".isEmail);
}
```

- 扩展运算符是一种将数组或集合打散为参数列表的方式，例如：

```kotlin
fun sum(a: Int, b: Int, c: Int) = a + b + c
val list = listOf(1, 2, 3)
val result = sum(*list.toIntArray())
```



#### 函数/属性的引用

- 支持属性引用，可以使用 `::` 运算符来引用属性

- 支持函数引用，可以使用 `::` 运算符来引用函数

```kotlin
fun test8() {
    class Person(val name: String) {
        fun printName() {
            println(name)
        }
    }
    val person = Person("Kotlin")
    val nameProperty = Person::name
    println(getType(nameProperty))
    println(nameProperty.toString())
    val name = nameProperty.get(person)
    println(name)

    fun printName(name: String) {
        println(name)
    }
    val namePrinter = ::printName
    namePrinter("Kotlin")

    val c= String::class
    println(c)

    val d= String::toString
    println(d("abc"))

    val e= String::equals
    println(e("abc", "abc"))

}
```



#### 操作符重载

不是所有操作符都支持重载，支持的操作符主要是运算类的。

| 表达式  | 翻译为            |
| ------- | ----------------- |
| `a + b` | `a.plus(b)`       |
| `a - b` | `a.minus(b)`      |
| `a * b` | `a.times(b)`      |
| `a / b` | `a.div(b)`        |
| `a % b` | `a.rem(b)`        |
| `a..b`  | `a.rangeTo(b)`    |
| `a..<b` | `a.rangeUntil(b)` |



```kotlin
fun test9() {
    data class Point(val x: Int, val y: Int) {
        operator fun plus(other: Point) = Point(x + other.x, y + other.y)
        operator fun minus(other: Point) = Point(x - other.x, y)

    }

    val p1 = Point(1, 2)
    val p2 = Point(3, 4)

    val p3 = p1 + p2
    println(p3)

    val p4 = p2 - p1
    println(p4)

}
```



#### Lambda 表达式

Java：支持 Lambda 表达式，但写法比较繁琐。

如果只有一个显式声明的抽象方法，那么它就是一个函数接口。

java Lambda表达式只能应用于函数接口。

```java
    private static void test12(){
        new Thread(
            () -> System.out.println("Thread run().....")
        ).start();

        Call call= (a,b)->{ return a+b; };
        System.out.println(call.plus(1,4));
    }

    static interface Call {
        int plus(int a, int b);
        // int minus(int a, int b);
    }
```



Kotlin：支持 Lambda 表达式，写法简洁，例如 `val sum = { a: Int, b: Int -> a + b }`。

```kotlin
private fun test10() {
    Thread { println("Thread run().....") }.start()
    val sum = { a: Int, b: Int -> a + b }
    println(sum(1,4))
}
```



Java：使用 for 循环和 if 语句来实现过滤器。

Kotlin：使用 Lambda 表达式和过滤器函数来实现，例如 `val nums = listOf(1, 2, 3, 4, 5).filter { it % 2 == 0 }`。

```kotlin
private fun test10() {
    Thread { println("Thread run().....") }.start()
    val sum = { a: Int, b: Int -> a + b }
    println(sum(1,4))

    val nums = listOf(1, 2, 3, 4, 5).filter { it % 2 == 0 }
    println(nums)
}
```



#### 数组/List/Map/元组

数组： 不再使用[ ], 而是用Array类来代替掉，

List：  直接用listOf就可以进行初始化，直接用forEach就可以打印所有元素

Map：  直接用hashMapOf就可以进行初始化，直接用forEach就可以打印所有元素

元组：支持元组，使用 `Pair` 和 `Triple` 类来表示二元组和三元组。主要用于记录小量的二元/三元数据，而不必要重新定义一个类。

```kotlin
fun test11() {
    //数组
    val arrayEmpty = emptyArray<String>()
    val array1 = arrayOfNulls<Int>(5)
    val array2 = arrayOf(1, 2, 3, 4)
    array2.forEach {
        print(" $it")
    }
    println()

    // List
    val listEmpty = emptyList<String>()
    val nums = listOf(1, 2, 3, 4, 5)
    val sum = nums.reduce { acc, i -> acc + i }
    for (item in nums)
        print(" $item")
    println()

    val map = hashMapOf("Kotlin" to 1, "Java" to 2, "Python" to 3)
    println(map["Kotlin"])
    map["Lucas"] = 23
    println(map["Lucas"])

    for ((key, value) in map) {
        print("$key = $value, ")
    }
    println()

    map.forEach {
            (key, value) -> print("$key = $value, ")
    }
    println()

    val pair = Pair("Kotlin", 20)
    val triple = Triple("Kotlin", 20, "male")
    val (name, age) = pair
    println(pair)
    println(triple)

    val triple2 = Triple("Lucas", 27, "male")

    var arrays = arrayOf(triple,triple2)
    arrays.forEach {
        println(it)
    }
}
```



### 控制表达式

#### if/when

Java：

使用 if-else if-else 或 switch-case 来实现条件判断。



Kotlin：

if 表达式是有返回值的，可以用来赋值，基本可以代替三目运算符，例如：

```kotlin
fun test12() {
    val a = 10
    val b = 20
    //val max = a>b? a:b
    val max = if (a > b) a else b

    println(max)

    val value = 88
    if (value in 1..100) {
        println("$value")
    }

}
```



使用 when 表达式，例如：

```kotlin
fun test14( index : String): String {
     val num=10;
    when(index){
        "a"->return "A"
        "b"->return "B"
        "c"->return "C"
    }
    return when(num){
        1-> "99"
        2-> "88"
        3-> "77"
        else->"-1"
    }
}

fun test13() {
    var num=34
    when(num){
        10 -> println("10")
        23 -> println("23")
        34 -> println("OK!")
        35 -> println("35")
    }
}
```

不再需要break，不然又有什么坑要踩。



#### for/while

Kotlin：for 循环可以遍历集合、数组等对象，例如：

```kotlin
val list = listOf("Kotlin", "Java", "Python")
for (item in list) {
    println(item)
}
```



Kotlin：支持 Range 表达式，例如 `val nums = 1..10`。

```kotlin
fun test15() {
    for (i in 1..9) {
        print(i)
    }
    println()

    for (i in 9..1) {
        print(i)
    }
    println()

    for (i in 9 downTo 1) {
        print(i)
    }
    println()

    for (i in 1..20 step 2) {
        print(i)
    }
    println()

    for (i in 1 until 10) {
        print(i)
    }
    println()
}
```



Kotlin：while 循环可以重复执行某个代码块，例如：

```kotlin
var i = 0
while (i < 10) {
    println(i)
    i++
}
```



Kotlin：do-while 循环与 while 循环类似，但是至少会执行一次，例如：

```kotlin
var i = 0
do {
    println(i)
    i++
} while (i < 10)
```



```kotlin
fun test16() {
    var i = 0
    while (i < 10) {
        print(i)
        i++
    }
    println()

    var j = 0
    do {
        print(j)
        j++
    } while (j < 10)
    println()

}
```



#### try-catch

Java：使用 try-catch 语句块来捕获异常。

Kotlin：不仅可以使用语句块，还能使用 try-catch 表达式来捕获异常，例如：

```kotlin
fun test17() {
    try {
        val str:String? = null;
        println(str!!.length)
    }catch (e:NullPointerException){
        println("please check your code!")
    }

    val len = try {
        val str:String? = null;
        println(str!!.length)
    }catch (e:NullPointerException){
        println("please check your code!")
        5
    }
    println(len)
}
```



#### 位运算

Kotlin：位运算是一种对二进制位进行操作的方式，例如：

```kotlin
fun test18() {
    val a = 0b0101
    val b = 0b1010
    val c = a and b // 0b0000
    val d = a or b // 0b1111
    val e = a xor b // 0b1111
    val f = a.inv() // 0b1010

    println(c)
    println(d)
    println(e)
    println(f)
    println(Integer.toBinaryString(e))
    println(Integer.toBinaryString(f))
    
}
```



### 类

#### 类的定义/构造/继承

最简单的类定义：

```kotlin
class Empty

class Anything{
}
```



定义Person类，并调用

```kotlin
open class Person //主构造Person()
{
    constructor(id: Int, name: String) {

    }

    constructor(id: Int, sex: Char) {

    }

    //主构造
    constructor() {

    }

    override fun toString(): String {
        return "abc"
    }

}
```

```kotlin
fun test19() {
    var person:Person = Person()
    var person2:Person = Person(110,'C')
    var person3:Person = Person(10086, "Lucas")
}
```



Java：使用关键字 `extends` 来实现类的继承，例如 `public class Student extends Person {}`。

```java
    private static void test7() {
        Student student = new Student();
        System.out.println(student);
    }

    static class Student extends Person {}

    static class Person {
        String name = "David";
        int age = 23;

        @Override
        public String toString() {
            return "Person{" +
                    "name='" + name + '\'' +
                    ", age=" + age +
                    '}';
        }
    }
```



Kotlin：使用关键字 `:` 来实现类的继承，例如 `class Student : Person()`。

并且Person必须为open，定义Student类，继承至Person

```kotlin
class Student() : Person()
{
    // Kotlin 全部都是没有默认值的
    // Java 成员有默认值，但是方法内部没有默认值
    // lateinit 懒加载  没有赋值 就不能使用，否则报错

    lateinit var name : String
    var age: Int = 0

    override fun toString(): String {
        return "Student(name='$name', age=$age)"
    }

    constructor(n:String) : this() {
        name = n
    }

    constructor(n:String, a:Int) : this() {
        name = n
        age = a
    }


}
```

```kotlin
fun test20() {
    var student:Student = Student("Hello")
    println(student.toString())
}
```



实现接口：

```kotlin
interface Eat {
    fun EatMethod() : Boolean
}
```

```kotlin
class Student() : Person(), Eat
{
    override fun EatMethod(): Boolean {
        TODO("Not yet implemented")
    }
    
    ...
}
```



#### 类的访问修饰符

Java：使用关键字 `public`、`private`、`protected` 和 `default`（没有修饰符）来修饰类的访问权限。

![image-20240218154616640](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240218154645959.png)

Kotlin：使用关键字 `public`、`private`、`protected` 和 `internal` 来修饰类的访问权限，默认为 `public`。

![image-20240218154726169](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240218154726169.png)

#### 数据类

Java：不支持数据类。

```java
	private static void test10() {
        User jack = new User("Jack", 23);
        System.out.println(jack.toString());
    }

    static class User{
        String username;
        int age;

        public User(String username, int age) {
            this.username = username;
            this.age = age;
        }

    }
```



Kotlin：

支持数据类，使用关键字 `data` 来声明，例如 `data class User(val id: Int, val name: String, val sex: Char)`。

> 编译器会自动的从主构造函数中根据所有声明的属性提取以下函数：
>
> - `equals()` / `hashCode()`
> - `toString()` 格式如 `"User(name=John, age=42)"`
> - `componentN() functions` 对应于属性，按声明顺序排列
> - `copy()` 函数



```kotlin
fun test21() {
    val user = User(99, "Lucas", 'M')

    val(myID, myName, mySex) = user.copy()
    println("myID:$myID, myName:$myName, mySex:$mySex")

    // _ 代表不接收
    val(_, myName2, _) = user.copy()
    println("myName2:$myName2")

    println(user.toString())
    val user1=user.copy()
    val user2=user.copy(name="Kotlin")
    println(user1.equals(user))
    println(user2.equals(user))
    
}
```



#### 类的别名

Java：不支持类型别名。

Kotlin：支持类型别名，使用关键字 `typealias` 来声明，例如：

```kotlin
typealias Name = String
typealias MyList = List<String>
fun test22() {
    fun printName(name: Name) {}
    val list: MyList = listOf("Kotlin", "Java", "Python")
}
```



此外，内部类和枚举类也和java稍有不同，可以自行查阅。



## 协程

Kotlin中的协程可以认为是一个“线程框架”，类似于Java中的线程池Executor，类似于Android中的Handler/AsyncTask。

Kotlin 协程的最大好处在于，你可以把运行的不同线程的代码写在同一个代码块里，可以随意切。（用看起来同步的方式写出异步代码）



## 总结

### 在AOSP中部分使用

以frameworks/base/packages/SystemUI为例，kt文件有510个java文件有1220个占比达到了1/3。

```
find  ./frameworks/base/packages/SystemUI/src  -name "*.kt" |  wc -l
510
find  ./frameworks/base/packages/SystemUI/src  -name "*.java" |  wc -l
1220
```



### 优缺点比较

|      | Java                                                         | Kotlin                                                       |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 优点 | 改进错误检测和解决的检查异常<br/>提供详细的文档。<br/>大量熟练的开发人员可用<br/>大量的第 3 方库<br/>它允许您形成标准程序和可重用代码。<br/>它是一个多线程环境，允许您在一个程序中同时执行多个任务。<br/>完美的表现<br/>易于浏览的社区资料 | 使用 Kotlin 多平台框架，您可以提取一个通用代码库，同时针对所有这些代码库<br/>Kotlin 提供了内置的 null 安全支持，这是一个救星，尤其是在 Android 上，它充满了旧的 Java 风格的 API。<br/>它比 Java 更简洁、更具表现力，这意味着出错的空间更小。<br/>提供用户友好且易于理解的编码规范<br/>将大型应用程序划分为更小的层。<br/>使用大量函数类型和专门的语言结构，如 lambda 表达式。<br/>帮助开发者创建扩展功能<br/>提供了一种非常简单且几乎自动化的方式来创建数据类<br/>Kotlin 是一种静态类型语言，因此非常易于阅读和编写。<br/>这种语言允许以各种方式交换和使用来自 Java 的信息。<br/>在 Kotlin 中编写新代码将花费更少的时间。<br/>部署 kotlin 代码并大规模维护它非常容易。 |
| 缺点 | 由于诸多限制，不太适合 Android API 设计<br/>需要大量手动工作，这增加了潜在错误的数量<br/>JIT 编译器使程序相对较慢。<br/>Java 具有较高的内存和处理要求。<br/>它不支持像指针这样的低级编程结构。<br/>您无法控制垃圾收集，因为 Java 不提供 delete()、free() 等函数。 | 开发者社区很小，因此缺乏学习材料和专业帮助。<br/>Java 不提供可能导致错误的检查异常的功能。<br/>编译速度比Java慢<br/>编译的产物比java大<br/>Kotlin 作为一种高度声明性的语言，有时它可以帮助您在相应的 JVM 字节码中生成大量样板 |
