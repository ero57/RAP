main:   
        # Sp um 1040 zurücksetzen -> platz für array und zusätzliche register
        addi    sp, sp, -1040
        # Ra in stack sichern
        sw      ra, 1036(sp)
        # Sichere den Wert Fp(s0) auf stack                    
        sw      s0, 1032(sp)
        # Setze s0 auf aktuellen sp +1040, um auf Basis von array zu verweisen                    
        addi    s0, sp, 1040
        # Anfangswerte Array
        li      t0, 2 #Beginne bei Index 2
        li      t1, 1000 # Gehe bis Index 100

innit_array:
        # Initalisiere das Array mit '0'
        # Sobald ende von array gehe zu start                             
        blt     t1, t0, start
        # Berechne die Adresse für das aktuelle Element
        addi    t1, s0, -1036
        add     t1, t1, t0
        li      a0, 0
        # Setze das aktuelle Element auf 0.
        sb      a0, 0(t1)
        # Setze grenze für nächste Iterration und gehe zurück
        li      t1, 10
        addi    t0, t0, 1
        j       innit_array
        
        
start:
        # Starte den Alogrithmus
        li      t3, 2
        li      t4, 1000

Outer_Loop:
        # Äußere Schleife des Siebs, wo wir jedes Element prüfen.                               
        li      t4, 1000
        # Überprüfe ob Ende des Arrays falls ja beende programm
        blt     t4, t3, exit
        # Berechne die adresse des aktuellen Elements
        addi    t4, s0, -1036
        add     t4, t4, t3
        # Lade den Wert des aktuellen Elements
        lbu     a0, 0(t4)
        bnez    a0, second_loop
        j       print_prime
        
print_prime:
        # Drucke die aktuelle Primzahl                               
        li a0, 32 # fds
        li a7, 11
        ecall
        mv a0, t3
        li a7,1
        ecall
        
second_loop:
        # Innere Schleife des Siebs
        mul     t5, t3, t3
        li      t6, 1000
        
not_prime_loop:
        # Makiere alle Vielfachen der aktuellen Primzahl als nicht-prim                                
        li      t6, 1000
        # Überprüfe ob wir das Ende des Arrays erreich haben. Wenn ja, gehen wir zu 'exit_inner_loop'.
        blt     t6, t5, exit_inner_loop
        #Berechne die Adresse des Aktuellen Elements
        addi    t6, s0, -1036
        add     t6, t6, t5
        # Makiere aktuelle Element als nicht_prim
        li      a0, 1
        sb      a0, 0(t6)
        # Gehe zum nächsten vielfachen der aktuellen Zahl und wiederhole die Schleife
        add     t5, t5, t3
        j       not_prime_loop

exit_inner_loop:
        # Verlasse die innere Schleife                             
        addi    t3, t3, 1
        j       Outer_Loop
        
exit:    
        # Verlasse Algortihmus und räume auf
        lw      a0, -24(s0)
        mv      sp, a0
        lw      a0, -16(s0)
        lw      ra, 1036(sp)                    
        lw      s0, 1032(sp)                    
        addi    sp, sp, 1040
        li a7, 10 #fasdfass
        ecall
