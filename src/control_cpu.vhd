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
        jalr_jump  : out std_logic;
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
    type estado_t is (INICIO, LEE_MEM_PC, CARGA_IR, DECODIFICA, LEE_MEM_DAT_INC_PC, CARGA_RD_DE_MEM,
                     EJECUTA_R,
                     EJECUTA_I,
                     CALC_DIR_STORE, ESCRIBE_MEM,STORE_UPDATE,
                     BRANCH_EVAL, EJECUTA_U,
                     EJECUTA_J, J_UPDATE,
                     EJECUTA_AUIPC, EJECUTA_JALR, JALR_UPDATE);
    signal estado_sig, estado : estado_t;

    subtype imm_mode_t is std_logic_vector (2 downto 0);
    constant IMM_CONST_4 : imm_mode_t := "000";
    constant IMM_I : imm_mode_t := "001";
    constant IMM_S : imm_mode_t := "010";
    constant IMM_B : imm_mode_t := "011";
    constant IMM_U : imm_mode_t := "100";
    constant IMM_J : imm_mode_t := "101";

    -- Constantes de OPCODE
    constant OPC_LOAD        :std_logic_vector(6 downto 0) := "0000011";
    constant OPC_IMM         :std_logic_vector(6 downto 0) := "0010011";
    constant OPC_ARITMETICAS :std_logic_vector(6 downto 0) := "0110011";
    constant OPC_JALR        :std_logic_vector(6 downto 0) := "1100111";
    constant OPC_STORE       :std_logic_vector(6 downto 0) := "0100011";
    constant OPC_BRANCH      :std_logic_vector(6 downto 0) := "1100011";
    constant OPC_LUI         :std_logic_vector(6 downto 0) := "0110111";
    constant OPC_AUIPC       :std_logic_vector(6 downto 0) := "0010111";
    constant OPC_JUMP        :std_logic_vector(6 downto 0) := "1101111";

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

                    --Instruccion tipo R
                    when OPC_ARITMETICAS => 
                        estado_sig <= EJECUTA_R;

                    --Instrucciones tipo I
                    when OPC_IMM =>
                        estado_sig <= EJECUTA_I;
                    
                    when OPC_JALR =>
                        estado_sig <= EJECUTA_JALR;
                   
                    --Instruciones tipo S
                    when OPC_STORE =>
                        estado_sig <= CALC_DIR_STORE;
                    
                    --TIPO B
                    when OPC_BRANCH =>
                        estado_sig <= BRANCH_EVAL;

                    --TIPO U
                    when OPC_LUI =>
                        estado_sig <= EJECUTA_U;
                    
                    when OPC_AUIPC =>
                        estado_sig <= EJECUTA_AUIPC;

                    --TIPO J
                    when OPC_JUMP =>
                        estado_sig <= EJECUTA_J;

                    --OTRO CASO
                    when others =>
                        estado_sig <= INICIO;
                end case; 
            when LEE_MEM_DAT_INC_PC =>
                    estado_sig <= CARGA_RD_DE_MEM;

            when CARGA_RD_DE_MEM =>
                    estado_sig <= LEE_MEM_PC;
            --TIPO R
            when EJECUTA_R =>
                    estado_sig <= LEE_MEM_PC;

            --TIPO I
            when EJECUTA_I =>
                    estado_sig <= LEE_MEM_PC;

            when EJECUTA_JALR =>
                    estado_sig <= JALR_UPDATE;
            
            when JALR_UPDATE =>
                    estado_sig <= LEE_MEM_PC;

            --TIPO S
            when CALC_DIR_STORE =>
                    estado_sig <= ESCRIBE_MEM;
            
            when ESCRIBE_MEM =>
                    estado_sig <= STORE_UPDATE;

            when STORE_UPDATE =>
                    estado_sig <= LEE_MEM_PC;

            --TIPO B
            when BRANCH_EVAL =>
                    estado_sig <= LEE_MEM_PC;

            --TIPO U
            when EJECUTA_U =>
                    estado_sig <= LEE_MEM_PC;
            
            when EJECUTA_AUIPC =>
                    estado_sig <= LEE_MEM_PC;

            --TIPO J
            when EJECUTA_J =>
                    estado_sig <= J_UPDATE;
            
            when J_UPDATE =>
                    estado_sig <= LEE_MEM_PC;

            --OTRO CASO
            when others =>
                estado_sig <= INICIO;
        end case ;
    end process;

    logica_salida : process (all)
    begin
        wpc <= '0';
        wmem <= '0';
        winst <= '0';
        wreg <= '0';
        jump <= '0';
        jalr_jump <= '0';
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
                
            -- TIPO R
            when EJECUTA_R =>
                alu_mode <= "10";--modo R
                wreg <= '1';--escribir resultado
                mem_source <= '0'; --decir al mux que el dato viene de ALU, no de memoria
                --actualizacion de PC
                wpc <= '1';  -- escribe PC
                            
            --TIPO I
            when EJECUTA_I =>
                alu_mode <= "01";
                sel_imm <= '1';
                imm_mode <= IMM_I;
                wreg <= '1';
                wpc <= '1';

            when EJECUTA_JALR =>
                s1pc <= '1';       
                sel_imm <= '1';    
                imm_mode <= IMM_CONST_4;
                alu_mode <= "00";  
                wreg <= '1';       
                wpc <= '0';        

            when JALR_UPDATE =>
             imm_mode <= IMM_I; 
             s1pc <= '0';       
             sel_imm <= '1';    
             alu_mode <= "00";  
             jalr_jump <= '1';  
             wpc <= '1';
                
            --TIPO S
            when CALC_DIR_STORE =>
                alu_mode <= "00"; --suma para calcular direccion
                sel_imm <= '1'; 
                imm_mode <= IMM_S; --inmediato tipo S

            when ESCRIBE_MEM =>
                alu_mode <= "00";
                sel_imm <= '1';
                imm_mode <= IMM_S;
            
                wmem <= '1'; --escribir ram
                data_addr <= '1';--usar direccion de alu
                --actualizacion de PC
                wpc <= '0';  -- escribe PC

            when STORE_UPDATE =>
                wpc <= '1';
                
            --TIPO B
            when BRANCH_EVAL =>
                alu_mode <= "11";--resta (SUB) para comparar
                sel_imm <= '0'; --compara rs1 y rs2 
                wpc <= '1'; 
                jump <= take_branch; --cpu decide si saltar
                imm_mode <= IMM_B;

            --TIPO U
            when EJECUTA_U =>
                alu_mode <= "00";
                sel_imm <= '1';
                imm_mode <= IMM_U;
                wreg <= '1';
                wpc <= '1';

            when EJECUTA_AUIPC =>
                s1pc <= '1';       
                sel_imm <= '1';    
                imm_mode <= IMM_U;
                alu_mode <= "00";  
                wreg <= '1';       
                wpc <= '1';        

            --TIPO J
            when EJECUTA_J =>
                s1pc <= '1';
                sel_imm <= '1';
                imm_mode <= IMM_CONST_4;
                alu_mode <= "00";
                wreg <= '1';
                mem_source <= '0';
                wpc <= '0';                         
                                           
            when J_UPDATE =>
                imm_mode <= IMM_J;
                jump <= '1';
                wpc <= '1';
                
            when others =>
        end case;
    end process;
end arch ; -- arch