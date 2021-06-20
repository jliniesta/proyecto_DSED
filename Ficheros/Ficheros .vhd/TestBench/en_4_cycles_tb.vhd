----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 18.11.2020 12:34:39
-- Module Name: Interfaz de audio
-- Design Name: Generador de enables y salida de reloj del microfono
-- File Name: en_4_cycles_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: TestBench para comprobar el correcto funcionamiento de las señales de
--              salida clk_3megas, en_2_ciclos y en_4_ciclos
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity en_4_cycles_tb is
end en_4_cycles_tb;

architecture Behavioral of en_4_cycles_tb is

--component declaration
component en_4_cycles Port ( 
            clk_12megas : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_3megas : out STD_LOGIC;
            en_2_ciclos : out STD_LOGIC;
            en_4_ciclos : out STD_LOGIC);
end component;

--input signal declaration
signal reset, clk_12megas: STD_LOGIC;

--output signals declaration
signal clk_3megas, en_2_ciclos, en_4_ciclos: STD_LOGIC;

-- Clock period definitions
constant clk_period : time := 83.33 ns;

begin

uut: en_4_cycles PORT MAP (
        reset=>reset,
        clk_12megas=>clk_12megas,
        clk_3megas=>clk_3megas,
        en_2_ciclos=>en_2_ciclos,
        en_4_ciclos=>en_4_ciclos);

-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk_12megas <= '0';
    wait for clk_period/2;
    clk_12megas <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin     
  
    reset<='1';
    wait for 50 ns;
    reset<='0';
    wait for 3 us;

end process;

end Behavioral;
