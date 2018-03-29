Fact:	addi $1 $0 1
		addi $2 $0 2
		addi $3 $0 3
		addi $4 $0 4               
		addi $7 $0 1
		addi $8 $0 2
		addi $9 $0 3
		bne $1 $0 fun


foo:	sub  $5 $4 $1
		mult $10 $8 $9
		add  $6 $1 $2
		div  $11 $10 $3
		slt $12 $7 $1
		slti $13 $2 1
		lw  $14 3($0)
		or $15 $12 $13
		sw $6 10($0)
		jal dope
		
go:		and $16 $12 $13
		lui $17, 32768
		nor $18 $12 $13
		xor $19 $15 $16
		andi $20 $7 0 
		ori $21 $18 0
		beq $20 $0 skip
		

skip: 	mult $5 $6 $7
		mfhi $22
		addi $28 $0 5
		mflo $23
		sra $29 $28 1
		j easter

fun: 	xori $24 $1 0
		addi $26 $0 5
		sll $25 $4 1
		srl $27 $26 1 
		j foo

dope: 	addi $0 $0 0
		add $30 $0 1
		j go

easter:	jr $31