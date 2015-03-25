LCD Library
===========

LCD Libary
-----------

The XMOS LCD library allows you to interface to LCD screens via a
parallel bus.

Features
........

   * Standard component to support different types LCD displays with RGB 565,
   * Resolution of up to 800 * 480 pixels,
   * Up to 62.5 MHz pixel clock,
   * Hsync/Vsync and/or Data_Enable signal interfaces supported,
   * Configurable porch timings.

Components
...........

 * LCD server.
 * LCD server with synchronisation.
 
 
Resource Usage
..............

  * - configuration: LCD server, 16 bit data, sync mode: DE
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out port lcd_data_enabled=XS1_PORT_1L;;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd;
    - fn: lcd_server(c_lcd,lcd_rgb,lcd_clk,lcd_data_enabled,null,null,lcd_cb,480,272,540,0,8,8,0,data16_port16,2);
    - pins: 18
    - ports: 2 (1-bit), 1 (16-bit)

  * - configuration: LCD server, 16 bit data, sync mode: h_sync, v_sync
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out buffered port:32   lcd_h_sync=XS1_PORT_1J;out port lcd_v_sync=XS1_PORT_1K;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd;
    - fn: lcd_server(c_lcd,lcd_rgb,lcd_clk,null,lcd_h_sync,lcd_v_sync,lcd_cb,480,272,540,1,8,8,1,data16_port16,2);
    - pins: 19
    - ports: 3 (1-bit), 1 (16-bit)

  * - configuration: LCD server, 16 bit data, sync mode: h_sync, v_sync, DE
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out port lcd_data_enabled=XS1_PORT_1L;out buffered port:32   lcd_h_sync=XS1_PORT_1J;out port lcd_v_sync=XS1_PORT_1K;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd;
    - fn: lcd_server(c_lcd,lcd_rgb,lcd_clk,lcd_data_enabled,lcd_h_sync,lcd_v_sync,lcd_cb,480,272,540,1,8,8,1,data16_port16,2);
    - pins: 20
    - ports: 4 (1-bit), 1 (16-bit)

  * - configuration: LCD server with syncronisation, 16 bit data, sync mode: DE
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out port lcd_data_enabled=XS1_PORT_1L;;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd;streaming chan c_sync;
    - fn: lcd_server_sync(c_lcd, c_sync,lcd_rgb,lcd_clk,lcd_data_enabled,null,null,lcd_cb,480,272,540,0,8,8,0,data16_port16,2);
    - pins: 18
    - ports: 2 (1-bit), 1 (16-bit)

  * - configuration: LCD server with syncronisation, 16 bit data, sync mode: h_sync, v_sync
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out buffered port:32   lcd_h_sync=XS1_PORT_1J;out port lcd_v_sync=XS1_PORT_1K;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd;streaming chan c_sync;
    - fn: lcd_server_sync(c_lcd,c_sync,lcd_rgb,lcd_clk,null,lcd_h_sync,lcd_v_sync,lcd_cb,480,272,540,1,8,8,1,data16_port16,2);
    - pins: 19
    - ports: 3 (1-bit), 1 (16-bit)

  * - configuration: LCD server with syncronisation, 16 bit data, sync mode: h_sync, v_sync, DE
    - globals: out buffered port:32 lcd_rgb = XS1_PORT_16B;out port lcd_clk=XS1_PORT_1I;out port lcd_data_enabled=XS1_PORT_1L;out buffered port:32   lcd_h_sync=XS1_PORT_1J;out port lcd_v_sync=XS1_PORT_1K;clock lcd_cb=XS1_CLKBLK_1;
    - locals:  streaming chan c_lcd; streaming chan c_sync;
    - fn: lcd_server_sync(c_lcd,c_sync,lcd_rgb,lcd_clk,lcd_data_enabled,lcd_h_sync,lcd_v_sync,lcd_cb,480,272,540,1,8,8,1,data16_port16,2);
    - pins: 20
    - ports: 4 (1-bit), 1 (16-bit)

Software version and dependencies
.................................

.. libdeps::

Related application notes
.........................

None

