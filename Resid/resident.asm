.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h  

ENTRY:
	jmp main   

exit proc
	jmp dword ptr cs:[defaultVector] 
exit endp

check proc
	mov ax, 0
	iret
check endp

removeHook proc
	pusha

	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	
	mov dx, word ptr cs:[defaultVector]
	mov ds, word ptr cs:[defaultVector+2]
	mov ax, 2500h ; 
	int 21h
	
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание
	
	mov ah, 9h
	mov dx, offset delMes
	int 21h
	
	mov ah, 49h ; освобождаем память 
    int 21h

	pop ds;восстановил ds вызывающей программы
	
	popa
	iret
removeHook endp

interruptHook proc
	cmp ah, 01h
	je removeHook
	
	cmp ah, 00h
	je exit
	
	cmp ah, 02h
	je check

	push ds ; сохраняю ds вызвавшей программы
	
	push cs
	pop ds ; в ds кладу сегмент, в котором лежит моё прерывание

	pushf
	mov ah, 9h
	mov dx, offset mes
	int 21h
	
	call dword ptr cs:[defaultVector]  ; Зовем стандартный обработчик

	pop ds;восстановил ds вызывающей программы
	
	iret ; восстановит cs

defaultVector	dd ?
mes db 'hook$'
delMes db 'hook deleted$'
interruptHook endp

main:
	mov	ax,3500h
	int	21h
	
	mov	word ptr defaultVector, bx 
	mov	word ptr defaultVector+2, es
	cli
	mov	ax,2500h 
	mov	dx,offset interruptHook
	int	21h
	sti
	
	mov	dx,offset main
	int	27h
	
cseg ends	
end ENTRY
