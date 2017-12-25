	         	  ORG 100H
;-----------------------Start-programu-------------------
    start:
            MOV DX, info
            PUSH DX
            CALL show

	    MOV DX, ent1
            PUSH DX
            CALL show

            MOV DX, info1
            PUSH DX
            CALL show

	    MOV DX, ent1
	    PUSH DX
	    CALL show	

            MOV AH, 10
            MOV DX, lancuch
            INT 21H

            MOV DX, ent1
            PUSH DX
            CALL show

            MOV DX, lancuch
            ADD DX, 2
            PUSH DX
	    CALL show

;-----------------------Koniec-programu------------------
   koniec:
            MOV AX, 4C00h
            INT 21H
;-------------------------Zmienne------------------------
info      db    "Witaj w programie wykorzystujacym szyfrowanie cezara.$"
info1     db    "Podaj slowo do zaszyfrowania:$ "
info2	  db    "Podaj przesuniecie do uzycia w szyfrowaniu: $"
lancuch   db	255
          db	  0
times 256 db    '$' 
ent1	  db	10,13,36

;--------------------------------------------------------
show:   
        POP  AX     ;Zrzuc adres powrotu
        POP  BX     ;Zrzuc adres zmiennej do wyswietlenia
        PUSH AX     ;Wrzuc adres powrotu
        MOV  CX, 0  ;Przenies do CX wartosc 0

    showloop:
            MOV SI, CX       ;Do rejestru SI przenies wartosc CX
            MOV DL, [BX + SI];Do DL przenies kolejny znak wedrujac rejestrem SI od bazowego BX
            CMP DL, 36       ;Porownaj czy to znak dolara
            JE  showEND      ;Jesli tak koniec wyswietlania lancucha
            MOV AH, 2        ;Zaladuj AH wartoscia 2 czyli wypisanie znaku z DL
            INT 21H          ;Przerwanie DOS
            INC CX           ;Zwieksz o 1 wartosc CX
            JMP showloop     ;Przejdz do kolejnego kroku
     showEND:
RET



