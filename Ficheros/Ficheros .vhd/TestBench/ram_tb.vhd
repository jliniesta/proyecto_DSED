----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 26.12.2020 16:54:22
-- Module Name: Filtro FIR Configurable
-- Design Name: Testbench de la memoria RAM
-- File Name: ram_tb.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Testbench para comprobar el funcionamiento de la memoria RAM
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity ram_tb is
end ram_tb;

architecture Behavioral of ram_tb is

component ram_mem_project is
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
end component;

signal clka, ena : STD_LOGIC := '0';
signal wea : STD_LOGIC_VECTOR (0 downto 0) := (others => '0');
signal addra : STD_LOGIC_VECTOR (18 downto 0) := (others => '0');
signal dina, douta : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

constant clk_period : time := 83.33 ns; -- Periodo de 12 MHz

begin

-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clka <= '0';
    wait for clk_period/2;
    clka <= '1';
    wait for clk_period/2;
end process;

uut_ram: ram_mem_project 
    port map( 
    clka => clka,
    ena => ena,
    wea => wea,
    addra => addra,
    dina => dina,
    douta => douta);
    
 -- Stimulus process
stim_proc: process
begin 
     
    ena <= '1'; -- Se habilita la RAM
    wea <= "1"; -- Escritura  
    addra <= "0000000000000011000"; -- Direccion de escritura
    dina <= "01010000"; -- Dato a escribir
    wait for clk_period;
    addra <= "0000000000000001000"; -- Direccion de escritura
    dina <= "00001100"; -- Dato a escribir
    wait for clk_period;
    wea <= "0"; -- Lectura
    addra <= "0000000000000011000"; -- Direccion de lectura
    wait for 10*clk_period;    

end process;

end Behavioral;
