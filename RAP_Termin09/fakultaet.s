fakultaet:
    # Werte Initalisieren
    addi a0, zero, 1 # f = 1
    addi t1, zero, 1 # i = 1
    addi t2, zero, 31 # n = 5
loop:
    # Loop
    bgt t1, t2, end_loop # Abbruch Loop
    mul a0, a0, t1 # f = f * i
    addi t1, t1, 1 # inc i
    j loop # Jump Loop

end_loop:
    # Programm Ende
    li a7, 1 # Print erg
    ecall
    li a7, 10 # Programm Ende
    ecall
