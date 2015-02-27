import xmostest

class LCD_syncTiming_checker(xmostest.SimThread):
    """"
    This simulator thread checks the front porch, back porch and width of sync pulses 

    """

    def __init__(self, lcd_rgb, lcd_clk, lcd_data_enabled, lcd_h_sync, lcd_v_sync, lcd_h_front_porch, lcd_h_back_porch, lcd_h_pulse_width, lcd_v_front_porch, lcd_v_back_porch, lcd_v_pulse_width, lcd_clk_div, lcd_height, lcd_width):
        self._lcd_rgb = lcd_rgb
        self._lcd_clk = lcd_clk
        self._lcd_data_enabled = lcd_data_enabled
        self._lcd_h_sync = lcd_h_sync
        self._lcd_v_sync = lcd_v_sync
        self._lcd_h_front_porch = lcd_h_front_porch
        self._lcd_h_back_porch = lcd_h_back_porch
        self._lcd_h_pulse_width = lcd_h_pulse_width
        self._lcd_v_front_porch = lcd_v_front_porch
        self._lcd_v_back_porch = lcd_v_back_porch
        self._lcd_v_pulse_width = lcd_v_pulse_width
        self._lcd_clk_div = lcd_clk_div
        self._lcd_height = lcd_height
        self._lcd_width = lcd_width


    def get_port_val(self, xsi, port):
        is_driving = xsi.is_port_driving(port)
        if not is_driving:
            print ("ERROR: port is not driving");
        return xsi.sample_port_pins(port);

   
    def run(self):
        xsi = self.xsi  
    
        # Bring vsync high   
        self.wait_for_port_pins_change([self._lcd_v_sync])    
        v_sync_val = self.get_port_val(xsi, self._lcd_v_sync);
        if (v_sync_val == 0):
            self.wait_for_port_pins_change([self._lcd_v_sync])
         
        # Check for vsync width
        self.wait_for_port_pins_change([self._lcd_v_sync])
        vsync_low_time = xsi.get_time();
        self.wait_for_port_pins_change([self._lcd_v_sync])
        vsync_high_time = xsi.get_time();
        vPW_computed = vsync_high_time-vsync_low_time

        # Check for hsync width
        self.wait_for_port_pins_change([self._lcd_h_sync])
        hsync_high_time = xsi.get_time();
        hPW_computed = hsync_high_time-vsync_high_time

        # Check for vsync back porch + hsync back porch
        self.wait_for_port_pins_change([self._lcd_data_enabled])
        de_high_time = xsi.get_time();
        vBP_hBP_computed = de_high_time-hsync_high_time

        # Check for hsync front porch
        self.wait_for_port_pins_change([self._lcd_data_enabled])
        de_low_time = xsi.get_time();
        self.wait_for_port_pins_change([self._lcd_h_sync])
        hsync_low_time = xsi.get_time();
        hFP_computed = hsync_low_time-de_low_time

        # Skip the remaining lines
        for row in range(1,self._lcd_height):
            self.wait_for_port_pins_change([self._lcd_h_sync])
            self.wait_for_port_pins_change([self._lcd_h_sync]) 
 
        # Check for vsync front porch
        hsync_low_time1 = xsi.get_time();
        self.wait_for_port_pins_change([self._lcd_v_sync])
        vsync_low_time1 = xsi.get_time();
        vFP_computed = vsync_low_time1-hsync_low_time1
 
        # Find expected timings
        lcd_clk_ns = self._lcd_clk_div * 20
        hPW_expected = self._lcd_h_pulse_width * lcd_clk_ns
        hFP_expected = self._lcd_h_front_porch * lcd_clk_ns
        hBP_expected = self._lcd_h_back_porch * lcd_clk_ns
        hsync_ns = hPW_expected + hFP_expected + hBP_expected + (self._lcd_width * lcd_clk_ns)
        vPW_expected = self._lcd_v_pulse_width * hsync_ns
        vFP_expected = self._lcd_v_front_porch * hsync_ns
        vBP_expected = self._lcd_v_back_porch * hsync_ns
        vBP_hBP_expected = vBP_expected + hBP_expected

        # Print computed and expected timings
        print ("hsync width: computed = %d ns; expected = %d ns" % (hPW_computed, hPW_expected))
        print ("vsync width: computed = %d ns; expected = %d ns" % (vPW_computed, vPW_expected))
        print ("back porches: computed = %d ns; expected = %d ns" % (vBP_hBP_computed, vBP_hBP_expected))
        print ("hsync front porch: computed = %d ns; expected = %d ns" % (hFP_computed, hFP_expected))
        print ("vsync front porch: computed = %d ns; expected = %d ns" % (vFP_computed, vFP_expected))

             
        xsi.terminate()



