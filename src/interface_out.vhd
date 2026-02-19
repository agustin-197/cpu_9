library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_out is
    port(
    clk            :in std_logic;
    nreset         :in std_logic;

    --señales del bus conectadas a la cpu
    bus_addr       :in std_logic_vector(31 downto 0);
    bus_dms        :in std_logic_vector(31 downto 0);
    bus_tms        :in std_logic;

    --señales de salida del periferico
    dout     : out std_logic_vector(31 downto 0); -- Dato guardado
    escribir : out std_logic;                     -- Pulso de escritura
    bus_sact : out std_logic
    );
end interface_out;


architecture arch of interface_out is
    
    signal addr_match :std_logic;
    signal we_internal:std_logic;

begin
    
    --comparador de direccion
addr_match <= '1' when bus_addr = x"80000000" else '0';

    --compuerta and
we_internal <= addr_match and bus_tms;

    --bloque secuencial
process (clk)
begin
    if rising_edge(clk) then
        if nreset = '0' then
        dout     <=(others => '0');
        escribir <= '0';
        bus_sact <= '0';
    else
        escribir    <= we_internal;
        bus_sact    <= we_internal;

        if we_internal = '1' then
            dout <= bus_dms;
        end if;
        end if;
    end if;
end process;

end architecture;