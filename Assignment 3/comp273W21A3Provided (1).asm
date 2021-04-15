# TODO: PUT YOUR NAME AND STUDENT NUMBER HERE!!!
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE
# TODO: NOTICE THE TODO IN THE .DATA SEGMENT
# TODO: RENAME THIS FILE AS PER THE SUBMISSION REQUIREMENTS

# Menu options
# r - read text buffer from file 
# p - print text buffer
# e - encrypt text buffer
# d - decrypt text buffer
# w - write text buffer to file
# g - guess the key
# q - quit

.data
MENU:              .asciiz "Commands (read, print, encrypt, decrypt, write, guess, quit):"
REQUEST_FILENAME:  .asciiz "Enter file name:"
REQUEST_KEY: 	 .asciiz "Enter key (upper case letters only):"
REQUEST_KEYLENGTH: .asciiz "Enter a number (the key length) for guessing:"
REQUEST_LETTER: 	 .asciiz "Enter guess of most common letter:"
ERROR:		 .asciiz "There was an error.\n"

FILE_NAME: 	.space 256	# maximum file name length, should not be exceeded
KEY_STRING: 	.space 256 	# maximum key length, should not be exceeded


.align 2		# ensure word alignment in memory for text buffer (not important)
TEXT_BUFFER:  	.space 10000
.align 2		# ensure word alignment in memory for other data (probably important)
FREQARR:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
# TODO: define any other spaces you need, for instance, an array for letter frequencies

##############################################################
.text
		move $s1 $0 	# Keep track of the buffer length (starts at zero)
MainLoop:	li $v0 4		# print string
		la $a0 MENU
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s0 $v0	# store command in $s0			
		jal PrintNewLine

		beq $s0 'r' read
		beq $s0 'p' print
		beq $s0 'w' write
		beq $s0 'e' encrypt
		beq $s0 'd' decrypt
		beq $s0 'g' guess
		beq $s0 'q' exit
		b MainLoop

read:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 0		# flags (read)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 read2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		
read2:		li $v0 14	# read file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		li $a2 9999
		syscall
		move $s1 $v0	# save the input buffer length
		bge $s0 0 read3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		move $s1 $0	# set buffer length to zero
		la $t0 TEXT_BUFFER
		sb $0 ($t0) 	# null terminate the buffer 
		b MainLoop
		
read3:		la $t0 TEXT_BUFFER
		add $t0 $t0 $s1
		sb $0 ($t0) 	# null terminate the buffer that was read
		li $v0 16	# close file
		move $a0 $s0
		syscall
		la $a0 TEXT_BUFFER
		jal ToUpperCase
		
print:		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop	

write:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 1		# flags (write)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 write2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		
write2:		li $v0 15	# write file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		move $a2 $s1	# set number of bytes to write
		syscall
		bge $v0 0 write3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		write3:
		li $v0 16	# close file
		move $a0 $s0
		syscall
		b MainLoop

encrypt:	jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal EncryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

decrypt:	jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal DecryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

guess:		li $v0 4		# print string
		la $a0 REQUEST_KEYLENGTH
		syscall
		li $v0 5		# read an integer
		syscall
		move $s2 $v0
		
		li $v0 4		# print string
		la $a0 REQUEST_LETTER
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s3 $v0	# store command in $s0			
		jal PrintNewLine

		move $a0 $s2
		la $a1 TEXT_BUFFER
		la $a2 KEY_STRING
		move $a3 $s3
		jal GuessKey
		li $v0 4		# print String
		la $a0 KEY_STRING
		syscall
		jal PrintNewLine
		b MainLoop

exit:		li $v0 10 	# exit
		syscall

###########################################################
PrintBuffer:	li $v0 4          # print contents of a0
		syscall
		li $v0 11	# print newline character
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintNewLine:	li $v0 11	# print char
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintSpace:	li $v0 11	# print char
		li $a0 ' '
		syscall
		jr $ra

#######################################################
GetFileName:	addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_FILENAME
		syscall
		li $v0 8		# read string
		la $a0 FILE_NAME  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 FILE_NAME 
		jal TrimNewline
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
GetKey:		addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_KEY
		syscall
		li $v0 8		# read string
		la $a0 KEY_STRING  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 KEY_STRING
		jal TrimNewline
		la $a0 KEY_STRING
		jal ToUpperCase
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
# Given a null terminated text string pointer in $a0, if it contains a newline
# then the buffer will instead be terminated at the first newline
TrimNewline:	lb $t0 ($a0)
		beq $t0 '\n' TNLExit
		beq $t0 $0 TNLExit	# also exit if find null termination
		addi $a0 $a0 1
		b TrimNewline

TNLExit:	sb $0 ($a0)
		jr $ra

##################################################
# converts the provided null terminated buffer to upper case
# $a0 buffer pointer
ToUpperCase:	lb $t0 ($a0)
		beq $t0 $zero TUCExit
		blt $t0 'a' TUCSkip
		bgt $t0 'z' TUCSkip
		addi $t0 $t0 -32	# difference between 'A' and 'a' in ASCII
		sb $t0 ($a0)

TUCSkip:	addi $a0 $a0 1
		b ToUpperCase

TUCExit:	jr $ra

###################################################
# END OF PROVIDED CODE... 
# TODO: use this space below to implement required procedures
###################################################

StrLen: la $s1 0($a2) 					# Load $a2 in $s1
	li $t0 0
	li $t1 0					# Initialize length counter
	StrLenLoop:	add $s1 $t0 $a2
			lb $t1 0($s1)			# Loads value in buffer to $t1	
	 		beqz $t1 StrLenExit
	 		addi $t0 $t0 1
	 		j StrLenLoop
	 		
	StrLenExit: 	li $v0 0
	 		add $v0 $v0 $t0
	 		jr $ra
	



##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
EncryptBuffer:	addi $sp $sp -4					# Move stack down
		sw $ra 0($sp)					# Store return address in stack
		la $a2 0($a1)					# Stores key location in $a2
		jal StrLen
		li $t8 0
		add $t8 $t8 $v0					# Put StrLen of Key in $t8
		lw $ra 0($sp)					# Put return address back in $ra
		addi $sp $sp 4					# Move stack up
		li $t0 0					# Initialize buffer counter
		EncryptLoop: 	add $s0 $a0 $t0			# Gets us to next position in buffer	
				lb $t2 0($s0)			# Loads value in buffer to $t2
				beqz $t2 EncryptExit		# Exits loop if Null Terminating Character
				blt $t2 'A' NotLetterE 		# If less than A, go to NotLetter
				bgt $t2 'Z' NotLetterE 		# If greater than Z, go to NotLetter
				div $t0 $t8			# Calculate keyPos % keySize 
				mfhi $t3			# Place remainder in $t3
				add $s1 $a1 $t3			# Position us on correct value of key
				lb $t4 0($s1)			# Load shift from key into $t4
				addi $t5 $t2 -65		# Bring us down to 0
				addi $t4 $t4 -65		# Brings key value down to addition value
				add $t5 $t5 $t4			# Calculate new position
				li $t6 26
				div $t5 $t6
				mfhi $t3
				addi $t3 $t3 65
				sb $t3 0($s0)
				addi $t0 $t0 1
				bnez $t0 EncryptLoop
				
		EncryptExit:	jr $ra
		
		
		NotLetterE:    addi $t0 $t0 1			# Increments buffer counter
				j EncryptLoop

##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
DecryptBuffer:	addi $sp $sp -4					# Move stack down
		sw $ra 0($sp)					# Store return address in stack
		la $a2 0($a1)					# Stores key location in $a2
		jal StrLen
		li $t8 0
		add $t8 $t8 $v0					# Put StrLen of Key in $t8
		lw $ra 0($sp)					# Put return address back in $ra
		addi $sp $sp 4					# Move stack up
		li $t0 0					# Initialize buffer counter
		li $t1 0					# Initialize key counter
		
		DecryptLoop: 	add $s0 $a0 $t0			# Gets us to next position in buffer	
				lb $t2 0($s0)			# Loads value in buffer to $t2
				beqz $t2 EncryptExit		# Exits loop if Null Terminating Character
				blt $t2 'A' NotLetterD 		# If less than A, go to NotLetter
				bgt $t2 'Z' NotLetterD		# If greater than Z, go to NotLetter
				div $t1 $t8			# Calculate keyPos % keySize 
				mfhi $t3			# Place remainder in $t3
				add $s1 $a1 $t3			# Position us on correct value of key
				lb $t4 0($s1)			# Load shift from key into $t4
				addi $t5 $t2 -65		# Bring us down to 0
				addi $t4 $t4 -65		# Brings key value down to addition value 
				sub $t3 $t5 $t4		
				blt $t3 $zero Negative
				addi $t3 $t3 65
				sb $t3 0($s0)
		
		PostAddition:	addi $t0 $t0 1
				addi $t1 $t1 1
				bnez $t0 DecryptLoop
		
		Negative:	addi $t3 $t3 26
				addi $t3 $t3 65
				sb $t3 0($s0)
				j PostAddition
				
		DecryptExit:	jr $ra
		
		NotLetterD:     addi $t0 $t0 1			# Increments buffer counter
				addi $t1 $t1 1
				j DecryptLoop

###########################################################
# a0 keySize - size of key length to guess
# a1 Buffer - pointer to null terminated buffer to work with
# a2 KeyString - on return will contain null terminated string with guess
# a3 common letter guess - for instance 'E' 
BufferClear:	li $t0 0
		la $t1 FREQARR
	BufferClearInnerL:	add $t3 $t1 $t0
				sw $zero 0($t3)
				addi $t0 $t0 4 	
				beq $t0 100 GuessKeyPosAfter			#Is there faster way to clear a buffer? Also, is 104 right (26*4)?
				j BufferClearInnerL

GuessKey:	li $s0 0
		li $s1 0
		
	GuessKeyPosLoop:	beq $s0 $a0 GuessExit
				j BufferClear
	GuessKeyPosAfter:	la $s1 FREQARR
				li $t0 0					# $t0 will be our position in the null-terminated buffer
				li $t1 0					# Will compared modulo position to current key pos
				li $t2 0
				li $t3 0
				li $t4 0
				li $t5 0

				GuessBufferIterator:	add $s2 $a1 $t0	 	 
							lb $t2 0($s2)		# Loads value of whatever's in $t2
							beqz $t2 EndOfList	# Exits loop if Null Terminating Character
							div $t0 $a0		# Divides pos number by length
							mfhi $t1
							bne $t1	$s0 NotMatch	# If current position isn't equal to key, skip
							blt $t2 'A' NotLetterG 		
							bgt $t2 'Z' NotLetterG
							subi $t4 $t2 65		# Scale ASCII value down to 0 - 25
							li $t5 4
							mult $t4 $t5		# Add requisite amount of 4's to attain position in FREQARR
							mflo $t4		# Gets the amount to shift pointer to FREQARR by
							add $t4 $t4 $s1		# Gets to corresponding in array
							lb $t5 0($t4)		# Load current value from position into $t5
							addi $t5 $t5 1		# Increment value by 1
							sb $t5 0($t4)		# Store incremented value back in FREQARR
							add $t0 $t0 $a0
							j GuessBufferIterator
							
			NotLetterG:   	add $t0 $t0 $a0				# Increments buffer counter
					j GuessBufferIterator
			
			NotMatch:	addi $t0 $t0 1
					j GuessBufferIterator
			
			EndOfList:	li $t0 0				# Incrementer
					li $t1 0				# Value within FreqArr
					li $t2 0				# Highest Value
					li $t3 0				# Highest Increment Character Value
					li $s2 0				# FREQARR Location
					li $t4 4
					EoLLoop: 	beq $t0 104 EndOfListAL
							add $s2 $s1 $t0	 	 
							lb $t1 0($s2)
							bgt $t1 $t2 Highest
							addi $t0 $t0 4		# Increments
							j EoLLoop
							
					Highest:	li $t2 0
							li $t3 0
							div $t0 $t4		
							mflo $t3		# Grabs character value
							addi $t3 $t3 65		# Stores new highest character
							add $t2 $t2 $t1		# Stores new highest number
							addi $t0 $t0 4		# Increments
							j EoLLoop	
									
			EndOfListAL:	li $t1 0
					li $t4 0
					li $t5 0
					sub $t1 $t3 $a3
					blt $t1 0 NegativeEnd
					li $t0 0
					addi $t3 $t1 65
			BackToStoring:	add $t0 $s0 $a2
					sb $t3 0($t0)
					addi $s0 $s0 1
					j GuessKeyPosLoop
					
			NegativeEnd: 	addi $t4 $t1 26
					addi $t4 $t4 65
					move $t3 $t4
					j BackToStoring
									
GuessExit:		jr $ra	
		





