#!/usr/bin/env python
import xmostest
from lcd_data_checker import LCD_data_checker
import os


def runtest():
    resources = xmostest.request_resource("xsim")

    xmostest.build('lcd_testbench_port32')

    binary = 'lcd_testbench_port32/bin/lcd_testbench.xe' 

    checker = LCD_data_checker("tile[0]:XS1_PORT_32A",
                               "tile[0]:XS1_PORT_1I",
                               "tile[0]:XS1_PORT_1L",
                               "tile[0]:XS1_PORT_1J",
                               "tile[0]:XS1_PORT_1K",
                               lcd_height = 50,
                               lcd_width = 60)

    tester = xmostest.ComparisonTester(open('lcd_data_test.expect'),
                                     'lib_lcd', 'lcd_sim_tests',
                                     'data32_test', regexp=True)

    
    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=['--weak-external-drive'],
                              suppress_multidrive_messages = True,
                              tester = tester)

  

