addi $1, $0, 3
        addi $2, $0, 1
Start:  beq $1, $0, Finish
        addi $1, $1, $2
        j Start
Finish: add $4, $2, $1