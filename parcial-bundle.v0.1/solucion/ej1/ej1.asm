extern free
extern malloc
extern printf
extern strlen

section .rodata
porciento_ese: db "%s", 0

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; El tipo de los `texto_cualquiera_t` que son cadenas de caracteres clásicas.
TEXTO_LITERAL       EQU 0
; El tipo de los `texto_cualquiera_t` que son concatenaciones de textos.
TEXTO_CONCATENACION EQU 1

; Un texto que puede estar compuesto de múltiples partes. Dependiendo del campo
; `tipo` debe ser interpretado como un `texto_literal_t` o un
; `texto_concatenacion_t`.
;
; Campos:
;   - tipo: El tipo de `texto_cualquiera_t` en cuestión (literal o
;           concatenación).
;   - usos: Cantidad de instancias de `texto_cualquiera_t` que están usando a
;           este texto.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       uint64_t unused0; // Reservamos espacio
;       uint64_t unused1; // Reservamos espacio
;   } texto_cualquiera_t;
;   ```
TEXTO_CUALQUIERA_OFFSET_TIPO EQU 0
TEXTO_CUALQUIERA_OFFSET_USOS EQU 4
TEXTO_CUALQUIERA_SIZE        EQU 24

; Un texto que tiene una única parte la cual es una cadena de caracteres
; clásica.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_LITERAL`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - tamanio:   El tamaño del texto.
;   - contenido: El texto en cuestión como un array de caracteres.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       uint64_t tamanio;
;       const char* contenido;
;   } texto_literal_t;
;   ```
TEXTO_LITERAL_OFFSET_TIPO      EQU 0
TEXTO_LITERAL_OFFSET_USOS      EQU 4
TEXTO_LITERAL_OFFSET_TAMANIO   EQU 8
TEXTO_LITERAL_OFFSET_CONTENIDO EQU 16
TEXTO_LITERAL_SIZE             EQU 24

; Un texto que es el resultado de concatenar otros dos `texto_cualquiera_t`.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_CONCATENACION`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - izquierda: El tamaño del texto.
;   - derecha:   El texto en cuestión como un array de caracteres.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       texto_cualquiera_t* izquierda;
;       texto_cualquiera_t* derecha;
;   } texto_concatenacion_t;
;   ```
TEXTO_CONCATENACION_OFFSET_TIPO      EQU 0
TEXTO_CONCATENACION_OFFSET_USOS      EQU 4
TEXTO_CONCATENACION_OFFSET_IZQUIERDA EQU 8
TEXTO_CONCATENACION_OFFSET_DERECHA   EQU 16
TEXTO_CONCATENACION_SIZE             EQU 24

; Muestra un `texto_cualquiera_t` en la pantalla.
;
; Parámetros:
;   - texto: El texto a imprimir.
global texto_imprimir
texto_imprimir:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; Este texto: ¿Literal o concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	je .literal
.concatenacion:
	; texto_imprimir(texto->izquierda)
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_imprimir

	; texto_imprimir(texto->derecha)
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_imprimir

	; Terminamos
	jmp .fin

.literal:
	; printf("%s", texto->contenido)
	mov rsi, [rdi + TEXTO_LITERAL_OFFSET_CONTENIDO]
	mov rdi, porciento_ese
	mov al, 0
	call printf

.fin:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Libera un `texto_cualquiera_t` pasado por parámetro. Esto hace que toda la
; memoria usada por ese texto (y las partes que lo componen) sean devueltas al
; sistema operativo.
;
; Si una cadena está siendo usada por otra entonces ésta no se puede liberar.
; `texto_liberar` notifica al usuario de esto devolviendo `false`. Es decir:
; `texto_liberar` devuelve un booleando que representa si la acción pudo
; llevarse a cabo o no.
;
; Parámetros:
;   - texto: El texto a liberar.
global texto_liberar
texto_liberar:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; ¿Nos usa alguien?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS], 0
	; Si la rta es sí no podemos liberar memoria aún
	jne .fin_sin_liberar

	; Este texto: ¿Es concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	; Si no es concatenación podemos liberarlo directamente
	je .fin
.concatenacion:
	; texto->izquierda->usos--
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->izquierda)
	call texto_liberar

	; texto->derecha->usos--
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->derecha)
	call texto_liberar

	; Terminamos
	jmp .fin

.fin:
	; Liberamos el texto que nos pasaron por parámetro
	mov rdi, [rbp - 8]
	call free

.fin_sin_liberar:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_literal
;   - texto_concatenar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Crea un `texto_literal_t` que representa la cadena pasada por parámetro.
;
; Debe calcular la longitud de esa cadena.
;
; El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
;
; Parámetros:
;   - texto: El texto que debería ser representado por el literal a crear.

; texto_literal_t* texto_literal(const char* texto) {
; rdi = texto
global texto_literal
texto_literal:
	; armo stackframe
	push rbp
	mov rbp, rsp
	push r15 ; desalineada
	push r14 ; alineada

	; me guardo rdi en un registro no volatil
	mov r15, rdi ; r15 = texto
	; calculo el length
	;	size_t longitud = strlen(texto);
	mov rdi, r15
	call strlen
	; ahora el resultado de strlen lo tengo que guardar en un registro no volatil r14
	mov r14, rax ; r14 = longitud
	; ahora tengo que reservar memoria para el texto literal
; 	texto_literal_t* literal = malloc(sizeof(texto_literal_t));
	mov rdi, TEXTO_LITERAL_SIZE
	call malloc
; entonces desde rax puedo acceder a la memoria reservada y lleno los campos de la estructura
	; literal->tipo = TEXTO_LITERAL;
	mov qword [rax + TEXTO_LITERAL_OFFSET_TIPO], TEXTO_LITERAL
	; literal->usos = 0;
	mov qword [rax + TEXTO_LITERAL_OFFSET_USOS], 0
	; literal->tamanio = longitud;
	mov qword [rax + TEXTO_LITERAL_OFFSET_TAMANIO], r14
	; literal->contenido = texto;
	mov qword [rax + TEXTO_LITERAL_OFFSET_CONTENIDO], r15
	; y por ultimo tengo que devolver el puntero a la estructura
	; return literal;
	pop r15
	pop r14
	pop rbp
	ret

; Crea un `texto_concatenacion_t` que representa la concatenación de ambos
; parámetros.
;
; Los textos `izquierda` y `derecha` serán usadas por el resultado, por lo que
; sus contadores de usos incrementarán.
;
; Parámetros:
;   - izquierda: El texto que debería ir a la izquierda.
;   - derecha:   El texto que debería ir a la derecha.

;texto_concatenacion_t* texto_concatenar(texto_cualquiera_t* izquierda, texto_cualquiera_t* derecha) {
; rdi = izquierda, rsi = derecha
global texto_concatenar
texto_concatenar:
	; armo stackframe
	push rbp
	mov rbp, rsp
	push r15 ; desalineada
	push r14 ; alineada
	; me voy a guardar los 2 parametros que me vienen en registros no volatiles
	mov r15, rdi ; r15 = izquierda
	mov r14, rsi ; r14 = derecha

	; reservo memoria para el texto concatenacion
; 	texto_concatenacion_t* concatenacion = malloc(sizeof(texto_concatenacion_t));
	mov rdi, TEXTO_CONCATENACION_SIZE
	call malloc

	; lleno los campos de la estructura
	; concatenacion->tipo = TEXTO_CONCATENACION;
	mov qword [rax + TEXTO_CONCATENACION_OFFSET_TIPO], TEXTO_CONCATENACION
	; concatenacion->usos = 0;
	mov qword [rax + TEXTO_CONCATENACION_OFFSET_USOS], 0

	; incremento los usos de los textos que me pasaron por parametro
	; izquierda->usos++;
	inc DWORD [r15 + TEXTO_CUALQUIERA_OFFSET_USOS]
	; derecha->usos++;
	inc DWORD [r14 + TEXTO_CUALQUIERA_OFFSET_USOS]

	; y los guardamos en la concatenacion
	; concatenacion->izquierda = izquierda;
	mov qword [rax + TEXTO_CONCATENACION_OFFSET_IZQUIERDA], r15
	; concatenacion->derecha = derecha;
	mov qword [rax + TEXTO_CONCATENACION_OFFSET_DERECHA], r14

	; y por ultimo tengo que devolver el puntero a la estructura

	pop r15
	pop r14
	pop rbp
	ret

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_tamanio_total
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Calcula el tamaño total de un `texto_cualquiera_t`. Es decir, suma todos los
; campos `tamanio` involucrados en el mismo.
;
; Parámetros:
;   - texto: El texto en cuestión.
; uint64_t texto_tamanio_total(texto_cualquiera_t* texto) {
; rdi = texto
global texto_tamanio_total
texto_tamanio_total:
	; armo stackframe
	push rbp
	mov rbp, rsp

	; pusheo los registros no volatiles que voy a usar
	push r15 ; desalineada
	push r14 ; alineada
	push r13 ; desalineada
	push r12 ; alineada

	; ahora qiuero preguntarme que tipo de texto es
	cmp dword [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	je .literal
	.concatenacion:
		; si no es literal, es concatenacion
		; entonces tengo que sumar los tamanios de los textos que componen la concatenacion	
		
		; quiero hacer la siguiente linea en assembler
		;		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		mov qword r13, rdi ; r13 = texto
		; ahora tengo que sumar los tamanios de los textos que componen la concatenacion
		; uint64_t tamanio_izquierda = texto_tamanio_total(concatenacion->izquierda);
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
		call texto_tamanio_total
		mov r15, rax ; r15 = tamanio_izquierda	
		; uint64_t tamanio_derecha = texto_tamanio_total(concatenacion->derecha);
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_DERECHA]
		call texto_tamanio_total
		mov r14, rax ; r14 = tamanio_derecha
		; ahora tengo que sumar los tamanios
		; return tamanio_izquierda + tamanio_derecha;
		add r15, r14
		mov rax, r15
		jmp .fin
	.literal:
		; si es literal, devuelvo el tamanio
		; return ((texto_literal_t*) texto)->tamanio;
		mov rax, [rdi + TEXTO_LITERAL_OFFSET_TAMANIO]

	.fin:
		; desarmo stackframe
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbp
		ret

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_chequear_tamanio
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Chequea si los tamaños de todos los nodos literales internos al parámetro
; corresponden al tamaño de la cadenas que apuntadan.
;
; Es decir: si los campos `tamanio` están bien calculados.
;
; Parámetros:
;   - texto: El texto verificar.
;bool texto_chequear_tamanio(texto_cualquiera_t* texto) {
; rdi = texto
global texto_chequear_tamanio
texto_chequear_tamanio:
	; armo stackframe
	push rbp
	mov rbp, rsp
	; pusheo los registros no volatiles que voy a usar
	push r15 ; desalineada
	push r14 ; alineada
	push r13 ; desalineada
	push r12 ; alineada
	; primero voy a armar la misma estructura de if else que en el ejercicio anterior
	; quiero preguntarme que tipo de texto es
	cmp dword [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	je .literal
	.concatenacion:
		; si no es literal, es concatenacion
		; texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		mov qword r13, rdi ; r13=texto
		;		return texto_tamanio_total(concatenacion) == texto_tamanio_total(concatenacion->izquierda) + texto_tamanio_total(concatenacion->derecha) && texto_chequear_tamanio(concatenacion->izquierda) && texto_chequear_tamanio(concatenacion->derecha);

		; primero chequeo que el tamanio de la concatenacion sea igual a la suma de los tamanios de los textos que la componen
		; uint64_t tamanio_concatenacion = texto_tamanio_total(concatenacion);
		mov rdi, r13
		call texto_tamanio_total
		mov r15, rax ; r15 = tamanio_concatenacion
		; uint64_t tamanio_izquierda = texto_tamanio_total(concatenacion->izquierda);
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
		call texto_tamanio_total
		mov r14, rax ; r14 = tamanio_izquierda
		; uint64_t tamanio_derecha = texto_tamanio_total(concatenacion->derecha);
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_DERECHA]
		call texto_tamanio_total
		; ahora tengo que sumar los tamanios
		; return tamanio_izquierda + tamanio_derecha;
		add r14, rax ; r14 = tamanio_izquierda + tamanio_derecha
		; ahora me falta && texto_chequear_tamanio(concatenacion->izquierda) && texto_chequear_tamanio(concatenacion->derecha);
		; entonces tengo que hacer un and
		cmp r15, r14
		je .chequear_izquierda
		jmp .finFalse
	.chequear_izquierda:
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
		call texto_chequear_tamanio
		cmp rax, FALSE
		je .finFalse
		mov rdi, [r13 + TEXTO_CONCATENACION_OFFSET_DERECHA]
		call texto_chequear_tamanio
		cmp rax, FALSE
		jne .finTrue
		jmp .finFalse
	.literal:
		;		// para chequear que un literal tiene el tamaño bien calculado, simplemente comparo el tamaño del contenido con el tamaño del literal
;		return literal->tamanio == strlen(literal->contenido);
		; primero tengo que calcular el tamaño del contenido
		; size_t longitud = strlen(((texto_literal_t*) texto)->contenido);
		mov r15, rdi ; pongo esta linea por legibilidad
		mov rdi, [r15 + TEXTO_LITERAL_OFFSET_CONTENIDO]
		call strlen
		; ahora tengo que comparar el tamaño del contenido con el tamaño del literal
		; return literal->tamanio == longitud;
		cmp qword [r15 + TEXTO_LITERAL_OFFSET_TAMANIO], rax
		je .finTrue
		jmp .finFalse

	.finTrue:
		mov rax, TRUE
		jmp .fin
	
	.finFalse:
		mov rax, FALSE
		jmp .fin

	.fin:
		; desarmo stackframe
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbp
		ret




	ret
