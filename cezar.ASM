	         	  ORG 100H
;-----------------------Start-programu-------------------
    start:
            MOV  DX, info	;Adres zmiennej do DX
            PUSH DX		;Adres wrzuc na stos
            CALL show		;Wyswietla za pomoca procedury
    xError:
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

	    MOV DX, ent1
	    PUSH DX
	    CALL show

	    MOV DX, info2
	    PUSH DX
	    CALL show

        CALL input

;-----------------------Koniec-programu----------------------
   koniec:
            MOV AX, 4C00h
            INT 21H
;-------------------------Zmienne----------------------------
info      db    "Witaj w programie wykorzystujacym szyfrowanie cezara.$"
info1     db    "Podaj slowo do zaszyfrowania:$ "
info2	  db    "Podaj przesuniecie do uzycia w szyfrowaniu: $"
info3     db    "Podales bledne dane. $"
lancuch   db	255
          db	  0
times 256 db    '$' 
ent1	  db	10,13,36
adr_init  dw    0
mnoznik   dw    1
shifter   dw    0
st_count  dw    0
;------------------Wypisanie-lancucha-------------------------
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
;---------------------Wprowadzanie-przesuniecia-------------------------------
input:
        POP AX              ;Zrzuc adres powrotu
    MOV [adr_init], AX      ;Przenies adres do AX
    MOV CX, 0           ;Wyzeruj licznik
    
    pushloop:
            MOV AH, 1       ;Wczytanie znaku z wejscia
            INT 21H         ;Przerwanie DOS
        
            CMP AL, 13      ;Porownaj czy enter
            JE poploop      ;Jesli tak przejdz do zrzucania
        
            CMP AL, 48      ;Sprawdz czy mniejsze od cyfr w ascii
            JL _error       ;Jesli tak to koniec
            
            CMP AL, 57      ;Sprawdz czy wieksze od znakow cyfr ascii
            JG _error       ;Jesli tak to koniec
 
            INC CX          ;Mamy cyfre wiec zwieksz CX
            MOV [st_count], CX  ;Przenies do zmiennej przechowujacej ilosc liczb na stosie wartosc CX
                
            SUB  AL, 48     ;Odejmij od znaku 48 tak aby uzyskac odpowiadajaca jemu cyfre
            XOR  AH, AH     ;Wyzeruj gore rejestru AX
            PUSH AX         ;Wrzuc AX na stos

            JMP pushloop        ;Kolejny krok petli
        
       poploop:

            POP BX          ;Zdejm cyfre ze stosu
            XOR BH, BH      ;Wyzeruj gore rejestru BX
            ;MOV [digit], BX     ;Przenies cufre do zmiennej
        
            XOR AX, AX      ;Wyzeruj AX 
            MOV AX, [mnoznik]   ;Przenies do AX wartosc mnoznika
            MUL BX          ;Pomnoz AX razy BX wynik w DX:AX
        
            ADD [shifter], AX      ;Dodaj do zmiennej tymczasowej kolejna wartosc
        
            MOV BX, 10      ;Zaladuj rejestr BX wartoscia 10
            XOR BH, BH      ;Wyzeruj gore BX
            MOV AX, [mnoznik]   ;Przenies do AX wartosc mnoznika
            MUL BX          ;Z kazdym kolejnym zdjeciem ze stosu mnoznik wzrasta x 10 po 
            MOV [mnoznik], AX   ;Przenies mnoznik do zmiennej 
    
            loop poploop        ;Wykonuj petle

                MOV AX, [adr_init]      ;Przenies do AX adres powrotu procedury
        PUSH AX             ;Wrzuc adres powrotu na stos
        XOR AX, AX      ;Wyzeruj AX
        MOV AX, 1       ;Przenies do AX wartosc poczatkowa mnoznika
        MOV [mnoznik], AX   ;Do zmiennej mnoznik przenies jego wartosc poczatkowa
        XOR AX, AX      ;Wyzeruj AX
        XOR BX, BX      ;Wyzeruj BX
        
  RET
;-----------------------------Obsluga-bledow-----------------------------

_error:
        MOV  DX, ent1
        PUSH DX
        CALL show

        MOV  DX, info3
        PUSH DX
        CALL show
    
    MOV  DX, ent1
    PUSH DX
    CALL show

        JMP xError
;------------------------------------------------------------------------ 