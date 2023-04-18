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
  git clone https://github.com/rvermeulen/codeql-workshop-integer-conversion.git
  ```

- Install the CodeQL pack dependencies using the command `CodeQL: Install Pack Dependencies` and select `exercises`, `exercises-tests`, `solutions`, and `solutions-tests`.

## Workshop

### Learnings

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

The implicit conversion becomes relevant in function calls such as in the following example where there is an implicit conversion from `int` to `size_t` (defined as `unsigned int`).

```cpp
int get_len(int fd);
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

## Exercises

### Exercise 1

Create the a class `SignedInt` that represents that specific `IntType` type. Then write a query that uses class to return all occurrences of that type in any source code. Implement this in [Exercise1.ql](exercises/Exercise1.ql).

<details>
<summary>Hints</summary>

- The `class` keyword is used to write a user defined QL class.
- C/C++ provides ways such as `typedef` and `using` to create type aliases. The predicate `getUnderlyingType` gets the type after resolving typedefs.

</details>

A solution can be found in the query [Exercise1.ql](solutions/Exercise1.ql)

### Exercise 2

Create the a class `UnsignedInt` that represents that specific `IntType` type. Then write a query that uses class to return all occurrences of that type in any source code. Implement this in [Exercise2.ql](exercises/Exercise2.ql).

<details>
<summary>Hints</summary>

- This is very similar to Exercise 1.

</details>

A solution can be found in the query [Exercise2.ql](solutions/Exercise2.ql)

### Exercise 3

In the case of `signed int` to `unsigned int` conversions we are interested in the conversion [`IntegeralConversion`](https://codeql.github.com/codeql-standard-libraries/cpp/semmle/code/cpp/exprs/Cast.qll/type.Cast$IntegralConversion.html) class that models _implicit_ and _explicit_ conversions from one integral type to another.

Create the class `SignedToUnsignedConversion` that models a `signed int` to `unsigned int` conversion. Use the classes `SignedInt` and `UnsignedInt` defined in [Exercise1.ql](exercises/Exercise1.ql) and [Exercise2.ql](exercises/Exercise2.ql).

Place all relevant classes (and a query that selects from that class) in [Exercise3.ql](exercises/Exercise3.ql).

A solution can be found in the query [Exercise3.ql](solutions/Exercise3.ql)

### Exercise 4

Now that we have modeled the `signed int` to `unsigned int` conversion write a query that find the vulnerable conversion, in [Exercise4.ql](exercises/Exercise4.ql).

A solution can be found in the query [Exercise4.ql](solutions/Exercise4.ql)

<details>
<summary>Solution Note</summary>

- Note that this solution uses a `VariableAccess` as an argument of the call. This excludes direct uses of literal values.

</details>

<details>
<summary>Alternative Solution</summary>

```ql
import cpp

from FunctionCall call, int idx, Expr arg
where call.getArgument(idx) = arg and arg.getUnspecifiedType().(IntType).isSigned() and not arg.isConstant() and
call.getTarget().getParameter(idx).getUnspecifiedType().(IntType).isUnsigned()
select call, arg
```

</details>

### Exercise 5

On a real-world database our current query provides a lot of results so it is key to turning this into a manageable list that can be audited.
Implement a heuristic that can meaningfully reduce the list of results in [Exercise5.ql](exercises/Exercise5.ql).

<details>
<summary>Hints</summary>

  - Look for parameters containing the sub-string `len`, `size`, or `nbyte`.

</details>

A solution can be found in the query [Exercise5.ql](solutions/Exercise5.ql)

### Exercise 6

Implement another possible heuristic that can meaningfully reduce the list of results in [Exercise6.ql](exercises/Exercise6.ql).

<details>
<summary>Hints</summary>

  - Look for parameters of type `size_t`.

</details>

A solution can be found in the query [Exercise6.ql](solutions/Exercise6.ql)

### Exercise 7

In the opposite direction unsigned to signed conversion can result in [out of bounds access]( https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-33909) when the signed value is used in a pointer computation. CVE-2021-33909 is discussed by [Qualys](https://blog.qualys.com/vulnerabilities-threat-research/2021/07/20/sequoia-a-local-privilege-escalation-vulnerability-in-linuxs-filesystem-layer-cve-2021-33909) and [Sequoia variant analysis](https://pwning.systems/posts/sequoia-variant-analysis/).
The latter discusses a CodeQL query similar to the production query used as an inspiration that can be found at [UnsignedToSignedPointerArith.ql](https://github.com/github/codeql/blob/main/cpp/ql/src/experimental/Security/CWE/CWE-787/UnsignedToSignedPointerArith.ql).

Consider the following example:

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

<details>
<summary>Hints</summary>

- this is similar to what we did in Exercise 1-3.

</details>

A solution can be found in the query [Exercise7.ql](solutions/Exercise7.ql)

### Exercise 8

The second requirement for the vulnerable case is the participation in a computation that results in a pointer.
Complete the query by establishing that the parameter `n` is used to compute a pointer and put it in [Exercise8.ql](exercises/Exercise8.ql).

You can run your solution on a prebuilt [database](https://drive.google.com/file/d/1fWBKEVs3uw6zzFwGV1IeNRUhizWL76dC/view?usp=share_link) of the Linux kernel v5.12 and see if this finds the conversion part of [CVE-2021-33909]( https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-33909)

<details>
<summary>Hints</summary>

- Pointer arithmetic operations are modeled by the class `PointerArithmeticOperation`.
- Dataflow analysis can help with determining if a value is used somewhere. For local dataflow analysis you can use `DataFlow::localFlow`
- The dataflow library provides helper predicates such as `DataFlow::parameterNode` and `DataFlow::exprNode` to relate AST elements to their dataflow graph counterparts.

</details>

A solution can be found in the query [Exercise8.ql](solutions/Exercise8.ql).
