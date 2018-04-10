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
```
        addi $1, $0, 0
        addi $2, $0, 0
        addi $3, $0, 100
Loop:   beq  $3, $2, END
        addi $2, $2, 1
        j Loop
END:    addi $1, $0, 1
```

#### Machine Code
```
00100000000000010000000000000000
00100000000000100000000000000000
00100000000000110000000001100100
00010000011000100000000000000010
00100000010000100000000000000001
00001000000000000000000000000011
00100000000000010000000000000001
```

### 2. For loop, 3 if statements
#### Code
```java 
    int a = 0;
    for (i=0;i<3;i++){
        if(a == 0){
            a=1;
        }
        if(a == 1){
            a=2;
        }
        if(a == 2){
            a = 3;
        }
        a = 0;
    }
```
#### Assembly
```
        addi $1, $0, 0 # a=0
        addi $2, $0, 0
        addi $3, $0, 3
        addi $4, $0, 0

loop:   beq $3, $2, end

if1:    bne $1, $4, if2
        addi $1, $0, 1
        addi $4, $0, 1

if2:    bne $1, $4, if2
        addi $1, $0, 2
        addi $4, $0, 2

if3:    bne $1, $4, if2
        addi $1, $0, 3
        addi $4, $0, 3
        
        addi $2, $2, 1
        j loop

end:    addi $1, $0, 1
```
#### Machine Code
```
00100000000000010000000000000000
00100000000000100000000000000000
00100000000000110000000000000011
00100000000001000000000000000000
00010000011000100000000000001011
00010100001001000000000000000010
00100000000000010000000000000001
00100000000001000000000000000001
00010100001001001111111111111111
00100000000000010000000000000010
00100000000001000000000000000010
00010100001001001111111111111100
00100000000000010000000000000011
00100000000001000000000000000011
00100000010000100000000000000001
00001000000000000000000000000100
00100000000000010000000000000001
```

### 3. Factorial calculator 10!
#### Code
```java
    int a = 5;
    int result = 1;
    
    while (a > 0){
        result = a*result;
        a--;
    }
```

#### Assembly
```
        addi $1, $0, 5
        addi $2, $0, 4
loop:   beq $2, $0, end
        mult $1, $2
        mflo $1
        addi $2, $2, -1
        j loop
end:    addi $1, $0, -1
```
#### Machine Code
```
00100000000000010000000000000101
00100000000000100000000000000100
00000000000000000000000000000000
00010000010000000000000000000100
00000000000000000000000000000000
00000000001000100000000000011000
00000000000000000000100000010010
00100000010000101111111111111111
00001000000000000000000000000010
00100000000000011111111111111111
```

### 4. 3 Sequential branch statements
#### Code
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
#### Assembly
```
        addi $1, $0, 1
        addi $2, $0, 3
        addi $3, $0, 3
if1:    bne $2, $1, if2
if2:    bne $2, $3, if3
        addi $2, $0, 4
if3:    bne $2, $1, end
end:    addi $1, $0, -1
```
#### Machine Code
```
00100000000000010000000000000001
00100000000000100000000000000011
00100000000000110000000000000011
00010100010000010000000000000000
00010100010000110000000000000001
00100000000000100000000000000100
00010100010000010000000000000000
00100000000000011111111111111111
```
### 5. Every second branch statement taken loop to 10
#### Code

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
#### Assembly
```
        addi $1, $0, 0
        addi $2, $0, 10
        addi $3, $0, 0 #a=0
loop:   beq $1, $2, end
        bne $0, $3, else
        addi $3, $0, 1
        addi $1, $1, 1
        j loop
else:   addi $3, $0, 0
end:    addi $4, $0, -1
```
#### Machine Code
```
00100000000000010000000000000000
00100000000000100000000000001010
00100000000000110000000000000000
00010000001000100000000000000101
00010100000000110000000000000011
00100000000000110000000000000001
00100000001000010000000000000001
00001000000000000000000000000011
00100000000000110000000000000000
00100000000001001111111111111111
```
### 6. Infinite for loop, 1 if statement, counter
#### Code

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

#### Assembly
```
        addi $1, $0, 2
        addi $2, $0, 1
        addi $3, $0, 1
loop:   beq $0, $1, end
        bne $2, $3, else
        addi $3, $0, 0
else:   addi $3, $0, 1
        j loop
end:    addi $5, $0, -1
```
#### Machine Code
```
00100000000000010000000000000010
00100000000000100000000000000001
00100000000000110000000000000001
00010000000000010000000000000100
00010100010000110000000000000001
00100000000000110000000000000000
00100000000000110000000000000001
00001000000000000000000000000011
00100000000001011111111111111111
```

## Results
|Test a | No-Branch Prediction (Clock Cycles)| W/ Branch Prediction (Clock Cycles)|
|----| --------------------| --------------------|
| 0-100 For Loop| 0 | 414 |
| 3 If Statements For Loop| 0 | 71 |
| Factorial Calculator| NOT WORKING | 36 |
| Sequential Branch Statements| 0 | 14 |
| Every Second Branch Taken Loop|0| 18 |
| Infinite For Loop (Only 20 iterations taken) NOT A GOOD TEST | 0|0 | 