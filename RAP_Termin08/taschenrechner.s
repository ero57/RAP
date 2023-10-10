.data
input: .string "0+0" 

.text
main:
addi sp,sp, -16 # Sp 16(Konvention) Bytes
sw ra,0(sp) 
sw s0,4(sp)

la s0, input 

    li t4, 43 # ASCII "+" in t4 laden
    li t5, 45 # ASCII "-" in t5 laden
    
    lb t0, 0(s0) # Lade Bit in t0
    addi s0, s0, 1 # Zeiger um 1 verschieben
    
    lb t1, 0(s0) # Labe Bit in t1
    addi, s0, s0, 1 # Zeiger um 1 verschieben
    
    lb t2, 0(s0) # Lade Bit in t2
    
    addi t0, t0, -48 # Wert ausrechnen
    addi t2, t2, -48 # Wert ausrechnen
    
    beq t1, t4, add_num # Wenn "+" gleich spring zu add
    beq t1, t5, sub_num # Wenn "-" gleich spring zu sub
    
    j error # Wenn Operand nicht gleich dann error

    
add_num:
    add a0, t0, t2 # Addiere t2(zweiter Summand) und t0(erster Summand) in a0
    j end # Ende
    
sub_num:
    sub a0, t0, t2 # Subtrahiere t2(zweiter Summand) und t0(erster Summand) in a0
    j end # Ende
    
end: 
    lw ra,0(sp) # Register Restaurieren
    lw s0,4(sp)
    addi sp,sp,16
    
    li a7,1 # Ergebniss ausgabe
    ecall
    li a7, 10 # Programm beenden
    ecall
    
error:
    lw ra,0(sp) # Register Restaurieren
    lw s0,4(sp)
    addi sp,sp,16
    
    li a0, -1 # Fehler Ausgabe
    li a7, 1
    ecall
    li a7, 10 # Programm beenden 
    ecall