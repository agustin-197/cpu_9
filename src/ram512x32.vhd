library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram512x32 is
    generic(
        constant archivo_init : string := ""
    );
    port (
        clk     : in  std_logic;
        we      : in  std_logic;
        mask   : in  std_logic_vector(3 downto 0);
        addr    : in  std_logic_vector(8 downto 0);
        din     : in  std_logic_vector(31 downto 0);
        dout    : out std_logic_vector(31 downto 0)
    );
end entity ram512x32;

architecture behavioral of ram512x32 is
    type ram_type is array (0 to 511) of std_logic_vector(31 downto 0);

    impure function ram_init return ram_type is
        variable contenido : ram_type := (others=>(others=>'0'));
        file harchivo_init : text;
        variable linea : line;
        variable palabra : std_logic_vector(31 downto 0);
        variable status : file_open_status;
        variable valid : boolean;
        variable i : integer := 0;
    begin
        file_open(status,harchivo_init,archivo_init,read_mode);
        if status = open_ok then
            while not endfile(harchivo_init) loop
                readline(harchivo_init, linea);
                hread(linea, palabra, valid);
                if valid then
                    contenido(i) := palabra;
                    i := i + 1;
                end if;
            end loop;
            report "Inicializadas " & integer'image(i) 
                   & " palabras de ram desde " & archivo_init
                severity note;
        end if;
        return contenido;
    end function;

    signal ram : ram_type := ram_init;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                for i in 0 to 3 loop
                    if mask(i) = '1' then
                        ram(to_integer(unsigned(addr)))(i*8 + 7 downto i*8) <= din(i*8 + 7 downto i*8);
                    end if;
                end loop;
            end if;
            dout <= ram(to_integer(unsigned(addr)));
        end if;
    end process;
end architecture behavioral;