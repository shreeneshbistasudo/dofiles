return {
    "mfussenegger/nvim-dap",
    recommended = true,
    desc = "Debugging support. Requires language-specific adapters to be configured. (see lang extras)",

    dependencies = {
        "rcarriga/nvim-dap-ui",
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = {},
        },
        {
            "jay-babu/mason-nvim-dap.nvim",
            opts = {},
        },
        { "nvim-neotest/nvim-nio" },
    },

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },

    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local mason_dap = require("mason-nvim-dap")

        -- Setup dap-ui
        dapui.setup()
        -- Setup dap-ui
        -- Highlight for the stopped line
        vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        -- Sign definitions
        for name, sign in pairs(LazyVim.config.icons.dap) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define(
                "Dap" .. name,
                { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
            )
        end

        -- Language-specific configuration
        -- Python
        dap.adapters.python = function(cb, config)
            if config.request == "attach" then
                local port = (config.connect or config).port
                local host = (config.connect or config).host or "127.0.0.1"
                cb({
                    type = "server",
                    port = assert(port, "`connect.port` is required for a python `attach` configuration"),
                    host = host,
                    options = { source_filetype = "python" },
                })
            else
                cb({
                    type = "executable",
                    command = "python", -- Adjust to your global Python interpreter
                    args = { "-m", "debugpy.adapter" },
                    options = { source_filetype = "python" },
                })
            end
        end

        dap.configurations.python = {
            {
                type = "python",
                request = "launch",
                name = "Launch Python File",
                program = "${file}",
                pythonPath = "python", -- Adjust as needed
            },
        }

        -- Node.js
        -- Configurations for JavaScript, TypeScript, JSX, and TSX
        local node_config = {
            {
                type = "node",
                request = "launch",
                name = "Launch Node.js Program",
                program = "${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal",
            },
            {
                type = "node",
                request = "attach",
                name = "Attach to Node.js Process",
                processId = require("dap.utils").pick_process,
            },
        }

        -- Assign configurations to filetypes
        dap.configurations.javascript = node_config
        dap.configurations.typescript = node_config
        dap.configurations.javascriptreact = node_config -- for JSX
        dap.configurations.typescriptreact = node_config -- for TSX
    end,
}
