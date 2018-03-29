Start:  addi $1, $0, 12
        addi $2, $0, 12
        sw $1,40($0)
        sw $2,44($0)
        lw $3,40($0)
        beq $1, $2, Finish

Finish: add $4, $2, $$1
        jr $31
