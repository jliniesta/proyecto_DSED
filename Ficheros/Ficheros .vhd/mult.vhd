----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 16.12.2020 12:04:38
-- Module Name: Filtro FIR Configurable
-- Design Name: Multiplicador
-- File Name: mult.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: 
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity mult is
    Port ( mult_op1 : in signed (sample_size - 1 downto 0);
           mult_op2 : in signed (sample_size - 1 downto 0);
           mult_out : out signed (sample_size - 1 downto 0));
end mult;

architecture Behavioral of mult is

-- <1,7> * <1,7> = <2,14>
signal mult_out_aux : signed (2*sample_size - 1 downto 0); -- (15 downto 0)

begin

mult_out_aux <= mult_op1 * mult_op2; -- Se realiza la multiplacion

-- Descartamos el bit mas significativo y los 7 bits menos significativos
mult_out <= mult_out_aux (2*sample_size - 2 downto sample_size -1);

end Behavioral;
