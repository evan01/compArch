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
### 6. Random Branch and Loop Program
#### Code

```java
    int a = 10;
    int b = 1;
    int c = 0;
    int d = 2;
    while(a > 0){
        a = a - 1;
        if(c = 0){
            c = 1
        }
        if(c = 1){
            c = 2;
        }
        if(c = 2){
            c = 0;
        }
    }
    d = 1;
```

#### Assembly
```
        addi $1, $0, 10
        addi $2, $0, 1
        addi $3, $0, 0
        addi $4, $0, 2
Start:  beq $1, $0, Finish #PC 16
        sub $1, $1, $2
        bne $3, $0, If1 #PC 24
        addi $3, $0, 1
If1:    bne $3, $2, If2 # PC 32
        addi $3, $0, 2
        j Start
If2:    bne $3, $4, Start #PC 44
        addi $3, $0, 0
If3:    j Start
Finish: add $4, $2, $1 # PC 56
```
#### Machine Code
```
00100000000000010000000000001010
00100000000000100000000000000001
00100000000000110000000000000000
00100000000001000000000000000010
00010000001000000000000000001001
00000000001000100000100000100010
00010100011000000000000000000100
00100000000000110000000000000001
00010100011000100000000000000010
00100000000000110000000000000010
00001000000000000000000000000100
00010100011001001111111111111000
00100000000000110000000000000000
00001000000000000000000000000100
00000000010000010010000000100000
```

### 7. Taken - Taken
####Code
```java
    int a = 1;
    int b = 1;
    for(int i=0; i<10; i++){
        if(a = 2){
            a = 1;
        }
        if(b = 2){
            b = 1
        }
        a = 1;
        b = 1;
    }
```
#### Assembly
```
        addi $1, $0, 1
        addi $2, $0, 1
        addi $3, $0, 0 #loop counter
        addi $4, $0, 10 #loop stop
        addi $5, $0, 2 #dummy comparator
loop:   beq $3, $4, end
        bne $1, $5, if2
if1:    addi $1, $0, 1
if2:    bne $2, $5, endif
endif:  addi $1, $0, 1
        addi $2, $0, 1
        addi $3, $3, 1
        j loop
end: addi $10, $0, -1
```
#### Machine Code
```
00100000000000010000000000000001
00100000000000100000000000000001
00100000000000110000000000000000
00100000000001000000000000001010
00100000000001010000000000000010
00010000011001000000000000000111
00010100001001010000000000000001
00100000000000010000000000000001
00010100010001010000000000000000
00100000000000010000000000000001
00100000000000100000000000000001
00100000011000110000000000000001
00001000000000000000000000000101
00100000000010101111111111111111

```
### 8. Taken - Not-Taken
#### Code
```java
    int b = 1;
    for(int i=0; i<10; i++){
        if(b = 0){
            b = 1;
        } else {
            b = 0
        }
    }
```
#### Assembly
```
        addi $1, $0, 1
        addi $3, $0, 0 #loop counter
        addi $4, $0, 10 #loop stop
loop:   beq $3, $4, end
        addi $3, $3, 1
        bne $1, $0, else
        addi $1, $0, 1
        j loop
else:   addi $1, $0, 0
        j loop        
end: addi $10, $0, -1
```
#### Machine Code
```
00100000000000010000000000000001
00100000000000110000000000000000
00100000000001000000000000001010
00010000011001000000000000000110
00100000011000110000000000000001
00010100001000000000000000000010
00100000000000010000000000000001
00001000000000000000000000000011
00100000000000010000000000000000
00001000000000000000000000000011
00100000000010101111111111111111
```

### 9. Not-Taken - Taken
####Code
```java
    int b = 1;
    for(int i=0; i<10; i++){
        if(b = 1){
            b = 0;
        } else{
            b = 1
        }
    }
```
#### Assembly
```
        addi $1, $0, 1
        addi $2, $0, 0
        addi $3, $0, 10
        addi $4, $0, 1
loop:   beq $2, $3, end
        addi $2, $2, 1
        bne $1, $4, else
        addi $1, $0, 0
        j end
else:   addi $1, $0, 1
end: addi $10, $0, -1
```
#### Machine Code
```
00100000000000010000000000000001
00100000000000100000000000000000
00100000000000110000000000001010
00100000000001000000000000000001
00010000010000110000000000000110
00100000010000100000000000000001
00010100001001000000000000000010
00100000000000010000000000000000
00001000000000000000000000001011
00100000000000010000000000000001
00001000000000000000000000000100
00100000000010101111111111111111

```

### 10. Not-Taken - Not-Taken
#### Code
```java
    int b = 1;
    for(int i=0; i<10; i++){
        if(b = 1){
            b = 1;
        }
    }

```
#### Assembly
```
        addi $1, $0, 1
        addi $2, $0, 0
        addi $3, $0, 10
        addi $4, $0, 1
loop:   beq $2, $3, end
        addi $2, $2, 1
        bne $1, $4, else
        addi $1, $1, 0
        addi $7, $0, 0
else:   j loop
end: addi $10, $0, -1
```
#### Machine Code
```
00100000000000010000000000000001
00100000000000100000000000000000
00100000000000110000000000001010
00100000000001000000000000000001
00010000010000110000000000000101
00100000010000100000000000000001
00010100001001000000000000000010
00100000001000010000000000000000
00100000000001110000000000000000
00001000000000000000000000000100
00100000000010101111111111111111
```

### 11. Taken,Taken,Taken -> Not-Taken
#### Code
```java
    for(int i=0; i<10; i++){
        if(i == 6){
            z = -1;
        }
    }

```
#### Assembly
```
addi $1, $0, 0 #b = 0
addi $2, $0, 0
addi $3, $0, 10
addi $4, $0, 6
loop:   beq $2, $3, end
addi $2, $2, 1
bne $2, $4, else #24
addi $5, $0, -1
else:   j loop #32
end: addi $10, $0, -1

```
#### Machine Code
```
00100000000000010000000000000000
00100000000000100000000000000000
00100000000000110000000000001010
00100000000001000000000000000110
00010000010000110000000000000100
00100000010000100000000000000001
00010100010001000000000000000001
00100000000001011111111111111111
00001000000000000000000000000100
00100000000010101111111111111111


```

### 12. Not-Taken-Not-Taken-Not-Taken -> Taken
#### Code
```java
    int b = 0
    for(int i=0; i<10; i++){
        if(b < 3){
            b += 1;
        }
    }

```
#### Assembly
```
        addi $1, $0, 0
        addi $2, $0, 0
        addi $3, $0, 10
        addi $4, $0, 3
loop:   beq $2, $3, end
        addi $2, $2, 1
        beq $2, $4, st_tak
        addi $7, $0, 20
        addi $8, $0, 20
        beq $1, $4, else
        addi $5, $0, -1
else:   j loop

st_tak: addi $1, $0, 3
        j loop
end: addi $10, $0, -1
```
#### Machine Code
```
00100000000000010000000000000000
00100000000000100000000000000000
00100000000000110000000000001010
00100000000001000000000000000011
00010000010000110000000000001001
00100000010000100000000000000001
00010000010001000000000000000101
00100000000001110000000000010100
00100000000010000000000000010100
00010000001001000000000000000001
00100000000001011111111111111111
00001000000000000000000000000100
00100000000000010000000000000011
00001000000000000000000000000100
00100000000010101111111111111111

```
## Results
|Test a | No-Branch Prediction (Clock Cycles)| W/ Branch Prediction (Clock Cycles)|
|----| --------------------| --------------------|
| 1. 0-100 For Loop| 416 | 414 |
| 2. 3 If Statements For Loop| 72 | 71 |
| 3. Factorial Calculator| 36 | 36 |
| 4. Sequential Branch Statements| 15 | 14 |
| 5. Every Second Branch Taken Loop| 19 | 18 |
| 6. Every Branch Taken Loop |  96 | 96 |
| 7. Taken Taken |  122 | 113 |
| 8. Taken - Not Taken |  76 | 75 |
| 9. Not-Taken Taken |  22 | 22 |
| 10. Not-Taken Not-Taken |  80 | 80 |
| 11. Taken, Taken, Taken - Not-Taken |  124 | 121 |
| 12. Not-Taken, Not-Taken, Not-Taken |  109 | 104 |
