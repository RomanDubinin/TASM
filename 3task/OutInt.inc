OutInt proc
	
	push ax
	push bx
	push cx
	push dx
	push bp
	mov bp, sp ; bp - мой указатель на стек

	mov ax, [bp+12]

; Проверяем число на знак.
	test ax, ax
	jns oi1

; Если оно отрицательное, выведем минус и оставим его модуль.
	mov  cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	neg ax
; Количество цифр будем держать в CX.
oi1:
	xor cx, cx
	mov bx, 10
oi2:
	xor dx,dx
	div bx
; Делим число на основание сс. В остатке получается последняя цифра.
; Сразу выводить её нельзя, поэтому сохраним её в стэке.
	push dx
	inc cx
; А с частным повторяем то же самое, отделяя от него очередную
; цифру справа, пока не останется ноль, что значит, что дальше
; слева только нули.
	test ax, ax
	jnz oi2
; Теперь приступим к выводу.
	mov ah, 02h
oi3:
	pop dx
; Извлекаем очередную цифру, переводим её в символ и выводим.
	add dl, '0'
	int 21h
; Повторим ровно столько раз, сколько цифр насчитали.
	loop oi3

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

OutInt endp