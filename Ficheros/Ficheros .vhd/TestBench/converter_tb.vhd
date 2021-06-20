----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.12.2020 19:00:00
-- Design Name: 
-- Module Name: converter_tb - Behavioral
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


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.package_dsed.all;

entity converter_tb is
end converter_tb;

architecture Behavioral of converter_tb is

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
signal Sample_In : signed (sample_size - 1 downto 0) := (others => '0');

--output signals declaration
signal Sample_Out_ready : STD_LOGIC;
signal Sample_Out : signed (sample_size - 1 downto 0);

constant clk_period : time := 83.33 ns;

-- Files
--FILE in_file : text OPEN read_mode IS "sample_in.dat";
FILE in_file : text OPEN read_mode IS "C:\Users\Francisco Javier\OneDrive - Universidad Politécnica de Madrid\GITST\4.  CUARTO\1er CUATRIMESTRE\DSED - DISEÑO DE SISTEMAS ELECTRÓNICOS DIGITALES\Proyecto FPGA\sample_in.dat";

--FILE out_file : text OPEN write_mode IS "sample_out.dat";
FILE out_file : text OPEN write_mode IS "C:\Users\Francisco Javier\OneDrive - Universidad Politécnica de Madrid\GITST\4.  CUARTO\1er CUATRIMESTRE\DSED - DISEÑO DE SISTEMAS ELECTRÓNICOS DIGITALES\Proyecto FPGA\sample_out.dat";

signal endf: boolean := false;

begin

uut_fir_filter: fir_filter PORT MAP(
    clk=>clk,
    Reset=>Reset,
    Sample_In=>Sample_In,
    Sample_In_enable=>Sample_In_enable,
    filter_select=>filter_select,
    Sample_Out=>Sample_Out,
    Sample_Out_ready=>Sample_Out_ready);

-- Clock statement
clk <= not clk after clk_period/2;

sample_in_clock: process
begin
    Sample_In_enable <= '0';
    wait for 10*clk_period;
    Sample_In_enable <= '1';
    wait for clk_period;
end process;

read_process : PROCESS (clk)
    VARIABLE in_line : line;
    VARIABLE in_int : integer;
    VARIABLE in_read_ok : BOOLEAN;
    
BEGIN
    if rising_edge(clk) then
        if (Sample_In_enable = '1') then
            if NOT endfile(in_file) then
                ReadLine(in_file,in_line);
                Read(in_line, in_int, in_read_ok);
                sample_in <= to_signed(in_int, 8); -- 8 = the bit width
            else
                endf <= true;
            end if;
        end if;
     end if;
end process;

write_process : PROCESS (clk)
    VARIABLE out_line : line;
    VARIABLE out_int : integer;
    
BEGIN
    if rising_edge(clk) then
        if endf = false then
            if (Sample_Out_ready = '1') then
                out_int := to_integer(sample_out); 
                Write(out_line, out_int);
                WriteLine(out_file,out_line);
            end if;
        else
            file_close(out_file);
            --assert false report "Simulation Finished" severity note;
        end if;
    end if;
end process;

end Behavioral;