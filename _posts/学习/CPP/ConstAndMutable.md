
# const 和 mutable

const 是一个假的关键字，它是程序员的一种承诺，承诺之后不会对它修饰的东西进行更改，虽然我们可以绕过这个承诺。  
mutable 是在 const 基础上突破它的限制。  

## const 修饰普通类型

代表着这个类型的数据不允许被更改，是个常量。

## const 修饰指针

```Cpp
int a = 1, b = 2;
// 不允许这个指针指向的内存中的东西更改，但是可以改变指针本身的指向
const int* ptr0 = &a;	
*ptr0 = b;		// *ptr 不允许更改
ptr0 = &b;		// ptr 允许更改

// const 后置则相反
int* const ptr1 = &a;	
*ptr1 = b;		// *ptr 允许更改
ptr1 = &b;		// ptr 不允许更改

// 两者更是可以配合使用
const int* const ptr2 = &a;	
*ptr2 = b;		// *ptr 不允许更改
ptr2 = &b;		// ptr 不允许更改

// const int * 和 int const * 是一样的，这里关键是*和 const 的相对位置
```