.. include:: ../../../README.rst

Hardware characteristics
------------------------

The signals from the xCore required to drive the LCD are:

.. _lcd_wire_table:

.. list-table:: LCD data and signal wires
     :class: vertical-borders horizontal-borders

     * - *Pixel Clock*
       - Clock line, this is the master clock the LCD will use for 
         sampling all the other signals.
     * - *Data*
       - The pixel data supplied to the LCD over a parallel bus.
     * - *Data Enabled (DE)*
       - Strobe to indicate that the data bus contains valid data.
     * - *Horizontal Sync (h_sync)*
       - A signal which sends a pulse to indicate the start of the 
         horizontal scan.
     * - *Vertical Sync (v_sync)*
       - A signal which sends a pulse to indicate the start of the 
         vertical scan.

The LCD library will assume a data output mode that matches the physical
wiring of the data bus.

The data bus may be wired to the LCD in any electrically sound 
configuration. For example, a 24 bit colour LCD could be driven 
with a 16 bit bus in the standard configuration of RGB565, meaning::

  - data[ 4: 0] drives red[7:3]
  - data[10: 5] drives green[7:2]
  - data[15:11] drives blue[7:3]

The same LCD could also be driven in monochrome by::

  - data[0] drives red[7]
  - data[0] drives green[7]
  - data[0] drives blue[7]

The DE, h_sync and v_sync signals are all optional, however, every LCD
will require some of them. See the datasheet of the LCD to find out
which signals are required.

The Pixel Clock rate will be given in the datasheet of the LCD. 

Output Mode
...........

The correct output mode must be selected for the application and physical
setup. The data may be up to 32 bits per pixel and the data bus can be 
from one to 32 bits wide.


LCD API
--------

All LCD functions can be accessed via the ``lcd.h`` header::

  #include <lcd.h>

You will also have to add ``lib_lcd`` to the ``USED_MODULES`` field of your application Makefile.

LCD server and client are instantiated as parallel tasks that run in a
``par`` statement. The client (application on most cases) can connect via 
a streaming channel.

For example, the following code instantiates an LCD server
and connects and application to it::

  out buffered port:32   lcd_rgb                     = XS1_PORT_16B;
  out port               lcd_clk                     = XS1_PORT_1I;
  out port               lcd_data_enabled            = XS1_PORT_1L;
  out buffered port:32   lcd_h_sync                  = XS1_PORT_1J;
  out port               lcd_v_sync                  = XS1_PORT_1K;
  clock                  lcd_cb                      = XS1_CLKBLK_1;
   
  int main(void) {
    streaming chan c_lcd;
    par {
      lcd_server(
          c_lcd,
          lcd_rgb,
          lcd_clk,
          lcd_data_enabled,
          lcd_h_sync,
          lcd_v_sync,
          lcd_cb,
          480,
          272,
          5, 40, 1,
          8, 8, 1,
          data16_port16,
          3);
      my_application(c_lcd);
    }
    return 0;
  }

Note that the client and LCD server must be on the same tile as the 
line buffers are transfered my moving pointers from one task to another.

lcd_init is used to start the LCD running, before this the pixel clock is 
not running and no other signals are outputting. This gives the application
time to perpare any necessary line buffers before begining. As soon as the 
lcd_init has been executed then there is a constant real-time requirement
on the client to update the LCD server with more line buffers. 
The LCD server will request new line buffers by inserting a token into the 
channel to the client. The client must call lcd_req either by selecting on it
or by explicitly called normally to acknoledge this request. 

Between the client and the LCD server is a buffer capable of holding of up to 
two line buffers from the client to the server. This means that the client can 
call lcd_update more than once per lcd_req in order to increase the time between 
subsequenct updates if need be. However, for every lcd_req there must be one 
lcd_update on average.

API
...

.. doxygenfunction:: lcd_server
.. doxygenfunction:: lcd_init
.. doxygenfunction:: lcd_update
.. doxygenfunction:: lcd_req

|newpage|

|appendix|

Known Issues
------------

There are no known issues with this library.

.. include:: ../../../CHANGELOG.rst

