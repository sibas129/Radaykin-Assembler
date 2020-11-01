;Радайкин Владислав Александрович БПИ193 Микропроект №1

format PE console
entry start
include 'include\win32ax.inc'
;Секция данных содержит строковые переменные и константы, доступна только для чтения
section '.data' data readable writeable

x1      dq ?            ;введенное значение
eps1    dd 0.0005       ;точность 0.05%
;константы
c2      dd 2
msg1    db 'Enter x (x>0): ',0
msg2    db 'Wrong number.',13,10,0
fmt1    db '%lf',0
msg3    db "Geron's formula = %lg",13,10,0
msg4    db 'Sqrt = %lg',13,10,0
buf     db 256 dup(0)
;секция кода
section '.code' code readable executable
start:                                       ; точка входа в программу
        ccall [printf],msg1             ;вывести сообщение
        ccall [gets],buf                ;ввод строки с консоли
        ccall [sscanf],buf,fmt1,x1      ;преобразовываем введенную строку в число
        cmp eax,1               ;если преобразование удалось, 
        jz m1                   ;продолжить
        ccall [printf],msg2     ;вывести сообщение об ошибке
        jmp start               ;начать заново
m1:     fld [x1]                ;x
        fldz                    ;0
        fcompp                  ;сравнить 0 с веденным числом
        fstsw   ax              ;записать флаги сопроцессора в ах
        sahf                    ;перенести их в флаги процессора
        jae start               ;0>=x, начать заново
        fld [eps1]              ;точность вычисления
        sub esp,8               ;выделить в стеке место под double
        fstp qword [esp]        ;записать в стек double число     
        fld qword [x1]          ;введенное значение
        sub esp,8               ;выделить в стеке место под double
        fstp qword [esp]        ;записать в стек double число     
        call mysqrt             ;Вычислить mysqrt(x,eps)
        add esp,16              ;удалить переданные параметры     

        sub esp,8               ;передать вычисленное по формуле Герона значение
        fstp qword [esp]        ;функции через стек
        push msg3               ;формат сообщения
        call [printf]           ;сформировать результат
        add esp,12              ;коррекция стека

        fld qword [x1]          ;введенное значение
        fsqrt                   ;вычислить квадратный корень из него

        sub esp,8               ;передать точное значение квадратного корня
        fstp qword [esp]        ;функции через стек
        push msg4               ;формат сообщения
        call [printf]           ;сформировать результат
        add esp,12              ;коррекция стека

        ccall [_getch]          ;ожидание нажатия любой клавиши
ex:     stdcall [ExitProcess], 0;выход

;double mysqrt(double a,double eps)
;вычисление sqrt(a) с точностью eps
;соглашение вызова cdecl
mysqrt:
        push ebp                ;создать кадр стека
        mov ebp,esp
        sub esp,08h             ;создание локальных переменных
;локальные переменные
xp      equ ebp-8h              ;значение х на предыдущем шаге          
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
        fcomp qword [ebp+16]    ;сравнить |x-xp| с eps
        fstsw ax        ;перенести флаги сравнения в ах
        sahf            ;занести ah в флаги процессора
        jae lp          ;если |x-xp| >= xp, продолжаем цикл

        leave                   ;эпилог функции
        ret

section '.idata' import data readable        ; секция импортируемых функций

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

