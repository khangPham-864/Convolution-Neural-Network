.data	
	bufferread: .space 1000 	# Buffer to store file content
	fileO: .asciiz "D:\\KHANG\\BK\\Sem 4.1\\Computer Architecture\\Lab\\Assignment\\input_matrix.txt"          
	filename: .asciiz "D:\\KHANG\\BK\\Sem 4.1\\Computer Architecture\\Lab\\Assignment\\output matrix.txt"              
	newline: .asciiz "\n"
	space: .asciiz " "
	error_open: .asciiz "File is not exist!"
	invalid_size_str: .asciiz "Invalid kernel size!"
	
	# For file printing
	buffer_write: .space 10000
	dot: .word 0x0000002E
	space2: .word 0x00000020
	minus_sign: .word 0x0000002D
	newline_character: .word 0x0000000A
	
	# Line/character printing
    	enter_line: .asciiz "\n"
    	separate: .asciiz "\n-------------------------------------\n-------------------------------------\n"
    	separate_2: .asciiz "\n------------------------------------\n"
	
	# For debugging
	print_char: .asciiz "current char = "
	print_temp: .asciiz ", current temp = "
	size_of_M: .asciiz "M x M - 1 = "
	print_kernel_index: .asciiz ", kernel_index = "
	
	# Variables to store N, M, p, s
    	N: .word 0	# The size of the image matrix (3 ≤ N ≤ 7) or new image matrix (11 ≤ N ≤ 15)
    	M: .word 0
    	p: .word 0
    	s: .word 0
    	O: .word 0	# The size of the output matrix 

    	# Matrices (max sizes allocated)
    	image_matrix: .space 196 # For max size 7x7 image matrix (7*7 = 49 elements, 4 bytes each)
    	kernel_matrix: .space 64 # For max size 4x4 kernel matrix (4*4 = 16 elements, 4 bytes each)
    	new_image_matrix: .space 900	# For max size 15x15 image matrix after padding (15*15 = 225 elements, 4 bytes each)
    	output_matrix: .space 576	# For max size 12x12 output matrix (12*12 = 144 elements, 4 bytes each)
.text
main:
	# Open file input.txt
	li $v0, 13 
	la $a0, fileO
	li $a1, 0 # open for reading (flag = 0 for read)
	li $a2, 0 
	syscall 
	move $s0, $v0 # save file descriptor in $s0
	
	# Check if file opened successfully
	bltz $s0, error_handling 

	# Read file
	li $v0, 14 
	move $a0, $s0 # file descriptor
	la $a1, bufferread # buffer to store first line
	li $a2, 300 # number of byte to read 
	syscall 
	
	# Close the file
    	li $v0, 16            
    	move $a0, $s0          
    	syscall
    	
    	# Parse the first row (N, M, p, s)
	jal parse_first_row     # Parse the first row
	
	# Print N
	lw $a0, N             
	li $v0, 1            
	syscall
	# Print a space
	li $a0, 32              
	li $v0, 11             
	syscall
	# Print M
	lw $a0, M             
	li $v0, 1               
	syscall
	# Print a space
	li $a0, 32            
	li $v0, 11             
	syscall
	# Print p
	lw $a0, p              
	li $v0, 1              
	syscall
	# Print a space
	li $a0, 32             
	li $v0, 11              
	syscall
	# Print s
	lw $a0, s              
	li $v0, 1             
	syscall
	# Print a newline
	li $a0, 10              
	li $v0, 11              
	syscall
	la $a0, separate_2            
	li $v0, 4             
	syscall

	# Parse the image matrix (N x N)
	jal parse_image_matrix	
	jal print_image_matrix
	
	la $a0, separate_2             
	li $v0, 4             
	syscall
	# Parse the kernel matrix (M x M)
	jal parse_kernel_matrix
	jal print_kernel_matrix
    	
    	la $a0, separate             
	li $v0, 4             
	syscall
    	# Setup main variables
	lw $s0, N
	lw $s1, M
	lw $s2, s
	lw $s4, p
	jal apply_padding	
	j print_padding
	
	go_to_convolution:
	# Separate padding and convolution results
	li $v0, 4 
	la $a0, separate_2
	syscall
	
	lw $s0, N	# Reload the new_N into N
	
	# Check if kernel size > image size
	bgt $s1, $s0, invalid_size
	
	j convolution_calculation
	
	return_and_print:	
	# Open file for writing
    	li $v0, 13              # Syscall for opening file
    	la $a0, filename        # File name
    	li $a1, 1               # Open mode (write)
    	li $a2, 0               # Unused flags
    	syscall
   	move $s6, $v0           # Save file descriptor to $s0
	
	j print_convolution
	
invalid_size:
	li $a0, 10              
	li $v0, 11              
	syscall
	la $a0, invalid_size_str            
	li $v0, 4             
	syscall
	j exit
    	
# Function to parse the first row (N, M, p, s)
parse_first_row:
	la $t0, bufferread    # Load bufferread into $t0
	lui $t1, 0x0000		# Increment variable (index go through each element in a string including '' and '\n')

	loop:
	# Load N (first integer from the buffer)
	bgt $t1, 6, end_parse # check if has reached the end of a string
	lb $t3, 0($t0)	# $t3 store each char in string
	
	slti $t4, $t3, 48  # Check if char is not a digit (ascii < '0')
	beq $t4, 1, increment  # increment if ascii < '0'
	slti $t4, $t3, 57  # Check if char is not a digit (ascii > '9')
	beq $t4, 0, increment  # increment if ascii > '9'
	addi $t3, $t3, -48  # Converts $t3's ascii value to decimal value
	beq $t1, 0, storeN
	beq $t1, 2, storeM
	beq $t1, 4, storep
	sw $t3, s
	increment:
	addi $t1, $t1, 1  
	addi $t0, $t0, 1
	j loop
	
	storeN:
	sw $t3, N
	j increment
	storeM:
	sw $t3, M
	j increment
	storep:
	sw $t3, p
	j increment
	
	end_parse:
	jr $ra                

# Function to parse the image matrix (N x N)
parse_image_matrix:
    	la $t0, bufferread        # Load bufferread into $t0
    	lui $t1, 0x0000            # Counter for image matrix elements
    
    	# Skip the first newline 
	find_second_row:
    	lb $t3, 0($t0)          
    	beq $t3, '\n', start_image_parsing  # Start parsing after first newline
    	addi $t0, $t0, 1           
    	j find_second_row

    start_image_parsing:
    	addi $t0, $t0, 1           # Skip newline character 
    	li $t8, 0	# Negative flag
    	li $t9, 0	# Decimal flag
    	li $t6, 1	# divisor
    	# temp variable
    	li $t7, 0	
    	mtc1 $t7, $f9
    	cvt.s.w $f9, $f9
    	
    image_parse_loop:
        lb $t3, 0($t0)         # Load byte from buffer
        
        beq $t3, '\n', end_parse_image_matrix  # Stop parsing on newline
        
        beq $t3, 32, store_float
        lb $t4, 1($t0)
        beq $t4, '\n', store_float
        
        beq $t3, '-', neg_flag
        
        beq $t3, '.', dot_flag

	slti $t4, $t3, '0'  # Check if char is not a digit (ascii < '0')
	beq $t4, 1, increment_image  # increment if ascii < '0'
	slti $t4, $t3, 58  # Check if char is not a digit (ascii > '9')
	beq $t4, 0, increment_image   # increment if ascii > '9'
	
	    addi $t3, $t3, -48  # Converts $t3's ascii value to decimal value
	    mtc1 $t3, $f0       # Move a part (either integer or decimal) to $f0
    	    cvt.s.w $f0, $f0	# Convert to float
	    beq $t9, 1, float_process
	    
	    mtc1 $zero, $f8
	    c.lt.s $f8, $f9              # Checks if $f9 > 0.0
    	    bc1t accumulate_integer
    	    j save_in_temp
    accumulate_integer:
    	li $t7, 10	
    	mtc1 $t7, $f8
    	cvt.s.w $f8, $f8
    	mul.s $f9, $f9, $f8            
    	add.s $f0, $f9, $f0
    # save in temp
    save_in_temp:
	mov.s $f9, $f0
	j increment_image

    store_float:
    	beq $t8, 1, neg_process
    	
    	put_in_matrix:
        # Store parsed float in image_matrix
        sll $t5, $t1, 2         # Calculate offset (index * 4 bytes)
        la $t2, image_matrix
        add $t5, $t2, $t5       # Address to store value   
        swc1 $f9, 0($t5)        # Store the floating-point value in image_matrix
        mtc1 $zero, $f9		# Zero out $f9 for latter use
        li $t9, 0	# Reset decimal flag
        li $t6, 1	# Reset divisor

        addi $t1, $t1, 1        # Increment counter

    increment_image:
        addi $t0, $t0, 1        # Move to next character
        j image_parse_loop

    end_parse_image_matrix:
    	jr $ra                     # Return to caller
    	
    	
    neg_flag:
    	li $t8, 1
    	j increment_image
    	
    dot_flag:
    	li $t9, 1
    	j increment_image
    	
    neg_process:
    	neg.s $f9, $f9
    	li $t8, 0
    	j put_in_matrix

    float_process:
    	mul $t6, $t6, 10	
    	mtc1 $t6, $f2
    	cvt.s.w $f2, $f2
    	div.s $f0, $f0, $f2            # Divide by divisor to make it fractional
    	add.s $f0, $f9, $f0            # Add integer and fractional parts
    	j save_in_temp
    
    

# Function to parse the kernel matrix (M x M)
parse_kernel_matrix:
    	la $t0, bufferread        # Load bufferread into $t0
    	lui $t1, 0x0000            # Counter for image matrix elements
    
    	# Skip the first newline 
	find_second_row_2:
    	lb $t3, 0($t0)          
    	beq $t3, '\n', find_third_row  # Go find third row after first newline
    	addi $t0, $t0, 1           
    	j find_second_row_2
    	
    	find_third_row:
    	addi $t0, $t0, 1
    	find_third_loop:
    	lb $t3, 0($t0)          
    	beq $t3, '\n', start_kernel_parsing  # Start parsing after first newline
    	addi $t0, $t0, 1           
    	j find_third_loop

    start_kernel_parsing:
    	addi $t0, $t0, 1           # Skip newline character 
    	li $t8, 0	# Negative flag
    	li $t9, 0	# Decimal flag
    	li $t6, 1	# divisor
    	lw $s1, M	# Load M
    	mul $s1, $s1, $s1 
    	subi $s1, $s1, 1	# M x M - 1 (last number in matrix)    	
    	# temp variable
    	li $t7, 0	
    	mtc1 $t7, $f9
    	cvt.s.w $f9, $f9
    	
    kernel_parse_loop:
        lb $t3, 0($t0)         # Load byte from buffer
        
        bgt $t1, $s1, end_parse_kernel_matrix  # Stop parsing on newline
        
        beq $t3, 32, store_float_2
        
        beq $t3, '-', neg_flag_2
        
        beq $t3, '.', dot_flag_2

	slti $t4, $t3, '0'  # Check if char is not a digit (ascii < '0')
	beq $t4, 1, check_last_num  # increment or check for last element if ascii < '0'
	slti $t4, $t3, 58  # Check if char is not a digit (ascii > '9')
	beq $t4, 0, check_last_num   # increment or check for last element if ascii > '9'
	
	    addi $t3, $t3, -48  # Converts $t3's ascii value to decimal value
	    mtc1 $t3, $f0       # Move a part (either integer or decimal) to $f0
    	    cvt.s.w $f0, $f0	# Convert to float
	    beq $t9, 1, float_process_2
	    
	    mtc1 $zero, $f8
	    c.lt.s $f8, $f9              # Checks if $f9 > 0.0
    	    bc1t accumulate_integer_2
    	    j save_in_temp_2
    accumulate_integer_2:
    	li $t7, 10	
    	mtc1 $t7, $f8
    	cvt.s.w $f8, $f8
    	mul.s $f9, $f9, $f8            
    	add.s $f0, $f9, $f0
    # save in temp
    save_in_temp_2:
	mov.s $f9, $f0
	j increment_kernel

    store_float_2:
    	beq $t8, 1, neg_process_2
    	
    	put_in_matrix_2:
        # Store parsed float in image_matrix
        sll $t5, $t1, 2         # Calculate offset (index * 4 bytes)
        la $t2, kernel_matrix
        add $t5, $t2, $t5       # Address to store value   
        swc1 $f9, 0($t5)        # Store the floating-point value in image_matrix
        mtc1 $zero, $f9		# Zero out $f9 for latter use
        li $t9, 0	# Reset decimal flag
        li $t6, 1	# Reset divisor

        addi $t1, $t1, 1        # Increment counter
        j increment_kernel

    check_last_num:
    	beq $t1, $s1, store_float_2

    increment_kernel:
        addi $t0, $t0, 1        # Move to next character
        j kernel_parse_loop

    end_parse_kernel_matrix:
    	jr $ra                     # Return to caller
    	
    	
    neg_flag_2:
    	li $t8, 1
    	j increment_kernel
    	
    dot_flag_2:
    	li $t9, 1
    	j increment_kernel
    	
    neg_process_2:
    	neg.s $f9, $f9
    	li $t8, 0
    	j put_in_matrix_2

    float_process_2:
    	mul $t6, $t6, 10
    	#li $t6, 10	
    	mtc1 $t6, $f2
    	cvt.s.w $f2, $f2
    	div.s $f0, $f0, $f2            # Divide by divisor to make it fractional
    	add.s $f0, $f9, $f0            # Add integer and fractional parts
    	j save_in_temp_2             

apply_padding:
	# Save old N into $s5
	add $s5, $s0, $zero

	# Setup new_N = N + 2 * padding
	sll $t0, $s4, 1		# 2 * padding
	add $s0, $s0, $t0	# N + 2 * padding
	
	# Initialize new_image_matrix with zeros and setup new variables
	la $t0, new_image_matrix  	# Load address of new_image into $t0
    	li $t1, 0  		# Initialize counter for new_image index
    	mul $t9, $s0, $s0	# new_N x new_N
    	
	# Loop assigns 0 to all elements in new_image 
    	new_image_init:
        bge $t1, $t9, paste_image	# If index >= (new_N x new_N), jump to paste_image 
        mul $t2, $t1, 4		# Multiply index by 4 (since it's a float, 4 bytes per element)
	add $t2, $t0, $t2	# Final address of the image element
	li $t3, 0          	# Load immediate value 0 into general-purpose register $t0
	mtc1 $t3, $f0      	# Move the value in $t0 (which is 0) to floating-point register $f3
	cvt.s.w $f0, $f0 	# Convert integer 0 to single-precision floating-point 0 
        swc1 $f0, 0($t2)        # Store 0.0 at the new_image position
        addi $t1, $t1, 1        # Increment the counter
        j new_image_init        # Loop back
        
        # Loop to paste each element into image_matrix
        paste_image:
        li $t1, 0	# Initialize runner_x = 0
    	paste_image_loop_x:
	bge $t1, $s5, return_padding	# If runner_x >= N <=> (runner_x + padding) >= (new_N - padding), return
	li $t2, 0	# Initialize runner_y = 0
		paste_image_loop_y:
		bge $t2, $s5, end_pi_loop_y	# If runner_y >= N, exit inner loop
		
		# Get real index for image_matrix: index = (runner_x * N) + runner_y
		mul $t5, $t1, $s5	# runner_x * N
		add $t5, $t5, $t2	# (runner_x * N) + runner_y
		
		# Get value from index of image_matrix: image[runner_x, runner_y]
		la $t9, image_matrix
            	mul $t5, $t5, 4		# Multiply index by 4 (since it's a float, 4 bytes per element)
		add $t5, $t9, $t5	# Final address of the image element
            	lwc1 $f0, 0($t5)	# Load image pixel into $f0

		# Get real index for new_image_matrix: index = ((runner_x + padding) * new_N) + (runner_y + padding) 
		add $t3, $t1, $s4	# runner_x + padding
		add $t4, $t2, $s4	# runner_y + padding
		mul $t3, $t3, $s0	# (runner_x + padding) * new_N
		add $t3, $t3, $t4	# ((runner_x + padding) * new_N) + (runner_y + padding) 

            	# Load into: new_image[padding:new_image_height-padding, padding:new_image_width-padding]
		mul $t3, $t3, 4		# Multiply index by 4 (since it's a float, 4 bytes per element)
		add $t3, $t0, $t3	# Final address of the image element
		swc1 $f0, 0($t3)	# Store $f0
		
		addi $t2, $t2, 1	# Increment runner_y
		j paste_image_loop_y
	end_pi_loop_y:
	addi $t1, $t1, 1	# Increment runner_x
	j paste_image_loop_x
		
	return_padding:
	# Save new_N in variable N at the end
	sw $s0, N
	
	jr $ra

convolution_calculation:
	# Setup size of output matrix: output_height = (image_height - kernel_height) / stride + 1
	sub $s3, $s0, $s1      # image_height - kernel_height
	div $s3, $s3, $s2      # (image_height - kernel_height) / stride
	addi $s3, $s3, 1 	# (image_height - kernel_height) / stride + 1
	sw $s3, O	
	
	li $t0, 0	# x index variable increment through each row of image matrix
	loop_x:
	beq $t0, $s3, return_and_print
	li $t1, 0 	# y index variable increment through each column of image matrix
		loop_y:
		beq $t1, $s3, end_loop_y
		
		jal get_current_region	# Extract current region from image for calculating
		
		addi $t1, $t1, 1
		j loop_y
	end_loop_y:
	addi $t0, $t0, 1
	j loop_x

get_current_region:
    	mul $t2, $t0, $s2        # x * stride
    	mul $t3, $t1, $s2        # y * stride

    	# Initialize sum = 0
    	li $t4, 0          # Load immediate value 0 into general-purpose register $t0
	mtc1 $t4, $f3      # Move the value in $t0 (which is 0) to floating-point register $f3
	cvt.s.w $f3, $f3   # Convert integer 0 to single-precision floating-point 0           

    	# Inner loop to calculate the sum of element-wise products of the current region with the kernel
    	li $t4, 0	# kernel_x = 0
    	krnl_x_loop:
        slt $t6, $t4, $s1   # if kernel_x >= kernel_size, exit loop
        beq $t6, 0, end_krnl_x_loop

        li $t5, 0	# kernel_y = 0
        	krnl_y_loop:
        	slt $t6, $t5, $s1 # if kernel_y >= kernel_size, exit loop
            	beq $t6, 0, end_krnl_y_loop
            	
            	# Get real image index: address = (x*stride + kernel_x) * N + (y*stride + kernel_y)
		add $t6, $t2, $t4	# x*stride + kernel_x
		add $t7, $t3, $t5	# y*stride + kernel_y
		mul $t6, $t6, $s0	# (x*stride + kernel_x) * N
		add $t6, $t6, $t7	# (x*stride + kernel_x) * N + (y*stride + kernel_y)

            	# Load image pixel: image[x*stride + kernel_x, y*stride + kernel_y]
		la $t8, new_image_matrix 	# Load base address of image_matrix
		mul $t6, $t6, 4		# Multiply index by 4 (since it's a float, 4 bytes per element)
		add $t6, $t8, $t6	# Final address of the image element
		lwc1 $f0, 0($t6) 	# Load image pixel into $f0
		
		# Get real kernel index: address = kernel_x * M + kernel_y
		mul $t6, $t4, $s1	# kernel_x * M
		add $t6, $t6, $t5	# kernel_x * M + kernel_y

            	# Load kernel value: kernel[kernel_x, kernel_y]
            	la $t8, kernel_matrix 	# Load base address of kernel_matrix
		mul $t6, $t6, 4		
		add $t6, $t8, $t6	
		lwc1 $f1, 0($t6) 	# Load kernel value into $f1
		
            	# Multiply image pixel by kernel value and accumulate sum
		mul.s $f2, $f0, $f1 	
		add.s $f3, $f3, $f2	# updated sum
		
            	# Increment kernel_y
            	addi $t5, $t5, 1
            	j krnl_y_loop
        
        end_krnl_y_loop:
        # Increment kernel_x
        addi $t4, $t4, 1
        j krnl_x_loop
    	
    	end_krnl_x_loop:
    	# Store the result in the output matrix: output_index = image_index
	mul $t6, $t0, $s3	# output_x * output_size
	add $t6, $t6, $t1	# (output_x * output_size) + output_y
	mul $t6, $t6, 4   	
	la $t8, output_matrix  	# Load base address of output_matrix
	add $t8, $t8, $t6	
	swc1 $f3, 0($t8)

	jr $ra


print_padding:
	#lw $s0, N	# Reload the new_N into N
	# Set up loop variables for traversing the output matrix
    	li $t0, 0      	# Index variable (we'll traverse the matrix linearly)
    	li $t1, 0	# Counter for each row printing
    	mul $t9, $s0, $s0	# size of output_matrix

	print_loop_padding:
    	bge $t0, $t9, go_to_convolution  # If we've printed all elements, exit the loop
    	bge $t1, $s0, enter_1	# Enter to new line if runner go to the end of the row

	continue_1:
    	# Load the floating-point value from the output matrix
    	la $t2, new_image_matrix        # Load base address of the output_matrix
    	mul $t3, $t0, 4              # Calculate byte offset (index * 4 bytes per float)
    	add $t2, $t2, $t3            # Add offset to base address
    	lwc1 $f0, 0($t2)             # Load the float value from memory into $f0

    	mov.s $f12, $f0 # Move contents of register $f3 to register $f12
   	li $v0, 2 # Print float number
    	syscall

	# Space
    	li $v0, 4 
	la $a0, space 
	syscall

    	# Increment index
   	addi $t0, $t0, 1             # Increment the index
   	addi $t1, $t1, 1	      # Increment the counter
    	j print_loop_padding         # Jump back to the start of the loop
    	
    	enter_1:
    	li $t1, 0	# Reset counter
    	
    	# Enter to new line
    	li $v0, 4 
	la $a0, enter_line 
	syscall
	
	j continue_1

print_convolution:
	#lw $s3, O	# Reload O into $s3
	# Set up loop variables for traversing the output matrix
    	li $t0, 0          # Index variable (we'll traverse the matrix linearly)
    	li $t1, 0		# Counter for each row printing
    	la $t8, buffer_write	# Buffer
    	mul $t9, $s3, $s3	# size of output_matrix
    	# Number 10000.0 and 10.0
    	li $s7, 10000	
    	mtc1 $s7, $f8
    	cvt.s.w $f8, $f8
    	
    	li $s5, 10

	print_loop:
    	bge $t0, $t9, to_file  # If we've printed all elements, exit the loop
    	bge $t1, $s3, enter_2	# Enter to new line if runner go to the end of the row

	continue_2:
    	# Load the floating-point value from the output matrix
    	la $t2, output_matrix        # Load base address of the output_matrix
    	mul $t3, $t0, 4              # Calculate byte offset (index * 4 bytes per float)
    	add $t2, $t2, $t3            # Add offset to base address
    	lwc1 $f0, 0($t2)             # Load the float value from memory into $f0

    	mov.s $f12, $f0 # Move contents of register $f3 to register $f12
   	li $v0, 2 # Print float number
    	syscall

    	# Space
    	li $v0, 4 
	la $a0, space 
	syscall
	
	
	# Print to file
	mul.s $f0, $f0, $f8	# float * 10000.0
	round.w.s $f0, $f0	# round up 
	# convert to integer
	mfc1 $t5, $f0
	div $t5, $s7	# int / 10000
	mfhi $t6	# decimal part
	mflo $t4	# integer part
	
	blt $t6, 0, change_to_pos		
 	
 	check_for_int_part:
 	blt $t4, 0, lower_than_0
	bgt $t4, 9, greater_than_9
	
	convert_hi_to_str:
	addi $t4, $t4, 48	# convert hi to string
	sb $t4, 0($t8)
	addi $t8, $t8, 1
	
	place_decimal:
	lw $t3, dot
    	sb $t3, 0($t8)	# Place dot
    	addi $t8, $t8, 1
	
	# Convert lo to str
	div $t6, $s5	# int / 10
	mfhi $t6	# lower integer part
	mflo $t5	# higher integer part	
	div $t5, $s5	# int / 10
	mfhi $t5	# lower integer part
	mflo $t4	# higher integer part
	div $t4, $s5	# int / 10
	mfhi $t4	# lower integer part
	mflo $t3	# higher integer part
	
	addi $t3, $t3, 48
	sb $t3, 0($t8)
	addi $t4, $t4, 48
	sb $t4, 1($t8)
	addi $t5, $t5, 48
	sb $t5, 2($t8)
	addi $t6, $t6, 48
	sb $t5, 3($t8)
	addi $t8, $t8, 4
	
	lw $t3, space2	# Place space character
    	sb $t3, 0($t8)
	addi $t8, $t8, 1

    	# Increment index
   	addi $t0, $t0, 1             # Increment the index
   	addi $t1, $t1, 1             # Increment the index
    	j print_loop                 # Jump back to the start of the loop
    	
    	enter_2:
    	li $t1, 0	# Reset counter
    	
    	# Enter to new line
    	li $v0, 4 
	la $a0, enter_line 
	syscall
	
	lw $t3, newline_character	# Place newline character
    	sb $t3, 0($t8)
	addi $t8, $t8, 1

	j continue_2
	
	# Change the decimal part to positve
	change_to_pos:
	sub $t6, $zero, $t6
	j check_for_int_part

	# Process num greater than 9
	greater_than_9:
	bgt $t4, 99, greater_than_99
	div $t4, $s5	# int / 10
	mfhi $t5	# lower integer part
	mflo $t3	# higher integer part
	addi $t3, $t3, 48
	sb $t3, 0($t8)
	addi $t5, $t5, 48
	sb $t5, 1($t8)
	addi $t8, $t8, 2
	j place_decimal
	
	greater_than_99:
	div $t4, $s5	# int / 10
	mfhi $t5	# lower integer part
	mflo $t4	# higher integer part	
	div $t4, $s5	# int / 10
	mfhi $t4	# lower integer part
	mflo $t3	# higher integer part
	
	addi $t3, $t3, 48
	sb $t3, 0($t8)
	addi $t4, $t4, 48
	sb $t4, 1($t8)
	addi $t5, $t5, 48
	sb $t5, 2($t8)
	addi $t8, $t8, 3
	j place_decimal
	
	# Process num lower than 0
	lower_than_0:	
	lw $t3, minus_sign
    	sb $t3, 0($t8)
    	addi $t8, $t8, 1
    	blt $t4, -9, lower_than_9
    	sub $t4, $zero, $t4	# convert to positive
    	j convert_hi_to_str
	
	lower_than_9:
	blt $t4, -99, lower_than_99
	sub $t4, $zero, $t4	# convert to positive
	div $t4, $s5	# int / 10
	mfhi $t5	# lower integer part
	mflo $t3	# higher integer part
	addi $t3, $t3, 48
	sb $t3, 0($t8)
	addi $t5, $t5, 48
	sb $t5, 1($t8)
	addi $t8, $t8, 2
	j place_decimal
	
	lower_than_99:
	sub $t4, $zero, $t4	# convert to positive
	div $t4, $s5	# int / 10
	mfhi $t5	# lower integer part
	mflo $t4	# higher integer part	
	div $t4, $s5	# int / 10
	mfhi $t4	# lower integer part
	mflo $t3	# higher integer part
	
	addi $t3, $t3, 48
	sb $t3, 0($t8)
	addi $t4, $t4, 48
	sb $t4, 1($t8)
	addi $t5, $t5, 48
	sb $t5, 2($t8)
	addi $t8, $t8, 3
	j place_decimal

# Error handling if cannot open file
error_handling:
	li $v0, 4                     
    	la $a0, error_open            
    	syscall

exit:
	li $v0, 10	# Exit syscall
    	syscall
    	
to_file:
	li $v0 , 15 # system call for write to file
 	move $a0 , $s6 # file descriptor
 	la $a1 , buffer_write # address of buffer from which to write
 	li $a2 , 10000 # hardcoded buffer length
 	syscall
 	j exit


# Function to print the image matrix (N x N) with floating-point values
print_image_matrix:
    lw $t0, N                # Load N (size of image matrix)
    li $t1, 0                # Element index counter
    li $t2, 0                # Row index counter

    print_image_loop:
    	# Check if we have printed N * N elements
   	mul $t3, $t0, $t0        # Calculate N * N
    	beq $t1, $t3, end_print_image_matrix

    	# Load the current floating-point element from image_matrix
    	sll $t4, $t1, 2          # Calculate offset (index * 4 bytes)
    	la $t5, image_matrix
    	add $t5, $t5, $t4        # Address of the current element
    	lwc1 $f12, 0($t5)        # Load floating-point element into $f12

    	# Print the floating-point element
   	li $v0, 2                # Syscall code for printing a floating-point number
    	syscall

    	# Print a space after each element
    	li $a0, 32               # ASCII code for space
    	li $v0, 11               # Syscall code for printing a character
    	syscall

    	# Check if end of row (after N elements)
    	addi $t1, $t1, 1         # Increment element index
    	addi $t2, $t2, 1         # Increment row counter
    	rem $t6, $t2, $t0        # Check if row complete by mod N
    	bne $t6, 0, print_image_loop

    	# Print a newline after each row
    	li $a0, 10               # ASCII code for newline
    	li $v0, 11               # Syscall code for printing a character
    	syscall

    	j print_image_loop

    end_print_image_matrix:
    	jr $ra

# Function to print the kernel matrix (M x M) with floating-point values
print_kernel_matrix:
    lw $t0, M                # Load M (size of image matrix)
    li $t1, 0                # Element index counter
    li $t2, 0                # Row index counter

    print_kernel_loop:
    	# Check if we have printed M * M elements
   	mul $t3, $t0, $t0        # Calculate M * M
    	beq $t1, $t3, end_print_kernel_matrix

    	# Load the current floating-point element from image_matrix
    	sll $t4, $t1, 2          # Calculate offset (index * 4 bytes)
    	la $t5, kernel_matrix
    	add $t5, $t5, $t4        # Address of the current element
    	lwc1 $f12, 0($t5)        # Load floating-point element into $f12

    	# Print the floating-point element
   	li $v0, 2                # Syscall code for printing a floating-point number
    	syscall

    	# Print a space after each element
    	li $a0, 32               # ASCII code for space
    	li $v0, 11               # Syscall code for printing a character
    	syscall

    	# Check if end of row (after N elements)
    	addi $t1, $t1, 1         # Increment element index
    	addi $t2, $t2, 1         # Increment row counter
    	rem $t6, $t2, $t0        # Check if row complete by mod N
    	bne $t6, 0, print_kernel_loop

    	# Print a newline after each row
    	li $a0, 10               # ASCII code for newline
    	li $v0, 11               # Syscall code for printing a character
    	syscall

    	j print_kernel_loop

    end_print_kernel_matrix:
    	jr $ra
