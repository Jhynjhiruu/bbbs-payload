MEMORY {
    KERN : ORIGIN = 0xA0000000, LENGTH = 0x00400000
    CACHED : ORIGIN = 0x80000000, LENGTH = 0x00400000
}

SECTIONS {
    text_offset = 0x0;

    .text 0x80000000 + text_offset : {
        __entry_start = .;
        KEEP(*(.entry));
        KEEP(*(.low));
        . = ALIGN(8);
        __entry_end = .;
        
        __text_start = .;
        *(.text*);

        . = ALIGN(8);
        *(.data*);

        . = ALIGN(8);
        *(.rodata*);

        . = 0x00006060 - text_offset;

        LONG(0x08000000 | ((__payload_entry & 0x0FFFFFFF) >> 2));
        LONG(0x00000000);

        . = __entry_start + 0xDEFFC;
        LONG(0x00000000);

        . = ALIGN(8);
        __text_end = .;
    } > CACHED = 0x00

    /DISCARD/ : {
        *(.MIPS.*)
        *(.comment)
        *(.mdebug.*)
        *(.pdr)
        *(.reginfo)

        /*
         * We may need the global offset table some day.
         * Our target is currently set with a static relocation-model, so this
         * might not be needed after all.
         */
        *(.got)
    }
}
