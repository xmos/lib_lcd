// Copyright (c) 2015, XMOS Ltd, All rights reserved
#include <platform.h>
#include <xs1.h>
#include <xclib.h>
#include "lcd.h"
#include <print.h>
#include <stdlib.h>

static void init(streaming chanend c_lcd){
    c_lcd :> int;
    c_lcd <: 0;
}
void lcd_sync_update(streaming chanend c_sync, int n){
   c_sync <:n;
}
void lcd_init(streaming chanend c_lcd, unsigned * unsafe buffer){
    c_lcd <: 0;
    c_lcd :> int;
    unsafe {
        c_lcd <: buffer;
    }
}

void lcd_update(streaming chanend c_lcd, unsigned * unsafe buffer){
    unsafe {
        c_lcd <: buffer;
    }
}

static void return_pointer(streaming chanend c_lcd, unsigned * unsafe buffer){
    unsafe {
        c_lcd <: buffer;
    }
}

void lcd_req(streaming chanend c_lcd){
    c_lcd :> int;
}

static void fetch_pointer(streaming chanend c_lcd, unsigned * unsafe & buffer){
    c_lcd :> buffer;
}

#pragma unsafe arrays
static void output_data16_port16(
        out buffered port:32  p_rgb,
        out port ?p_data_enabled,
        unsigned * unsafe buffer,
        unsigned &time,
        unsigned width){
    unsigned words_per_row = width>>1;

    unsafe {
        p_rgb @ time <: buffer[0];

        time += width;
        if(!isnull(p_data_enabled))
           p_data_enabled @ time <: 0;         //blocking instruction for that port

        for (unsigned i = 1; i < words_per_row; i++)
          p_rgb <: buffer[i];                   //TODO compiler optimisations needed to speed this bit up

    }
}

#pragma unsafe arrays
static void output_data16_port32(
        out buffered port:32  p_rgb,
        out port ?p_data_enabled,
        unsigned * unsafe buffer,
        unsigned &time,
        unsigned width){
    unsigned words_per_row = width>>1;

    unsafe {
        unsigned d = buffer[0];
	p_rgb @ time <: d;

        time += width;
        if(!isnull(p_data_enabled))
            p_data_enabled @ time <: 0;         //blocking instruction

        p_rgb <: (d>>16);

        for (unsigned i = 1; i < words_per_row; i++){
          d = buffer[i];
          p_rgb <: d;
          p_rgb <: (d>>16);
        }


    }
}

#pragma unsafe arrays
static void output_hsync_pulse(unsigned time,
        out buffered port:32 p_h_sync, unsigned h_pulse_width){
    if(h_pulse_width < 32){
        partout_timed(p_h_sync, h_pulse_width + 1, 1 << h_pulse_width, time);
    } else {
        partout_timed(p_h_sync, 1, 0, time);
        unsigned t = time + h_pulse_width;
        partout_timed(p_h_sync, 1, 1, t);
    }
}

static void error(){}



#pragma unsafe arrays
void lcd_impl(streaming chanend c_client,
        streaming chanend      ?c_sync,
        out buffered port:32   p_rgb ,
        out port               p_clk,
        out port               ?p_data_enabled,
        out buffered port:32   ?p_h_sync,
        out port               ?p_v_sync,
        clock                  p_cb,
        const static unsigned width,
        const static unsigned height,
        const static unsigned h_front_porch,
        const static unsigned h_back_porch,
        const static unsigned h_pulse_width,
        const static unsigned v_front_porch,
        const static unsigned v_back_porch,
        const static unsigned v_pulse_width,
        const static e_output_mode output_mode,
        const static unsigned clock_divider){

  unsigned time;

  stop_clock(p_cb);

  configure_clock_ref(p_cb, clock_divider);
  configure_port_clock_output(p_clk, p_cb);
  configure_out_port(p_rgb, p_cb, 0);

  set_port_inv(p_clk);

  if(!isnull(p_data_enabled))
      configure_out_port(p_data_enabled, p_cb, 0);
  if(!isnull(p_h_sync))
      configure_out_port(p_h_sync, p_cb, 1);
  if(!isnull(p_v_sync))
      configure_out_port(p_v_sync, p_cb, 1);


  // Sanity checks
  if(isnull(p_h_sync) && h_pulse_width!=0)
      error();

  if(isnull(p_v_sync) && v_pulse_width!=0)
      error();

  //wait here for the client to say that it is ready
  init(c_client);

  start_clock(p_cb);

  // get the port time
  p_rgb <: 0 @ time;

  time += 1000;

  //The count of pixel clocks per horizontal scan line
  unsigned h_sync_clocks = h_pulse_width + h_front_porch + h_back_porch + width;

  while (1) {
      if (!isnull(c_sync)){
      select {
          case c_sync:> int n:{
              time +=n;
              break;
          }
      default:
          break;
      }
    }
    if(!isnull(p_v_sync))
        p_v_sync @ time <: 0;

    if(!isnull(p_h_sync)){
         for (unsigned i = 0; i < v_pulse_width; i++) {
             output_hsync_pulse(time, p_h_sync, h_pulse_width);
             time += h_sync_clocks;
         }
    } else
        time += h_sync_clocks * v_pulse_width;

    if(!isnull(p_v_sync))
        p_v_sync @ time <: 1;

    if(!isnull(p_h_sync)){
        for(unsigned i=0;i<v_back_porch;i++) {
            output_hsync_pulse(time, p_h_sync, h_pulse_width);
            time += h_sync_clocks;
        }
    } else
        time += h_sync_clocks*v_back_porch;

    for (int y = 0; y < height; y++) {
        if(!isnull(p_h_sync))
            output_hsync_pulse(time, p_h_sync, h_pulse_width);
        time += (h_pulse_width + h_back_porch);

        unsigned * unsafe buffer;
        fetch_pointer(c_client, buffer);

	    if(!isnull(p_data_enabled))
	        p_data_enabled @ time <: 1;

	    switch(output_mode){
          case data16_port16: output_data16_port16(p_rgb, p_data_enabled, buffer, time, width); break;
          case data16_port32: output_data16_port32(p_rgb, p_data_enabled, buffer, time, width); break;
	    }
	    return_pointer(c_client, buffer);

        time += h_front_porch;
    }

    for(unsigned i=0;i<v_front_porch;i++) {
        if(!isnull(p_h_sync))
            output_hsync_pulse(time, p_h_sync, h_pulse_width);

        time += h_sync_clocks;
    }
  }
}

void lcd_server_sync(streaming chanend c_client,
        streaming chanend      c_sync,
        out buffered port:32   p_rgb ,
        out port               p_clk,
        out port               ?p_data_enabled,
        out buffered port:32   ?p_h_sync,
        out port               ?p_v_sync,
        clock                  p_cb,
        const static unsigned width,
        const static unsigned height,
        const static unsigned h_front_porch,
        const static unsigned h_back_porch,
        const static unsigned h_pulse_width,
        const static unsigned v_front_porch,
        const static unsigned v_back_porch,
        const static unsigned v_pulse_width,
        const static e_output_mode output_mode,
        const static unsigned clock_divider) {

   lcd_impl(c_client, c_sync, p_rgb, p_clk, p_data_enabled, 
            p_h_sync, p_v_sync, p_cb, width, height, 
            h_front_porch, h_back_porch, h_pulse_width, 
            v_front_porch, v_back_porch, v_pulse_width, 
            output_mode, clock_divider);

}

void lcd_server(streaming chanend c_client,
        out buffered port:32   p_rgb ,
        out port               p_clk,
        out port               ?p_data_enabled,
        out buffered port:32   ?p_h_sync,
        out port               ?p_v_sync,
        clock                  p_cb,
        const static unsigned width,
        const static unsigned height,
        const static unsigned h_front_porch,
        const static unsigned h_back_porch,
        const static unsigned h_pulse_width,
        const static unsigned v_front_porch,
        const static unsigned v_back_porch,
        const static unsigned v_pulse_width,
        const static e_output_mode output_mode,
        const static unsigned clock_divider) {

   lcd_impl(c_client, null, p_rgb, p_clk, p_data_enabled, 
            p_h_sync, p_v_sync, p_cb, width, height, 
            h_front_porch, h_back_porch, h_pulse_width, 
            v_front_porch, v_back_porch, v_pulse_width, 
            output_mode, clock_divider);

}
