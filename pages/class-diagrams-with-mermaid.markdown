---
layout: page
title: "Class diagrams with mermaid js"
---
To see more about mermaid js [click here](https://mermaid.js.org/intro/)
#### Class A uses Class B
```mermaid
classDiagram
    class A
    class B

    A --> B
```

#### Class A implements interface B
```mermaid
classDiagram
    class A
    class B
    <<interface>> B

    A --|> B
```

#### Public properties
```mermaid
classDiagram
    class A
    A: +Int count
```

#### Public methods
```mermaid
classDiagram
    class A
    A: +doSomething()
```

#### Private properties
```mermaid
classDiagram
    class A
    A: -Int count
```

#### Private methods
```mermaid
classDiagram
    class A
    A: -doSomething()
```