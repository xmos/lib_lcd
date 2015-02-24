import xmostest

class LCD_data_checker(xmostest.SimThread):
    """"
    This simulator thread checks the pixel data sent to LCD

    """

    def __init__(self, lcd_rgb, lcd_clk, lcd_data_enabled, lcd_h_sync, lcd_v_sync, lcd_height, lcd_width):
        self._lcd_rgb = lcd_rgb
        self._lcd_clk = lcd_clk
        self._lcd_data_enabled = lcd_data_enabled
        self._lcd_h_sync = lcd_h_sync
        self._lcd_v_sync = lcd_v_sync
        self._lcd_height = lcd_height
        self._lcd_width = lcd_width


    def get_port_val(self, xsi, port):
        is_driving = xsi.is_port_driving(port)
        if not is_driving:
            print ("ERROR: port is not driving");
        return xsi.sample_port_pins(port);

   
    def run(self):
        xsi = self.xsi  
 
        # Check for port initialization 
        self.wait_for_port_pins_change([self._lcd_v_sync])   # Wait for initialization of ports by LCD server
        h_sync_val = self.get_port_val(xsi, self._lcd_h_sync);
        v_sync_val = self.get_port_val(xsi, self._lcd_v_sync);
        data_enabled_val = self.get_port_val(xsi, self._lcd_data_enabled);
        if (h_sync_val != 1 or v_sync_val != 1):
            print("ERROR: hsync or vsync not high at initialization")
        if (data_enabled_val != 0):
            print("ERROR: data enable not low at initialization")
    
              
        # Check for frame arrival 
        self.wait_for_port_pins_change([self._lcd_v_sync])
        print("vsync received")
        self.wait_for_port_pins_change([self._lcd_v_sync])
        

        # Check for arrival of data
        pix_val = 1;
        for row in range(1,self._lcd_height+1):
            self.wait_for_port_pins_change([self._lcd_data_enabled])
            error_flag = 0  
          
            for col in range(1,self._lcd_width+1):
                self.wait_for_port_pins_change([self._lcd_clk])
                rcvd_pix_val = self.get_port_val(xsi, self._lcd_rgb)
                if (rcvd_pix_val != pix_val) :
                    error_flag = 1
                pix_val = pix_val+1
                self.wait_for_port_pins_change([self._lcd_clk])

            if error_flag == 1 :
                print("ERROR: Wrong data")                
            self.wait_for_port_pins_change([self._lcd_clk])	# Do not wait for data enabled
            print ("Line %d received" % row)
 

        # Check for arrival of next frame
        self.wait_for_port_pins_change([self._lcd_v_sync])
        print("vsync received")

        xsi.terminate()

