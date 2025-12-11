---
layout: post
title:  "Solid principles"
description: "Explanation of solid with simple examples"
date:   2025-12-08 20:00:00 +0300
categories: architecture
---
## The Single Responsibility Principle
A module should be responsible to one, and only one, actor, Uncle Bob says.

Suppose we use a class in two different features or screens etc. and the implementation of a method has to be different in these features. A quick fix that violates this principle and may cause big troubles in time is adding a flag parameter in the method and using it in **two different actors**.

Suppose we have a class called **Logger**.
```mermaid
classDiagram
    class Logger
    Logger: +log(message)
```
**To see what these diagrams tell [click here](https://mutkuensert.github.io/pages/class-diagrams-with-mermaid.html).**

Let's say if the program is in debug mode we want to print the message, or if the program is in release mode we don't want to print the message but we want to send the message to a service. If we put a flag parameter called **isDebug** in **log** method for example, what will happen if we also want different behavior for different variants like **testDebug, testRelease, productionDebug** etc. The right way to prevent the complexity is:

```mermaid
classDiagram
    class Logger
    <<interface>> Logger
    Logger: +log(message)

    class Foo
    Foo: -Logger logger
    Foo --> Logger

    class DebugLogger
    DebugLogger --|> Logger

    class ReleaseLogger
    ReleaseLogger --|> Logger
```
Class Foo uses Logger interface. This way, we created different implementations(DebugLogger, ReleaseLogger) for different actors(debug mode, release mode).

## The Open-Closed Principle
*"A software artifact should be open for extension but closed for modification."*

```mermaid
classDiagram
    note for Domain "Highest level code/business rules"
    class Domain
    
    note for Presentation "Views, view logics etc."
    class Presentation

    note for Data "Database, network etc"
    class Data

    Data --> Domain
    Presentation --> Domain
```

or as in the clean architecture book

```mermaid
classDiagram
    note for Interactor "Highest level code/business rules"
    class Interactor
    
    note for Presenter "View logics etc."
    class Presenter

    class View

    note for Data "Database, network etc."
    class Data

    Data --> Interactor
    Presenter --> Interactor
    View --> Presenter
```
One of the most important rules is dependency direction must be in one direction only. If class A uses class B, class B cannot know anything about class A.

The purpose of a program, business rules, they are the highest level code should be protected from changes but open for extension so that the changes that are being made in low level code like ui, database etc. won't affect these business rules. As you see in the graphs, other modules depend on domain(or interactor) module. This means that changes in other modules won't affect them.

## The Liskov Substitution Principle

```mermaid
classDiagram
    class Car
    <<abstract>> Car
    Car: +putGasoline(amount)
    Car: +Int gasoline

    class ElectricCar
    ElectricCar: -Int chargeAmount
    ElectricCar: +charge(amount)
    ElectricCar --|> Car
```
The structure above **forces** the developer to type-check the object to determine if he or she can use the putGasoline method or not. Because if the Car object is an ElectricCar object, using putGasoline method may cause something wrong.

An implementation of a super type must not limit the usage of super type functionalities and must not require type checking so that the the developer can decide to use those functionalities or not.

## The Interface Segregation Principle
```mermaid
classDiagram
    class ImageEditor
    ImageEditor: +compress(qualityPercentage) Bitmap
    ImageEditor: +crop() Bitmap
    ImageEditor --> ImageLibrary

    class FeatureA
    class FeatureB

    FeatureA --> ImageEditor
    FeatureB --> ImageEditor
```
Suppose we use an image processing library and created an ImageEditor class using the library. We use this class in more than one place in our program. In new versions of this library, changes in the internals will cause recompiling of the modules that depend on our class. To fix it:

```mermaid
classDiagram
    class ImageCompressor
    <<interface>> ImageCompressor
    ImageCompressor: +compress(qualityPercentage)

    class ImageCropper
    <<interface>> ImageCropper
    ImageCropper: +crop() Bitmap

    class ImageEditor
    ImageEditor --|> ImageCompressor
    ImageEditor --|> ImageCropper
    ImageEditor --> ImageLibrary

    class FeatureA
    class FeatureB

    FeatureA --> ImageCompressor
    FeatureB --> ImageCropper
```

Now, features depend on interfaces only and new changes in the internals of the library won't affect our features and won't cause recompilation.

## The Dependency Inversion Principle
Dependency inversion is a technique that allows us to change dependency direction and actually we used it in previous principles. This principle promotes concrete classes use/depend on interfaces/abstract classes so that changes in implementation details won't affect the ones using them. Suppose we have 2 classes.

```mermaid
classDiagram
    class A
    class B

    A --> B
```

class A uses class B. To apply dependency inversion:

```mermaid
classDiagram
    class A
    class B
    
    class C
    <<interface>> C

    A --> C
    B --|> C
```
This way, B now implements C interface. A uses C and doesn't depend on implementation details(B) anymore.