OutInt proc
        push ax
        push bx
        push cx
        push dx

; Проверяем число на знак.
        test ax, ax
        jns outAbs
 ; Если оно отрицательное, выведем минус и оставим его модуль.
        push ax
        mov ah, 02h
        mov dl, '-'
        int 21h
        pop ax
        neg ax

outAbs:
        mov bx, 10
        mov cx, ax
        jcxz outZ
        
dropInsignificantZ:
        xor dx,dx
        div bx
        mov cx, dx
        jcxz dropInsignificantZ ; Если остаток от деления 0
        ; first not 0 num
        push ax
        add dl, '0'
        mov ah, 02h
        int 21h
        pop ax
        
outModulo:

        mov cx, ax
        jcxz exit
        
        xor dx,dx
        div bx

        push ax
        add dl, '0'
        mov ah, 02h
        int 21h
        pop ax

        test ax, ax
        jnz outModulo

exit:
;Выходим.
        pop dx
        pop cx
        pop bx
        pop ax
       
        ret
 
 outZ: 
        mov dl, '0'
        mov ah, 02h
        int 21h
        
        jmp exit
 
OutInt endp