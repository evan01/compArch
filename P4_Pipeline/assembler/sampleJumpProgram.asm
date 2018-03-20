Fact: 	addi $1, $0, 1
		addi $2, $0, 2
		addi $3, $0, 3
Loop:	beq $3, $0, Skip
		addi $3, $0, -1
		j Loop
		
Skip: 	j Evan

Evan: 	addi $1, $0, 1
		addi $2, $0, 2
		addi $3, $0, 3
		jr $31
