segment .data
	msg1 db "nhap sau S:"	
	len1 equ $- msg1	; do dai msg1
	msg2 db "nhap sau C:"
	len2 equ $- msg2	; do dai msg2
	newline db 0xa		;dau xuong dong
	cach db 32 		;dau cach
segment .bss
	offset resq 1		;offest dung de luu vi tri cua chuoi con tim kiem duoc
	S resb 101		; xau S 
	C resb 11		;xau C
	lenC resq 1		; do dai xau C
	count resq 1		; bien count de dem so lan chuoi C xuat hien trong chuoi S
	index resb 4		
	output resq 10		; output dung de luu cac vi tri cua chuoi C trong S
segment .text
	global _start:
_start:
	mov qword[count],0	; thiet lap bien count =0
	
	
	mov rsi,msg1		; move rsi dia chi cua msg1
	mov rdx,len1		; do dai cua chuoi msg1
	call _print		; goi ham _print
	
	mov rsi,S		;dia chi de luu xau S
	mov rdx,101		; do dai muon ham sysread doc vo chuoi S
	call _scan		; goi ham _scan
	
	mov rsi,msg2		; move rsi dia chi chuoi msg2
	mov rdx,len2		; do dai cua chuoi msg2
	call _print		;goi ham Print
	
	mov rsi,C		;dia chi de luu chuoi C
	mov rdx,11		; do dai muon hamf sysread doc vo chuoi C
	call _scan		;goi ham scan
	dec rax			; sau khi goi ham sysread ,do dai cua chuoi vua doc se duoc luu vo rax , can tru rax di 1 de loai bo ky tu "\n"
	mov qword [lenC],rax	; luu gia tri cua rax vo lenC
	
	mov rsi,S		;chi rsi den dia chi cua chuoi S
	mov rdi,C		;chi rdi den dia chi cua chuoi C
	mov ecx,0		; truyen chi ecx gia tri 0
	mov qword[offset],0	;thiet lap offset =0 
	mov rdx,rdi		; chi rdx den cung chuoi C
_find:
	mov rdi,rdx		;moi khi ham loop ta can rdi quay lai chi vo dia chi ban dau cua chuoi C da duoc thanh rdx luu
	mov al,[rsi]		;dua tung byte cua chuoi S vo al
	cmp al,0xa		;so sanh al voi "\n" 
	je _printloop		; neu al=="\n' thi da het sau S
	
	cmp al,[rdi]		; so sanh al voi byte dau tien cua cua chuoi C
	jne _ret		; neu khog giong nhau thi nhay den ham _ret
	
	mov rdx,rdi		; neu al== ky tu dau tien cua chuoi C thi ta can luu dia chi cua chuoi C vo thanh rdx con thanh rdi se dung de so sanh voi rsi
	_check:
		mov al,[rdi]	; truyen ky tu cau chuoi C vo al
		cmp al,0xa	; kiem tra xem no co bang voi ky tu xuong dong
		je _found	; neu al=="\n" thi tuc la da tim thay chuoi con
		
		mov al,[rdi]	; truyen ky tu cau chuoi C vo al
		cmp al,[rsi]	;so sanh al voi tung ky tu tuong ung voi xau S
		jne _find	; neu khong bang nhau thi quay tro  lai func _find 
		
		inc rdi		; tang gia tri cua rdi de chi den ky tu tiep theo cua chuoi C
		inc rsi		;tang gia tri tiep theo cua rsi de chi den gia tri tiep theo cua chuoi S
		add qword [offset],1	;tang offset them 1 de keeptrack voi kys tu tuong ung cua chuoi S
		jmp _check		; loop ham check de kiem tra chuoi con
	_found:
		add qword [count],1	;neu tim thay chuoi con thi tang count len 1
		mov rax,[offset]	; dua vi tri hien tai cua chuoi S vo rax
		sub rax,qword [lenC]	; lay vi tri hien tai -do dai cua chuoi C thi se tim duoc vi tri xuat hien cua chuoi con C trong S
		mov qword[output +r8*8],rax	;luu vi tri cua chuoi con vo mang output[r8]  
		inc r8				; tang r8 them 1 de chi vo vi tri tiep theo cua mang
		jmp _find			; quay to lai ham find de tim vi tri cua cac chuoi con tiep theo
	_ret:
		inc rsi			; tang gia tri cua rsi them 1 de chi vao ky tu tiep theo cua chuoi S
		add qword[offset],1	;tang offset them 1 de keeptrack voi vi tri hien tai cua chuoi S
		jmp _find		; loop lai func _find
	
_printloop:
	mov r9,4
	mov rax, qword[count]	;truyen gia tri cua bien count vo rax
	call _intoa		; goi ham _intoa de doi gia tri so sang ascii tuong ung va tra ve index
	mov rsi,index		;chi rsi den index
	mov rdx,8		;do dai cua chuoi muon in
	call _print		; goi ham _print 
	
	mov rsi,newline		;in ky tu xuong dong
	mov rdx,1
	call _print
	
	
	mov r8,0		;dung r8 de chi den cac phan tu chua mang output
	
	_print_index:
		cmp r8,qword [count];cho nay sai
		je _exit	; so sanh r8 voi bien count neu bang roi thif thoat chuong trinh
		mov r9,4	
		mov rax,qword[output +r8*8]	;chir rax den output[r8]
		call _intoa			; goi ham _intoa de doi rax ra ky tu ascii tuong ung va tra ve index
		mov rsi,index			;chir rsi den index
		mov rdx,4			; doi dai chuoi muon in
		call _print			; goi ham print
		
		mov rsi,cach			; in dau cach
		mov rdx,1
		call _print
		inc r8				; tang r8 them 1 de chi den phan tu tiep theo cua output
		jmp _print_index		;loop ham -print_index
	_exit:
		mov rax,60
		syscall
_intoa:
	dec r9			;giam r9 de chi den vi tri tiep theo cua index tu phai qua trai
	mov ebx,10		; rbx=10
	xor edx,edx		; edx=0
	div ebx			; edx=rax % rbx
	add dl,"0"		;dl +0x30 de lay ky tu ascii tuong ung
	mov byte [index+r9],dl	;dua dl vo index tu phai qua trai
	cmp rax,0		; so sanh rax voi 0
	jnz _intoa		; loop ham -intoa neu rax!=0
	ret			; tra chuong trinh ve luong thuc thi truoc do
_print:
	mov rax,1		; syswrite
	mov rdi,1		; tham so cho stdout
	syscall			; goi ham write
	ret			; tra ve luong thuc thi ban dau
_scan:
	mov rax,0		;sysread
	mov rdi,0		;tham so cho stdin 
	syscall			; goi ham read
	ret			;tra ve luong thuc thi ban dau