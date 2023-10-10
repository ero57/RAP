.data
input: .string "rera wnrtre"

.text
main:
    li t0 97        # ASCII-Wert 'a'
    li t1 122       # ASCII-Wert 'z' 
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)
    
    la s0 input
    
Loop:
    lb t2 0(s0)
    beqz t2 exit
    addi t2 t2 13
    
    bgt t2 t1 wrap
    blt t2 t0 wrap
    
    
print:
    mv a0 t2
    li a7 11
    ecall
    addi s0 s0 1
    j Loop
    
wrap:
    lb t2 0(s0)
    addi t2 t2 -13
    j print
    
exit:
    lw ra 0(sp)
    lw s0 4(sp)
    addi sp sp 16
    li a7 10
    ecall