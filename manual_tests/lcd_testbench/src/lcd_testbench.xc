// Copyright (c) 2015, XMOS Ltd, All rights reserved
#include <platform.h>
#include "lcd.h"

/*
 * Put an lcd into circle slot of A16 board.
 * You should see three colour bars(rgb) fading from left to right surrounded
 * by a white boarder.
 */

#define LCD_CLOCK_DIVIDER 4
#define LCD_H_FRONT_PORCH 5
#define LCD_H_BACK_PORCH 40
#define LCD_H_PULSE_WIDTH 1
#define LCD_V_FRONT_PORCH 8
#define LCD_V_BACK_PORCH 8
#define LCD_V_PULSE_WIDTH 1
#define LCD_HEIGHT 272
#define LCD_WIDTH 480
#define LCD_BYTES_PER_PIXEL 2
#define LCD_OUTPUT_MODE data16_port16
#define LCD_ROW_WORDS (LCD_WIDTH/2)

void test(streaming chanend c_lcd) {
    unsigned full_line[LCD_ROW_WORDS];
    unsigned index = 0;
    unsigned red[2][LCD_ROW_WORDS];
    unsigned green[2][LCD_ROW_WORDS];
    unsigned blue[2][LCD_ROW_WORDS];
    for(unsigned i=0;i<LCD_ROW_WORDS;i++)
        full_line[i] = 0xffffffff;

    for(unsigned index=0;index <2;index++){
        for(unsigned w=0;w<LCD_ROW_WORDS;w++){
            unsigned c = 0x001f*w/LCD_ROW_WORDS;
            red[index][w] = ((c+1)<<16)|c;
        }
        red[index][0] |= 0x0000ffff;
        red[index][LCD_ROW_WORDS-1] |= 0xffff0000;

        for(unsigned w=0;w<LCD_ROW_WORDS;w++){
            unsigned c = 0x003f*w/LCD_ROW_WORDS;
            green[index][w] = (((c+1)<<16)|c)<<5;
        }
        green[index][0] |= 0x0000ffff;
        green[index][LCD_ROW_WORDS-1] |= 0xffff0000;

        for(unsigned w=0;w<LCD_ROW_WORDS;w++){
            unsigned c = 0x001f*w/LCD_ROW_WORDS;
            blue[index][w] = (((c+1)<<16)|c)<<11;
        }
        blue[index][0] |= 0x0000ffff;
        blue[index][LCD_ROW_WORDS-1] |= 0xffff0000;
    }

    unsafe {

        lcd_init(c_lcd, full_line);

        while(1){

            //red
            for(unsigned i=1;i<LCD_HEIGHT/3;i++){
                lcd_req(c_lcd);
                lcd_update(c_lcd, red[index]);
                index = 1-index;
            }

            //green
            for(unsigned i=LCD_HEIGHT/3;i<2*LCD_HEIGHT/3;i++){
                lcd_req(c_lcd);
                lcd_update(c_lcd, green[index]);
                index = 1-index;
            }

            //blue
            for(unsigned i=2*LCD_HEIGHT/3;i<LCD_HEIGHT-1;i++){
                lcd_req(c_lcd);
                lcd_update(c_lcd, blue[index]);
                index = 1-index;
            }

            lcd_req(c_lcd);
            lcd_update(c_lcd, full_line);

            lcd_req(c_lcd);
            lcd_update(c_lcd, full_line);
        }
    }
}

on tile[1] : out buffered port:32   lcd_rgb                     = XS1_PORT_16B;
on tile[1] : out port               lcd_clk                     = XS1_PORT_1I;
on tile[1] : out port               lcd_data_enabled            = XS1_PORT_1L;
on tile[1] : out buffered port:32   lcd_h_sync                  = XS1_PORT_1J;
on tile[1] : out port               lcd_v_sync                  = XS1_PORT_1K;
on tile[1] : clock                  lcd_cb                      = XS1_CLKBLK_1;

int main() {
    streaming chan c_lcd;
  par {
    on tile[1]: lcd_server(c_lcd, lcd_rgb, lcd_clk, lcd_data_enabled, lcd_h_sync, lcd_v_sync,
            lcd_cb,
              LCD_WIDTH,
              LCD_HEIGHT,
              LCD_H_FRONT_PORCH,
              LCD_H_BACK_PORCH,
              LCD_H_PULSE_WIDTH,
              LCD_V_FRONT_PORCH,
              LCD_V_BACK_PORCH,
              LCD_V_PULSE_WIDTH,
              LCD_OUTPUT_MODE,
              LCD_CLOCK_DIVIDER);
    on tile[1]: test(c_lcd);
    on tile[1]: par(int i=0;i<6;i++) while (1);
  }
  return 0;
}
