OutInt proc
	
	push ax
	push bx
	push cx
	push dx
	push bp
	mov bp, sp ; bp - ��� ��������� �� ����

	mov ax, [bp+12]

; ��������� ����� �� ����.
	test ax, ax
	jns oi1

; ���� ��� �������������, ������� ����� � ������� ��� ������.
	mov  cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	neg ax
; ���������� ���� ����� ������� � CX.
oi1:
	xor cx, cx
	mov bx, 10
oi2:
	xor dx,dx
	div bx
; ����� ����� �� ��������� ��. � ������� ���������� ��������� �����.
; ����� �������� � ������, ������� �������� � � �����.
	push dx
	inc cx
; � � ������� ��������� �� �� �����, ������� �� ���� ���������
; ����� ������, ���� �� ��������� ����, ��� ������, ��� ������
; ����� ������ ����.
	test ax, ax
	jnz oi2
; ������ ��������� � ������.
	mov ah, 02h
oi3:
	pop dx
; ��������� ��������� �����, ��������� � � ������ � �������.
	add dl, '0'
	int 21h
; �������� ����� ������� ���, ������� ���� ���������.
	loop oi3

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

OutInt endp