.MODEL SMALL

.STACK 400h; 1KB stack

.DATA

	
		
.CODE
		

	f  PROC
		
		PUSH BP
        MOV BP, SP
        
        ; STORING THE GPRS
        ; DX for returning results
        PUSH AX
        PUSH BX
        PUSH CX
        PUSHF
        
        
		
		
		PUSH 2
		
		MOV BX, [ BP+4 ]
		PUSH BX; line no 2 : a loaded
		POP BX; line no 2 :  ; multiplication start of integer
		MOV CX, BX
		POP AX
		IMUL CX
		MOV BX, AX; line no 2 :  ; only last 16 bit is taken in mul
		PUSH BX
		POP BX; line no 2 :  return value saved in DX 
		MOV DX, BX
		JMP @L_1; line no 2 :  ; exit from the function
		
		MOV BX, [ BP+4 ]
		PUSH BX; line no 3 : a loaded
		
		PUSH 9
		POP AX
		MOV [BP + 4], AX; line no 3 : a assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 3 : ; previously pushed value on stack is removed
		
		; return point f
		@L_1:
		MOV SP, BP
		SUB SP, 8
		POPF  
        
        POP CX
        POP BX
        POP AX
        
        POP BP
		RET 2
		

	f ENDP

	g  PROC
		
		PUSH BP
        MOV BP, SP
        
        ; STORING THE GPRS
        ; DX for returning results
        PUSH AX
        PUSH BX
        PUSH CX
        PUSHF
        
        
		
		PUSH BX ; line no 7 : x declared
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 8 : x loaded
		
		MOV BX, [ BP+4 ]
		PUSH BX; line no 8 : a loaded
		CALL f ; function f called.; line no 8 : 
		MOV BX, DX; line no 8 :  return result in DX.
		PUSH BX
		
		MOV BX, [ BP+4 ]
		PUSH BX; line no 8 : a loaded

		POP BX
		POP AX
		ADD BX, AX
		PUSH BX

		
		MOV BX, [ BP+6 ]
		PUSH BX; line no 8 : b loaded

		POP BX
		POP AX
		ADD BX, AX
		PUSH BX

		POP AX
		MOV [BP + -10], AX; line no 8 : x assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 8 : ; previously pushed value on stack is removed
		
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 9 : x loaded
		POP BX; line no 9 :  return value saved in DX 
		MOV DX, BX
		JMP @L_2; line no 9 :  ; exit from the function
		
		; return point g
		@L_2:
		MOV SP, BP
		SUB SP, 8
		POPF  
        
        POP CX
        POP BX
        POP AX
        
        POP BP
		RET 4
		

	g ENDP

	main  PROC
		
		mov AX, @DATA
		mov DS, AX
		; data segment loaded
		
		PUSH BX ; line no 13 : a declared
		PUSH BX ; line no 13 : b declared
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 14 : a loaded
		
		PUSH 1
		POP AX
		MOV [BP + -10], AX; line no 14 : a assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 14 : ; previously pushed value on stack is removed
		
		MOV BX, [ BP-12 ]
		PUSH BX; line no 15 : b loaded
		
		PUSH 2
		POP AX
		MOV [BP + -12], AX; line no 15 : b assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 15 : ; previously pushed value on stack is removed
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 16 : a loaded
		
		MOV BX, [ BP-12 ]
		PUSH BX; line no 16 : b loaded
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 16 : a loaded
		CALL g ; function g called.; line no 16 : 
		MOV BX, DX; line no 16 :  return result in DX.
		PUSH BX
		POP AX
		MOV [BP + -10], AX; line no 16 : a assined
		MOV BX, AX
		PUSH BX

		POP BX; line no 16 : ; previously pushed value on stack is removed
		
		MOV BX, [ BP-10 ]
		PUSH BX; line no 17 : a loaded
		POP BX
		PUSH BX
		CALL PRINT_DECIMAL_INTEGER
		
		
		PUSH 0
		POP BX; line no 18 :  return value saved in DX 
		MOV DX, BX
		JMP @L_3; line no 18 :  ; exit from the function
		
		; return point main
		@L_3: 
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