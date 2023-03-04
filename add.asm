segment .data
	msg1 db "nhap so dau tien:"		
	len1 equ $- msg1			; do dai msg1
	msg2 db "nhap so thu hai:"
	len2 equ $- msg2			; do dai msg2
	total TIMES 21 db "0"		; total de cong tong cua hai so 
	num1_rev TIMES 21 db "0"	; dung de chua so dau tien bi dao nguoc
	num2_rev TIMES 21 db "0"	; dung de chua so thu 2 bi dao nguoc
segment .bss
	num1 resb 21				;so dau tien
	num2 resb 21				; so thu 2
	
segment .text
	global _start:
_start:
	mov rsi,msg1				; chi rsi den dia chi cua msg1
	mov rdx,len1				; do dai can in cua chuoi msg1
	call _print					;goi func _print

	mov rsi,num1				; chi rsi den dia chi cua num1
	mov rdx,21					;do dai muon ham sysread doc vo num1
	call _scan					;goi ham _scan

	; sau khi goi ham sysread thi do dai chuoi doc vo se duoc luu vao thanh rax
	dec rax						;giam gia tri cua thanh rax di 1 de loai bo ky tu "\n"
	mov r8,rax					;dung r8 de chi den  tan cung ben phai num1 vd:num1=1234 thi [num1 + r8]=4
	dec r8
	mov r9,0					; set r9=0
	mov ecx,eax					; dung ecx lam bien counter cho vong lap _rev_num1
	clc							; clear carry flag
_rev_num1:
	mov al,[num1 + r8]			; al= gia tri num1[r8]
	pushf						
	or al,0x30					; al = gia tri ascii cua cua so num1[r8]
	popf
	mov [num1_rev+r9],al		;num1_rev[r9]= al 
	inc r9						; tang r9 them 1
	dec r8						;r8-=1
	loop _rev_num1				; loop _rev_num1 ==> sau khi ket thuc vong lap thi num1=1234 num1_rev=4321

	mov rsi,msg2				; chi rsi den msg2
	mov rdx,len2				; do dai can in msg2
	call _print					; goi ham _print
	
	mov rsi,num2				; chi rsi den num2
	mov rdx,21					; do dai muon ham sysread doc vo num2
	call _scan					; goi ham scan
	
	dec rax						; tu day tro di no lam y het nhu cac buoc tren
	mov r8,rax
	dec r8
	mov r9,0
	mov ecx,eax
	clc
	
_rev_num2:
	mov al,[num2 + r8]
	pushf
	or al,0x30
	popf
	mov [num2_rev+r9],al
	inc r9
	dec r8
	loop _rev_num2				;==> sau khi ket thuc vong lap thi num1=56789 num1_rev=98765
	
	
	mov ecx,21					; dung thanh ecx lam counter loop cho add_loop
	mov r8,0					;r8=0
	mov r9,20					;r9=19 chi den gia tri tan cung ben phai cua total
	mov sil,0					; sil =0
	clc
_add_loop:
	mov al,[num1_rev+r8]		;al=num1_rev[r8] 
	sub al,"0"					; tru al di 0x30 de lay gia tri thuc cua al
	mov bl,[num2_rev+r8]		;bl=num2_rev[r8]
	sub bl,"0"					;bl=bl-0x30
	add al,bl					; al+=bl
	add al,sil					;al+=sil
	cmp al,10					; so sanh al voi 10
	jge _carry					; neu lon hon thi nhay toi _carry de su ly
	mov sil,0					;sil=0
	add al,"0"					; cong them alvoi "0" de dua no ve ky tu ascii tuong ung
	mov [total+r9],al			;dua al vo total[r9]
	inc r8						;r8+=1
	dec r9						;r9-=1
	loop _add_loop				;loop add_loop
	
	mov rsi,total				;chi rsi den total
	mov rdx,21					;do dai cua total
	call _print					;goi ham _print
	
	
	
	
	;exit
	mov rax,60					;sysexit
	syscall


_carry:
	mov sil,1					;sil=1 va phan du sil se duoc cong vao hang tiep theo
	sub al,10					;al=al-10
	add al,"0"					;al+=0x30
	
	mov [total+r9],al			;[total +r9]=al
	inc r8						;r8+=1
	dec r9						;r9-=1
	jmp _add_loop				;quay tro lai add_loop

_print:
	mov rax,1					;syswrite
	mov rdi,1					; tham so cho stdout
	syscall						;goi ham syswrite
	ret							; tra ve luong thuc thi truoc do cua chuong trinh
_scan:
	mov rax,0					;sysread
	mov rdi,0					;tham so cho stdin
	syscall						;  goi ham sysread
	ret							; tra ve luong thuc thi truoc do cua chuong trinh