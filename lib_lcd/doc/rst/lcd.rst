.. rheader::

   LCD |version|

LCD Library
===========

LCD Libary
-----------

The XMOS LCD library allows you to interface to LCD screens via a
parallel connection.

Features
........

   * Standard component to support different types LCD displays with RGB 565,
   * Resolution of up to 800 * 480 pixels,
   * 1, 4, 8, 16 or 32 bits per pixel,
   * Up to 62.5 MHz pixel clock,
   * Hsync/Vsync and/or Data_Enable signal interfaces supported,
   * Configurable blanking timings.

Components
...........

 * LCD server.
 
 
Resource Usage
..............

TODO

Software version and dependencies
.................................

This document pertains to version |version| of the LCD library. It is
intended to be used with version 13.x of the xTIMEcomposer studio tools.

The library does not have any dependencies (i.e. it does not rely on any
other libraries).

Related application notes
.........................

The following application notes use this library:

  * AN00101 - How to get the most out of a LCD driver

Hardware characteristics
------------------------


API
---

All LCD functions can be accessed via the ``lcd.h`` header::

  #include <lcd.h>

You will also have to add ``lib_lcd`` to the
``USED_MODULES`` field of your application Makefile.

|newpage|

LCD API
.......

.. doxygenfunction:: lcd_server
.. doxygenfunction:: lcd_init
.. doxygenfunction:: lcd_update
.. doxygenfunction:: lcd_req
.. doxygenfunction:: multibit_output_gpio