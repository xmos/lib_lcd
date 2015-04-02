// Copyright (c) 2015, XMOS Ltd, All rights reserved
#ifndef _lcd_h_
#define _lcd_h_
#include <xs1.h>

typedef enum {
    data16_port16,  //use all the bits of a 16 bit port
    data16_port32,  //use the lower 16 bits of a 32 bit port
} e_output_mode;

/** \brief The LCD server.
 *
 * \param c_client          The data channel connecting to the client.
 * \param lcd_rgb           The parallel data port.
 * \param lcd_clk           The pixel clock.
 * \param lcd_data_enabled  The data enabled signal.
 * \param lcd_h_sync        The horizontal sync signal.
 * \param lcd_v_sync        The vertical sync signal.
 * \param lcd_cb            A clock block to manage the ports.
 * \param width             Width of the LCD screen in pixels.
 * \param height            Height of the LCD screen in pixels.
 * \param h_front_porch     Time of horizontal front porch in pixel clocks.
 * \param h_back_porch      Time of horizontal back porch in pixel clocks.
 * \param h_pulse_width     Time of horizontal pulse width in pixel clocks.
 * \param v_front_porch     Time of vertical front porch in horizontal times.
 * \param v_back_porch      Time of vertical back porch in horizontal times.
 * \param v_pulse_width     Time of vertical pulse width in horizontal times.
 * \param output_mode       The mode of writing line buffers to the data port.
 * \param clock_divider     The divider of the system clock to give the pixel clock.
 */
void lcd_server(streaming chanend c_client,
        out buffered port:32   lcd_rgb ,
        out port               lcd_clk,
        out port               ?lcd_data_enabled,
        out buffered port:32   ?lcd_h_sync,
        out port               ?lcd_v_sync,
        clock                  lcd_cb,
        const static unsigned width,
        const static unsigned height,
        const static unsigned h_front_porch,
        const static unsigned h_back_porch,
        const static unsigned h_pulse_width,
        const static unsigned v_front_porch,
        const static unsigned v_back_porch,
        const static unsigned v_pulse_width,
        const static e_output_mode output_mode,
        const static unsigned clock_divider
       );

/** \brief The LCD server with synchronization.
 *
 * \param c_client          The data channel connecting to the client.
 * \param c_sync            The synchronisation channel connecting to the client.
 * \param lcd_rgb           The parallel data port.
 * \param lcd_clk           The pixel clock.
 * \param lcd_data_enabled  The data enabled signal.
 * \param lcd_h_sync        The horizontal sync signal.
 * \param lcd_v_sync        The vertical sync signal.
 * \param lcd_cb            A clock block to manage the ports.
 * \param width             Width of the LCD screen in pixels.
 * \param height            Height of the LCD screen in pixels.
 * \param h_front_porch     Time of horizontal front porch in pixel clocks.
 * \param h_back_porch      Time of horizontal back porch in pixel clocks.
 * \param h_pulse_width     Time of horizontal pulse width in pixel clocks.
 * \param v_front_porch     Time of vertical front porch in horizontal times.
 * \param v_back_porch      Time of vertical back porch in horizontal times.
 * \param v_pulse_width     Time of vertical pulse width in horizontal times.
 * \param output_mode       The mode of writing line buffers to the data port.
 * \param clock_divider     The divider of the system clock to give the pixel clock.
 */
void lcd_server_sync(streaming chanend c_client,
        streaming chanend      c_sync,
        out buffered port:32   lcd_rgb ,
        out port               lcd_clk,
        out port               ?lcd_data_enabled,
        out buffered port:32   ?lcd_h_sync,
        out port               ?lcd_v_sync,
        clock                  lcd_cb,
        const static unsigned width,
        const static unsigned height,
        const static unsigned h_front_porch,
        const static unsigned h_back_porch,
        const static unsigned h_pulse_width,
        const static unsigned v_front_porch,
        const static unsigned v_back_porch,
        const static unsigned v_pulse_width,
        const static e_output_mode output_mode,
        const static unsigned clock_divider
       );


/** \brief Adds or removes n pixel clock periods from the vertical back porch.
 *
 * \param c_sync    The synchronisation channel to the LCD server
 * \param n         The number of pixel clocks to add to to veritcal back porch
 */
void lcd_sync_update(streaming chanend c_sync, int n);

/** \brief Initialises the LCD with the first line to be rendered. After this completes
 * there is a permanent real time requirement to update the LCD server with more data to render.
 *
 * \param c_lcd     The channel to the LCD server
 * \param buffer    This is a pointer to the data to be written to the LCD
 */
void lcd_init(streaming chanend c_lcd, unsigned * unsafe buffer);

/** \brief Passes a buffer to be rendered by the LCD
 *
 * \param c_lcd     The channel to the LCD server
 * \param buffer    This is a pointer to the data to be written to the LCD
 */
void lcd_update(streaming chanend c_lcd, unsigned * unsafe buffer);

/** \brief Returns the movable pointer from the LCD server to the client for reuse
 * This is a blocking call that may be used as a select handler.
 *
 * \param c_lcd     The channel to the LCD server
 */
#pragma select handler
void lcd_req(streaming chanend c_lcd);

#endif
