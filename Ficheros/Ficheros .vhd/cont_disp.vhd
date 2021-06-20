----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 25.01.2021 11:34:50
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Controlador del display
-- File Name: cont_disp.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Creacción de un controlador de los displays, para que en cada instante de tiempo
--               solo pueda estar activado uno, con el valor adecuado
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cont_disp is
    Port ( clk : in STD_LOGIC; -- Reloj de 100 MHz
           reset: in STD_LOGIC;
           unidades_disp : in STD_LOGIC_VECTOR (6 downto 0);
           decenas_disp : in STD_LOGIC_VECTOR (6 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end cont_disp;

architecture Behavioral of cont_disp is

signal ENABLE_REG, ENABLE_NEXT : UNSIGNED(16 DOWNTO 0) := (others => '0');
signal S_REG, S_NEXT : UNSIGNED(0 DOWNTO 0) := (others => '0');
signal S : UNSIGNED(0 DOWNTO 0);

begin

--next state logic
process(ENABLE_REG, S_REG)
begin

   if (ENABLE_REG = 100000) then -- Cada 1 ms
        S_NEXT <= S_REG + 1;  -- Genera la secuencia 0,1
        ENABLE_NEXT <= (others => '0');
    else 
        ENABLE_NEXT <= ENABLE_REG +1;
        S_NEXT <= S_REG;
    end if;
end process;

--state register
process(clk, reset)
begin
    if (reset = '1') then -- Si se activa el reset, se ponen a 0 los registros
        ENABLE_REG <= (others => '0');
        S_REG <= (others => '0');
    elsif (rising_edge(clk)) then
        ENABLE_REG <= ENABLE_NEXT;
        S_REG <= S_NEXT;
    end if;
end process;

--output logic
process(S_REG, unidades_disp, decenas_disp)
begin
    if (S_REG = 0) then 
        an<="11111110"; --Se activa el display de las unidades
        seg <= unidades_disp; -- Se pone en el display los segundos de las unidades restantes
    else 
        an<= "11111101";--Se activa el display de las  decenas
        seg <= decenas_disp; -- Se pone en el display las decenas de segundos restantes
    end if;
    
end process;

end Behavioral;
