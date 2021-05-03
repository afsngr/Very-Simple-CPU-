`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2020 22:45:57
// Design Name: 
// Module Name: VerySimpleCPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module VerySimpleCPU ( clk , rst , data_fromRAM , wrEn , addr_toRAM , data_toRAM ) ;
    
parameter SIZE = 14;
input clk , rst ;
input wire [31:0] data_fromRAM ;
output reg wrEn ;
output reg [SIZE -1:0] addr_toRAM ;
output reg [31:0] data_toRAM ;

reg [3:0] state_current , state_next ;
reg [SIZE -1:0] pc_current , pc_next ; // pc: program counter
reg [31:0] iw_current , iw_next ; // iw: instruction word
reg [31:0] r1_current , r1_next ;
reg [31:0] r2_current , r2_next ;

always@ ( posedge clk ) begin
    if(rst ) begin
        state_current <= 0;
        pc_current <= 14'b0;
        iw_current <= 32'b0;
        r1_current <= 32'b0;
        r2_current <= 32'b0;
    end
    else begin
        state_current <= state_next ;
        pc_current <= pc_next ;
        iw_current <= iw_next ;
        r1_current <= r1_next ;
        r2_current <= r2_next ;
    end    
end

always @(*) begin
    state_next = state_current ;
    pc_next = pc_current ;
    iw_next = iw_current ;
    r1_next = r1_current ;
    r2_next = r2_current ;
    wrEn = 0;
    addr_toRAM = 0;
    data_toRAM = 0;
    case ( state_current )
        0: begin
            pc_next = 0;
            iw_next = 0;
            r1_next = 0;
            r2_next = 0;
            state_next = 1;
        end
        1: begin // Reset'ten sonraki ilk islem
            addr_toRAM = pc_current ;  // PC'yi RAM'den okudum
            state_next = 2;
        end
        
        2: begin //RAM'den 
            iw_next = data_fromRAM ; // RAM'den PC'nin gosterdigi instruction geldi
            case ( data_fromRAM [31:28]) // Opcode'unu aldým
                {3'b000, 1'b0 }: begin // ADD
                    addr_toRAM = data_fromRAM [27:14]; // RAM'den R1'i okudum. Instruction set'den geldi 
                    state_next = 3;
                end
                    {3'b000, 1'b1 }: begin // ADDi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 4; // Cunku R2 icin RAM'e gitmeme gerek yok
                    r2_next = data_fromRAM [13:0]; // r2 data'si IW icinde geldi 
                end
                {3'b001, 1'b0 }: begin // NAND
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3;
                end
                {3'b001, 1'b1 }: begin // NANDi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 4; // Cunku R2 icin RAM'e gitmeme gerek yok
                    r2_next = data_fromRAM [13:0];  // r2 data'si IW icinde geldi
                end
                {3'b010, 1'b0 }: begin // SRL
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3;
                end
                {3'b010, 1'b1 }: begin // SRLi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 4; // Cunku R2 icin RAM'e gitmeme gerek yok
                    r2_next = data_fromRAM [13:0];  // r2 data'si IW icinde geldi
                end
                {3'b011, 1'b0 }: begin // LT
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3;
                end
                {3'b011, 1'b1 }: begin // LTi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 4; // Cunku R2 icin RAM'e gitmeme gerek yok
                    r2_next = data_fromRAM [13:0];  // r2 data'si IW icinde geldi
                end
                {3'b111, 1'b0 }: begin // MUL
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3;
                end
                {3'b111, 1'b1 }: begin // MULi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 4; // Cunku R2 icin RAM'e gitmeme gerek yok
                    r2_next = data_fromRAM [13:0];  // r2 data'si IW icinde geldi
                end
                //DATA TRANSFER INSTRUCTIONS
                {3'b100, 1'b0 }: begin // CP
                    addr_toRAM = data_fromRAM [13:0];//R2yi okuyorum.
                    state_next = 4;//
                    end
                {3'b100, 1'b1 }: begin // CPi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = iw_current [13:0]; //  Gelen datayi R1'e yazacam
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum
                    end
                {3'b101, 1'b0 }: begin // CPI
                    addr_toRAM = data_fromRAM [13:0];
                    state_next = 3;
                    end
                {3'b101, 1'b1 }: begin // CPIi
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3; 
                    end
                {3'b110, 1'b0 }: begin // BZJ
                    addr_toRAM = data_fromRAM [27:14];
                    state_next = 3;
                    end
                {3'b110, 1'b1 }: begin // BZJi
                    addr_toRAM = data_fromRAM [27:14];
                    r2_next = data_fromRAM [13:0];
                    state_next = 4;
                    end                                                                                                                                                                                                                                   
            default : begin
                pc_next = pc_current ;
                state_next = 1;
                end
            endcase
        end
        
        3: begin//fetch etmek için
            case(iw_current [31:28])
            {3'b101, 1'b0 }: begin // CPI - Gelen data baska adres gosteriyor
                r1_next = data_fromRAM ; // Ramden gelen datayi, r1'e kaydettim
                addr_toRAM = data_fromRAM; // Gelen data adres gosteriyor. O adresteki datayi okuyorum
                state_next = 4;               
            end
            default: begin
                r1_next = data_fromRAM ; // Ramden gelen datayi, r1'e kaydettim
                addr_toRAM = iw_current [13:0]; // RAM'den R2'yi okudum
                state_next = 4;
            end  
            endcase
        end
        
        4: begin
            case ( iw_current [31:28])
                {3'b000 ,1'b0 }: begin // ADD
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = data_fromRAM + r1_current ; // R2 hala data_fromRAM'den gelmis bekliyor. Add iþlemini burada yapiyorum.
                    // R1 = r1_current
                    // R2 = data_fromRAM                 
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b000 ,1'b1 }: begin //ADDi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = data_fromRAM + r2_current ; // R1 hala data_fromRAM'den gelmis bekliyor. Addi iþlemini burada yapiyorum.
                    // R1 = data_fromRAM
                    // R2 = r2_current                
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b001 ,1'b0 }: begin // NAND
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = ~(data_fromRAM && r1_current) ; // R2 hala data_fromRAM'den gelmis bekliyor. NAND iþlemini burada yapiyorum. 
                    // R1 = r1_current
                    // R2 = data_fromRAM                
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b001 ,1'b1 }: begin //NANDi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = ~(data_fromRAM && r2_current) ; // R1 hala data_fromRAM'den gelmisbekliyor. NANDi iþlemini burada yapiyorum.
                    // R1 = data_fromRAM
                    // R2 = r2_current                 
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end 
                {3'b010 ,1'b0 }: begin // SRL
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = (data_fromRAM < 32) ? (r1_current >> data_fromRAM) : (r1_current << (data_fromRAM-32)); // R2 hala data_fromRAM'den gelmis bekliyor. SRL iþlemini burada yapiyorum.                
                    // R1 = r1_current
                    // R2 = data_fromRAM 
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end 
                {3'b010 ,1'b1 }: begin //SRLi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = (r2_current < 32) ? (data_fromRAM >> r2_current) : (data_fromRAM << (r2_current-32)) ;// R1 hala data_fromRAM'den gelmisbekliyor. SRLi iþlemini burada yapiyorum.                
                    // R1 = data_fromRAM
                    // R2 = r2_current                     
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.            
                    end 
                {3'b011 ,1'b0 }: begin // LT
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = (r1_current < data_fromRAM) ? 1 : 0; // R2 hala data_fromRAM'den gelmisbekliyor. LT iþlemini burada yapiyorum. 
                    // R1 = r1_current
                    // R2 = data_fromRAM                
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b011 ,1'b1 }: begin //LTi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = (data_fromRAM < r2_current) ? 1 : 0 ;// R1 hala data_fromRAM'den gelmisbekliyor. LTi islemini burada yapiyorum.  
                    // R1 = data_fromRAM
                    // R2 = r2_current               .                
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.            
                    end
                {3'b111 ,1'b0 }: begin // MUL
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = r1_current * data_fromRAM; // R2 hala data_fromRAM'den gelmis bekliyor. MUL islemini burada yapiyorum.
                    // R1 = r1_current
                    // R2 = data_fromRAM                 
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b111 ,1'b1 }: begin //MULi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = (data_fromRAM * r2_current);// R1 hala data_fromRAM'den gelmis bekliyor. MULi islemini  burada yapiyorum. 
                    // R1 = data_fromRAM
                    // R2 = r2_current                
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.            
                    end
                //DATA TRANSFER INSTRUCTIONS
                {3'b100 ,1'b0 }: begin // CP
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu R1'e yaziyorum
                    data_toRAM = data_fromRAM; //  R2'yi R1'e kopyaladim
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b101 ,1'b0 }: begin // CPI
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = iw_current [27:14]; // Sonucu memory'e yaziyorum
                    data_toRAM = data_fromRAM; // En son adresten gelen data 
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b101 ,1'b1 }: begin // CPIi
                    wrEn = 1; // RAM'e yazma aktif
                    addr_toRAM = r1_current; // Sonucu R1'in gosterdigi adrese yaziyorum
                    data_toRAM = data_fromRAM; // R2 datasini, memory'de R1 adresine yazdim
                    pc_next = pc_current + 1'b1; // PC'yi 1 arttirdim 
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b110 ,1'b0 }: begin // BZJ
                    // Burada RAM'e yazma yok. Sadece PC nin yeni degerini belirliyoruz
                    pc_next = (data_fromRAM == 0) ? r1_current : (pc_current + 1);
                    // R1 = r1_current
                    // R2 = data_fromRAM  
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end
                {3'b110 ,1'b1 }: begin // BZJi
                    // Burada RAM'e yazma yok. Sadece PC nin yeni deger belirliyoruz
                    pc_next = data_fromRAM + r2_current;
                    // R1 = data_fromRAM
                    // R2 = r2_current  
                    state_next = 1; // RAM'den okumaya geri dondum.
                    end                                                                                                                                                                                                                                                  
            endcase
        end
    endcase
end

endmodule