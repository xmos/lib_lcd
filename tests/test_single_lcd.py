#!/usr/bin/env python
import xmostest

def test_single_lcd():
    resources = xmostest.request_resource("LCD_test_setup")

    xmostest.build('lcd_testbench')

    print "\nRunning on A16 board with LCD slice connected to circle slot"
    print "\nPlease check LCD display for fading Red, Green and Blue bars bounded by a white box"
    print "\nPress CTRL-c to quit\n"

    binary = 'lcd_testbench/bin/lcd_testbench.xe' 
    xmostest.run_on_xcore(resources['A16'], binary,
                              tester = None,
                              enable_xscope = False,
                              xscope_handler = None,
                              timeout = 600)


def runtest():
    test_single_lcd()
   
