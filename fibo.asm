segment .data
	newline db 10       	;newline de xuong dong
	msg1 db "nhap N:"	;lay input	
	len1 equ $- msg1	;do dai cua msg1
	
segment .bss
	fibo resq 99	; cap bo nho cho moi so in ra 8byte , nhieu nhat 99 so
	num resb 21	; num dung de doi tu gia tri ra ascii cua no roi dung sau do truyen num vo rsi de in ra
	N resb 3	;N de lay gia tri input
	M resq 1	;M dung de doi N tu ascii sang value
segment .text
	global _start;
_start:
	mov rax,1	;syswrite
	mov rdi,1	;tham so cho stdout
	mov rsi,msg1	;chuoi can in
	mov rdx,len1	; do dai chuoi muon in
	syscall		; in chuoi msg1
	
	mov rax,0	;sysread
	mov rdi,0	;tham so cho stdin
	mov rsi,N	;dia chi N de luu gia tri input
	mov rdx,3	; no dai muon doc
	syscall		;doc input
	; sau khi read input thi do dai cua inpur se duoc luu vao thah rax
	dec rax		; giam do dai cua thanh rax di 1 de loai bo ky tu xuong dong"\n"
	mov ecx,eax	;luu eax vo ecx dung ecx lam bien counter cho vong lap
	mov r9,0	; dung r9 de chi vao tung byte gia tri cua N
	mov rdx,0	; 
	mov rax,0	;
	clc
_strtoi:
	mov rbx,10	; rax *rbx
	mul rbx		;rax*rbx
	mov bl,byte[N+r9]	;dua cac gia tri ascii cua N vo bl
	sub bl,0x30	; tru bl di 0x30 
	add rax,rbx	; rax+rbx
	inc r9		; tang r9 them 1 de chi vo byte tiep theo cua N
	loop _strtoi	; lap func nay so lan bang voi gia tri cua ecx
	
	mov [M],rax     ; luu gia tri vua doi tu N vao M
	
		
	mov r8,0	;	r8 gia tri lien tiep trong chuoi so fibonacci duoc luu vo bien fibo
	mov qword [fibo],0	;thiet lap gia tri dau tien trong chuoi fibo =0
	mov rsi,fibo		; in gia tri dau tien =0
	call _print
	mov qword [fibo+8],1	;thiet lap gia tri thu 2 trong chuoi fibo =1
	mov rsi,qword [fibo+8]	;in gia tri thu 2 do ra 
	call _print
	call _print_loop	; goi ham print loop de in cac gia tri tiep sau do
_print_loop:
	mov rax,r8		;khong biet vi sao khong so sanh truc tiep r8 voi gia tri M duoc nen em phai chuyen no vo rax 
	cmp rax,qword[M]	;kiem tra xem da in du so fibonacci chua
	je _exit		; neu rax=M thi thoat chuong trinh
	mov rax,qword [fibo +r8*8 -16]	;move rax gia tri cua so fibo thu r8-2
	add rax,qword [fibo +r8*8 -8]	; cong rax voi gia tri cua so fibo thu r8-1
	mov qword [fibo +r8*8],rax	;luu rax vo so fibo thu r8
	mov rsi,qword [fibo +r8*8]	;in gia tri cua so thu r8
	call _print			; goi ham print
	loop _print_loop		; lap vong _print_loop
_exit:	
	mov rax,60		;sysexit
	syscall			; thoat chuong trinh
	ret			;can them lenh ret de no tra ve luongf thuc thi luc dau

_intoa:				; ham nay dung de doi gia tri cua cac so fibo ra ky tu ascii tuong ung
	dec r9			; giam gia tri cua r9 de chi den cac byte tan cung phia phai cua num
	mov ebx,10
	xor edx,edx		;dua edx=0
	div ebx			; thuc hien chia rax cho ebx=10
	add dl,"0"		; phan du se duoc luu o edx ,cong dl voi 0x30 de dua no ve gia tri ascii tuong ung
	mov byte [num+r9],dl	; dua dl vo gia tri tuong ung voi no o trong num
	cmp rax,0		; so sanh rax voi 0
	jnz _intoa		; neu rax !=0 thi loop lai chuong trinh nay
	ret			; tra ve luong thuc thi truoc do
_print:
	mov r9,21			;r9=21 de chi ve byte tan cung ben phai cua num
	mov rax,qword[fibo + r8*8]	;dua gia tri cua so fibo thu r8 vo rax
	call _intoa			; goi ham _intoa de doi gia tri cua r so ra gia tri ascii tuong ung va luu vao bien num
	mov rsi,num			; truyen dia chi ham num vo rsi de in ra
	mov rax,1			; syswrite
	mov rdi,1			; tham so cho stdout
	mov rdx,21			; do dai cua num
	syscall				;goi ham write
	
	mov rsi,newline			; truyen gia tri cua ky tu "\n"vo rsi
	mov rax,1			;syswrite	
	mov rdi,1			;tham so cho stdout
	mov rdx,1			;do dai cua ky tu "\n"
	syscall				;goi ham ra
	
	inc r8				; tang gia tri r8 de chi den so fibo tiep the0
	ret 				; tra ve luong thuc thi ban dau
	
	
	