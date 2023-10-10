
ggt:
    li a0, 1024         #a
    li a1, 522          #b
    jal while
    li a7, 1          # return a
    ecall
    li a7, 10
    ecall
    
while:
    beqz a1, return    #while b != 0
    
    bgt a0, a1, big_a # if a > b then
    j big_b           # else
    
big_a:
    sub a0, a0, a1    # a = a - b
    j while
    
big_b:
    sub a1, a1, a0    # b = b - a
    j while
    
return:
    jr ra