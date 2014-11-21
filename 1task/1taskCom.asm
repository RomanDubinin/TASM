cseg segment use16
assume CS:cseg, DS:cseg
Org 100h
    
entry:
    jmp start

    mas dw 403, -20, -5139, 134, -88
    masSize dw 5
    mes db ' ,$'

include OutInt.inc

start:
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
end entry