return {
    'Decodetalkers/csharpls-extended-lsp.nvim',
    config = function()
        require("csharpls_extended").buf_read_cmd_bind()
    end
}
