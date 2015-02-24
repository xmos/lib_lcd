#!/usr/bin/env python
import xmostest
from lcd_syncTiming_checker import LCD_syncTiming_checker
import os


def runtest():

    resources = xmostest.request_resource("xsim")

    xmostest.build('lcd_testbench_port16')

    binary = 'lcd_testbench_port16/bin/lcd_testbench.xe' 

    checker = LCD_syncTiming_checker("tile[0]:XS1_PORT_16B",
                               "tile[0]:XS1_PORT_1I",
                               "tile[0]:XS1_PORT_1L",
                               "tile[0]:XS1_PORT_1J",
                               "tile[0]:XS1_PORT_1K",
                               lcd_clk_div = 4,
                               lcd_h_front_porch = 5,
                               lcd_h_back_porch = 40,
                               lcd_h_pulse_width = 1,
                               lcd_v_front_porch = 8,
                               lcd_v_back_porch = 8,
                               lcd_v_pulse_width = 1,
                               lcd_height = 50,
                               lcd_width = 60)

    tester = xmostest.ComparisonTester(open('lcd_syncTiming_test.expect'),
                                     'lib_lcd', 'lcd_sim_tests',
                                     'sync_test', regexp=True)

    xmostest.run_on_simulator(resources['xsim'], binary,
                              simthreads = [checker],
                              simargs=['--weak-external-drive'],
                              suppress_multidrive_messages = True,
                              tester = tester)




