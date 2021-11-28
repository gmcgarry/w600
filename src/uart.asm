	.equ	APBCLK,		40000000
	.equ	BAUD,		115200

	.equ	RX_PIN,		5
	.equ	TX_PIN,		4

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

	.equ	UART0_BASE,	APB_BASE + 0x0800
	.equ	LINE_CTRL,	0x00
	.equ	FLOW_CTRL,	0x04
	.equ	DMA_CTRL,	0x08
	.equ	FIFO_CTRL,	0x0C
	.equ	BAUD_RATE_CTRL,	0x10
	.equ	INT_MASK,	0x14
	.equ	INT_SRC,	0x18
	.equ	FIFO_STATUS,	0x1C
	.equ	TX_WIN,		0x20
	.equ	RX_WIN,		0x30

	.equ	ULCON_WL5,		0x00
	.equ	ULCON_WL6,		0x01
	.equ	ULCON_WL7,		0x02
	.equ	ULCON_WL8,		0x03
	.equ	ULCON_STOP_2,		0x04  ; 2 stop bit
	.equ	ULCON_PMD_EN,		0x08  ; no parity
	.equ	ULCON_PMD_ODD,		0x18  ; odd parity	
	.equ	ULCON_PMD_EVEN,		0x08  ; even parity
	.equ	ULCON_TX_EN,		0x40
	.equ	ULCON_RX_EN,		0x80

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

	ldr	r2, gpio_base

	; enable GPIO function connected to PA4, PA5
	mov	r1, #((1<<RX_PIN)|(1<<TX_PIN))
	ldr	r3, [r2, #GPIO_AFSEL]
	orr	r3, r1
	str	r3, [r2, #GPIO_AFSEL]
	mvn	r1, r1
	ldr	r3, [r2, #GPIO_AFS0]
	and	r3, r1
	str	r3, [r2, #GPIO_AFS0]
	ldr	r3, [r2, #GPIO_AFS1]
	and	r3, r1
	str	r3, [r2, #GPIO_AFS1]

	; enable push-pull on rx pin (0=enable pull, 1=disable pull)
	mov	r1, #~(1<<RX_PIN)
	ldr	r3, [r2, #GPIO_REN]	
	and	r3, r1
	str	r3, [r2, #GPIO_REN]

	ldr 	r2, uart_base

	ldr	r3, baud_register
	str	r3, [r2, #BAUD_RATE_CTRL]

	mov	r3, #(ULCON_WL8 | ULCON_TX_EN | ULCON_RX_EN)
	str	r3, [r2, #LINE_CTRL]

	mov	r3, #0
	str	r3, [r2, #FLOW_CTRL]	; disable flow control
	str	r3, [r2, #DMA_CTRL]	; disable dma
	str	r3, [r2, #FIFO_CTRL]	; one-byte tx

	mov	r3, #0xFF
	str	r3, [r2, #INT_MASK]	; disable interrupts

loop:

recvchar:
	mov	r1, #0xFC0
1:
	ldr	r3, [r2, #FIFO_STATUS]	
	and	r3, r1
	beq	1b

	ldr	r0, [r2, #RX_WIN]

sendchar:
	mov	r3, #0x3
	str	r3, [r2, #INT_MASK]

	mov	r1, #0x3F
1:
	ldr	r3, [r2, #FIFO_STATUS]
	and	r3, r1
	bne	1b

	str	r0, [r2, #TX_WIN]

	mov	r3, #0
	str	r3, [r2, #INT_MASK]

	b	loop

	.align	3
gpio_base:
	.word	GPIOA_BASE
uart_base:
	.word	UART0_BASE
	; baud register (115200 : 21, 9600 : 260)
baud_register:
	.word	(APBCLK / (16 * BAUD) - 1) | (((APBCLK % (BAUD * 16)) * 16 / (BAUD * 16)) << 16)

	.pool
