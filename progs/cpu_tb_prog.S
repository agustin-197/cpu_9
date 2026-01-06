.data
val_a: .word 5
val_b: .word 4
resultado: .word 0

.section .text.startup
.globl _start

_start:
    lw x1, val_a
    lw x2, val_b
    add x3, x1, x2
    sw x3, resultado, x4
fin:
    j fin
