----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 30.11.2020 11:30:36
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Testbench del controlador para la implementacion fisica y test en placa
-- File Name: controlador_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Testbench que verifica la funcionalidad del controlador de audio (sin filtro, ni RAM)
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity controlador_tb is
end controlador_tb;

architecture Behavioral of controlador_tb is

component controlador is 
    Port ( clk_100Mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;
           --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end component;

--input signal declaration
signal reset, clk_100Mhz, micro_data: STD_LOGIC := '0';

--output signals declaration
signal micro_clk, micro_LR, jack_sd, jack_pwm : STD_LOGIC := '0';

-- Clock period definitions
constant clk_period : time := 10 ns;

--input signals for generating random signal micro_data
signal a,b,c : STD_LOGIC := '0';


begin

uut_controlador : controlador port map(
   clk_100Mhz => clk_100Mhz,
   reset => reset,
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

-- micro_data es una señal pseudo-aleatoria
--a <= not a after 1300 ns;
--b <= not b after 2100 ns;
--c <= not c after 3700 ns;
--micro_data <= a xor b xor c;

-- Stimulus process
stim_proc: process
begin
--    Opcion a): micro_data es una señal fija a '1'
    micro_data<='1';
    reset<='1';
    wait for 200 ns;      
    reset<='0';
    wait for 500 us;      
end process;

end Behavioral;
