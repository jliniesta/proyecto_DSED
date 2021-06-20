----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 10.01.2021 12:38:47
-- Module Name: Conversor de binario a complemento a 2
-- Design Name: Converter binary into ca2
-- File Name: converter_bin_ca2.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Conversor que recibe los datos en binario y los pasa a complemento a 2
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity converter_bin_ca2 is
    Port ( bin_in : in STD_LOGIC_VECTOR (sample_size -1 downto 0);
           ca2_out : out signed (sample_size - 1 downto 0));
end converter_bin_ca2;

architecture Behavioral of converter_bin_ca2 is

begin

-- Invierte el bit mas significativo
ca2_out <= signed((not bin_in(sample_size -1)) & bin_in(sample_size -2 downto 0));

end Behavioral;
