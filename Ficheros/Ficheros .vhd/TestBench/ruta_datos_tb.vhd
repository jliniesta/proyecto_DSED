----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 18.12.2020 12:02:45
-- Module Name: Filtro FIR Configurable
-- Design Name: Testbench de la ruta de datos del filtro FIR de 5 etapas
-- File Name: ruta_datos_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Testbench para comprobar el correcto funcionamiento de la ruta de
--              datos del filtro FIR de 5 etapas.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity ruta_datos_tb is
end ruta_datos_tb;

architecture Behavioral of ruta_datos_tb is

component fir_filter is
    Port ( clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Sample_In : in signed (sample_size - 1 downto 0);
           Sample_In_enable : in STD_LOGIC;
           filter_select : in STD_LOGIC;
           Sample_Out : out signed (sample_size - 1 downto 0);
           Sample_Out_ready : out STD_LOGIC);
end component;

--input signal declaration
signal Reset, clk, Sample_In_enable, filter_select : STD_LOGIC := '0';
signal Sample_In : signed (sample_size - 1 downto 0):= (others => '0');

--output signals declaration
signal Sample_Out_ready : STD_LOGIC;
signal Sample_Out : signed (sample_size - 1 downto 0);

-- Clock period definitions
constant clk_period : time := 83.33 ns;

begin

uut_fir_filter: fir_filter PORT MAP(
    clk=>clk,
    Reset=>Reset,
    Sample_In=>Sample_In,
    Sample_In_enable=>Sample_In_enable,
    filter_select=>filter_select,
    Sample_Out=>Sample_Out,
    Sample_Out_ready=>Sample_Out_ready);
    
-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin     
  
    reset<='1';
    filter_select <= '0';
    wait for 50 ns;
    reset<='0';
    Sample_In_enable <= '1';
    Sample_In <= "01010101";
    wait for  420 ns;

end process;

end Behavioral;
