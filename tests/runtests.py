#!/usr/bin/env python2.7
import xmostest

if __name__ == "__main__":
    xmostest.init()

    xmostest.register_group("lib_lcd",
                            "lcd_sim_tests",
                            "LCD Simulator Tests",
    """
Tests are performed by running the LCD library connected to a simulator model 
(written as a python plugin to xsim). The simulator model checks the HSYNC and 
VSYNC timings, and the data sent by the testbench.

""")

    xmostest.runtests()

    xmostest.finish()


