// Copyright (c) 2016, XMOS Ltd, All rights reserved
#include <platform.h>
#include <stddef.h>
#include "lcd.h"

/*
 * Each LCD test frame consists of RGB565 pixel values ranging from 1 to LCD_WIDTH sent repeatedly
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
    unsigned data[LCD_ROW_WORDS];

    for (unsigned c=0; c<LCD_WIDTH; c++)
        (data,unsigned short[])[c] = c+1;

    unsafe {
        lcd_init(c_lcd, data);

        while(1){
	      lcd_req(c_lcd);
	      lcd_update(c_lcd, data);			
            }
    }

}


on tile[0] : out buffered port:32   lcd_rgb                     = XS1_PORT_16B;
on tile[0] : out port               lcd_clk                     = XS1_PORT_1I;
on tile[0] : out buffered port:32   lcd_h_sync                  = XS1_PORT_1J;
on tile[0] : out port               lcd_v_sync                  = XS1_PORT_1K;
on tile[0] : clock                  lcd_cb                      = XS1_CLKBLK_1;

int main() {
    streaming chan c_lcd;
  par {
    on tile[0]: lcd_server(c_lcd, lcd_rgb, lcd_clk, NULL, lcd_h_sync, lcd_v_sync,
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
    on tile[0]: test(c_lcd);
    on tile[0]: par(int i=0;i<6;i++) while (1);
  }
  return 0;
}
