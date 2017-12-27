org 100h

; etykieta start odnosi siê do pokazywania menu, tutaj wracaja wszystkie procedury po zakoñczeniu dzia³ania
start:
	; wyœwietl MENU
	mov	ah, 9
	mov	dx, menu0
	int	21h
	; wczytaj wybór w MENU
	mov	ah, 1
	int	21h
	; wrzuæ punkt powrotny dla wyboru MENU
	push	start
	cmp	al, 27	; [ESCAPE] wyjdŸ z programu
	je	koniec
	cmp	al, 49	; [1] wczytaj tekst
	je	readword
	cmp	al, 50	; [2] wykonaj przesuniêcie
	je	przesun
	cmp	al, 51	; [3] wypisz aktualnie przechowywany tekst
	je	writword
	pop	ax	; jeœli wybór ¿aden z podanych to zdejmij adres powrotu
	jmp	start	; wywo³aj menu jeszcze raz
koniec:	; koñczy program
mov	ax, 4C00h
int	21h
; podstawa wpisywanej wartoœci przesuniêcia
podst	dw	10
; do zapamiêtania ile trzeba przesun¹æ
przes	dw	0
; ró¿ne komunikaty
msg0	db	13,"Podaj liczbe: $"
msg1	db	10,13,"Podaj tekst: $"
msg2	db	10,13,"Aktualny wynik: $"
cmsg0a	db	8,32,8,36
cmsg0b	db	32,32,8,8,36
emsg0	db	"Nie mozna wyswietlic wyniku operacji: Wynik nie miesci sie na 16 bitach!$"
; bufor do zapamiêtania danych
slowo	db	255
	db	0
	TIMES 256 db '$'
; znak entera
ent1	db	10,13,'$'
; wypisywane menu
menu0	db	"1) Wpisz slowo",10,13,"2) Przesun",10,13,"3) Wypisz wynik",10,13,"ESC) Wyj˜cie",10,13,36

;wczytywanie bufora znaków
readword:
	; komunikat
	mov	dx, msg1
	push	dx
	call	wypiszs
	; wczytaj tekst od u¿ytkownika
	mov	ah, 10
	mov	dx, slowo
	int	21h
	; zamieñ du¿e litery na ma³e
	call tolower
ret

; wypisz aktualny tekst w buforze
writword:
	; poka¿ co jest wypisywane
	mov	dx, msg2
	push	dx
	call	wypiszs
	; wypisz aktualny tekst w buforze
	mov	dx, slowo
	add	dx, 2	; pierwsze 2 bajty s¹ dla ah = 10
	push	dx
	call	wypiszs
	call	wypisze
ret

; wypisuje enter
wypisze:
	mov	dx, ent1
	push	dx
	call	wypiszs
ret

; zamienia du¿e litery na ma³e
tolower:
	mov	bx, slowo	; adres s³owa
	add	bx, 1
	mov	si, 0	; do iteracji po kolejnych literach
	tolower0:
		inc	si	; kolejna litera
		mov	al, [bx + si]	; wybierz kolejny bajt
		cmp	al, 36	; jeœli $ to zakoñcz procedure
		je	tolowerk
		; sprawdŸ warunki na du¿¹ literê, jeœli nie to przejdŸ do nastêpnego znaku
		cmp	al, 65
		jb	tolower0
		cmp	al, 90
		ja	tolower0
		; konwersja na ma³¹ literê
		add	al, 32
		mov	[bx + si], al
		jmp	tolower0	; przejdŸ do nastêpnej litery
	tolowerk:
ret

; wykonaj szyfrowanie
przesun:
	call	readnum	; wczytaj wartoœæ przesuniêcia, zapis liczby do kodowania ZM
	mov	bx, slowo
	add	bx, 1
	mov	si, 0
	przesun0:
		inc	si
		mov	al, [bx + si]	; wybierz kolejn¹ literê
		cmp	al, 36
		je	przesunk
		cmp	al, 97
		jb	przesun0
		cmp	al, 122
		ja	przesun0
		; wykonaj przesuniêcie
		mov	ah, 0
		sub	al, 97
		mov	dx, [przes]
		add	ax, dx
		cmp	ax, 26
		jb	przesun1
		sub	ax, 26
		przesun1:
		add	al, 97
		mov	[bx + si], al	; zapisz przesuniêcie
		jmp	przesun0
	przesunk:
ret

; wczytaj wartoœæ przesuniêcia
readnum:
	call	wczytaj	; wczytaj liczbê
	pop	dx	; pobierz liczbê
	mov	ax, dx
	readnum0:	; jeœli ujemna to dodawaj tak d³ugo 26, a¿ bêdzie dodatnia
		shl	ax, 1
		jnc	readnum1
		push	dx
		mov	ax, 26
		push	ax
		call	opadd
		pop	dx
	jmp	readnum0
	readnum1:	; jeœli dodatnia to odejmuj 26 tak d³ugo, a¿ bêdzie z zakresu [0, 25]
		cmp	dx, 26
		jb	readnumk
		sub	dx, 26
	jmp	readnum1
	readnumk:
	mov	[przes], dx	; zapamiêtaj wczytan¹ wartoœæ
ret

; wczytuje liczbe (kod z Zajêcia 8)
wczytaj:
	mov	si, sp
	mov	ax, [si]
	sub	sp, 2
	mov	di, sp
	mov	[di], ax

	xor	ax, ax
	push	ax

	xor	bx, bx
	mov	cx, [podst]

	wczytaj0:
		pop	ax
		push	ax
		push	bx

		shl	ax, 15
		or	bx, ax
		push	bx

		mov	dx, msg0
		push	dx
		call	wypiszs

		call	wypiszl

		mov	dx, cmsg0b
		push	dx
		call	wypiszs

		pop	bx

		mov	ah, 1
		int	21h

		xor	dx, dx
		mov	dl, al
		sub	dl, 48
	cmp	dx, 253
	je	wczytajm
	cmp	dx, 216
	je	wczytaj1
	cmp	dx, 221
	je	wczytajk
	mov	cx, [podst]
	cmp	dx, cx
	jae	wczytaji
		push	bx
		push	dx
		mov	ax, bx
		xor	dx, dx
		mul	cx
		pop	dx
		mov	bx, ax
		add	bx, dx
		mov	dx, bx
		call	miesci
		jc	wczytajp
		pop	dx
		jmp	wczytaj0
	wczytajp:
		pop	bx
		jmp	wczytaj0
	wczytaj1:
		mov	cx, [podst]
		mov	ax, bx
		xor	dx, dx
		div	cx
		mov	bx, ax
	jmp	wczytaj0
	wczytaji:
		push	bx
		mov	dx, cmsg0a
		push	dx
		call	wypiszs
		pop	bx
	jmp	wczytaj0
	wczytajm:
		pop	ax
		not	ax
		and	ax, 1
		push	ax
	jmp	wczytaj0
	wczytajk:
		pop	ax

		mov	di, sp
		add	di, 2

		shl	ax, 15
		or	bx, ax
		mov	[di], bx
ret

; dodawanie dwóch liczb (z Zajêcia 9)
opadd:
	pop	dx
	pop	bx
	pop	ax
	push	dx
	call	znakipor
	pop	cx
	mov	dx, ax

	cmp	cx, 0
	je	opadd0
	cmp	cx, 3
	je	opadd0
	jmp	opadd12

	opadd0:
	push	cx
	add	dx, bx
	jnc	opaddk
	jmp	opadde

	opadd12:
	xor	ax, ax
	cmp	dx, bx
	ja	opadd12b
	mov	ax, dx
	mov	dx, bx
	mov	bx, ax
	mov	ax, 1
	opadd12b:
	shl	ax, 2
	or	cx, ax
	push	cx
	sub	dx, bx
	jmp	opaddk

	opadde:
	mov	dx, emsg0
	push	dx
	call wypiszs
	jmp koniec

	opaddk:
	call	miesci
	jc	opadde
	mov	bx, 172
	call	znakpisz
	pop	ax
	push	dx
	push	ax
ret

; usuwanie znaku w liczbie (z Zajêcia 9)
usunznak:
	shl	ax, 1
	shr	ax, 1
ret

; czy nie dosz³o do przepe³nienia ? (z Zajêcia 9)
miesci:
	push	dx
	mov	ax, 0
	jc	miescik
	shl	dx, 1
	jc	miescik
	miescik:
	pop	dx
ret

; porównanie znaków liczb (z Zajêcia 9)
znakipor:
	push	ax
	push	bx
	shr	ax, 15
	shl	ax, 1
	shr	bx, 15
	mov	cx, 0
	or	cx, ax
	or	cx, bx
	pop	bx
	pop	ax
	pop	dx
	push	cx
	push	dx
	shl	ax, 1
	shr	ax, 1
	shl	bx, 1
	shr	bx, 1
ret

; ustal znak na podstawie maski wyniku operacji (z Zajêcia 9)
znakpisz:
	pop	ax
	pop	cx
	push	ax
	shr	bx, cl
	and	bx, 1
	shl	bx, 15
	or	dx, bx
ret

; wypisywanie liczby (z Zajêcia 8)
wypiszl:
	pop	bx
	pop	ax
	push	bx

	mov	dx, ax
	shr dx, 15

	cmp	dx, 0
	je	wypiszlz

	cmp	ax, 32768
	je	wypiszlz
	push	ax
	mov	ah, 2
	mov	dl, '-'
	int	21h
	pop	ax

	wypiszlz:
	call	usunznak
	mov	cx, 0
	mov	bx, [podst]

	cyfry0:
		xor	dx, dx
		div	bx
		push	dx
		inc	cx
	cmp	al, 0
	ja	cyfry0

	xor	dx, dx
	mov	ah, 2
	cyfry1:
		pop	dx
		add	dl, 48
		int	21h
	loop cyfry1
ret

; wypisywanie ciagu znaków, odpowiednik ah = 9
wypiszs:
	pop	ax
	pop	bx
	push	ax

	mov	cx, 0
	wypiszs0:
	mov	ah, 2
		mov	si, cx
		mov	dl, [bx + si]
		cmp	dl, 36
		je	wypiszsk
		int	21h
		inc cx
		jmp	wypiszs0
	wypiszsk:
ret