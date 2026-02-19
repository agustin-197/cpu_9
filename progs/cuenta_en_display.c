// Programa de prueba para el último punto de la actividad 9
#include <stdint.h>
#include <stdbool.h>

// Módulo interfaz de salida en 0x80000000 cuyos 8 bit menos
// significativos se encuentran conectados a un display de 7 segmentos
// (MSb) p,g,f,e,d,c,b,a (LSb)
#define SALIDA ((volatile uint32_t *)0x80000000U)

// Depende de la implementación del CPU!
// Para -O1 serían instrucciones addi sw lw bgeu addi jalr
#define N_CICLOS_FUERA_DE_LAZO (4U + 6U + 5U + 4U + 4U + 5U)
// Para -O1 serían instrucciones lw addi sw lw bltu
#define N_CICLOS_LAZO (5U + 4U + 6U + 5U + 4U)

#define N_LAZOS(nciclos) (((nciclos) < N_CICLOS_FUERA_DE_LAZO) ? 0U : (((nciclos) - N_CICLOS_FUERA_DE_LAZO + (N_CICLOS_LAZO / 2U)) / N_CICLOS_LAZO))

/**
 * @brief Espera n pasadas por un lazo, aproximadamente (6 + 5 * nLazos) instrucciones
 *
 * @param nLazos
 */
void espera(unsigned nLazos)
{
    for (volatile unsigned i=0; i<nLazos ; ++i);
}

int main(void)
{
    static const uint8_t fuente[16] = {
        [0] = 0b00111111,
        [1] = 0b00000110,
        [2] = 0b01011011,
        [3] = 0b01001111,
        [4] = 0b01100110,
        [5] = 0b01101101,
        [6] = 0b01111101,
        [7] = 0b00000111,
        [8] = 0b01111111,
        [9] = 0b01101111,
        [0xA] = 0b01110111,
        [0xb] = 0b01111100,
        [0xC] = 0b00111001,
        [0xd] = 0b01011110,
        [0xE] = 0b01111001,
        [0xF] = 0b01110001
    };
    uint8_t contador = 0;
    const uint8_t limite = 15;
    for(;;)
    {
        const bool fin_cuenta = contador >= limite;

        *SALIDA = fuente[contador & 0xFU] | ((uint8_t)fin_cuenta << 7U);

        if (fin_cuenta) {
            contador = 0;
        } else {
            contador = contador + 1;
        }
        espera(N_LAZOS(12000000U / 2U));
    }
}