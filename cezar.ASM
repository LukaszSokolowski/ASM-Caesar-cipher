	         	  ORG 100H
;-----------------------Start-programu-------------------
    start:
            MOV  DX, info	;Adres zmiennej do DX
            PUSH DX		;Adres wrzuc na stos
            CALL show		;Wyswietla za pomoca procedury

	    MOV  DX, ent1	;Do DX adres zmiennej
            PUSH DX		;Adres na stos
            CALL show		;Wyswietla lancuch

            MOV  DX, info1	;Do DX adres zmiennej
            PUSH DX		;Wrzuc na stos adres
            CALL show		;Wywolanie procedury wyswietlajacej

	    MOV  DX, ent1	;Do DX adres zmiennej
	    PUSH DX		;Wrzuc adres na stos
	    CALL show		;Wyswietlanie lancucha

            MOV AH, 10		;Wejscie za pomoca bufora
            MOV DX, lancuch	;Adres zmiennej lancuch 
            INT 21H		;Przerwanie DOS
		
            MOV DX, ent1	;Wrzuc adres zmiennej do DX
            PUSH DX		;Wrzuc adres na stos
            CALL show		;Wywolanie procedury wyswietlajacej

            MOV DX, lancuch	;Przenies zmienna pobrana z wejscia buforowego
            ADD DX, 2		;przesun adres o 2 
            PUSH DX		;Wrzuc adres na stos
	    CALL show		;Wyswietlanie lancucha

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



