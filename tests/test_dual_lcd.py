#!/usr/bin/env python
import xmostest

def test_dual_lcd():
    resources = xmostest.request_resource("LCD_test_setup")

    xmostest.build('dual_lcd_testbench')

    print "\nRunning on A16 board with LCD slices connected to circle and square slots"
    print "\nPlease check LCD displays for fading Red, Green and Blue bars bounded by a white box"
    print "\nPress CTRL-c to quit\n"

    binary = 'dual_lcd_testbench/bin/dual_lcd_testbench.xe' 
    xmostest.run_on_xcore(resources['A16'], binary,
                              tester = None,
                              enable_xscope = False,
                              xscope_handler = None,
                              timeout = 600)

def runtest():
    test_dual_lcd()

