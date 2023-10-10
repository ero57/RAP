.data
input: .string "bbb aaa llllll ooo nnn"

.text

main:
    li t1, 98        #b
    li t2, 97        #a
    li t3, 108       #l
    li t4, 111       #o
    li t5, 110       #n
    la s0, input
    
loop:
    lb t0, 0(s0)
    
    addi s0, s0, 1
    
    beqz t0, count
    
    beq t0, t1, found_b
    beq t0, t2, found_a
    beq t0, t3, found_l
    beq t0, t4, found_o
    beq t0, t5, found_n
    
    j loop
    
found_b:
    addi a1, a1, 1  # b-Vorrat
    j loop
  
found_a:
    addi a2, a2, 1  # a-Vorrat
    j loop
    
found_l:
    addi a3, a3, 1  # l-Vorrat
    j loop
    
found_o:
    addi a4, a4, 1  # o-Vorrat
    j loop
    
found_n:
    addi a5, a5, 1  # n-Vorrat
    j loop  
    
count:
    addi a1, a1, -1
    blt a1, zero, print
    addi a2, a2, -1
    blt a2, zero, print
    addi a3, a3, -2
    blt a3, zero, print
    addi a4, a4, -1
    blt a4, zero, print
    addi a5, a5, -1
    blt a5, zero, print
    
    addi a0, a0, 1
    
    j count
    
print:
    li a7, 1
    ecall
    li a7,10
    ecall
    