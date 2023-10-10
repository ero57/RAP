main:
    la a0 task_one                     
    jal taschenrechner                 # int result = taschenrechner(in);
    li a7 1
    ecall                              # printf("%d", result);
    addi a0 zero 10
    li a7 11
    ecall                              # printf("\n");
    li a7 10
    ecall                              # return 0;

scan_decimal:                          # int scan_decimal(char str[], int startidx) {
    add s0 zero a0                    # int idx = startidx;
    add s1 zero a1                    # int is_negative = 0;
    add s3 s1 zero                    
    addi s2 zero 0                    
    add t0 s3 s0                      # if (str[idx] == '-') {
    lb t1 0(t0)                       
    addi t2 zero 45                   
    bne t1 t2 elseNotNegative         #   is_negative = 1;
    addi s2 zero 1                    #   idx += 1;
    addi s3 s3 1                      # }
    elseNotNegative:
    addi s4 zero 0                    # int val = 0;
    addi t2 zero 48                   # while ('0' <= str[idx] && str[idx] <= '9') {
    addi t3 zero 57                   
    while:
    add t0 s3 s0                      
    lb t1 0(t0)                       
    bgt t2 t1 eliwh                   
    bgt t1 t3 eliwh                   #   val = val * 10 + str[idx] - '0';
    addi t4 zero 10                    
    mul t5 s4 t4                       
    sub t6 t1 t2                      
    add s4 t5 t6                      
    addi s3 s3 1                      #   idx += 1;
    j while                            # }
    eliwh:                             # 
    beq s2 zero fi                    # if (is_negative) {
    sub s4 zero s4                    #   val = -val;
    fi:                                # }
    add a1 zero s4                    # value = val; 
    sub a0 s3 s1                      # return idx - startidx;
    jr ra                              # }

taschenrechner:                       # int taschenrechner(char in[]) {
    add s5 zero a0                    # int len_of_first_number = scan_decimal(in, 0);
    addi a1 zero 0                    
    addi sp sp -4                     
    sw ra 0(sp)                       
    jal scan_decimal                
    lw ra 0(sp)                       
    addi sp sp 4                     
    add s6 a0 zero                    
    add s7 a1 zero                    # int first_value = value;
    add t0 s5 s6                     # char operation = in[len_of_first_number];
    lb s11 0(t0)                      
    add a0 zero s5                    # int len_of_second_number = scan_decimal(in, len_of_first_number + 1);
    addi a1 s6 1                      
    addi sp sp -4                     
    sw ra 0(sp)                       
    jal scan_decimal                  
    lw ra 0(sp)                     
    addi sp sp 4                     
    add s8 a0 zero                    
    add s9 a1 zero                    # int second_value = value;
    add s10 zero zero                 # int result;
    addi t0 zero 43                   # switch (operation) {
    beq s11 t0 caseplus               #   case '+': result = first_value + second_value; break;
    addi t0 zero 45                   #   case '-': result = first_value - second_value; break;
    beq s11 t0 caseminus              # 
    addi t0 zero 42                   #   case '*': result = first_value * second_value; break;
    beq s11 t0 casemul                
    addi t0 zero 47                   #   case '/': result = first_value / second_value; break;
    beq s11 t0 casediv                # }
    caseplus:
        add s10 s7 s9                 
        j caseend                     
    caseminus:
        sub s10 s7 s9                 
        j caseend                     
    casemul:
        mul s10 s7 s9                 
        j caseend                     
    casediv:
        div s10 s7 s9                 
        j caseend                     
    caseend:
    add a0 s10 zero                  # return result;
    jr ra                             # }

.data
task_one:
    .string "53242/65"                    
