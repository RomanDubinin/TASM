.386
cseg segment use16
assume CS:cseg, DS:cseg, SS:cseg
Org 100h 

entry:
    jmp start

	mes db ' hi$'
start:
    
    mov ah, 01h
	int 00h
	
	mov ah, 9h
	mov dx, offset mes
	int 21h
    
    mov ah,04Ch
    int 21h
cseg ends
end entry