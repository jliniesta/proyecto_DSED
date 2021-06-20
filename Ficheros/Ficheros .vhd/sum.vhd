----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 16.12.2020 12:22:50
-- Module Name: Filtro FIR Configurable
-- Design Name: Sumador
-- File Name: sum.vhd
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

entity sum is
    Port ( sum_op1 : in signed (sample_size - 1 downto 0);
           sum_op2 : in signed (sample_size - 1 downto 0);
           sum_out : out signed (sample_size - 1 downto 0));
end sum;

architecture Behavioral of sum is

--signal sum_aux : signed (sample_size downto 0);

begin

-- OPCION 1: Sin considerar desbordamientos
sum_out <= sum_op1 + sum_op2; 

-- OPCION 2: Considerando desbordamientos
--sum_aux <= resize(sum_op1, 9) + resize(sum_op2, 9);
--sum_out <= sum_aux(sample_size downto 1);

end Behavioral;
