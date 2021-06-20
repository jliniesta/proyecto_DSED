----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 18.11.2020 11:46:20
-- Module Name: Interfaz de audio
-- Design Name: Generador de enables y salida de reloj del microfono
-- File Name: en_4_cycles.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Recibe la señal del reloj global de 12 MHz y proporciona a sus
--              salidas señales que van a ser utilizadas para temporizar el 
--              resto de modulos de la interfaz de audio.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity en_4_cycles is
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk_3megas : out STD_LOGIC;
           en_2_ciclos : out STD_LOGIC;
           en_4_ciclos : out STD_LOGIC);
end en_4_cycles;

architecture Behavioral of en_4_cycles is

signal current_state, next_state: UNSIGNED (2 downto 0);

begin

--next state logic
process(current_state)
begin
    if(current_state = 3) then
        next_state <= "000"; --0
    else
        next_state <= current_state + 1;
    end if;
end process;

--state register
process(clk_12megas)
begin
    if(clk_12megas'event and clk_12megas= '1') then
        if(reset = '1') then
            current_state <= (others => '0'); 
        else
            current_state <= next_state;
        end if;
    end if;
end process;

--output logic
process(current_state)
begin
    
-- La salida en_2_ciclos proporciona una señal activa durante un ciclo
-- de reloj cada *dos* ciclo (equivalente a un reloj de 6 MHz)
    if((current_state = 1) or (current_state = 3)) then
        en_2_ciclos <= '1'; --1
    else
        en_2_ciclos <= '0'; --0
    end if;

-- La salida en_4_ciclos proporciona una señal activa durante un ciclo
-- de reloj cada *cuatro* ciclos
    if(current_state = 2) then
        en_4_ciclos <= '1'; --1
    else
        en_4_ciclos <= '0'; --0
    end if;
 
-- La salida clk_3megas es un reloj de 3 MHz con un duty cicle del 50%   
    if((current_state = 2) or (current_state = 3)) then
        clk_3megas <= '1'; --1
    else
        clk_3megas <= '0'; --0
    end if;

end process;

end Behavioral;
