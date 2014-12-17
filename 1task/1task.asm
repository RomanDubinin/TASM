dseg segment
    ; определение данных
    mas dw 403, -20, -5139, 134, -88
    masSize dw 5
    mes db ' ,$'
dseg ends

sseg segment stack
    n dw 256 dup (?)
sseg ends

cseg segment

    assume ds: dseg, cs: cseg, ss: sseg
    include OutInt.inc
start: 
    mov ax, dseg
    mov ds, ax
    mov si, 0
    mov cx, masSize
    push mas[si]
    call OutInt
    add si, 2
    dec cx
cycle:
    mov dx, offset mes
    mov ah,09h
    int 21h
    
    push mas[si]
    call OutInt
    pop mas[si]
    
    
    add si, 2
    dec cx
    jcxz endprog
    jmp cycle

endprog:
    mov ah,04Ch
    int 21h
cseg ends
end start