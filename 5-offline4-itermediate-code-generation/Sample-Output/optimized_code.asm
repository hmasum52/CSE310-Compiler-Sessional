
.data           ; data segment

new@line        db 13,10,'$'
ten@            dw 10

.code           ; code segment

proc main
  ; Data Segment Initialization
  mov ax, @data
  mov ds, ax
  
  ; BP initialization for Local Variables
  mov bp, sp
  add bp, 2
  

  ; Line 3: int x,c[3];
  sub sp, 8		; Line 3: x,c[3]
  
  ; Optimized push-pop to assignment:   push 0		; Line 4: store 0
  ; Line 4: c[0]
  mov ax, 0 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  ; Optimized push-pop to assignment:   push 5		; Line 4: store 5
  ; Line 4: c[0]=5
  mov ax, 5 ; Optimized push-pop to assignment:   pop ax
  mov [bx], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Optimized push-pop to assignment:   push 1		; Line 5: store 1
  ; Line 5: c[1]
  mov ax, 1 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  ; Optimized push-pop to assignment:   push 6		; Line 5: store 6
  ; Line 5: c[1]=6
  mov ax, 6 ; Optimized push-pop to assignment:   pop ax
  mov [bx], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Optimized push-pop to assignment:   push 2		; Line 6: store 2
  ; Line 6: c[2]
  mov ax, 2 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  ; Optimized push-pop to assignment:   push 0		; Line 6: store 0
  ; Line 6: c[0]
  mov ax, 0 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  push [bx]		; Line 6: store c[0]
  ; Optimized push-pop to assignment:   push 1		; Line 6: store 1
  ; Line 6: c[1]
  mov ax, 1 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  push [bx]		; Line 6: store c[1]
  ; Line 6: c[0]*c[1]
  xor dx, dx
  pop bx
  pop ax
  imul bx
  ; Optimized redundent push-pop :   push ax
  ; Line 6: c[2]=c[0]*c[1]
  ; Optimized redundent push-pop :   pop ax
  mov [bx], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Line 7: int a;
  sub sp, 2		; Line 7: a
  
  ; Optimized push-pop to assignment:   push 2		; Line 8: store 2
  ; Line 8: c[2]
  mov ax, 2 ; Optimized push-pop to assignment:   pop ax
  lea bx, w.-4[bp-2]
  shl ax, 1
  sub bx, ax
  ; Optimized push-pop to assignment:   push [bx]		; Line 8: store c[2]
  ; Line 8: a=c[2]
  mov ax, [bx] ; Optimized push-pop to assignment:   pop ax
  mov w.-4[bp-8], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Line 9: println(a);
  push w.-4[bp-8]
  call println
  pop ax
  
  push w.-4[bp-8]		; Line 10: store a
  push 2		; Line 10: store 2
  ; Line 10: a/2
  xor dx, dx
  pop bx
  pop ax
  idiv bx
  ; Optimized redundent push-pop :   push ax
  ; Line 10: a=a/2
  ; Optimized redundent push-pop :   pop ax
  mov w.-4[bp-8], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Line 11: println(a);
  push w.-4[bp-8]
  call println
  pop ax
  
  push w.-4[bp-8]		; Line 12: store a
  push 3		; Line 12: store 3
  ; Line 12: a%3
  xor dx, dx
  pop bx
  pop ax
  idiv bx
  ; Optimized push-pop to assignment:   push dx
  ; Line 12: a=a%3
  mov ax, dx ; Optimized push-pop to assignment:   pop ax
  mov w.-4[bp-8], ax
  ; Optimized redundent push-pop :   push ax
  ; Optimized redundent push-pop :   pop ax
  
  ; Line 13: println(a);
  push w.-4[bp-8]
  call println
  pop ax
  
  add sp, 10		; remove block local variable
  ; DOS Exit, return to OS
  mov ah, 4ch     ; terminate process
  mov al, 0       ; return code
  int 21h         ; DOS Service Invoke
main endp

println proc
  push bp
  mov bx, sp
  lea bp, [bx+2]
  push 0               ; store wheather number is +/-
  test w.2[bp], 8000h  ; test sign bit
    jz number_positive
    mov w.-4[bp], 01b
    neg w.2[bp]
  number_positive:     ; number is positive
  mov ax, '$'
  push ax
  extract_digit:
    mov dx, 0
    mov ax, w.2[bp]    ; w.2[bp] - first argument of caller
    div ten@
    mov w.2[bp], ax
    add dx, '0'
    push dx    
    cmp w.2[bp], 0
  jne extract_digit
  cmp w.-4[bp], 0
  je digit_print       ; Positive, no sign needed
    mov dl, '-'        ; Negative, - print
    mov ah, 02h
    int 21h
  digit_print:
    pop ax
    cmp al, '$'
  je end_digit_print
    mov dl, al         ; Print one digit
    mov ah, 02h
    int 21h
    jmp digit_print
  end_digit_print:
  lea dx, new@line     ; print newline
  mov ah, 9
  int 21h
  pop ax               ; local variable - sign check
  pop bp               ; restore caller BP
  ret
println endp

end main

