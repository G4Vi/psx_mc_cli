#include <stdint.h>
#include <string.h>
#include "gifenc.h"

#if 0
/* begin tonyhax */
static const uint16_t PALETTE[16] = { 0x0000, 0x021F, 0x7FFF, 0x4210, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 };
static const uint8_t IMDATA[1][16][16] = {{
 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3,
 1, 0, 2, 2, 2, 2, 2, 0, 2, 0, 0, 0, 2, 0, 1, 3,
 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 3,
 1, 0, 0, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 0, 1, 3,
 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 3,
 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 3,
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3,
 1, 0, 2, 2, 2, 0, 2, 2, 2, 0, 2, 0, 0, 0, 1, 3,
 1, 0, 2, 0, 0, 0, 2, 0, 2, 0, 2, 0, 0, 0, 1, 3,
 1, 0, 2, 2, 2, 0, 2, 2, 2, 0, 2, 0, 0, 0, 1, 3,
 1, 0, 0, 0, 2, 0, 2, 0, 0, 0, 2, 0, 0, 0, 1, 3,
 1, 0, 2, 2, 2, 0, 2, 0, 0, 0, 2, 2, 2, 0, 1, 3,
 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3,
 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
}};
#define FRAMECNT 1
/* end tonyhax */
#endif

// moto
static const uint16_t PALETTE[16] = { 0x0000, 0x0010, 0x0200, 0x0210, 0x4000, 0x4010, 0x4200, 0x4210, 0x6318, 0x001F, 0x03E0, 0x03FF, 0x7C00, 0x7C1F, 0x7FE0, 0x7FFF };
static const uint8_t IMDATA[2][16][16] = {
{
 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 0, 15
 ,15, 0, 15, 15, 0, 0, 15, 15, 0, 0, 0, 0, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 0, 15, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 0, 15, 15, 0, 15, 0, 0, 0, 15
 ,15, 0, 15, 15, 0, 0, 15, 15, 0, 15, 0, 0, 15, 15, 0, 15
 ,15, 0, 15, 15, 0, 0, 15, 15, 0, 0, 15, 0, 15, 15, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 0, 15, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 0, 0, 15, 0, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 0, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
},
{
 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 0, 0, 0, 0, 15, 15, 15, 15, 0, 0, 0, 0, 15, 15
 ,15, 0, 15, 15, 0, 0, 0, 0, 0, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 15, 0, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 0, 15, 15, 0, 15, 0, 0, 15, 15, 0, 15
 ,15, 0, 15, 15, 0, 0, 15, 0, 15, 15, 0, 0, 15, 15, 0, 15
 ,15, 0, 15, 15, 0, 15, 0, 0, 15, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 15, 0, 15, 0, 0, 15, 15, 0, 0, 0, 15
 ,15, 0, 0, 0, 15, 0, 15, 15, 0, 15, 0, 0, 15, 15, 0, 15
 ,15, 0, 0, 0, 0, 0, 15, 0, 15, 15, 0, 0, 0, 0, 0, 15
 ,15, 0, 15, 15, 15, 15, 0, 0, 0, 0, 15, 15, 15, 15, 0, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
 ,15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
}};
#define FRAMECNT 2
// end moto

#define scale 5
#define w (16*scale)
#define h (16*scale)

int main(int argc, char **argv) {   
    
    static uint8_t scaled[FRAMECNT][w][h];
    for( int i = 0; i < FRAMECNT; i++) {
        for( int y = 0; y < 16; y++) {
            int scaledy = y*scale;
            for( int x = 0; x < 16; x++) {
                int scaledx = x*scale;
                for(int j = 0; j < scale; j++) {
                    scaled[i][scaledy][scaledx+j] = IMDATA[i][y][x];
                }                
            }
            for(int j = 1; j < scale; j++) {
                memcpy(&scaled[i][scaledy+j], &scaled[i][scaledy], (16*scale));
            }
        }
    }
    


    int red_mask = 0x1F;
    int green_mask = 0x3E0;
    int blue_mask = 0x7C00;
    static uint8_t colors[16][3];
    int transparent_index = -1;
    for(int i = 0; i < 16; i++) {
        uint8_t red = (PALETTE[i] & red_mask) << 3;
		uint8_t green = ((PALETTE[i] & green_mask) >> 5) << 3;
		uint8_t blue = ((PALETTE[i] & blue_mask) >> 10) << 3;
        colors[i][0] = red;
        colors[i][1] = green;
        colors[i][2] = blue;

        if((PALETTE[i] == 0) && (transparent_index == -1)) {
            transparent_index = i;
        }
    }

    uint16_t delay = 0;
    // https://psx-spx.consoledev.net/controllersandmemorycards/#title-frame-block-115-frame-0-in-first-block-of-file-only
    if (FRAMECNT == 2) {
        // (changes every 16 PAL frames)
        delay = (16 * 2);
    }
    else if(FRAMECNT == 3) {
        // (changes every 11 PAL frames)
        delay = (11 * 2);
    }


    ge_GIF *gif = ge_new_gif(
        "example.gif",  /* file name */
        w, h,           /* canvas size */
        (uint8_t*)colors,
        4,              /* palette depth == log2(# of colors) */
        0,              /* infinite loop */
        transparent_index
    );
    /* draw some frames */
    for(int i = 0; i < FRAMECNT; i++) {
        memcpy(gif->frame, &scaled[i], (w*h));
        ge_add_frame(gif, delay);
    }

    /* remember to close the GIF */
    ge_close_gif(gif);
    return 0;    
}


# if 0
/* create a GIF */
    int i, j;
    int w = 120, h = 90;
    ge_GIF *gif = ge_new_gif(
        "example.gif",  /* file name */
        w, h,           /* canvas size */
        (uint8_t []) {  /* palette */
            0x00, 0x00, 0x00, /* 0 -> black */
            0xFF, 0x00, 0x00, /* 1 -> red */
            0x00, 0xFF, 0x00, /* 2 -> green */
            0x00, 0x00, 0xFF, /* 3 -> blue */
        },
        2,              /* palette depth == log2(# of colors) */
        0               /* infinite loop */
    );
    /* draw some frames */
    for (i = 0; i < 4*6/3; i++) {
        for (j = 0; j < w*h; j++)
            gif->frame[j] = (i*3 + j) / 6 % 4;
        ge_add_frame(gif, 10);
    }
    /* remember to close the GIF */
    ge_close_gif(gif);
    return 0;
#endif