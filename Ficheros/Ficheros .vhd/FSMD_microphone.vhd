----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 20.11.2020 12:31:13
-- Module Name: Interfaz del microfono
-- Design Name: Muestreo en el microfono
-- File Name: FSMD_microphone.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Este modulo se encarga de tomar una muestra cada 150 periodos
--              de micro_clk, es decir, cada 50 us (f = 20 kHz)
-- Dependencies: 
-- Revision: v2.1
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity FSMD_microphone is

    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_4_cycles : in STD_LOGIC;
           micro_data : in STD_LOGIC;
           sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready : out STD_LOGIC);
           
end FSMD_microphone;

architecture Behavioral of FSMD_microphone is

type state_type is (sample_microphone);

signal state, next_state : state_type;
signal cuenta, cuenta_next : UNSIGNED (sample_size  downto 0) := (others => '0');
signal dato1, dato1_next : UNSIGNED (sample_size - 1  downto 0) := (others => '0');
signal dato2, dato2_next : UNSIGNED (sample_size - 1  downto 0) := (others => '0');

signal sample_out_reg, sample_out_next : STD_LOGIC_VECTOR (sample_size - 1 downto 0) := (others => '0');
signal sample_out_ready_reg, sample_out_ready_next : STD_LOGIC := '0';

signal primer_ciclo, primer_ciclo_next  : std_logic := '0';
begin

--state and data registers
process (clk_12megas, reset)
    begin
    if reset='1' then -- Si hay un reset se ponen a 0 los registros
        cuenta <= (others => '0');
        dato1 <= (others => '0');
        dato2 <= (others => '0');
        primer_ciclo <= '0';
        sample_out_ready_reg <= '0';
        sample_out_reg <= (others => '0');    
    elsif (rising_edge(clk_12megas)) then
        if (enable_4_cycles = '1') then
           state <= next_state;
           cuenta <= cuenta_next;
           dato1 <= dato1_next;
           dato2 <= dato2_next;
           sample_out_ready_reg <= sample_out_ready_next;
           sample_out_reg <= sample_out_next;
           primer_ciclo <= primer_ciclo_next;
         end if;
    end if;
end process;

--next state logic
process (state, cuenta, dato1, dato2, micro_data, sample_out_ready_reg, sample_out_reg, primer_ciclo)

begin

   cuenta_next <= cuenta;
   dato1_next <= dato1;
   dato2_next <= dato2;
   sample_out_ready_next <= sample_out_ready_reg;
   sample_out_next <= sample_out_reg;
   primer_ciclo_next <= primer_ciclo;

   case (state) is
       when sample_microphone =>
           -- Muestreo
           if (((0<=cuenta) and (cuenta<=104)) or ((149<=cuenta) and (cuenta<=254))) then
                cuenta_next <= cuenta +1;
                if (micro_data = '1') then
                    dato1_next <= dato1 + 1;
                    dato2_next <= dato2 + 1;
                end if;
                next_state <= sample_microphone;
                
           --Señal digitalizada estable del segundo contador
           elsif ((105<=cuenta) and (cuenta<=148)) then 
                cuenta_next <= cuenta + 1;
                if (micro_data = '1') then
                    dato1_next <= dato1 + 1;
                end if;
                
                -- Actualizacion de sample_out con el valor digitalizado del contador 2 
                if ((primer_ciclo = '1') and (cuenta = 105)) then
                    sample_out_next <= std_logic_vector(dato2);
                    dato2_next <= (others => '0');
                    sample_out_ready_next <= '1';
                else 
                    sample_out_ready_next <= '0';
                end if;
                next_state <= sample_microphone;
                
             else
             
                -- Reseteo de la cuenta
                if (cuenta = 299) then 
                    cuenta_next <= (others => '0');
                    primer_ciclo_next <= '1'; 
                else 
                    cuenta_next <= cuenta + 1;
                end if;
                if (micro_data = '1') then
                    dato2_next <= dato2 + 1;
                end if;
                
                -- Actualizacion de sample_out con el valor digitalizado del contador 1  
                if (cuenta = 255) then
                    sample_out_next <= std_logic_vector(dato1);
                    dato1_next <= (others => '0');
                    sample_out_ready_next <= '1';
                 else 
                    sample_out_ready_next <= '0';
                end if;
                next_state <= sample_microphone;
            end if;
    end case;    
             
end process;

--output logic
sample_out <= sample_out_reg;
sample_out_ready <= sample_out_ready_reg and enable_4_cycles;

end Behavioral;
