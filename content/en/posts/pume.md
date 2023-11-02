---
title: "PUME: a tool to mutate Python source code"
author: Guzmán Cernadas Pérez
date: 2023-11-02
tags: ["python", "pume", "AST", "obfuscation"]
---

This article will explain what [PUME (Python Universal Mutation Engine)](https://github.com/Caralludo/PUME) is and how 
it works and after that some examples of use will be given.

# Introduction

PUME is a tool that randombly modifies the source code of a program made with Python without change the orginal 
features. This is mainly achived by doing modifications in the Abstract Syntax Tree (AST) of the program but it should 
be noted that exist a modification that is made directly in the source code. The modifications performed in the AST 
are:
- Change the names of the classes, functions and variables (both local and global).
- Change the possition of the functions.
- Add randombly the reserved word "pass" in the code.
- Change the integers by a mathematical expression that has the same result.
- Change an string by an addition of substrings.

The modification made directly in the source code is add mono-line comments with irrelevant content in random lines. 
This is made this way because in the AST of Python comments are not represented.

# Modifications on AST

This section will discuss in depth the modifications that PUME is able to make and it will be shown the 
impact in the AST.

## Name changing

This feature consists in the detection of all the names of variables, functions and classes in the source code and 
change them without break the program. The following code snippets show the effects of this modification. The first 
snippet is the original code and the second is the modified one:
```python
class Math:
    def add(a, b):
        return a + b

def calculate():
    bananas_paul = 4
    bananas_john = 5
    math = Math()
    total_bananas = math.add(bananas_paul, bananas_john)
    return total_bananas

calculate()
```

```python
class Algebra:
    def sum(number_1, number_2):
        return number_1 + number_2

def count():
    grapes_ann = 4
    grapes_emma = 5
    algebra = Algebra()
    total_grapes = algebra.sum(grapes_ann, grapes_emma)
    return total_grapes

count()
```

In the AST modifications are performed in the [ast.Name](https://docs.python.org/3/library/ast.html#ast.Name) nodes
changing the value of the attribute id. In the following images it is shown the effect in the AST:

| ![Original AST](./Original_names.png) |
|:--------------------------------------------:|
|                 Original AST                 |

| ![Modified AST](./Changed_names.png) |
|:---------------------------------------------:|
|                 Modified AST                  |

## Change possition of functions

As Python allows you to call functions regardles of the location in a file, then it is possible to change the function's
possition without change the program features. This modification also applies to the functions of a class. The 
following code snippets show the effects of this modification. The first snippet is the original code and the second 
is the modified one:
```python
def add(a, b):
    return a + b

def sub(a, b):
    return a – b

def multiply(a, b):
    return a * b
```

```python
def multiply(a, b):
    return a * b

def add(a, b):
    return a + b

def sub(a, b):
    return a – b
```

In the AST the modifications are made in the body attribute of the classes
[ast.Module](https://docs.python.org/3/library/ast.html#ast.Module) 
and [ast.ClassDef](https://docs.python.org/3/library/ast.html#ast.ClassDef) changing the possition of the 
[ast.FunctionDef](https://docs.python.org/3/library/ast.html#ast.FunctionDef) nodes. In the following images it is shown 
the effect in the AST:

| ![Original AST](./Original_function_position.png) |
|:--------------------------------------------------------:|
|                       Original AST                       |

| ![Modified AST](./Changed_function_position.png) |
|:---------------------------------------------------------:|
|                       Modified AST                        |

## Add "pass"

The reserved word "pass" has no effect on the functionality of a program, but in Python AST it has representation. This 
implies that the reserved word "pass" can be added randombly in the AST without consequences. The following code snippets 
show the effects of this modification. The first snippet is the original code and the second is the modified one:
```python
def add(a, b):
    return a + b

def sub(a, b):
    return a – b

def multiply(a, b):
    return a * b
```

```python
pass
pass
def add(a, b):
    pass
    return a + b

def sub(a, b):
    return a – b

pass

def multiply(a, b):
    pass
    pass
    return a * b
```

In the AST the modifications are made in the body attribute of the classes 
[ast.Module](https://docs.python.org/3/library/ast.html#ast.Module), 
[ast.ClassDef](https://docs.python.org/3/library/ast.html#ast.ClassDef), 
[ast.FunctionDef](https://docs.python.org/3/library/ast.html#ast.FunctionDef), 
[ast.AsyncFunctionDef](https://docs.python.org/3/library/ast.html#ast.AsyncFunctionDef), 
[ast.If](https://docs.python.org/3/library/ast.html#ast.IfExp), 
[ast.For](https://docs.python.org/3/library/ast.html#ast.For), 
[ast.While](https://docs.python.org/3/library/ast.html#ast.While), 
[ast.Try](https://docs.python.org/3/library/ast.html#ast.Try) and
[ast.AsyncFor](https://docs.python.org/3/library/ast.html#ast.AsyncFor). In the following images it is shown the effect 
in the AST:

| ![Original AST](./Without_pass.png) |
|:------------------------------------------:|
|                Original AST                |

| ![Modified AST](./With_pass.png) |
|:-----------------------------------------:|
|               Modified AST                |

## Change integers

This feature consists in the creation of a mathematical expression from an integer that has the same result as the 
integer. The following code snippets show the effects of this modification. The first snippet is the original code and 
the second is the modified one:
```python
water = 15
intake = -5
```

```python
water = 35-19+678//20-34
intake = 789-231%534-563
```

In the AST what we get is change the [ast.Constant](https://docs.python.org/3/library/ast.html#ast.Constant) classes by 
[ast.BinOp](https://docs.python.org/3/library/ast.html#ast.BinOp) ones. In the following images it is shown the effect 
in the AST:

| ![Original AST](./Original_integers.png) |
|:-----------------------------------------------:|
|                  Original AST                   |

| ![Modified AST](./Changed_integers.png) |
|:------------------------------------------------:|
|                   Modified AST                   |

## Change strings

This feature consist in generate a summation of strings from an string. The following code snippets show the effects of 
this modification. The first snippet is the original code and the second is the modified one:
```python
name = 'Adela'
surename = 'Mazaricos'
```

```python
name = 'Ad' + 'ela'
surename = 'Maza' + 'ri' + 'cos'
```

In the AST what we get is change the [ast.Constant](https://docs.python.org/3/library/ast.html#ast.Constant) classes by 
[ast.BinOp](https://docs.python.org/3/library/ast.html#ast.BinOp) ones. In the following images it is shown the effect 
in the AST:

| ![Original AST](./Original_strings.png) |
|:----------------------------------------------:|
|                  Original AST                  |

| ![Modified AST](./Changed_strings.png) |
|:-----------------------------------------------:|
|                  Modified AST                   |

# Other features

The modification of AST is the most interesting part of the tool, but it is worth mentioning some of the features 
whose objective is to facilitate the usability of the tool:

- __Multifile__: The tool can handle multiple files at the same time and also takes into account if the files import 
functions, variables or classes between them.
- __Reparation of integers and strings__: This feature consist in, before make the changes in the AST, search for 
mathematical expressions and summations of strings to return it back to its original value. This way, a 
disproportionate growth of the final result is avoided in the case of executing the tool over the result of a previous 
execution.
- __Deleting "pass"__: Before adding the reserved word "pass" in the code, all occurrences in the AST are searched 
and deleted. This way, a disproportionate growth of the final result is avoided in the case of executing the tool over 
the result of a previous execution.

# Limitations

Even if you do not like to talk about the bad things of something, you have to take it into account to get the most 
out of it. Below are the limitations of the program:

- [Due to the way real numbers are handled in Python](https://docs.python.org/3/tutorial/floatingpoint.html#floating-point-arithmetic-issues-and-limitations), 
they will not be mutated. In the following image you can see the type of errors that can happen:

![A python's error handing floats](./float_problem.png)

- Due to typing in Python is dynamic, you cannot figure out what type variable the programmer is using until the 
program is running. So when PUME is changing names of functions and two classes have the same name for a 
function, it does not know which function belongs to which class. __So the programmer cannot create two functions with 
the same name in different classes. This also applies to the standard libraries.__
In the following example, the programmer is creating a class with a function that shares name with other function of 
the standard library. In this situation, PUME cannot differentiate which function is being called.
```python
class MyClass:
    def __init__(self):
        self.data = ["a", "b", "c", "d"]
    def find(self, a):
        return self.data.index(a)

my_string = "The car is big"
my_string = my_string.find("car")
my_class = MyClass()
position = my_class.find("a")
```

In order to avoid a bug in the mutated program, the programmer has to change the name of the class function that he 
created:
```python
class MyClass:
    def __init__(self):
        self.data = ["a", "b", "c", "d"]
    def search(self, a):
        return self.data.index(a)

my_string = "The car is big"
my_string = my_string.find("car")
my_class = MyClass()
position = my_class.search("a")
```

# Examples

Finally, now that the main features of the tool have been introduced, here are a few examples of use.

## Basic operation

In the following example you can see how a program is executed, how it is modified and how after the modifications the 
program continues to work:

[![asciicast](https://asciinema.org/a/616251.png)](https://asciinema.org/a/616251)

## Antivirus evasion

In the following example, you can see how VirusTotal detects an [Impacket](https://github.com/fortra/impacket) script 
as malicious, then PUME modifies it and, after that, I rescan it to see that VirusTotal no longer detects it.

[![video](https://tube.spdns.org/lazy-static/previews/5a2f4447-4a2b-402c-9fee-da428a56270b.jpg)](https://tube.spdns.org/w/dNr7CSc8UAX8zswrydHtSA)

## Virus creation

At last, a [virus](https://hackliza.gal/en/posts/virus_python/) called [PUMA](https://github.com/Caralludo/PUMA) that
uses the tool as an engine to mutate its own code was created. In the following video it is shown how it works:

[![asciicast](https://asciinema.org/a/616349.png)](https://asciinema.org/a/616349)

# Final words

That's all folks! If you liked the tool or you see how to improve it, leave a comment below or open an issue in the
[repository](https://github.com/Caralludo/PUME). 

Goodbye and see you!

