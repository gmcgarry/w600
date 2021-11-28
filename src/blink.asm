	; 40MHz, 4 cycles per loop
	.equ	APBCLK,		40000000
	.equ	DELAY_COUNT,	APBCLK / 4 / 2

	.equ	LED_PIN,	0

	.equ	LOADADDR,	0x08010100
	.equ	RAM,		0x20000000
	.equ	STACK,		RAM + 0x28000

	.equ	PERIPH_BASE,	0x40000000
	.equ	APB_BASE,	PERIPH_BASE + 0x10000

	.equ	GPIOA_BASE,	APB_BASE + 0x0C00
	.equ	GPIO_DATA,	0x00
	.equ	GPIO_EN,	0x04
	.equ	GPIO_DIR,	0x08
	.equ	GPIO_REN,	0x0C
	.equ	GPIO_AFSEL,	0x10
	.equ	GPIO_AFS1,	0x14
	.equ	GPIO_AFS0,	0x18

	.section .text
	.thumb
	
	.org	LOADADDR
vector_table:
	.word	STACK
	.word	reset+1

	.align	3
reset:
	ldr	r1, stackaddr	
	mov	sp, r1
	ldr	r1, startaddr	
	bx	r1
stackaddr:
	.word	STACK
startaddr:
	.word	start+1

	.align	3
start:
	mov 	r1, #(1<<LED_PIN)
	ldr	r2, gpio_base

	; disable function connected to LED_PIN
	ldr	r3, [r2, #GPIO_AFSEL]	
	mvn	r0, r1
	and	r3, r0
	str	r3, [r2, #GPIO_AFSEL]	

	; set pin for output (0=input, 1=output)
	ldr	r3, [r2, #GPIO_DIR]	
	orr	r3, r1
	str	r3, [r2, #GPIO_DIR]	

	; disable push-pull (0=enable pull, 1=disable pull)
	ldr	r3, [r2, #GPIO_REN]	
	orr	r3, r1
	str	r3, [r2, #GPIO_REN]	

	; enable pin
	ldr	r3, [r2, #GPIO_EN]	
	orr	r3, r1
	str	r3, [r2, #GPIO_EN]	

	ldr	r0, counter
loop:
	ldr	r3, [r2, #GPIO_DATA]	
	eor	r3, r1
	str	r3, [r2, #GPIO_DATA]	

	mov	r3, r0		; set counter
delay:
	sub	r3, r3, #1
	cmp	r3, #0
	bgt	delay

	b	loop

	.align	3
gpio_base:
	.word	GPIOA_BASE
counter:
	.word	DELAY_COUNT
