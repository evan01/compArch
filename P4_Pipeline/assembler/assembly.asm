#Computes the factorial of the input in $1

Fact: 	addi $1, $0, 5 #input, n=5
		addi $2, $0, 1
Loop:	slti $3, $1, 2
		bne $3, $0, Skip
		mult $1, $2
		mflo $2
		addi $1, $1, -1
		j Loop
Skip:	jr $31