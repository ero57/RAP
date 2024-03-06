main:
    # Anzahl fib zahlen zu berechnen n=5
    addi a0 zero 8
    jal ra fib
    li a7,1 # Print erg
    ecall
    li a7,10 # Programm ende
    ecall

fib:
    li t3, 2
   blt a0, t3, fib_exit
   
   addi sp, sp -16
   sw ra, 12(sp)
   sw a0, 8(sp)
   
   # Fib(n-1)
   addi a0, a0, -1
   jal ra, fib
   sw a0, 4(sp)
   #Fib(n-2)
   lw a0, 8(sp)
   addi a0, a0, -2
   jal ra ,fib
   # Add Fib(n-1) Fib(n-2)
   lw a1, 4(sp)
   add a0, a0, a1
   
   lw ra, 12(sp)
   addi sp, sp, 16
   jr ra
   
fib_exit:
    jr ra 
    