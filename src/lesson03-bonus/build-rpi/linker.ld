SECTIONS
{
    . = 0x0;
 .text.boot : { *(.text.boot) }
 .text : { *(.text) }
 . = ALIGN(0x8);
 bss_begin = .;
 .bss : { *(.bss*) }
 bss_end = .;
 .rodata : { *(.rodata) }
 .data : { *(.data) }
}
