----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 01.02.2021 19:14:43
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Señal de pitido
-- File Name: signal_pitido.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Creacción de una señal triangular de periodo 250 us, que actúa como un pitido
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity signal_pitido is
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           pitido_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0));
end signal_pitido;

architecture Behavioral of signal_pitido is

signal PENDIENTE_REG, PENDIENTE_NEXT : STD_LOGIC := '1';
signal TRIANG_REG, TRIANG_NEXT : UNSIGNED(7 DOWNTO 0) := (others => '0'); 
signal ENABLE_REG, ENABLE_NEXT : UNSIGNED(3 DOWNTO 0) := (others => '0'); 

begin

--next state logic
process(TRIANG_REG, PENDIENTE_REG, ENABLE_REG)
begin
    if (PENDIENTE_REG = '1') then -- Pendiente 1 = pendiente positiva
    
        if ( ENABLE_REG = 5 ) then -- Cada 6 ciclos del reloj de 12 MHz
            TRIANG_NEXT <= TRIANG_REG + 1; -- Se suma 1 a la senal triangular
            PENDIENTE_NEXT <= '1'; -- La pendiente sigue valiendo 1
            ENABLE_NEXT <= (others => '0'); -- Se reinicia la cuenta
            
            if (TRIANG_REG = 249) then -- Si llega al maximo de la senal triangular, cambia la pendiente a 0
                PENDIENTE_NEXT <= '0';
            end if;
            
        else 
            ENABLE_NEXT <= ENABLE_REG +1; -- Se suma 1 a la cuenta
            TRIANG_NEXT <= TRIANG_REG; 
            PENDIENTE_NEXT <= '1'; -- La pendiente sigue valiendo 1
        end if;

    else  -- Pendiente 0 = pendiente negativa
    
        if ( ENABLE_REG = 5 ) then  -- Cada 6 ciclos del reloj de 12 MHz
            TRIANG_NEXT <= TRIANG_REG - 1; -- Se resta 1 a la senal triangular
            PENDIENTE_NEXT <= '0';  -- La pendiente sigue valiendo 0
            ENABLE_NEXT <= (others => '0'); -- Se reinicia la cuenta
            
            if (TRIANG_REG = 1) then -- Si llega al minimo de la senal triangular, cambia la pendiente a 1
                PENDIENTE_NEXT <= '1';
            end if;
            
        else 
            ENABLE_NEXT <= ENABLE_REG +1; -- Se suma 1 a la cuenta
            TRIANG_NEXT <= TRIANG_REG; 
            PENDIENTE_NEXT <= '0'; -- La pendiente sigue valiendo 0   
        end if;
    
    end if;    
    
end process;

--state register
process(clk, reset)
begin
    if (reset = '1') then -- Si hay un reset se ponen a 0 los registros
        TRIANG_REG <= (others => '0');
        ENABLE_REG <= (others => '0');
        PENDIENTE_REG <= '0';
    elsif (rising_edge(clk)) then 
        TRIANG_REG <= TRIANG_NEXT;
        ENABLE_REG <= ENABLE_NEXT;
        PENDIENTE_REG <= PENDIENTE_NEXT;
    end if;
end process;

--output logic
process(TRIANG_REG)
begin
    pitido_out <= std_logic_vector(TRIANG_REG); 
end process;

end Behavioral;
