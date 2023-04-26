# CodeQL workshop for C/C++: Integer conversion

This workshop is adapted from this [material](https://github.com/advanced-security/codeql-workshops-staging/blob/master/cpp/type-conversions-dangling-pointer/README.md).

In this workshop we will explore integer conversion, how it is represented by the standard library, and how it to relates to type conversion security vulnerabilities.

## Contents

- [CodeQL workshop for C/C++: Integer conversion](#codeql-workshop-for-cc-integer-conversion)
  - [Contents](#contents)
  - [Prerequisites and setup instructions](#prerequisites-and-setup-instructions)
  - [Workshop](#workshop)
    - [Learnings](#learnings)
    - [Type Conversion Vulnerabilities](#type-conversion-vulnerabilities)
    - [Type conversions in CodeQL](#type-conversions-in-codeql)
    - [Signed to unsigned](#signed-to-unsigned)
  - [Exercises](#exercises)
    - [Exercise 1](#exercise-1)
    - [Exercise 2](#exercise-2)
    - [Exercise 3](#exercise-3)
    - [Exercise 4](#exercise-4)
    - [Exercise 5](#exercise-5)
    - [Exercise 6](#exercise-6)
    - [Exercise 7](#exercise-7)
    - [Exercise 8](#exercise-8)

## Prerequisites and setup instructions

- Install [Visual Studio Code](https://code.visualstudio.com/).
- Install the [CodeQL extension for Visual Studio Code](https://codeql.github.com/docs/codeql-for-visual-studio-code/setting-up-codeql-in-visual-studio-code/).
- You do _not_ need to install the CodeQL CLI: the extension will handle this for you.
- Clone this repository:
  
  ```bash
  git clone https://github.com/hohn/codeql-workshop-integer-conversion.git
  ```

- Install the CodeQL pack dependencies using the command `CodeQL: Install Pack Dependencies` and select `exercises`, `exercises-tests`, `solutions`, and `solutions-tests`.

- (For exercise 5 and beyond) Get the real-world
  [database](https://drive.google.com/file/d/1fWBKEVs3uw6zzFwGV1IeNRUhizWL76dC/view?usp=share_link)
  of the Linux kernel v5.12 and unzip it.

## Workshop

### Format and learning objectives

This repository has the directory structure
```
exercises
exercises-tests
├── Exercise1
├── Exercise2
├── Exercise3
├── Exercise4
├── Exercise5
├── Exercise6
├── Exercise7
└── Exercise8
solutions
solutions-tests
├── Exercise1
├── Exercise2
├── Exercise3
├── Exercise4
├── Exercise5
├── Exercise6
├── Exercise7
└── Exercise8
```
The `exercises` directory has templates for you to fill in as you work through
this tutorial; the `exercises-tests` directory has tests for correct answers and
can be used to 
1.  check your work
2.  produce databases for development.  When a test fails, the database stays and
    can be imported/used for query development.

The `solutions` and `solutions-tests` trees have complete examples.

The workshop is split into multiple exercises introducing control flow.
In these exercises you will learn:

- About integer conversion.
- How  integer conversion is represented in QL.
- How integer conversion relates to integer overflow vulnerabilities.

### Type Conversion Vulnerabilities

Most security related type conversion issues are implicit conversion from *signed integers* to *unsigned integers*. When a *signed integer* is converted to an *unsigned integer* of the same size then the underlying *bit-pattern* remains the same, but the value is potentially interpreted differently. The opposite conversion is *implementation defined*, but typically follows the same implementation of leaving the underlying *bit-pattern* unchanged. 

### Type conversions in CodeQL

In CodeQL all conversions are modeled by the class [`Conversion`](https://codeql.github.com/codeql-standard-libraries/cpp/semmle/code/cpp/exprs/Cast.qll/type.Cast$Conversion.html) and its sub-classes.

### Signed to unsigned 

The implicit conversion becomes relevant in function calls such as in the
following example where there is an implicit conversion from `int` to `size_t`
`size_t` as used by `read` is defined as `unsigned int`, but the call uses plain
`int`.  (See [sample1](exercises-tests/Sample1/sample1.cpp) for code)

```cpp
int get_input(int fd);
using size_t = unsigned int;
size_t read(int fildes, void *buf, size_t nbyte);

void buffer_overflow(int fd) {
	int len;
	char buf[128];

	len = get_input(fd);
	if (len > 128) {
		return;
	}

	read(fd, buf, len);
}
```

In the following exercise we are going to implement a basic query to find the above problematic implicit conversion.
Why does the conversion pose a security risk?

Next are the exercises used to further explore integer conversion.

## Goals
1.  Find all signed ints; define class `SignedInt`
2.  Find all unsigned ints; define class `UnsignedInt`
3.  Find all conversions from signed to unsigned int; define class
    `SignedToUnsignedConversion` that models a signed int to unsigned int
    conversion.
4.  Test this on simple test code.
5.  Test it on linux kernel code.
6.  (on the kernel): Narrow the result set via simple heuristics based on names and types.
7.  (on the kernel): Unsigned to signed conversion, and queries using predicates and casts.
8.  (on the kernel): Unsigned to signed conversions in the presence of pointers.

## Goal 1 exercises

### Exercise 1

Create the a class `SignedInt` that represents that specific `IntType` type. Then write a query that uses class to return all occurrences of that type in any source code. Implement this in [Exercise1.ql](exercises/Exercise1.ql).


- The `class` keyword is used to write a user defined QL class.
- C/C++ provides ways such as `typedef` and `using` to create type aliases. The predicate `getUnderlyingType` gets the type after resolving typedefs.


A solution can be found in the query [Exercise1.ql](solutions/Exercise1.ql)

## Goal 2 exercises

### Exercise 2

Create the a class `UnsignedInt` that represents that specific `IntType` type. Then write a query that uses class to return all occurrences of that type in any source code. Implement this in [Exercise2.ql](exercises/Exercise2.ql).

- This is very similar to Exercise 1.

A solution can be found in the query [Exercise2.ql](solutions/Exercise2.ql)

## Goal 3 & 4 exercises

### Exercise 3

In the case of `signed int` to `unsigned int` conversions we are interested in the conversion [`IntegeralConversion`](https://codeql.github.com/codeql-standard-libraries/cpp/semmle/code/cpp/exprs/Cast.qll/type.Cast$IntegralConversion.html) class that models _implicit_ and _explicit_ conversions from one integral type to another.

Create the class `SignedToUnsignedConversion` that models a `signed int` to `unsigned int` conversion. Use the classes `SignedInt` and `UnsignedInt` defined in [Exercise1.ql](exercises/Exercise1.ql) and [Exercise2.ql](exercises/Exercise2.ql).

Place all relevant classes (and a query that selects from that class) in [Exercise3.ql](exercises/Exercise3.ql).

A solution can be found in the query [Exercise3.ql](solutions/Exercise3.ql)

### Exercise 4

Now that we have modeled the `signed int` to `unsigned int` conversion write a
query that finds the vulnerable conversion, in
[Exercise4.ql](exercises/Exercise4.ql).

A solution can be found in the query [Exercise4.ql](solutions/Exercise4.ql)

Some hints:
- There are several type-related predicates `.getUnspecifiedType()` is the one we
  want.

- If an expression is a conversion, the predicate `.getConversion()` will give it
  to us.

- Note that this solution uses a `VariableAccess` as an argument of the call. This
  excludes direct uses of literal values.

- An alternative approach that uses inline type restrictions and is frequently
  found in the CodeQL standard library:

  ```ql
  import cpp
   
  from FunctionCall call, int idx, Expr arg
   
  where call.getArgument(idx) = arg
  and
  arg.getUnspecifiedType().(IntType).isSigned()
  and not arg.isConstant()
  and
  call.getTarget().getParameter(idx).getUnspecifiedType().(IntType).isUnsigned()
   
  select call, arg
  ```

## Goal 5 & 6 exercises
### Exercise 5

On the real-world
[database](https://drive.google.com/file/d/1fWBKEVs3uw6zzFwGV1IeNRUhizWL76dC/view?usp=share_link)
of the Linux kernel v5.12 our current query provides a lot of results so it is key
to turning this into a manageable list that can be audited.  Implement a heuristic
that can meaningfully reduce the list of results in
[Exercise4.ql](solutions/Exercise4.ql).

  - Look for parameters containing the sub-string `len`, `size`, or `nbyte`.

A solution can be found in the query [Exercise5.ql](solutions/Exercise5.ql)

### Exercise 6
Implement another possible heuristic that can meaningfully reduce the list of results in [Exercise6.ql](exercises/Exercise6.ql).

  - Look for parameters of type `size_t`.

A solution can be found in the query [Exercise6.ql](solutions/Exercise6.ql)

## Goal 7 exercises
### Exercise 7

In the opposite direction unsigned to signed conversion can result in [out of bounds access]( https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-33909) when the signed value is used in a pointer computation. CVE-2021-33909 is discussed by [Qualys](https://blog.qualys.com/vulnerabilities-threat-research/2021/07/20/sequoia-a-local-privilege-escalation-vulnerability-in-linuxs-filesystem-layer-cve-2021-33909) and [Sequoia variant analysis](https://pwning.systems/posts/sequoia-variant-analysis/).
The latter discusses a CodeQL query similar to the production query used as an inspiration that can be found at [UnsignedToSignedPointerArith.ql](https://github.com/github/codeql/blob/main/cpp/ql/src/experimental/Security/CWE/CWE-787/UnsignedToSignedPointerArith.ql).

Consider the following example, found in
[Exercise7/test.cpp](solutions-tests/Exercise7/test.cpp)

```cpp
char* out_of_bounds(char * c, int n) {
  char * ptr = c + n;
  return ptr;
}

#define INT_MAX 2147483648

int main(void) {
  unsigned int n = INT_MAX + 1;
  char buf[1024];
  char *ptr = out_of_bounds(buf, n);
}
```

The variable `n` can range from `-2147483648` to `2147483648` (assuming 32-bit integers). Passing an unsigned integer, which can range from `0` to `4294967296`, to a call to `out_of_bounds` can result in a pointer that is out of bound because `n` can become negative.

To find the above vulnerable case, start by writing the class `UnsignedToSigned` that identifies conversions from `unsigned int` to `signed int` and put it in [Exercise7.ql](exercises/Exercise7.ql).

- this is similar to what we did in Exercise 1-3.

A solution can be found in the query [Exercise7.ql](solutions/Exercise7.ql)


### Exercise 7a

An alternative approach to writing queries that uses inline type restrictions and
predicates and is frequently found in the CodeQL standard library.

XX:  TODO

  ```ql
  import cpp
   
  from FunctionCall call, int idx, Expr arg
   
  where call.getArgument(idx) = arg
  and
  arg.getUnspecifiedType().(IntType).isSigned()
  and not arg.isConstant()
  and
  call.getTarget().getParameter(idx).getUnspecifiedType().(IntType).isUnsigned()
   
  select call, arg
  ```



### Exercise 8

The second requirement for the vulnerable case is the participation in a
computation that results in a pointer.  Complete the query by establishing that
the parameter `n` is used to compute a pointer and put it in
[Exercise8.ql](exercises/Exercise8.ql).

You can run your solution on a prebuilt
[database](https://drive.google.com/file/d/1fWBKEVs3uw6zzFwGV1IeNRUhizWL76dC/view?usp=share_link)
of the Linux kernel v5.12 and see if this finds the conversion part of
[CVE-2021-33909]( https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-33909)


- Pointer arithmetic operations are modeled by the class
  `PointerArithmeticOperation`.
- Dataflow analysis can help with determining if a value is used somewhere. For
  local dataflow analysis you can use `DataFlow::localFlow`
- The dataflow library provides helper predicates such as
  `DataFlow::parameterNode` and `DataFlow::exprNode` to relate AST elements to
  their dataflow graph counterparts.

A solution can be found in the query [Exercise8.ql](solutions/Exercise8.ql).
