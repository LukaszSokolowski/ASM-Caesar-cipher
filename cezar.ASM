	         	  ORG 100H
;-----------------------Start-programu-------------------
    start:
		MOV  DX, info	;Adres zmiennej do DX
		PUSH DX		;Adres wrzuc na stos
		CALL show	;Wyswietla za pomoca procedury
    xError:
		MOV  DX, ent1	;Do DX adres zmiennej
		PUSH DX		;Adres na stos
		CALL show	;Wyswietla lancuch

		MOV  DX, info1	;Do DX adres zmiennej
		PUSH DX		;Wrzuc na stos adres
		CALL show	;Wywolanie procedury wyswietlajcej lancuch

		MOV  DX, ent1	;Do DX adres zmiennej
		PUSH DX		;Wrzuc adres na stos
		CALL show	;Wyswietlanie lancucha

		MOV AH, 10	;Wejscie za pomoca bufora
		MOV DX, inpStrin;Adres zmiennej lancuch 
		INT 21H		;Przerwanie DOS
		
		MOV  DX, ent1	;Wrzuc adres zmiennej do DX
		PUSH DX		;Wrzuc adres na stos
		CALL show	;Wywolanie procedury wyswietlajacej

		CALL lower	;Sprawdz czy lancuch zawiera duze litery
       
		MOV  DX, info2	;Przenies do DX adres zmiennej info2
		PUSH DX		;Wrzuc adres na stos
		CALL show	;Wyswietl lancuch

		CALL input	;Wywolaj procedure wprowadzenia wartosci przesuniecia
            
		MOV  DX, info4  ;Adres zmiennej do DX
		PUSH DX         ;Adres wrzuc na stos
		CALL show       ;Wywolaj procedure wyswietlenia znakow

		MOV  DX, ent1   ;Wrzuc adres zmiennej ent1 do DX
		PUSH DX         ;Adres na stos
		CALL show       ;Wywolaj procedure wyswietlenia znakow
        
        MOV AH, 1       ;Wczytanie znaku z wejscia
        INT 21H         ;Przerwanie DOS
        CMP AL, '-'
        JE  ujemn
        CMP AL, '+'
        JE  dodat


   reslt:

        MOV  DX, ent1
        PUSH DX
        CALL show

        MOV  DX, info5
        PUSH DX
        CALL show

        MOV  DX, inpStrin
        ADD  DX, 2
        PUSH DX
        CALL show


;-----------------------Koniec-programu----------------------
   koniec:
            MOV AX, 4C00h
            INT 21H
;-------------------------Zmienne----------------------------
info      db    "Witaj w programie wykorzystujacym szyfrowanie cezara.$"
info1     db    "Podaj slowo do zaszyfrowania:$ "
info2	  db    "Podaj wartosc bezwzgledna przesuniecia w zakresie od 0 do 25: $"
info3     db    "PODALES BLEDNE DANE! $"
info4     db    "Przesuniecie ma byc dodatnie czy ujemne? Wprowadz - gdy ujemne + gdy dodatnie.$"
info5     db    "Zaszyfrowany lancuch ma postac: $"
info6     db    "Lancuch przed: $"
inpStrin  db	255
          db	  0
times 256 db    '$' 
ent1	  db	10,13,36
adr_init  dw    0
multip    dw    1
shift     dw    0
st_count  dw    0
shiftCP   db    0
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
        POP AX             	;Zrzuc adres powrotu
        MOV [adr_init], AX  	;Przenies adres do AX
        MOV CX, 0           	;Wyzeruj licznik
    
    pushloop:
            MOV AH, 1       	;Wczytanie znaku z wejscia
            INT 21H         	;Przerwanie DOS
        
            CMP AL, 13      	;Porownaj czy enter
            JE poploop      	;Jesli tak przejdz do zrzucania
        
            CMP AL, 48      	;Sprawdz czy mniejsze od cyfr w ascii
            JL _error       	;Jesli tak to koniec
            
            CMP AL, 57      	;Sprawdz czy wieksze od znakow cyfr ascii
            JG _error       	;Jesli tak to koniec
 
            INC CX          	;Mamy cyfre wiec zwieksz CX
            MOV [st_count], CX  ;Przenies do zmiennej przechowujacej ilosc liczb na stosie wartosc CX
                
            SUB  AL, 48     	;Odejmij od znaku 48 tak aby uzyskac odpowiadajaca jemu cyfre
            XOR  AH, AH     	;Wyzeruj gore rejestru AX
            PUSH AX         	;Wrzuc AX na stos

            JMP pushloop        ;Kolejny krok petli
        
       poploop:

            POP BX          	;Zdejm cyfre ze stosu
            XOR BH, BH      	;Wyzeruj gore rejestru BX
        
            XOR AX, AX      	;Wyzeruj AX 
            MOV AX, [multip]   ;Przenies do AX wartosc mnoznika
            MUL BX          	;Pomnoz AX razy BX wynik w DX:AX
        
            ADD [shift], AX   ;Dodaj do zmiennej tymczasowej kolejna wartosc
        
            MOV BX, 10      	;Zaladuj rejestr BX wartoscia 10
            XOR BH, BH      	;Wyzeruj gore BX
            MOV AX, [multip]   ;Przenies do AX wartosc mnoznika
            MUL BX          	;Z kazdym kolejnym zdjeciem ze stosu mnoznik wzrasta x 10 po 
            MOV [multip], AX   ;Przenies mnoznik do zmiennej 
    
            loop poploop        ;Wykonuj petle

            XOR AX, AX          ;Wyzeruj AX
            MOV AX, [shift]     ;Przenies wartosc przesuniecia do AX
            CMP AX, 0           ;Porownaj czy mniejsze od 0
            JL _error           ;Jesli tak to wyswietl blad
            CMP AX, 25          ;Sprawdz czy wieksze od 25
            JG _error           ;Jesli wieksze to wyswietl blad

        MOV AX, [adr_init]      ;Przenies do AX adres powrotu procedury
        PUSH AX                 ;Wrzuc adres powrotu na stos
        XOR AX, AX      	;Wyzeruj AX
        MOV AX, 1       	;Przenies do AX wartosc poczatkowa mnoznika
        MOV [multip], AX       ;Do zmiennej mnoznik przenies jego wartosc poczatkowa
        XOR AX, AX      	;Wyzeruj AX
        XOR BX, BX      	;Wyzeruj BX
        
  RET
;-----------------------------Obsluga-bledow-----------------------------

_error:
        MOV  DX, ent1       ;Przenies do DX adres zmiennej ent1
        PUSH DX             ;Wrzuc adres na stos
        CALL show           ;Wyswietl lancuch

        MOV  DX, info3      ;Przenies adres zmiennej info3
        PUSH DX             ;Wrzuc adres na stos
        CALL show           ;Wyswietl lancuch
    
    MOV  DX, ent1           ;Wrzuc adres zmiennej do DX
    PUSH DX                 ;Wrzuc na stos
    CALL show               ;Wyswietl lancuch

        JMP xError          ;Bezwarunkowo przejdz do etykiety xError

;------------------Sprawdzenie-czy-zawiera-duze-litery----------------------- 

lower:
         POP AX                  ;Zrzuc adres powrotu
         MOV [adr_init], AX      ;Przenies adres do AX

         MOV BX, inpStrin        ;Przenies do BX adres zmiennej inpStrin  
         MOV DI, 0               ;Wyzeruj rejestr indeksowy SI
         ADD BX, 1               ;Inkrementuj rejestr BX
        
    lowLoop:
           INC DI                ;Kolejny znak w lancuchu
           MOV DL, [BX + DI]     ;Przenies do DL znak z wyniku adresowania bazowo-indeksowego
           CMP DL, '$'           ;Porownaj czy znak konca lancucha
           JE toLowEnd           ;Jesli rowne znaku konca lancucha to przejdz do zakonczenia procedury
           CMP DL, 65            ;Porownaj czy znak ponizej rozpoczenia duzych liter w ascii
           JL lowLoop            ;Jesli ponizej to nie jest to duza litera wiec szukaj dalej
           CMP DL, 90            ;Porownaj czy znak powyzej duzych liter w ascii
           JG lowLoop            ;Jesli powyzej to nie jest to duza litera wiec przejdz do kolejnego kroku

           ADD DL, 32            ;Zostaje nam duza litera wiec dodaj wartosc tak aby w ascii byla to mala
           MOV [BX + DI], DL     ;zamien wartosc tego znaku w lancuchu

           JMP lowLoop           ;Kolejny krok petli

toLowEnd:
         MOV  AX, [adr_init]     ;Do AX wartosc adresu powrotu
         PUSH AX                 ;Wrzuc adres powrotu na stos
RET
;--------------------------------Wykonaj-przesuniecie-ujemne-------------------------------
ujemn:

        XOR AX, AX              ;Wyczysc AX
        XOR BX, BX              ;Wyczysc BX
        XOR DX, DX              ;Wyczysc DX
        MOV BX, inpStrin        ;Przenies do BX adres zmiennej inpStrin
        MOV SI, 0               ;Przenies do SI wartosc 0
        ADD BX, 1               ;Dodaj do rejestru bazowego 1

     shiftM:
            INC SI              ;Zwieksz rejestr SI o jeden
            MOV DL, [BX + SI]   ;Przenies pod DL znak spod adresu BX+SI
            CMP DL, '$'         ;Porowaj ze znakiem dolara
            JE ujemEnd          ;Jesli tak to przejdz do konca etykiety
            CMP DL, 97          ;Sprawdz czy znak inny niz litera
            JL shiftM           ;Jesli tak to przejdz do kolejnego kroku bez szyfrowania
            CMP DL, 122         ;Sprawdz czy znak inny niz litera
            JG shiftM           ;Jesli tak to przejdz do kolejnego kroku bez szyfrowania
            MOV DH, [shift]     ;Przenies wartosc przesuniecia do DH
            SUB DL, DH          ;Odejmij od wartosci znaku wartosc przesuniecia
            CMP DL, 97          ;Porownaj wartosc DL z 97
            JL odej             ;Jesli ponizej to przejdz do etykiety odej
            MOV [BX + SI], DL   ;Jesli nie to przesuniecie znaku miesci sie w zakresie wiec zatwierdz
     JMP shiftM                 ;Przejdz do kolejnego kroku

       odej:            
            MOV DH, 97          ;Przenies do DH wartosc 97
            SUB DH, DL          ;Odejmij od 97 wartosc przesuniecia
            MOV DL, 122         ;Przenies do DL 122 
            SUB DL, DH          ;Odejmij od 122 wartosc roznicy przesuniecia
            MOV [BX + SI], DL   ;Zapisz znak
      JMP shiftM                ;Przejdz do kolejnego kroku
            
ujemEnd:
      JMP reslt

;-------------------------------Wykonaj-przesuniecie-dodatnie----------------------------
dodat:
        XOR AX, AX              ;Wyczysc AX
        XOR BX, BX              ;Wyczysc BX
        XOR DX, DX              ;Wyczysc DX
        MOV BX, inpStrin        ;Przenies do BX adres zmiennej inpStrin
        MOV DI, 0               ;Przenies do DI wartosc 0
        ADD BX, 1               ;Dodaj do rejestru bazowego BX wartosc 1

     shiftP:
            INC DI
            MOV DL, [BX + DI]
            CMP DL, '$'
            JE dodEnd
            CMP DL, 97          ;Sprawdz czy znak inny niz litera
            JL shiftP           ;Jesli tak to przejdz do kolejnego kroku bez szyfrowania
            CMP DL, 122         ;Sprawdz czy znak inny niz litera
            JG shiftP           ;Jesli tak to przejdz do kolejnego kroku bez szyfrowania
            MOV DH, [shift]     ;Przenies do DH wartosc przesuniecia
            ADD DL, DH          ;Dodaj do znaku wartosc przesuniecia
            CMP DL, 122         ;Porownaj do 122
            JG dod              ;Jesli wieksze to przejdz do etykiety dod
            MOV [BX + DI], DL   ;Zaszyfruj znak wartoscia przesuniecia
     JMP shiftP

       dod:
            MOV DH, 122         ;Przenies do DH wartosc 122
            SUB DL, DH          ;Odejmij od sumy przesuniecia i znaku wartosc 122
            MOV DL, 97          ;Przenies wartosc 97 do DL
            ADD DL, DH          ;Dodaj do 97 wartosc obliczonego przesuniecia
            MOV [BX + DI], DL   ;Zaszyfruj znak wartosci? przesuniecia           
     JMP shiftP
            
dodEnd:
      JMP reslt
;--------------------------------------------------------------------------------------------