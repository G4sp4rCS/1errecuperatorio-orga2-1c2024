#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Muestra un `texto_cualquiera_t` en la pantalla.
 *
 * Parámetros:
 *   - texto: El texto a imprimir.
 */
void texto_imprimir(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		printf("%s", literal->contenido);
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		texto_imprimir(concatenacion->izquierda);
		texto_imprimir(concatenacion->derecha);
	}
}

/**
 * Libera un `texto_cualquiera_t` pasado por parámetro. Esto hace que toda la
 * memoria usada por ese texto (y las partes que lo componen) sean devueltas al
 * sistema operativo.
 *
 * Si una cadena está siendo usada por otra entonces ésta no se puede liberar.
 * `texto_liberar` notifica al usuario de esto devolviendo `false`. Es decir:
 * `texto_liberar` devuelve un booleano que representa si la acción pudo
 * llevarse a cabo o no.
 *
 * Parámetros:
 *   - texto: El texto a liberar.
 */
bool texto_liberar(texto_cualquiera_t* texto) {
	if (texto->usos != 0) {
		// Alguien está usando a este texto, aún no lo podemos liberar
		return false;
	}

	if (texto->tipo == TEXTO_CONCATENACION) {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// Vamos a dejar de usar la cadena de la izquierda
		concatenacion->izquierda->usos--;
		texto_liberar(concatenacion->izquierda);

		// Y vamos a dejar de usar la cadena de la derecha
		concatenacion->derecha->usos--;
		texto_liberar(concatenacion->derecha);
	}
	free(texto);
	return true;
}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_literal
 *   - texto_concatenar
 */
bool EJERCICIO_1A_HECHO = false;

/**
 * Crea un `texto_literal_t` que representa la cadena pasada por parámetro.
 *
 * Debe calcular la longitud de esa cadena.
 *
 * El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
 *
 * Parámetros:
 *   - texto: El texto que debería ser representado por el literal a crear.
 */
texto_literal_t* texto_literal(const char* texto) {
	// primero calculamos la longitud de la cadena
	size_t longitud = strlen(texto);
	// luego reservamos memoria para el texto literal
	texto_literal_t* literal = malloc(sizeof(texto_literal_t));
// no voy a chequear la nulidad de literal porque no se pide en el enunciado
// y ahora llenamos los campos del literal
	literal->tipo = TEXTO_LITERAL;
	literal->usos = 0;
	literal->tamanio = longitud;
	// y en contenido le paso el puntero que me dan por parametro
	literal->contenido = texto;
	return literal;
}

/**
 * Crea un `texto_concatenacion_t` que representa la concatenación de ambos
 * parámetros.
 *
 * Los textos `izquierda` y `derecha` serán usadas por el resultado, por lo
 * que sus contadores de usos incrementarán.
 *
 * El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
 *
 * Parámetros:
 *   - izquierda: El texto que debería ir a la izquierda.
 *   - derecha:   El texto que debería ir a la derecha.
 */
texto_concatenacion_t* texto_concatenar(texto_cualquiera_t* izquierda, texto_cualquiera_t* derecha) {
// primero reservamos memoria para el texto concatenacion
	texto_concatenacion_t* concatenacion = malloc(sizeof(texto_concatenacion_t));
	// no voy a chequear la nulidad de concatenacion porque no se pide en el enunciado
	// ahora llenamos los campos de la concatenacion
	concatenacion->tipo = TEXTO_CONCATENACION;
	concatenacion->usos = 0;
	// incrementamos los usos de los textos que vamos a concatenar
	izquierda->usos++;
	derecha->usos++;
	// y los guardamos en la concatenacion
	concatenacion->izquierda = izquierda;
	concatenacion->derecha = derecha;
	// calculamos el tamaño de la concatenacion
	return concatenacion;

}

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_tamanio_total
 */
bool EJERCICIO_1B_HECHO = false;

/**
 * Calcula el tamaño total de un `texto_cualquiera_t`. Es decir, suma todos los
 * campos `tamanio` involucrados en el mismo.
 *
 * Parámetros:
 *   - texto: El texto en cuestión.
 */
uint64_t texto_tamanio_total(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		// ¿Cómo calculo el tamaño del texto que representa un literal?
		// si el tipo es TEXTO_LITERAL, entonces el tamaño es el tamaño del contenido
		// y para calcular el tamaño del texto que representa un literal, simplemente devuelvo el tamaño del contenido
		return literal->tamanio;
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// ¿Cómo calculo el tamaño del texto que representa una concatenación?
		// para calcular el tamaño del texto que representa una concatenación, simplemente sumo los tamaños de los textos que se concatenan y devuelvo la suma
		return texto_tamanio_total(concatenacion->izquierda) + texto_tamanio_total(concatenacion->derecha);}
}

/**
 * Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - texto_chequear_tamanio
 */
bool EJERCICIO_1C_HECHO = true;

/**
 * Chequea si los tamaños de todos los nodos literales internos al parámetro
 * corresponden al tamaño de la cadenas que apuntadan.
 *
 * Es decir: si los campos `tamanio` están bien calculados.
 *
 * Parámetros:
 *   - texto: El texto verificar.
 */
bool texto_chequear_tamanio(texto_cualquiera_t* texto) {
	if (texto->tipo == TEXTO_LITERAL) {
		texto_literal_t* literal = (texto_literal_t*) texto;
		// ¿Cómo chequeo si un literal tiene el tamaño bien calculado?
		// para chequear que un literal tiene el tamaño bien calculado, simplemente comparo el tamaño del contenido con el tamaño del literal
		return literal->tamanio == strlen(literal->contenido);
	} else {
		texto_concatenacion_t* concatenacion = (texto_concatenacion_t*) texto;
		// ¿Cómo chequeo si una concatenación tiene el tamaño de sus literales
		// Yo se que la concatenacion tiene el tamaño de sus literales si el tamaño de la concatenacion es igual a la suma de los tamaños de los literales que se concatenan y si el tamaño de la concatenacion es igual a la suma de los tamaños de los literales que se concatenan, entonces chequeo si los literales tienen el tamaño bien calculado
		return texto_tamanio_total(concatenacion) == texto_tamanio_total(concatenacion->izquierda) + texto_tamanio_total(concatenacion->derecha) && texto_chequear_tamanio(concatenacion->izquierda) && texto_chequear_tamanio(concatenacion->derecha);
	
	}
}

