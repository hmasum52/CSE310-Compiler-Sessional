.MODEL SMALL

.STACK 400h; 1KB stack

.DATA

	
		
.CODE
	main  PROC
		
		mov AX, @DATA
		mov DS, AX
		; data segment loaded
		
		PUSH BX ; line no 2 : a declared
		PUSH BX ; line no 2 : b declared
		MOV CX, 3; line no 2 : ; new array of size 3
		@L_2:
		JCXZ @L_3
		PUSH BX
		DEC CX
		JMP @L_2
		@L_3: 
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 3 : a loaded
		
		PUSH 1
		
		PUSH 2
		
		PUSH 3

		POP BX
		POP AX
		ADD BX, AX
		PUSH BX

		POP BX; line no 3 :  ; multiplication start of integer
		MOV CX, BX
		POP AX
		IMUL CX
		MOV BX, AX; line no 3 :  ; only last 16 bit is taken in mul
		PUSH BX
		
		PUSH 3
		POP BX
		MOV CX, BX; line no 3 :  ; / or % operation
		XOR DX, DX
		POP AX
		IDIV CX
		MOV BX, DX
		PUSH BX
		POP AX
		MOV [BP + -10], AX; line no 3 : a assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 3 : ; previously pushed value on stack is removed
		
		MOV BX, [ BP-12 ]
		PUSH BX; line no 4 : b loaded
		
		PUSH 1
		
		PUSH 5
		

		POP BX
		POP AX
		CMP AX, BX; line no 4 :  relop operation
		MOV BX, 1; line no 4 :  First let it assume positive
		JL @L_4
		MOV BX, 0; line no 4 :  the condition is false
		@L_4: 

		PUSH BX

		POP AX
		MOV [BP + -12], AX; line no 4 : b assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 4 : ; previously pushed value on stack is removed
		
		
		PUSH 0
		POP BX; line no 5 : ; Array index in BX
		SHL BX, 1; line no 5 :  ; because 2 byte element
		NEG BX
		ADD BX, -14; Array from BP/or data segment
		ADD BX,BP
		PUSH [BX]
		PUSH BX; line no 5 : ; address pushed to stack
		
		PUSH 2
		POP AX
		POP BX
		POP DX; line no 5 :  ;array value popped
		MOV [BX], AX; line no 5 : c assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 5 : ; previously pushed value on stack is removed
		
		; if else statement
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 6 : a loaded
		
		MOV BX, [ BP-12 ]
		PUSH BX; line no 6 : b loaded
		

		POP BX
		CMP BX, 0
		JE @L_5; line no 6 :  ; not true
		POP BX
		CMP BX, 0
		JE @L_5; line no 6 :  ; not true
		PUSH 1; line no 6 : ; conditioin is true
		JMP @L_6
		@L_5: 
		PUSH 0
		@L_6: ; line no 6 :  ; exiting and operation
		POP BX
		CMP BX, 0
		JE @L_7 ; go to else
		
		
		PUSH 0
		POP BX; line no 7 : ; Array index in BX
		SHL BX, 1; line no 7 :  ; because 2 byte element
		NEG BX
		ADD BX, -14; Array from BP/or data segment
		ADD BX,BP
		PUSH [BX]
		PUSH BX; line no 7 : ; address pushed to stack
		POP BX
		POP AX
		PUSH AX

		INC AX
		MOV [BX], AX; line no 7 : 
		POP BX; line no 7 : ; previously pushed value on stack is removed
		JMP @L_8 ; exit
		@L_7:  ; else label

		
		
		PUSH 1
		POP BX; line no 9 : ; Array index in BX
		SHL BX, 1; line no 9 :  ; because 2 byte element
		NEG BX
		ADD BX, -14; Array from BP/or data segment
		ADD BX,BP
		PUSH [BX]
		PUSH BX; line no 9 : ; address pushed to stack
		
		
		PUSH 0
		POP BX; line no 9 : ; Array index in BX
		SHL BX, 1; line no 9 :  ; because 2 byte element
		NEG BX
		ADD BX, -14; Array from BP/or data segment
		ADD BX,BP
		PUSH [BX]
		PUSH BX; line no 9 : ; address pushed to stack
		POP BX
		POP AX
		POP BX
		POP DX; line no 9 :  ;array value popped
		MOV [BX], AX; line no 9 : c assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 9 : ; previously pushed value on stack is removed
		@L_8: ; if else exit

		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 10 : a loaded
		POP BX
		PUSH BX
		CALL PRINT_DECIMAL_INTEGER
		
		MOV BX, [ BP-12 ]
		PUSH BX; line no 11 : b loaded
		POP BX
		PUSH BX
		CALL PRINT_DECIMAL_INTEGER
		
		; return point main
		@L_1: 
		mov AH, 4Ch
		int 21h
		; returned control to OS
		

	main ENDP
		

	PRINT_NEWLINE PROC
        ; PRINTS A NEW LINE WITH CARRIAGE RETURN
        PUSH AX
        PUSH DX
        MOV AH, 2
        MOV DL, 0Dh
        INT 21h
        MOV DL, 0Ah
        INT 21h
        POP DX
        POP AX
        RET
    PRINT_NEWLINE ENDP
    
    PRINT_CHAR PROC
        ; PRINTS A 8 bit CHAR 
        ; INPUT : GETS A CHAR VIA STACK 
        ; OUTPUT : NONE    
        PUSH BP
        MOV BP, SP
        
        ; STORING THE GPRS
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSHF
        
        MOV DX, [BP + 4]
        MOV AH, 2
        INT 21H
    
        POPF  
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        POP BP
        RET 2
    PRINT_CHAR ENDP 

    PRINT_DECIMAL_INTEGER PROC NEAR
        ; PRINTS SIGNED INTEGER NUMBER WHICH IS IN HEX FORM IN ONE OF THE REGISTER
        ; INPUT : CONTAINS THE NUMBER  (SIGNED 16BIT) IN STACK
        ; OUTPUT : 
        
        ; STORING THE REGISTERS
        PUSH BP
        MOV BP, SP
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSHF
        
        MOV AX, [BP+4]
        ; CHECK IF THE NUMBER IS NEGATIVE
        OR AX, AX
        JNS @POSITIVE_NUMBER
        ; PUSHING THE NUMBER INTO STACK BECAUSE A OUTPUT IS WILL BE GIVEN
        PUSH AX

        MOV AH, 2
        MOV DL, 2Dh
        INT 21h

        ; NOW IT'S TIME TO GO BACK TO OUR MAIN NUMBER
        POP AX

        ; AX IS IN 2'S COMPLEMENT FORM
        NEG AX

        @POSITIVE_NUMBER:
            ; NOW PRINTING RELATED WORK GOES HERE

            XOR CX, CX      ; CX IS OUR COUNTER INITIALIZED TO ZERO
            MOV BX, 0Ah
            @WHILE_PRINT:
                
                ; WEIRD DIV PROPERTY DX:AX / BX = VAGFOL(AX) VAGSESH(DX)
                XOR DX, DX
                ; AX IS GUARRANTEED TO BE A POSITIVE NUMBER SO DIV AND IDIV IS SAME
                DIV BX                     
                ; NOW AX CONTAINS NUM/10 
                ; AND DX CONTAINS NUM%10
                ; WE SHOULD PRINT DX IN REVERSE ORDER
                PUSH DX
                ; INCREMENTING COUNTER 
                INC CX

                ; CHECK IF THE NUM IS 0
                OR AX, AX
                JZ @BREAK_WHILE_PRINT; HERE CX IS ALWAYS > 0

                ; GO AGAIN BACK TO LOOP
                JMP @WHILE_PRINT

            @BREAK_WHILE_PRINT:

            ;MOV AH, 2
            ;MOV DL, CL 
            ;OR DL, 30H
            ;INT 21H
            @LOOP_PRINT:
                POP DX
                OR DX, 30h
                MOV AH, 2
                INT 21h

                LOOP @LOOP_PRINT

        CALL PRINT_NEWLINE
        ; RESTORE THE REGISTERS
        POPF
        POP DX
        POP CX
        POP BX
        POP AX
        
        POP BP
        
        RET


    PRINT_DECIMAL_INTEGER ENDP

END MAIN