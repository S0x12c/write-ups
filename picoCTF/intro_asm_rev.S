.intel_syntax noprefix
	
.global asm0

asm0:
	push ebp
	mov ebp,esp
    push ebx //RG
	mov eax,DWORD PTR [ebp+0x8]
	mov ebx,DWORD PTR [ebp+0xc]
	mov eax,ebx
    pop ebx //RG
	mov esp,ebp
	pop ebp	
	ret
