.MODEL SMALL
.STACK 100h
.DATA


.CODE
	main PROC
		MOV AX, @DATA
		mov DS, AX
		; data segment loaded

		MOV BP, SP
	
		SUB SP, 2	;line 2: a declared: W. [BP-2]
		SUB SP, 2	;line 2: b declared: W. [BP-4]
		SUB SP, 2	;line 2: c declared: W. [BP-6]
		SUB SP, 2	;line 2: i declared: W. [BP-8]
	
		PUSH 0	;line 3: save 0

; line 3: b=0
		POP AX	;line 3: load 0
		MOV W. [BP-4], AX	;line 3: b=0
		PUSH AX	;line 3: save b

		POP AX	;line 3: evaluated exp: b=0;

		PUSH 1	;line 4: save 1

; line 4: c=1
		POP AX	;line 4: load 1
		MOV W. [BP-6], AX	;line 4: c=1
		PUSH AX	;line 4: save c

		POP AX	;line 4: evaluated exp: c=1;

; line 5: ======for loop start======
; line 5: for loop initialization
		PUSH 0	;line 5: save 0

; line 5: i=0
		POP AX	;line 5: load 0
		MOV W. [BP-8], AX	;line 5: i=0
		PUSH AX	;line 5: save i

		POP AX	;line 5: evaluated for loop init exp: i=0;

; line 5: for loop condition
		@FOR_COND_1:	
		PUSH W. [BP-8]	;line 5: save i

		PUSH 4	;line 5: save 4

; line 5: i<4
		POP BX	;line 5: load 4
		POP AX	;line 5: load i
		CMP AX, BX	
		JL @L_5	;line 5: i<4
			PUSH 0
			JMP @L_6	
		@L_5:
			PUSH 1	
		@L_6:
	
		POP AX	;line 5: load i<4;
		CMP AX, 0	
		JE @END_FOR_4	;line 5: break for loop
		JMP @FOR_STMT_2	;line 5: execute for statement
; line 5: for loop update
		@FOR_UPDATE_3:	
		PUSH W. [BP-8]	
		INC W. [BP-8]	;line 5: i++
		POP AX	;line 5: evaluated for loop update exp: i++

		JMP @FOR_COND_1	;line 5: continue for loop
; line 5: for loop statement
		@FOR_STMT_2:	
		PUSH 3	;line 6: save 3

; line 6: a=3
		POP AX	;line 6: load 3
		MOV W. [BP-2], AX	;line 6: a=3
		PUSH AX	;line 6: save a

		POP AX	;line 6: evaluated exp: a=3;

		@WHILE_LOOP_7:	
		PUSH W. [BP-2]	
		DEC W. [BP-2]	;line 7: a--
; line 7: while block start
		POP AX	;line 7: load a--
		CMP AX,0	
		JE @END_WHILE_8	
		PUSH W. [BP-4]	
		INC W. [BP-4]	;line 8: b++
		POP AX	;line 8: evaluated exp: b++;

		JMP @WHILE_LOOP_7	
		@END_WHILE_8:
	
		JMP @FOR_UPDATE_3	;line 10: go to update section
; line 10: ======for loop end======
		@END_FOR_4:	
; line 11: println(a)
		MOV BX, W. [BP-2]	;line 11: load a
		CALL PRINT_NUM_FROM_BX	
; line 12: println(b)
		MOV BX, W. [BP-4]	;line 12: load b
		CALL PRINT_NUM_FROM_BX	
; line 13: println(c)
		MOV BX, W. [BP-6]	;line 13: load c
		CALL PRINT_NUM_FROM_BX	

		@L_0:
		MOV AH, 4CH
		INT 21H
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

PRINT_NUM_FROM_BX PROC
    PUSH CX  
    ; push to stack to 
    ; check the end of the number  
    MOV AX, 'X'
    PUSH AX
    
    CMP BX, 0  
    JE ZERO_NUM
    JNL NON_NEGATIVE 
    
    NEG BX
    ; print - for negative number
    MOV DL, '-'
    MOV AH, 2
    INT 21H
    JMP NON_NEGATIVE  
    
    ZERO_NUM:
        MOV DX, 0
        PUSH DX
        JMP POP_PRINT_LOOP
    
    NON_NEGATIVE:
    
    MOV CX, 10 
    
    MOV AX, BX
    PRINT_LOOP:
        ; if AX == 0
        CMP AX, 0
        JE END_PRINT_LOOP
        ; else
        MOV DX, 0 ; DX:AX = 0000:AX
        
        ; AX = AX / 10 ; store reminder in DX 
        DIV CX
    
        PUSH DX
        
        JMP PRINT_LOOP

    END_PRINT_LOOP:
    
    
    
    POP_PRINT_LOOP:
        POP DX
        ; loop ending condition
        ; if DX == 'X'
        CMP DX, 'X'
        JE END_POP_PRINT_LOOP
        
        ; if DX == '-'
        CMP DX, '-'
        JE PRINT_TO_CONSOLE
        
        ; convert to ascii
        ADD DX, 30H       
        ; print the digit
        PRINT_TO_CONSOLE:
        MOV AH, 2
        INT 21H
        
        JMP POP_PRINT_LOOP
    
    END_POP_PRINT_LOOP: 
CALL PRINT_NEWLINE
    POP CX
    RET
PRINT_NUM_FROM_BX ENDP

END MAIN
