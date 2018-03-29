Fact:	addi $1 $0 1
		addi $2 $0 2
		addi $3 $0 3
		srl  $4 $3 1
		beq  $4 $1 fun


fun: 	lw 	$6 4($0)
		sub $7 $1 $6
		beq $7 $0 skip


skip:  	sw $8 8($0)
		mult $9 $3 $2
		mflo $10
		sw $11 12($0)
		lw $12 12($0)
		j link

link:  	sub $13 $10 $1
		bnq $13 $0 link
		jal dope


dope:	add $14 $1 $3
		sub $15 $14 $3
		beq $14 $15 finish

finish: jr $31				
		

