#include "bbb_regs.h"

///////////////////////////////////////////////////////////////////////////////
void disable_wdt(void)
{
  WDT_WSPR = 0xAAAA;
  while((WDT_WWPS & (1<<4)));
  WDT_WSPR = 0x5555;
  while((WDT_WWPS & (1<<4)));
}
///////////////////////////////////////////////////////////////////////////////
void delay1s(void)
{
  //unsigned int d = 0xfffffff;
  //while(d--);

  unsigned char s = SECONDS_REG;
  while (s==SECONDS_REG);
}
///////////////////////////////////////////////////////////////////////////////
void put_ch(unsigned char c)
{
  while(!(UART0_LSR & (1<<5)));

  UART0_THR = c;
}
///////////////////////////////////////////////////////////////////////////////
unsigned char get_ch(unsigned char c)
{
  while(!(UART0_LSR & (1<<0)));

  return (unsigned char)UART0_RHR;
}
///////////////////////////////////////////////////////////////////////////////
void rtc_setup(void)
{
    /*  Clock enable for RTC TRM 8.1.12.6.1 */
    CM_RTC_CLKSTCTRL   = 0x2;
    CM_RTC_RTC_CLKCTRL = 0x2;

    /* Disable write protection TRM 20.3.5.23 e 20.3.5.24 */
    KICK0R = 0x83E70B13;
    KICK1R = 0x95A4F1E0;

    
    /* Select external clock*/
    RTC_OSC_REG = 0x48;

    /* Interrupt setup */
    RTC_INTERRUPTS_REG = 0x4;   /* interrupt every second */
    //RTC_INTERRUPTS_REG = 0x5;   /* interrupt every minute */
    //RTC_INTERRUPTS_REG = 0x6;   /* interrupt every hour */

    /* Start RTC */
    RTC_CTRL_REG |= 0x01;
  
    /* Interrupt setup */
    while((RTC_STATUS_REG & 0x01));

    /* Interrupt mask */
    INTC_MIR_CLEAR2 |= (1<<11);//(75 --> Bit 11 do 3º registrador (MIR CLEAR2))


}
///////////////////////////////////////////////////////////////////////////////
void gpio_setup()
{
  /* set clock for GPIO1, TRM 8.1.12.1.31 */
  CM_PER_GPIO1_CLKCTRL = 0x40002;

  /* clear pin 21 for output, led USR0, TRM 25.3.4.3 */
  GPIO1_OE &= ~(1<<21);
}
///////////////////////////////////////////////////////////////////////////////
void ledOff(void)
{
  GPIO1_CLEARDATAOUT = (1<<21);
}
///////////////////////////////////////////////////////////////////////////////
void ledOn(void)
{
  GPIO1_SETDATAOUT = (1<<21);
}
///////////////////////////////////////////////////////////////////////////////
void print_time(void)
{
  unsigned char h,m,s;

  h = HOURS_REG;
  m = MINUTES_REG;
  s = SECONDS_REG;
 
  //converte de BCD para ascii
  //hora
  put_ch(0x30 + ((h >> 4) & 0x3)); //dezena
  put_ch(0x30 + ((h >> 0) & 0xf)); //unidade
  put_ch(':');
  //minutos
  put_ch(0x30 + ((m >> 4) & 0x7)); //dezena
  put_ch(0x30 + ((m >> 0) & 0xf)); //unidade
   put_ch(':');
  //segundos
  put_ch(0x30 + ((s >> 4) & 0x7)); //dezena
  put_ch(0x30 + ((s >> 0) & 0xf)); //unidade

  put_ch('\r');
}
///////////////////////////////////////////////////////////////////////////////
/********************************************************/
int flg_led = 0;
void rtc_irq_handler(void)
{
  //Pisca o led
  ((flg_led++ & 0x1) ? ledOn() : ledOff());

  //Imprime a hora
  print_time();
    
}

void IRQ_Handler(void)
{
     /* Verifica se é interrupção do RTC */
    unsigned int irq_number = INTC_SIR_IRQ & 0x7f; 
    if(irq_number == 75)
    {
      rtc_irq_handler();
    }
    
    /* Reconhece a IRQ */
    INTC_CONTROL = 1;

}

/********************************************************/

int main(void)
{
  /* Hardware setup */
  gpio_setup();
  rtc_setup();
  disable_wdt();

  const char *hello = "Hello Interrupt2!\n\r";
  unsigned char *h = (unsigned char *)hello;
  while(*h != 0)
  {
    put_ch(*h++);
  }

  while(1);

  return 0;
}




