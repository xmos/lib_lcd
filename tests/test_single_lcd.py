#!/usr/bin/env python
import xmostest

def test_single_lcd():
    resources = xmostest.request_resource("LCD_test_setup")

    xmostest.build('lcd_testbench')

    binary = 'lcd_testbench/bin/lcd_testbench.xe' 

    xmostest.run_on_xcore(resources['A16'], binary,
                              tester = None,
                              enable_xscope = False,
                              xscope_handler = None,
                              timeout = 20)


def runtest():
    test_single_lcd()

