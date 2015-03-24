.. include:: ../../../README.rst

Hardware characteristics
------------------------

The signals from the xCore required to drive the LCD are:

.. _lcd_wire_table:

.. list-table:: LCD data and signal wires
     :class: vertical-borders horizontal-borders

     * - Pixel Clock
       - Clock line, all other signals with be clocked off of this.
     * - Data
       - The pixel data supplied to the LCD over a parallel bus.
     * - Data Enabled (DE)
       - Strobe to indicate that the data on the paralle
     * - Horizontal Sync (h_sync)
       - A signal which sends a pulse to indicate the start of the 
         horizontal scan.
     * - Vertical Sync (v_sync)
       - A signal which sends a pulse to indicate the start of the 
         vertical scan.

Connecting to the xCORE SPI master
..................................

The LCD wires need to be connected to the xCORE device as shown in
:ref:`lcd_xcore_connect`. The control signals can be connected to any of the
one bit ports on the device provide they do not overlap any other used
ports and are all on the same tile. The parallel data bus must not overlap 
with any of the control signals.

.. _lcd_xcore_connect:

.. figure:: images/lcd_connect.*
   :width: 40%

   LCD connection to the xCORE device


The data bus may be wired to the LCD in any electrically sound 
configuration. For example, a 24 bit colour LCD with 8 bits for 
each of red, green and blue, could be driven by a 16 bit bus. 
For the standard configuration of RGB565, this could be achieved 
by the wiring configuration of:

  - ``data[ 4: 0]`` from the xCore drives ``red[7:3]`` on the LCD
  - ``data[10: 5]`` from the xCore drives ``green[7:2]`` on the LCD
  - ``data[15:11]`` from the xCore drives ``blue[7:3]`` on the LCD
  - ``red[2:0]`` should be grounded on the LCD
  - ``green[1:0]`` should be grounded on the LCD
  - ``blue[2:0]`` should be grounded on the LCD

The same LCD could also be driven in monochrome by:

  - ``data[0]`` from the xCore drives ``red[7]`` on the LCD
  - ``data[0]`` from the xCore drives ``green[7]`` on the LCD
  - ``data[0]`` from the xCore drives ``blue[7]`` on the LCD

The ``DE``, ``h_sync`` and ``v_sync`` signals are all optional, however, every LCD
will require some of them. See the datasheet of the LCD to find out
which signals are required.

The LCDs datasheet will give all the timing characteristics necessary to setup the LCD. Refer to :ref:`lcd_vertical_timing` and :ref:`lcd_horizontal_timing` for clarification of the LCD timing definitions.

.. _lcd_vertical_timing:

.. wavedrom:: LCD vertical timing

  {signal: [
    {name: 'V_SYNC',      wave: '101|...|....|.01', node: '.AB..D....C...E'},
    {name: 'Horizontal',  wave: '222|222|2222|22'},
    {                     node: '.MH..I....K...J'},
    {                     node: '.N............O'}],
    edge: ['A-M', 'B-H', 'D-I', 'C-K','E-J' , 'M<->H Tvpw', 'H<->I Tvbp', 'I<->K Tvd', 'K<->J Tvfp', 'O<->N Tv']
  }

.. _lcd_horizontal_timing:

.. wavedrom:: LCD horizontal timing

  {signal: [
    {name: 'PIXEL_CLK',  wave: '10101|01010101|01010|101', node: '.A.B...D..........C....E'},
    {name: 'DE',         wave: '0....|.1......|...0.|...'},
    {name: 'H_SYNC',     wave: '10.1.|........|.....|..0'},
    {name: 'RGB',        wave: 'x....|.2.2.2.2|.2.x.|x..', node:'', data: ['DQ[0]','DQ[1]','DQ[2]',,'DQ[w-1]' ]},
     {              node: '.M.H...I..........K....J'},
     {              node: '.O.....................P'}],
    edge: ['M-A ', 'B-H', 'C-K' , 'D-I', 'E-J', 'M<->H Thpw', 'H<->I Thbp', 'I<->K Thd', 'K<->J Thfp', 'O<->P Th']
  }
  
.. list-table:: LCD Timing 
     :class: vertical-borders horizontal-borders

     * - *Tvpw*
       - Vertical pulse width
     * - *Tvbp*
       - Vertical back porch
     * - *Tvd*
       - Vertical data period
     * - *Tvfb*
       - Vertical front porch
     * - *Tv*
       - Vertical total time
     * - *Thpw*
       - Horizontal pulse width
     * - *Thbp*
       - Horizontal back porch
     * - *Thd*
       - Horizontal data valid
     * - *Thfb*
       - Horizontal front porch
     * - *Th*
       - Horizontal total time


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

``lcd_init`` is used to start the LCD running, before this the pixel clock is 
not running and no other signals are outputting. This gives the application
time to perpare any necessary line buffers before begining. As soon as the 
``lcd_init`` has been executed then there is a constant real-time requirement
on the client to update the LCD server with more line buffers. 
The LCD server will request new line buffers by inserting a token into the 
channel to the client. The client must call ``lcd_req`` either by selecting on it
or by explicitly called normally to acknoledge this request. 

Between the client and the LCD server is a buffer capable of holding of up to 
two line buffers from the client to the server. This means that the client can 
call lcd_update more than once per lcd_req in order to increase the time between 
subsequenct updates if need be. However, for every ``lcd_req`` there must be one 
``lcd_update`` on average.

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

