library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_cpu is
    port (
        clk        : in  std_logic;
        nreset     : in  std_logic;
        take_branch: in  std_logic;
        op         : in  std_logic_vector (6 downto 0);
        jump       : out std_logic;
        s1pc       : out std_logic;
        wpc        : out std_logic;
        wmem       : out std_logic;
        wreg       : out std_logic;
        sel_imm    : out std_logic;
        data_addr  : out std_logic;
        mem_source : out std_logic;
        imm_source : out std_logic;
        winst      : out std_logic;
        alu_mode   : out std_logic_vector (1 downto 0);
        imm_mode   : out std_logic_vector (2 downto 0)
    );
end control_cpu;

architecture arch of control_cpu is
    type estado_t is (INICIO, LEE_MEM_PC, CARGA_IR, DECODIFICA , LEE_MEM_DAT_INC_PC,
                     CARGA_RD_DE_MEM, EJECUTA_R, ESCRIBE_REG);
    signal estado_sig, estado : estado_t;

    subtype imm_mode_t is std_logic_vector (2 downto 0);
    constant IMM_CONST_4 : imm_mode_t := "000";
    constant IMM_I : imm_mode_t := "001";
    constant IMM_S : imm_mode_t := "010";
    constant IMM_B : imm_mode_t := "011";
    constant IMM_U : imm_mode_t := "100";
    constant IMM_J : imm_mode_t := "101";
begin

    registros : process (clk)
    begin
        if rising_edge(clk) then
            if not nreset then
                estado <= INICIO;
            else
                estado <= estado_sig;
            end if;
        end if;
    end process;

    logica_estado_sig : process (all)
    begin
        estado_sig <= INICIO;
        case( estado ) is
        
            when INICIO =>
                estado_sig <= LEE_MEM_PC;
            when LEE_MEM_PC =>
                estado_sig <= CARGA_IR;
            when CARGA_IR =>
                estado_sig <= DECODIFICA;
            when DECODIFICA =>
                case( op ) is
                    when OPC_LOAD =>
                        estado_sig <= LEE_MEM_DAT_INC_PC;

                    when "0110011" => --Instruccion tipo R
                        estado_sig <= EJECUTA_R;
                        
                    when EJECUTA_R =>
                        estado_sig <= LEE_MEM_PC;

                    when others =>
                        estado_sig <= INICIO;
                end case; 
            when LEE_MEM_DAT_INC_PC =>
                    estado_sig <= CARGA_RD_DE_MEM;
            when CARGA_RD_DE_MEM =>
                    estado_sig <= LEE_MEM_PC;

            when others =>
        end case ;
    end process;

    logica_salida : process (all)
    begin
        wpc <= '0';
        wmem <= '0';
        winst <= '0';
        wreg <= '0';
        jump <= '0';
        s1pc <= '0';
        alu_mode <= "00";
        imm_mode <= IMM_CONST_4;
        sel_imm <= '0';
        data_addr <= '0';
        mem_source <= '0';
        imm_source <= '0';
        case (estado) is
            when INICIO =>
                -- por defecto
            when LEE_MEM_PC =>
                data_addr <= '0';
            when CARGA_IR =>
                winst <= '1';
            when DECODIFICA =>
                -- por defecto
            when LEE_MEM_DAT_INC_PC =>
                alu_mode <= "00";
                sel_imm <= '1';
                imm_mode <= IMM_I;
                data_addr <= '1';
                wpc <= '1';
            when CARGA_RD_DE_MEM =>
                mem_source <= '1';
                wreg <= '1';

            when EJECUTAR_R => 
                alu_mode <= "10";

            when others =>
        end case;
    end process;
end arch ; -- arch