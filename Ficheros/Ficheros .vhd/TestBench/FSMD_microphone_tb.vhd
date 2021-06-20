----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 25.11.2020 12:08:47
-- Module Name: Interfaz del microfono
-- Design Name: Muestreo en el microfono
-- File Name: FSMD_microphone_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: TestBench para comprobar el correcto funcionamiento del muestreo de las señales, el incremento 
--              de cuenta, dato1 y dato2, primer ciclo y de las salidas sample_out y sample_out_ready  
-- Dependencies: 
-- Revision: v2.1
-- Additional Comments: Comentar y descomentar las lineas correspondientes en cada caso
--                      Opcion 1: micro_data <= 1 (fijo)
--                      Opcion 2: micro_data es una señal pseudoaleatoria
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity FSMD_microphone_tb is
end FSMD_microphone_tb;

architecture Behavioral of FSMD_microphone_tb is

--components declarations
component FSMD_microphone
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_4_cycles : in STD_LOGIC;
           micro_data : in STD_LOGIC;
           sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready : out STD_LOGIC);
end component;

component en_4_cycles
    Port ( 
            clk_12megas : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_3megas : out STD_LOGIC;
            en_2_ciclos : out STD_LOGIC;
            en_4_ciclos : out STD_LOGIC);
end component;

--input signal declaration
signal reset, enable_4_cycles, clk_12megas, micro_data: STD_LOGIC;

--output signals declaration
signal sample_out: STD_LOGIC_VECTOR (sample_size - 1 downto 0);
signal sample_out_ready, clk_3megas, en_2_ciclos : STD_LOGIC;

--Opcion b): input signals for generating random signal micro_data
signal a,b,c : STD_LOGIC := '0';

-- Clock period definitions
constant clk_period : time := 83.33 ns;

begin

uut_enable: en_4_cycles
    PORT MAP (
        reset=>reset,
        clk_12megas=>clk_12megas,
        clk_3megas=>clk_3megas,
        en_2_ciclos=>en_2_ciclos,
        en_4_ciclos=>enable_4_cycles);

uut_microphone : FSMD_microphone
    PORT MAP (
    clk_12megas => clk_12megas,
    reset => reset,
    enable_4_cycles => enable_4_cycles,
    micro_data => micro_data,
    sample_out => sample_out,
    sample_out_ready => sample_out_ready);

-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk_12megas <= '0';
    wait for clk_period/2;
    clk_12megas <= '1';
    wait for clk_period/2;
end process;

-- Opcion b): micro_data es una señal pseudo-aleatoria
a <= not a after 1300 ns;
b <= not b after 2100 ns;
c <= not c after 3700 ns;
micro_data <= a xor b xor c;   

-- Stimulus process
stim_proc: process
begin
--    Opcion a): micro_data es una señal fija a '1'
--    micro_data<='1';
    reset<='1';
    wait for 200 ns;      
    reset<='0';
    wait for 500 us;      
end process;

end Behavioral;
