# TODO: Christian Tonnesen #260847409

.data
TestNumber:	.word 2		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD2		# Procedure used by test 2, set to MADD1 or MADD2		
				
Size:		.word 64		# matrix size (MUST match size of matrix loaded for test 0 and 1)

.align 2
A2:	.word 100,200,300,400
.align 
B2: 	.word 500,600,700,800
.align 2
C2:	.word 0,0,0,0
.align 2
D2:	.word 2,2,2,2

Afname: 	.asciiz "A8.bin"
Bfname: 	.asciiz "B8.bin"
Cfname:		.asciiz "C8.bin"
Dfname:	 	.asciiz "D8.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:		la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
        		syscall	

compareMatrix:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix	# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check
		
		li $v0 10      			# load exit call code 10 into $v0
        	syscall         		# call operating system to exit	

testFromFile:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		#la $a0 A2
		#la $a1 B2
		#la $a2 C2
		#la $a3 2

		move $a0, $s0	# A
		move $a1, $s1	# B
		move $a2, $s2	# C
		move $a3, $s7	# n
		
		la $ra ReturnHere
		la $t0 Proc	# function pointer
		lw $t0 ($t0)	
		jr $t0		# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	move $a0 $s2	# C
		move $a1 $s3	# D
		move $a2 $s7	# n
		jal check	# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
	        	syscall         	# call operating system to exit	

compareMADD:	la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

###############################################################
# mallocMatrix( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0	
mallocMatrix: 	mul  $a0, $a0, $a0		# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall				# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  	# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
					# $v0 contains number of characters read (0 if end-of-file, negative if error).
                			# We'll assume that we do not need to be checking for errors!
					# Note, the bitmap display doesn't update properly on load, 
					# so let's go touch each memory address to refresh it!
		move $t0 $a3		# start address
		add $t1 $a3 $a2  	# end address
loadloop:	lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16	# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	li $v0 43
		syscall		# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	sw $zero 0($a0)	# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra



######################################################
# TODO: void subtract( float* A, float* B, float* C, int N )  C = A - B 
subtract: 	la $t0 ($a0)
		la $t1 ($a1)
		la $t2 ($a2)
		move $t3 $a3
		mul $t3 $t3 $t3				# Stores N^2 in $t3 for traversal
		li $t4 0				# Initialize $t4 as our counter
		subLoop:	beq $t4 $t3 SubLeave
				lwc1 $f2 0($t0)
				lwc1 $f4 0($t1)
				sub.s $f6 $f2 $f4
				swc1 $f6 ($t2)		# Load the values from A and B, subtract, then store again
				addi $t0 $t0 4
				addi $t1 $t1 4
				addi $t2 $t2 4		# Move forward the pointers in A, B and C (actually A)
				addi $t4 $t4 1		# Increment the counter
				j subLoop
				
		SubLeave:	jr $ra

#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm: la $t0 ($a0)				
		move $t1 $a1		
		mul $t1 $t1 $t1				# Stores N^2 in $t1 for traversal
		li $t2 0
		mtc1 $zero $f6 				#zeroes out $f6
		frobLoop:	beq $t2 $t1 frobLeave	
				lwc1 $f4 ($t0)
				mul.s $f4 $f4 $f4	# Squares current value
				add.s $f6 $f6 $f4  	# Adds to running total
				addi $t0 $t0 4
				addi $t2 $t2 1		# Increment $t2 and move pointer in matrix
				j frobLoop
				
		frobLeave:	sqrt.s $f0 $f6		# sqrt and store into $f0
				jr $ra

#################################################
# TODO: void check ( float* C, float* D, int N )
# Print the forbeneous norm of the difference of C and D
check: 		move $a3 $a2			# Move N into $a3
		la $a2 ($a0)			
		addi $sp $sp -4					
		sw $ra 0($sp)			# Store the pointer for the return address in the stack	
		jal subtract
		move $a1 $a3			# Set function argument variables 
		jal frobeneousNorm
		mov.s $f12 $f0			# Pulls the norm out of the return register
		li $v0 2
		syscall
		lw $ra 0($sp)			# Put return address back in $ra
		addi $sp $sp 4
		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )
MADD1: 		move $t0 $a3	# n
		li $t1 0	# i
		li $t2 0	# j
		li $t3 0	# k
		mul $t9 $t0 4		# Figures out how many bytes in a single row
		
		rowLoop:	beq $t1 $t0 MADD1LeaveL
				j colLoop	
		rowFinal: 	addi $t1 $t1 1
				li $t2 0		# Set j to 0 again 
				j rowLoop 
				
				colLoop:	beq $t2 $t0 rowFinal		
						j sumLoop
				colFinal:	addi $t2 $t2 1
						li $t3 0		# Set k to 0 again 
						j colLoop
						
						sumLoop:	beq $t3 $t0 colFinal
								mul $t4 $t9 $t1		# Calculates overall row (bytes in row * current row num)
								mul $t5 $t2 4		# Calculates overall col in row (current col number * 4)
								add $t6 $t5 $t4		# C Location Offset (Start row + start col)
								add $t6 $t6 $a2		# Loads Mem Address of C[i][j]
								lwc1 $f3 ($t6)		# C value into $f3			
								mul $t7 $t3 $t9 	# Calculate third loop row offset (k * bytes in row)
								mul $t8 $t3 4		# Calculate third loop col offset (k * byte block)
								add $t4 $t8 $t4		# A location Offset (Start row + k col)
								add $t5 $t7 $t5		# B Location Offset (Start col + k row)	
								add $t4 $t4 $a0		# Loads Mem Address of A[i][k]
								add $t5 $t5 $a1		# Loads Mem Address of B[k][j]
								lwc1 $f1 ($t4)		# A value into $f1
								lwc1 $f2 ($t5)		# B value into $f2
								mul.s $f2 $f2 $f1	# Multiply A and B value
								add.s $f3 $f3 $f2	# Add product to total
								swc1 $f3 ($t6)		# Store sum back into C
								addi $t3 $t3 1		
								j sumLoop 
							
		MADD1LeaveL: 	jr $ra

#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 		move $t0 $a3	# n
		li $t1 0	# jj
		li $t2 0	# kk
		li $t3 0	# i
		li $t4 0	# j
		li $t5 0	# k
		li $t6 0	
		li $t7 0	
		li $t8 0
		li $t9 0	
		mul $t9 $t0 4		# Figures out how many bytes in a single row
		
		JJLoop: 	bge $t1 $t0 MADD2LeaveL
				j KKLoop
		JJFinal:	addi $t1 $t1 4
				li $t2 0		# Resets KK to 0
				j JJLoop
				
				KKLoop:		bge $t2 $t0 JJFinal
						j ILoop
				KKFinal:	addi $t2 $t2 4
						li $t3 0		# Resets i to 0
						j KKLoop
						
						ILoop:		bge $t3 $t0 KKFinal
								move $t4 $t1			# Sets J = JJ 
								j JLoop
						IFinal:		addi $t3 $t3 1
								j ILoop
								
								JLoop:		addi $t6 $t1 4		# Calculates JJ + bsize
										blt $t6 $t0 MinJ	# Decides which is lower
										bge $t4 $t0 IFinal
										j JJump
								MinJ:		bge $t4 $t6 IFinal
								JJump:		mtc1 $zero $f3 		# Zeroes out $f3
										move $t5 $t2		# Sets K = KK
										j KLoop
								JFinal:		mul $t6 $t3 $t9 		# Calculate i row offset (i * bytes in row)
										mul $t7 $t4 4			# Calculate j col offset (j * byte block)
										add $t7 $t7 $t6			
										add $t7 $t7 $a2			# $t7 holds C[i][j]
										lwc1 $f4 ($t7)			# Load C[i][j]
										add.s $f4 $f4 $f3		# Add value from K Loop Sum
										swc1 $f4 ($t7)			# Store value back into C[i][j]
										addi $t4 $t4 1
										j JLoop
										
										KLoop:	addi $t6 $t2 4		# Calculates JJ + bsize
											blt $t6 $t0 MinK	# Decides which is lower
											bge $t5 $t0 JFinal
											j KJump	
										MinK:	bge $t5 $t6 JFinal
										KJump:	mul $t6 $t3 $t9 	# Calculate i row offset (i * bytes in row)
											mul $t7 $t5 4		# Calculate k col offset (k * byte block)
											add $t6 $t7 $t6		
											add $t6 $t6 $a0		# $t6 holds a[i][k]
											mul $t7 $t5 $t9		# Calculate k row offset (k * bytes in row)
											mul $t8 $t4 4		# Calculate j col offset (j * byte block)
											add $t8 $t8 $t7
											add $t8 $t8 $a1		# $t8 holds b[k][j]
											lwc1 $f1 ($t6)		# A value into $f1
											lwc1 $f2 ($t8)		# B value into $f2 
											mul.s $f2 $f2 $f1	# Multiply A and B value
											add.s $f3 $f3 $f2	# Add to sum
											addi $t5 $t5 1
											j KLoop
												 
	MADD2LeaveL:	jr   $ra
