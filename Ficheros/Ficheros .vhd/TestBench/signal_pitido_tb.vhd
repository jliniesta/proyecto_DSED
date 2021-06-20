----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 02.02.2021 09:18:47
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Testbench de la señal de pitido
-- File Name: signal_pitido_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Comprobacción del correcto funcionamiento de la señal triangular
--               de periodo 250 us, que actúa como un pitido
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity signal_pitido_tb is
end signal_pitido_tb;

architecture Behavioral of signal_pitido_tb is

component signal_pitido is 
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           pitido_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0));
end component;

--input signal declaration
signal reset, clk: STD_LOGIC;

--output signals declaration
signal pitido_out : STD_LOGIC_VECTOR (sample_size - 1 downto 0);

-- Clock period definitions
constant clk_period : time := 83.33 ns; -- Periodo de 12 MHz

begin

uut_signal_pitido: signal_pitido
         PORT MAP( reset => reset,
                   clk => clk,
                   pitido_out => pitido_out);            
                            
-- Clock process 
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
    wait for 100 ns;
    reset<='0';
    wait for 10 ms;

end process;

end Behavioral;
