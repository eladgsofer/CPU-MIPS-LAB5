.data 
	a: .word 3
	b: .word 2
	c: .word 0
	d: .word 0
	e: .word 0
	f: .word 0
	g: .word 0
	h: .word 0
.text
	lw  $t2,a # a starts in address 0
	lw  $t3,b # b starts in address 4
	add $t4,$t3,$t2
	slti $t4,$t3, 3
	sw  $t4,c # c starts in address 8
	bne $t2, $t3,AFTER
	xor $t4,$t3,$t2
	sw  $t4,d # c starts in address 8'
	move $t3,$t4
AFTER:	and $t4,$t3,$t2
	sw  $t4,e # c starts in address 8
	or $t4,$t3,$t2
	sw  $t4,f # c starts in address 8
	xor $t4,$t3,$t2
	sw  $t4,g # c starts in address 8
	mul $t4,$t3,$t2
	sw  $t4,h # c starts in address 8
 
