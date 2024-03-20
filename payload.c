#include <stdint.h>
#include <stddef.h>

#include "font.c"

volatile uint32_t * const VI_ORIGIN = 0xA4400004;

extern void __entry_start;
extern void __text_end;


//extern void		osInvalDCache(void *, s32);
extern void		osInvalICache(void *, int32_t);
extern void		osWritebackDCache(void *, int32_t);
//extern void		osWritebackDCacheAll(void);

extern void _binary_save_bin_start;
extern void _binary_save_bin_end;
extern void _binary_save_bin_size;

void * memset(void * dest, int c, size_t n) {
    uint8_t * const ptr = dest;
    for (size_t i = 0; i < n; i++) {
        ptr[i] = c;
    }
    
    return dest;
}

/*__attribute__(( section(".low") ))*/ void * memcpy(void * dest, void * src, size_t n) {
    uint8_t * const real_dest = dest;
    const uint8_t * const real_src = src;
    
    for (size_t i = 0; i < n; i++) {
        real_dest[i] = real_src[i];
    }
    
    return dest;
}

/*__attribute__(( section(".low") ))*/ static void disable_interrupts() {
    __asm__ volatile(
        "mfc0 $t0, $12\n"
        "andi $t0, $t0, 0xFFFE\n"
        "mtc0 $t0, $12\n"
    );
}

static void print_digit(uint16_t * const framebuffer, uint8_t digit, uint8_t x, uint8_t y) {
    const uint32_t start = (x * 12) + (y * 320 * 20);
    
    for (uint32_t y_off = 0; y_off < 16; y_off++) {
        const uint32_t row_start = start + y_off * 320;
        
        for (uint32_t x_off = 0; x_off < 8; x_off++) {
            const uint32_t pos = row_start + x_off;
            
            if (font[digit][y_off][x_off]) {
                framebuffer[pos] = 0xFFFF;
            }
        }
    }
}

static void print_u32(uint16_t * const framebuffer, uint32_t num, uint8_t x, uint8_t y) {
    for (uint8_t i = 0; i < 8; i++) {
        print_digit(framebuffer, ((num >> ((7 - i) * 4)) & 0x0F), x + i, y);
    }
}

void delay(int cycles) {
    for(int i = 0; i < cycles; i++) {
        __asm__ volatile("");
    }
}

const uint32_t check = 0xD638DD4B;

uint32_t get_check(const uint32_t * const ptr, size_t len) {
    const size_t words = len / 4;
    
    uint32_t rv = 0;
    
    for (size_t i = 0; i < words; i++) {
        rv += ptr[i];
    }
    
    return rv;
}

uint32_t (* const save_file_func)(void) = 0x807C0000;

const uint32_t * const v2_orig = 0x807C057C;
const uint32_t * const v2_ready = 0x807C067C;
const uint32_t * const v2_final = 0x807C077C;

void main(void) {    
    uint16_t * const framebuffer = 0xA0300000;
    const size_t framebuffer_len = 320 * 240 * sizeof(framebuffer[0]);
    
    memset(framebuffer, 0, framebuffer_len);
    
    *VI_ORIGIN = framebuffer;
    
    const uint32_t pre_checksum = get_check(&_binary_save_bin_start, &_binary_save_bin_size);
    
    print_u32(framebuffer, check, 2, 1);
    print_u32(framebuffer, pre_checksum, 2, 2);
    
    if (pre_checksum == check) {
        memcpy(save_file_func, &_binary_save_bin_start, &_binary_save_bin_size);
        
        osWritebackDCache(save_file_func, &_binary_save_bin_size);
        osInvalICache(save_file_func, &_binary_save_bin_size);
        
        const uint32_t post_checksum = get_check(save_file_func, &_binary_save_bin_size);
        
        print_u32(framebuffer, post_checksum, 2, 3);
        
        if (post_checksum == check) {
            const int32_t rv = save_file_func();
            
            print_u32(framebuffer, rv, 2, 4);
            
            print_u32(framebuffer, v2_orig[5], 2, 6);
            print_u32(framebuffer, v2_orig[6], 2, 7);
            print_u32(framebuffer, v2_orig[63], 2, 8);
            
            print_u32(framebuffer, v2_ready[5], 11, 6);
            print_u32(framebuffer, v2_ready[6], 11, 7);
            print_u32(framebuffer, v2_ready[63], 11, 8);
            
            print_u32(framebuffer, v2_final[5], 2, 9);
            print_u32(framebuffer, v2_final[6], 2, 10);
            print_u32(framebuffer, v2_final[63], 2, 11);
        } else {
            print_u32(framebuffer, 0xBAAD0002, 2, 4);
        }
    } else {
        print_u32(framebuffer, 0xBAAD0001, 2, 3);
    }
    
    while (1) {};
}

__attribute__(( section (".low") )) void startup(void) {
    disable_interrupts();
    memcpy(&__entry_start, 0xA0300000, &__text_end - &__entry_start);
    osWritebackDCache(&__entry_start, &__text_end - &__entry_start);
    osInvalICache(&__entry_start, &__text_end - &__entry_start);
    main();
}

__attribute__(( section(".entry") )) void __payload_entry(void) {
    __asm__ volatile (
        ".set noreorder\n"
        "b startup\n"
        "nop\n"
        ".word __payload_entry + 0x20001000\n"
        ".set reorder\n"
    );
}