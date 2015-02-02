#!/usr/bin/env python
import xmostest

if __name__ == "__main__":
    xmostest.init()

    xmostest.register_group("lib_lcd",
                            "single_lcd_testbench",
                            "Single LCD Testbench",
    """
Visual test is performed by running the LCD library on a
A16 sliceKIT with LCD slice attached to the circle slot. 
On the LCD display, one can 
see three colour bars (Red, Green and Blue) fading from left 
to right surrounded by a white border. Perfect display ensures 
testing of HSYNC and VSYNC pulses, and reproduction of basic colors.
""")

    xmostest.register_group("lib_i2c",
                            "dual_lcd_testbench",
                            "Dual LCD Testbench",
    """
Visual test is performed by running two LCD servers of the LCD library on a
A16 sliceKIT with LCD slices attached to the circle and square slots.
On each LCD, one can 
see three colour bars (Red, Green and Blue) fading from left 
to right surrounded by a white border. Perfect display ensures 
testing of HSYNC and VSYNC pulses, and reproduction of basic colors.
""")

    xmostest.runtests()


