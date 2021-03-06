;�������� ��������� ������������� ���193 ����������� �1

format PE console
entry start
include 'include\win32ax.inc'
;������ ������ �������� ��������� ���������� � ���������, �������� ������ ��� ������
section '.data' data readable writeable

x1      dq ?            ;��������� ��������
eps1    dd 0.0005       ;�������� 0.05%
;���������
c2      dd 2
msg1    db 'Enter x (x>0): ',0
msg2    db 'Wrong number.',13,10,0
fmt1    db '%lf',0
msg3    db "Geron's formula = %lg",13,10,0
msg4    db 'Sqrt = %lg',13,10,0
buf     db 256 dup(0)
;������ ����
section '.code' code readable executable
start:                                       ; ����� ����� � ���������
        ccall [printf],msg1             ;������� ���������
        ccall [gets],buf                ;���� ������ � �������
        ccall [sscanf],buf,fmt1,x1      ;��������������� ��������� ������ � �����
        cmp eax,1               ;���� �������������� �������, 
        jz m1                   ;����������
        ccall [printf],msg2     ;������� ��������� �� ������
        jmp start               ;������ ������
m1:     fld [x1]                ;x
        fldz                    ;0
        fcompp                  ;�������� 0 � �������� ������
        fstsw   ax              ;�������� ����� ������������ � ��
        sahf                    ;��������� �� � ����� ����������
        jae start               ;0>=x, ������ ������
        fld [eps1]              ;�������� ����������
        sub esp,8               ;�������� � ����� ����� ��� double
        fstp qword [esp]        ;�������� � ���� double �����     
        fld qword [x1]          ;��������� ��������
        sub esp,8               ;�������� � ����� ����� ��� double
        fstp qword [esp]        ;�������� � ���� double �����     
        call mysqrt             ;��������� mysqrt(x,eps)
        add esp,16              ;������� ���������� ���������     

        sub esp,8               ;�������� ����������� �� ������� ������ ��������
        fstp qword [esp]        ;������� ����� ����
        push msg3               ;������ ���������
        call [printf]           ;������������ ���������
        add esp,12              ;��������� �����

        fld qword [x1]          ;��������� ��������
        fsqrt                   ;��������� ���������� ������ �� ����

        sub esp,8               ;�������� ������ �������� ����������� �����
        fstp qword [esp]        ;������� ����� ����
        push msg4               ;������ ���������
        call [printf]           ;������������ ���������
        add esp,12              ;��������� �����

        ccall [_getch]          ;�������� ������� ����� �������
ex:     stdcall [ExitProcess], 0;�����

;double mysqrt(double a,double eps)
;���������� sqrt(a) � ��������� eps
;���������� ������ cdecl
mysqrt:
        push ebp                ;������� ���� �����
        mov ebp,esp
        sub esp,08h             ;�������� ��������� ����������
;��������� ����������
xp      equ ebp-8h              ;�������� � �� ���������� ����          
        fld qword [ebp+8]       ;x=a

lp:     fst qword [xp]          ;xp=x
        fld qword [ebp+8]       ;a
        fld st1                 ;x
        fdivp st1,st            ;a/x
        faddp st1,st            ;x+a/x
        fidiv [c2]              ;x=(x+a/x)/2
        fld st                  ;x
        fsub qword [xp]         ;x-xp
        fabs                    ;|x-xp|
        fcomp qword [ebp+16]    ;�������� |x-xp| � eps
        fstsw ax        ;��������� ����� ��������� � ��
        sahf            ;������� ah � ����� ����������
        jae lp          ;���� |x-xp| >= xp, ���������� ����

        leave                   ;������ �������
        ret

section '.idata' import data readable        ; ������ ������������� �������

library kernel,'kernel32.dll',\
        user,'user32.dll',\
        msvcrt,'msvcrt.dll'

import  kernel,\
        ExitProcess,'ExitProcess'

import  msvcrt,\
        sscanf,'sscanf',\
        gets,'gets',\
        _getch,'_getch',\
        printf,'printf'

