----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 24.01.2021 23:35:40
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Rom para el display
-- File Name: rom_display.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Creacción de una rom, que almacena el valor de los segmentos del display, 
--               para el caso de las decenas y unidades del contador de segundos restantes de grabaccion
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_display is
    Port ( time_recorded : in UNSIGNED(4 DOWNTO 0);
           decenas_disp : out STD_LOGIC_VECTOR (6 downto 0);
           unidades_disp : out STD_LOGIC_VECTOR (6 downto 0));
end rom_display;

architecture Behavioral of rom_display is

-- ROM DE LAS UNIDADES

type rom_unidades is array (0 to 2**4-6) of std_logic_vector (6 downto 0);

constant MY_ROM_unidades : rom_unidades := (
    0 => "1000000",
    1 => "1111001",
    2 => "0100100",
    3 => "0110000",
    4 => "0011001",
    5 => "0010010",
    6 => "0000010",
    7 => "1111000",
    8 => "0000000",
    9 => "0010000",
    10 => "0111111"
    );

-- ROM DE LAS DECENAS

type rom_decenas is array (0 to 2**2-1) of std_logic_vector (6 downto 0);

constant MY_ROM_decenas : rom_decenas := (
    0 => "1000000",
    1 => "1111001",
    2 => "0100100",
    3 => "0111111"
    );
    
signal aux : std_logic_vector (4 downto 0);

begin
    
process (time_recorded)
begin
    aux <= std_logic_vector(26 - time_recorded); -- Tiempo restante de grabaccion
end process;
    
process (aux)
begin

-- Dependiendo de los segundos restantes, se selecciona el valor adecuado 
-- de las unidades y decenas que debe aparecer en el display

    case aux is 
        when "00000" => 
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(0);
        when "00001" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(1);
        when "00010" => 
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(2);
        when "00011" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(3); 
        when "00100" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(4); 
        when "00101" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(5);
        when "00110" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(6);
        when "00111" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(7);
        when "01000" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(8);
        when "01001" =>
            decenas_disp <= MY_ROM_decenas(0);
            unidades_disp <= MY_ROM_unidades(9);
        when "01010" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(0);
        when "01011" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(1);
        when "01100" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(2);
        when "01101" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(3);
        when "01110" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(4);
        when "01111" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(5);
        when "10000" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(6);
        when "10001" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(7);
        when "10010" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(8);
        when "10011" =>
            decenas_disp <= MY_ROM_decenas(1);
            unidades_disp <= MY_ROM_unidades(9);
        when "10100" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(0);
        when "10101" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(1);
        when "10110" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(2);
        when "10111" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(3);
        when "11000" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(4);
        when "11001" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(5);
        when "11010" =>
            decenas_disp <= MY_ROM_decenas(2);
            unidades_disp <= MY_ROM_unidades(6);
        when others =>
            decenas_disp <= MY_ROM_decenas(3);
            unidades_disp <= MY_ROM_unidades(10);
    end case;
end process;

end Behavioral;
