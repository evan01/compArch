        addi    $1, $0, 10
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
If3:     j Start
Finish: add $4, $2, $1 # PC 56
