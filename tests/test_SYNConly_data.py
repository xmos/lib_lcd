#!/usr/bin/env python
import xmostest
from lcd_SYNConly_data_checker import LCD_SYNConly_data_checker
import os


def runtest():
    resources = xmostest.request_resource("xsim")

    binary = 'lcd_testbench_SYNConly_data/bin/lcd_testbench.xe' 

    checker = LCD_SYNConly_data_checker("tile[0]:XS1_PORT_16B",
                               "tile[0]:XS1_PORT_1I",
                               "tile[0]:XS1_PORT_1J",
                               "tile[0]:XS1_PORT_1K",
                               lcd_h_front_porch = 5,
                               lcd_h_back_porch = 40,
                               lcd_h_pulse_width = 1,
                               lcd_v_front_porch = 8,
                               lcd_v_back_porch = 8,
                               lcd_v_pulse_width = 1,
                               lcd_height = 272,
                               lcd_width = 480)

    tester = xmostest.ComparisonTester(open('lcd_data_test.expect'),
                                     'lib_lcd', 'lcd_sim_tests',
                                     'SYNConly_data_test', regexp=True)

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=['--weak-external-drive'],
                              suppress_multidrive_messages = True,
                              tester = tester)

  

