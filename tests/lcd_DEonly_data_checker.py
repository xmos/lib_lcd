import xmostest

class LCD_DEonly_data_checker(xmostest.SimThread):
    """"
    This simulator thread checks the pixel data sent to LCD

    """

    def __init__(self, lcd_rgb, lcd_clk, lcd_data_enabled, lcd_height, lcd_width):
        self._lcd_rgb = lcd_rgb
        self._lcd_clk = lcd_clk
        self._lcd_data_enabled = lcd_data_enabled
        self._lcd_height = lcd_height
        self._lcd_width = lcd_width


    def get_port_val(self, xsi, port):
        is_driving = xsi.is_port_driving(port)
        if not is_driving:
            print ("ERROR: port is not driving");
        return xsi.sample_port_pins(port);

   
    def run(self):
        xsi = self.xsi  
        self.wait_for_port_pins_change([self._lcd_data_enabled])  # Necessary for port-not-driving to port-init change
 
        # Check for arrival of data
        error_flag = 0  
        for row in range(0,self._lcd_height): 
            self.wait_for_port_pins_change([self._lcd_data_enabled])
          
            for col in range(1,self._lcd_width+1):
                self.wait_for_port_pins_change([self._lcd_clk])
                rcvd_pix_val = self.get_port_val(xsi, self._lcd_rgb) 
                if (rcvd_pix_val != col) :
                    error_flag = 1
                self.wait_for_port_pins_change([self._lcd_clk])

            self.wait_for_port_pins_change([self._lcd_clk])	# Do not wait for data enabled
            

        if error_flag == 1 :
            print("ERROR: Wrong data")  
        else :          
            print ("Data received correctly")
 

        xsi.terminate()

