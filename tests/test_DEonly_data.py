#!/usr/bin/env python
import xmostest
from lcd_DEonly_data_checker import LCD_DEonly_data_checker
import os


def runtest():
    resources = xmostest.request_resource("xsim")

    binary = 'lcd_testbench_DEonly_data/bin/lcd_testbench.xe' 

    checker = LCD_DEonly_data_checker("tile[0]:XS1_PORT_16B",
                               "tile[0]:XS1_PORT_1I",
                               "tile[0]:XS1_PORT_1L",
                               lcd_height = 272,
                               lcd_width = 480)

    tester = xmostest.ComparisonTester(open('lcd_data_test.expect'),
                                     'lib_lcd', 'lcd_sim_tests',
                                     'DEonly_data_test', regexp=True)

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=['--weak-external-drive'],
                              suppress_multidrive_messages = True,
                              tester = tester)

  

