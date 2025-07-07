module Memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,

    input  wire        rd_en_i,    // Indica uma solicitação de leitura
    input  wire        wr_en_i,    // Indica uma solicitação de escrita

    input  wire [31:0] addr_i,     // Endereço
    input  wire [31:0] data_i,     // Dados de entrada (para escrita)
    output wire [31:0] data_o,     // Dados de saída (para leitura)

    output wire        ack_o       // Confirmação da transação
);

	// declaração do array de memória.
    reg [31:0] mem_array [0:MEMORY_SIZE-1];

    // registro temporário para a saída de leitura, para garantir latência de 1 ciclo se necessário
    reg [31:0] data_o_reg;

    // inicialização da memória a partir de um arquivo, se fornecido.
    initial begin
        if (MEMORY_FILE != "") begin
            $readmemh(MEMORY_FILE, mem_array); // Lê o arquivo hexadecimal para a memória [47, 48]
        end 
    end

    // lógica de escrita e leitura síncrona da memória.
    always @(posedge clk) begin
        if (wr_en_i) begin
            mem_array[addr_i[11:0]] <= data_i; // Atribuição não-bloqueante para síncrono.
        end

        // lógica de leitura: Se rd_en_i estiver ativo, lê o dado do endereço addr_i.
        if (rd_en_i) begin
            data_o_reg <= mem_array[addr_i[11:0]]; // Atribuição não-bloqueante.
        end
    end

    // atribuição da saída de dados e acknowledge.
    assign data_o = data_o_reg;

    // ack_o sinaliza que uma operação (leitura ou escrita) está ocorrendo ou foi completada.
    assign ack_o = rd_en_i || wr_en_i;

endmodule
