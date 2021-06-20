----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 10.01.2021 12:46:17
-- Module Name: Conversor de complemento a 2 a binario
-- Design Name: Converter ca2 into binary
-- File Name: converter_ca2_bin.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Conversor que recibe los datos en complemento a 2 y los pasa binario
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity converter_ca2_bin is
    Port ( ca2_in : in SIGNED (sample_size -1 downto 0);
           bin_out : out STD_LOGIC_VECTOR (sample_size -1 downto 0));
end converter_ca2_bin;

architecture Behavioral of converter_ca2_bin is

begin

-- Invierte el bit mas significativo
bin_out <= STD_LOGIC_VECTOR ((not ca2_in(sample_size -1)) & ca2_in( sample_size -2 downto 0));

end Behavioral;
