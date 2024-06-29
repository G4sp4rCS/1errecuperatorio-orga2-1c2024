section .data
; voy a definir una mascara para extender un pixel de 8 bits a 32 bits
; la mascara es 0x000000FF // 00000000000000000000000011111111
mascara1: dd 0x000000FF


section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej2a
ej2a:

	; coloquio{
;		Preparar registros SIMD para las operaciones, pasar scale y offset a 128 bits	
;	Cargar los datos y extensión: cargar los pixeles de 8 bits desde la memoria y extender cada pixel a 32 bits
;	Operación SIMD: hacer la operación scale * px + offset dentro del ciclo
;	Extender con las instrucción SIGNADA para que los pixeles sean de 32 bits con signo
;	
;	
;	
;	
;
	;}



	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = int32_t* dst_depth
	; r/m64 = uint8_t* src_depth
	; r/m32 = int32_t  scale
	; r/m32 = int32_t  offset
	; r/m32 = int      width
	; r/m32 = int      height

	; siguiendo la convención ABI x86-64, los parámetros se pasan en los registros
	; rdi, rsi, rdx, rcx, r8, r9
	; rdi = dst_depth, rsi = src_depth, rdx = scale, rcx = offset, r8 = width, r9 = height
	; tengo que usar las instrucciones de SIMD y los registros XMM de 128 bits para recorrer los pixeles de las imagenes
	; 128/32 = 4 pixeles por registro
	; entonces puedo recorrer las imagenes de a 4 pixeles por vez
	; en este ejercicio me piden que haga la operacion scale * px + offset
	; la cual realiza la conversion de un pixel de 8 bits sin signo a 32 bits con signo
	; y para eso tengo que extender el pixel de 8 bits a 32 bits y luego hacer la multiplicacion y la suma

	; armo stackframe
	push rbp
	mov rbp, rsp

	; quiero pasar los registros a 32 bits para poder hacer operaciones aritmeticas
	; entonces tengo que extender el pixel de 8 bits a 32 bits
	; y luego hago la operacion scale * px + offset
	; para eso uso los registros XMM de 128 bits
	; puedo utilizar la instruccion PMOVZXBD para extender un pixel de 8 bits a 32 bits

	;Tengo que cargar los registros XMM por fuera del ciclo, y la extension de los pixeles tienen que ser dentro del ciclo
	; asigno:


	; habria que extender rdx, rcx para que sean de 128 bits para luego hacer la ecuacion de una manera SIMD-eana
	; de a 4
	; coloquio{
	movd xmm1, edx ; xmm1 = scale
	pshufd xmm1, xmm1, 0 ; xmm1 = scale, scale, scale, scale
	movd xmm2, ecx ; xmm2 = offset
	pshufd xmm2, xmm2, 0 ; xmm2 = offset, offset, offset, offset
	; hago los shuffles para que los registros xmm1 y xmm2 tengan los valores de scale y offset en los 4 elementos
	; pshufd me ayuda a configurar los registros para que la operación aritmetica SIMD se ejecute sobre varios pixeles a la vez. 
	; el argumento 0 significa: "replicá el elemento en la posición más baja en todos los otros elementos del registro"
	; Toma el double word en la posición más baja de xmm1 y lo copia en todas las posiciones de xmm1
	;
	
	}
	; tengo que guardar source y destination en registros xmm tambien
	movdqu xmm0, [rsi] ; acá tengo en rsi la dirección de memoria de src_depth

	; armo un ciclo para recorrer los pixeles de las imagenes
	
	; coloquio: width * height / 4 = cantidad de pixeles que tengo que recorrer
	; coloquio: configuro correctamente el ciclo {
	mov rax, r9 ; rax = height
	mul r8 ; rax = height * width
	mov r10, rax ; r10 = height * width = cantidad total de pixeles
	xor rax, rax ; contador del ciclo
	; }
	.loop:
		; coloquio{
		cmp rax, r10 ; comparo si llegue al final de la imagen
		jge .fin ; si llegue al final de la imagen termino el ciclo
		;}

		;extenderlo a 32 bits con la instruccion PMOVZXBD
		
		; quiero extender el rcx-esimo pixel de src_depth a 32 bits
		; entonces tengo que mover el pixel de 8 bits a xmm0
		PMOVZXBD xmm0, [rsi + rax];xmm0 ; acá tengo el pixel de 8 bits extendido a 32 bits en xmm0
		; ahora tengo el pixel de 8 bits extendido a 32 bits en xmm0
		; ahora tengo que hacer la operacion scale * px + offset

		; ahora hago la multiplicacion y la suma
;		PMULDQ xmm5, xmm0, xmm3 ; xmm5 = scale * px
		;coloquio: {
		PMULLD xmm0, xmm1 ; xmm0 = scale * px
		PADDD xmm0, xmm2 ; xmm0 = scale * px + offset		
		;}
		;PADDD xmm5, xmm5, xmm4 ; xmm5 = scale * px + offset

		



		; ahora hago primero la multiplicacion y despues la suma 
		;PMULDQ xmm5, xmm0, xmm3 ; xmm5 = scale * px
		;PADDD xmm5, xmm5, xmm4 ; xmm5 = scale * px + offset
		; ahora tengo el resultado de la operacion en xmm5
		; ahora tengo que guardar el resultado en dst_depth
		; para eso tengo que mover el pixel de 32 bits a la dirección de memoria de dst_depth
		;movdqu dword [rdi + rcx], xmm5 ; guardo el pixel de 32 bits en la dirección de memoria de dst_depth
		
		;Coloquio {
		movdqu [rdi + rax * 4], xmm0 ; guardo el pixel de 32 bits en la dirección de memoria de dst_depth		
		;}
		
		
		; ahora tengo que avanzar al siguiente pixel
		add rax, 4 ; avanzo al siguiente pixel
		jmp .loop 

	.fin:

	
	pop rbp
	ret

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej2b
ej2b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst ; rdi = dst tamaño de 32 bits
	; r/m64 = rgba_t*  a ; rsi = a, tamaño de 32 bits
	; r/m64 = int32_t* depth_a ; rdx = depth_a tamaño de 32 bits
	; r/m64 = rgba_t*  b ; rcx = b tamaño de 32 bits
	; r/m64 = int32_t* depth_b ; r8 = depth_b 
	; r/m32 = int      width ; r9 = width
	; r/m32 = int      height ; r10 = height
	; /**
; * Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
 ;* profundidad escribe en el destino el pixel de menor profundidad por cada
 ;* píxel de la imagen. En caso de empate se escribe el píxel de `b`.
; la gracia de hacerlo con SIMD es que puedo comparar los pixeles de a 4 por vez
; pensandolo en forma de ecuacion : dst[y,x] = depth_a[y,x] < depth_b[y,x] ? a[y,x] : b[y,x]
; entonces tengo que comparar los pixeles de a y b y ver cual es el menor
; en caso de ser empate tengo que elegir el pixel de b
; con SIMD podemos hacer ambas ramas de la comparacion en paralelo
; entonces puedo cargar los pixeles de a y b en registros xmm y compararlos
; y para ello voy a usar la instruccion PCMPGTD (o alguna de comparacion) que compara los pixeles de a y b y guarda en un registro xmm el resultado de la comparacion
; tengo que usar una mascara que me diga cual de las 2 profundidades es mayor, entonces puedo hacer un compare con eso, y me deja todo con ceros y unos
; y ahí puedo pasar PAND




	ret
