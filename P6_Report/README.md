# P6 Experiments and Benchmarking of a Processor with Corelated Branch Prediction

## Implementation
We decided to add general corelated branch prediction to our pipelined mips 32bit processor.

## Benchmarking
Using modelsim, we ran a suite of benchmark programs on the processor with branch prediction and measured their performance relative to our processor without branch prediction.

## Tests

### 1. 0 to 100 for loop counter
#### Code
```java
    int a = 0;
    for (i=0;i<100;i++){
        a = i;
    }
```
#### Assembly

### 2. For loop, 3 if statements
```java 
    int a = 0;
    for (i=0;i<3;i++){
        if(a == 0){
            a=1;
        }
        if(a == 1){
            i=2;
        }
        if(a == 2){
            a = 3;
        }
        a = 0;
    }
```

### 3. Factorial calculator 10!
```java
    int a = 5;
    int result = 1;
    while (a > 0){
        result = a*result;
        a--;
    }
```

### 4. 3 Sequential branch statements
```java
    int a = 3;
    int b = 2;
    if(a = 1){
        b = 2;
    }
    if(a = 3){
        b = 1 //This should be set
    }
    if(a = 4){
        b = 2
    }
```

### 5. Every second branch statement taken loop to 10
```java
    int a = 0;
    for (i=0;i<10;i++){
        if(a == 0){
            a = 1; 
        } else {
            a = 0;
        }
    }
```

### Infinite for loop, multiple branches
```java
    int b = 2;
    int counter = 0;
    while(1){
        counter ++;
        if(a = 1){
            b = 2;
        }
        if(a = 3){
            b = 1 //This should be set
        }
        if(a = 4){
            b = 2
        }
    }
```