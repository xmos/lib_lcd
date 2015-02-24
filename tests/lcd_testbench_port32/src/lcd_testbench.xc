#include <platform.h>
#include "lcd.h"

/*
 * Each LCD test frame consists of RGB565 pixel values ranging from 1 to LCD_HEIGHT*LCD_WIDTH 
 */

#define LCD_CLOCK_DIVIDER 4
#define LCD_H_FRONT_PORCH 5
#define LCD_H_BACK_PORCH 40
#define LCD_H_PULSE_WIDTH 1
#define LCD_V_FRONT_PORCH 8
#define LCD_V_BACK_PORCH 8
#define LCD_V_PULSE_WIDTH 1
#define LCD_HEIGHT 50
#define LCD_WIDTH 60
#define LCD_BYTES_PER_PIXEL 2
#define LCD_OUTPUT_MODE data16_port32
#define LCD_ROW_WORDS (LCD_WIDTH/2)


void test(streaming chanend c_lcd) {
    unsigned data[LCD_HEIGHT][LCD_ROW_WORDS];

    for (unsigned r=0; r<LCD_HEIGHT; r++)
        for (unsigned c=0; c<LCD_WIDTH; c++)
            (data[r],unsigned short[])[c] = r*LCD_WIDTH+c+1;

    unsafe {
        lcd_init(c_lcd, data[0]);

        while(1){
	    for (unsigned r=1; r<LCD_HEIGHT; r++) {
	        lcd_req(c_lcd);
        	lcd_update(c_lcd, data[r]);			
            }
            lcd_req(c_lcd);
 	    lcd_update(c_lcd, data[0]);		
        }
    }
}



on tile[0] : out buffered port:32   lcd_rgb                     = XS1_PORT_32A;
on tile[0] : out port               lcd_clk                     = XS1_PORT_1I;
on tile[0] : out port               lcd_data_enabled            = XS1_PORT_1L;
on tile[0] : out buffered port:32   lcd_h_sync                  = XS1_PORT_1J;
on tile[0] : out port               lcd_v_sync                  = XS1_PORT_1K;
on tile[0] : clock                  lcd_cb                      = XS1_CLKBLK_1;

int main() {
    streaming chan c_lcd;
  par {
    on tile[0]: lcd_server(c_lcd, lcd_rgb, lcd_clk, lcd_data_enabled, lcd_h_sync, lcd_v_sync,
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
