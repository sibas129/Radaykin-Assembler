format PE console
entry start

; Студент: Радайкин Владислав Александрович
; Группа: БПИ193
; Вариант: 18

; Задание: сгенерировать массив В из элементов A,
; с уменьшением всех элементов до первого положительного на 5

include 'win32a.inc'

;-----------------------—----—------------------------------------------—
section '.data' data readable writable

strVecSize db 'Input size of vector A: ', 0
strIncorSize db 'Incorrect size of vector = %d', 10, 0
strVecElemI db '[%d] = ', 0
strScanInt db '%d', 0
strVecOutA db 10, 'Vector A:', 10, 0
strVecOutB db 10, 'Vector B:', 10, 0
strVecElemOut db '[%d] = %d', 10, 0

A_size dd 0 ; размер массива А
B_size dd 0 ; размер массива В
i dd ?
tmp dd ?
tmpStack dd ?
vecA rd 100 ; массив А
vecB rd 100 ; массив В

;-----------------------—----—-------------------------------------------—
section '.code' code readable executable
start:

; 1) vector А input
call VectorInput

; 2) generate vector B
call VectorSub5

; 3) vector B out
push strVecOutB
call [printf]

call VectorOut

finish:
call [getch]

push 0
call [ExitProcess]

;------------------------------------------------------------------------—
VectorInput:
push strVecSize
call [printf]
add esp, 4

push A_size
push strScanInt
call [scanf]
add esp, 8

push strVecOutA
call [printf]
add esp, 4

mov eax, [A_size]
cmp eax, 0
jg getVector
; завершаем программу при введёном размере меньше или равном 0
push A_size
push strIncorSize
call [printf]
push 0
call [ExitProcess]
; заполняем массив
getVector:
xor ecx, ecx
mov ebx, vecA
getVecLoop:
mov [tmp], ebx
cmp ecx, [A_size]
jge endInputVector

; считываем значение
mov [i], ecx
push ecx
push strVecElemI
call [printf]
add esp, 8

push ebx
push strScanInt
call [scanf]
add esp, 8

mov ecx, [i]
inc ecx
mov ebx, [tmp]
add ebx, 4
jmp getVecLoop
endInputVector:
ret
;------------------------------------------------------------------------—
VectorSub5:
xor ecx, ecx
mov ebx, vecA
mov edx, vecB
Sub5:
cmp ecx, [A_size]
je endSumVector

; сравниваем значение из массива А с 0,
; чтобы определить, в какой цикл осуществить переход
mov eax, 0
cmp [ebx], eax
jg SimpleLoop

mov eax, [ebx]
mov [edx], eax
mov eax, 5
sub [edx], eax
add edx, 4
inc [B_size]
jmp ToNextElem

SimpleLoop:
cmp ecx, [A_size]
je endSumVector

mov eax, [ebx]
mov [edx], eax
add edx, 4
inc [B_size]

inc ecx
add ebx, 4
jmp SimpleLoop

ToNextElem:
inc ecx
add ebx, 4
jmp Sub5
endSumVector:
ret
;------------------------------------------------------------------------—
VectorOut:
mov [tmpStack], esp
xor ecx, ecx
mov ebx, vecB
putVecLoop:
mov [tmp], ebx
cmp ecx, [B_size]
je endOutputVector
mov [i], ecx

; выводим значение
push dword [ebx]
push ecx
push strVecElemOut
call [printf]

mov ecx, [i]
inc ecx
mov ebx, [tmp]
add ebx, 4
jmp putVecLoop
endOutputVector:
mov esp, [tmpStack]
ret

;-----------------—-----—---------------------------------------------------—

section '.idata' import data readable
library kernel, 'kernel32.dll',\
msvcrt, 'msvcrt.dll',\
user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
import kernel,\
ExitProcess, 'ExitProcess',\
HeapCreate,'HeapCreate',\
HeapAlloc,'HeapAlloc'
include 'api\kernel32.inc'
import msvcrt,\
printf, 'printf',\
scanf, 'scanf',\
getch, '_getch'