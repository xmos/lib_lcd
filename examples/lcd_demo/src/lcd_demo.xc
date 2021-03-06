// Copyright (c) 2014-2016, XMOS Ltd, All rights reserved
#include <platform.h>
#include "lcd.h"
#include "sprite.h"

#define LCD_CLOCK_DIVIDER 3
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

/*
 * Put an lcd into circle slot of A16 board.
 * You should see a bouncing XMOS logo.
 */
static unsafe void add(unsigned x, unsigned y, unsigned line, unsigned * unsafe buffer) {
  if (line >= x && line < x + SPRITE_HEIGHT_PX)
    for (unsigned i = y; i < y + SPRITE_WIDTH_WORDS; i++)
      buffer[i] = logo[(line - x) * SPRITE_WIDTH_WORDS + (i - y)];
}

static unsafe void sub(unsigned x, unsigned y, unsigned line, unsigned * unsafe buffer) {
  if (line >= x && line < x + SPRITE_HEIGHT_PX)
    for (unsigned i = y; i < y + SPRITE_WIDTH_WORDS; i++)
      buffer[i] = BACK_COLOUR;
}

static void move_sprite(int &x, int &y, int &vx, int &vy){
    x += vx;
    y += vy;
    if (y <= 0) {
        vy = -vy;
        y = 0;
    }
    if (y >= LCD_ROW_WORDS - SPRITE_WIDTH_WORDS) {
        vy = -vy;
        y = LCD_ROW_WORDS - SPRITE_WIDTH_WORDS - 1;
    }
    if (x <= 0) {
        vx = -vx;
        x = 0;
    }
    if (x >= LCD_HEIGHT - SPRITE_HEIGHT_PX) {
        vx = -vx;
        x = LCD_HEIGHT - SPRITE_HEIGHT_PX - 1;
    }
}

void demo(streaming chanend c_lcd) {
    unsigned buffer[2][LCD_ROW_WORDS];
    int x = 20, y = 0, vx = 1, vy = 2;
    unsigned index = 1;

    for(unsigned i=0;i<LCD_ROW_WORDS;i++){
        buffer[0][i] = BACK_COLOUR;
        buffer[1][i] = BACK_COLOUR;
    }

    unsafe {

        add(x, y, 0, buffer[0]);

        lcd_init(c_lcd, buffer[0]);

        unsigned line = 1;

        while(1){
            while(line < LCD_HEIGHT) {
                add(x, y, line, buffer[index]);
                lcd_req(c_lcd);
                lcd_update(c_lcd, buffer[index]);
                index = 1 - index;
                if(line)
                    sub(x, y, line - 1, buffer[index]);
                else
                    sub(x, y, LCD_HEIGHT - 1, buffer[index]);

                line++;
            }
            line = 0;

            move_sprite(x, y, vx, vy);
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
      on tile[1]:lcd_server(
              c_lcd,
              lcd_rgb,
              lcd_clk,
              lcd_data_enabled,
              lcd_h_sync,
              lcd_v_sync,
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
    on tile[1]: demo(c_lcd);
    on tile[1]: par(int i=0;i<6;i++) while (1);
  }
  return 0;
}

