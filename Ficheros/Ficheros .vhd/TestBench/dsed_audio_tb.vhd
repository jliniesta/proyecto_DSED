----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.01.2021 16:34:07
-- Design Name: 
-- Module Name: dsed_audio_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dsed_audio_tb is
end dsed_audio_tb;

architecture Behavioral of dsed_audio_tb is

component dsed_audio is 
    Port ( clk_100Mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           -- Control ports
           BTNL : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           SW0 : in STD_LOGIC;
           SW1 : in STD_LOGIC;
           
          --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;
           
          --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end component;

--input signal declaration
signal reset, clk_100Mhz: STD_LOGIC := '0';
signal BTNL, BTNC, BTNR, SW0, SW1: STD_LOGIC := '0';
signal micro_data: STD_LOGIC := '0';

--output signals declaration
signal micro_clk, micro_LR, jack_sd, jack_pwm : STD_LOGIC := '0';

-- Clock period definitions
constant clk_period : time := 10 ns;

--input signals for generating random signal micro_data
signal a,b,c : STD_LOGIC := '0';

begin

uut_dsed_audio : dsed_audio port map(
   clk_100Mhz => clk_100Mhz,
   reset => reset,
   BTNL => BTNL,
   BTNC => BTNC,
   BTNR => BTNR,
   SW0 => SW0,
   SW1 => SW1,
   micro_clk => micro_clk,
   micro_data => micro_data,
   micro_LR => micro_LR,
   jack_sd => jack_sd,
   jack_pwm => jack_pwm
   );

-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk_100Mhz <= '0';
    wait for clk_period/2;
    clk_100Mhz <= '1';
    wait for clk_period/2;
end process;

a <= not a after 1300 ns;
b <= not b after 2100 ns;
c <= not c after 3700 ns;
micro_data <= a xor b xor c;

-- Stimulus process
stim_proc: process
begin
    reset<='1';
    wait for 1 us;      
    reset<='0';
    wait for 5 us; 
    BTNL <= '1'; -- Grabación
    wait for 1500 us;
    BTNL <= '0';
    wait for 100us;
    BTNR <= '1'; -- Play Normal
    SW0 <= '0';
    SW1 <= '0';
    wait for 200 us;
    BTNR <= '0'; 
    wait for 2 ms;
    BTNR <= '1'; -- Play al reves
    SW0 <= '1';
    SW1 <= '0';
    wait for 200 us;
    BTNR <= '0'; 
    wait for 2 ms;
    BTNR <= '1'; -- Play con Filtro Paso Alto
    SW0 <= '1';
    SW1 <= '1';
    wait for 200 us;
    BTNR <= '0'; 
    wait for 2 ms;    
    BTNR <= '1'; -- Play con Filtro Paso Bajo
    SW0 <= '0';
    SW1 <= '1';
    wait for 200 us;
    BTNR <= '0'; 
    wait for 2 ms;      
    BTNC <= '1'; -- Borra
    wait for 500 us;
    BTNC <= '0';
    wait for 100 us;      

end process;

end Behavioral;
