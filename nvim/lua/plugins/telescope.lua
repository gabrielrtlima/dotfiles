-- return {
--   {
--     "telescope.nvim",
--     dependencies = {
--       {
--         "nvim-telescope/telescope-fzf-native.nvim",
--         build = "make",
--       },
--       "nvim-telescope/telescope-file-browser.nvim",
--     },
--     keys = {
--       {
--         "<leader>fP",
--         function()
--           require("telescope.builtin").find_files({
--             cwd = require("lazy.core.config").options.root,
--             previewer = false,
--           })
--         end,
--         desc = "Find Plugin File",
--       },
--       {
--         ";f",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.find_files({
--             no_ignore = false,
--             hidden = true,
--             previewer = false,
--           })
--         end,
--         desc = "Lists files in your current working directory, respects .gitignore",
--       },
--       {
--         ";r",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.live_grep()
--         end,
--         desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
--       },
--       {
--         "\\\\",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.buffers()
--         end,
--         desc = "Lists open buffers",
--       },
--       {
--         ";t",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.help_tags()
--         end,
--         desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
--       },
--       {
--         ";;",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.resume()
--         end,
--         desc = "Resume the previous telescope picker",
--       },
--       {
--         ";e",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.diagnostics()
--         end,
--         desc = "Lists Diagnostics for all open buffers or a specific buffer",
--       },
--       {
--         ";s",
--         function()
--           local builtin = require("telescope.builtin")
--           builtin.treesitter()
--         end,
--         desc = "Lists Function names, variables, from Treesitter",
--       },
--       {
--         "sf",
--         function()
--           local telescope = require("telescope")
--
--           local function telescope_buffer_dir()
--             return vim.fn.expand("%:p:h")
--           end
--
--           telescope.extensions.file_browser.file_browser({
--             path = "%:p:h",
--             cwd = telescope_buffer_dir(),
--             respect_gitignore = false,
--             hidden = true,
--             grouped = true,
--             previewer = false,
--             initial_mode = "normal",
--             layout_config = { height = 40 },
--           })
--         end,
--         desc = "Open File Browser with the path of the current buffer",
--       },
--     },
--     config = function(_, opts)
--       local telescope = require("telescope")
--       local actions = require("telescope.actions")
--       local fb_actions = require("telescope").extensions.file_browser.actions
--
--       opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
--         wrap_results = true,
--         layout_strategy = "horizontal",
--         layout_config = { prompt_position = "top" },
--         sorting_strategy = "ascending",
--         winblend = 0,
--         mappings = {
--           n = {},
--         },
--       })
--       opts.pickers = {
--         diagnostics = {
--           theme = "ivy",
--           initial_mode = "normal",
--           layout_config = {
--             preview_cutoff = 9999,
--           },
--         },
--       }
--       opts.extensions = {
--         file_browser = {
--           theme = "dropdown",
--           -- disables netrw and use telescope-file-browser in its place
--           hijack_netrw = true,
--           mappings = {
--             -- your custom insert mode mappings
--             ["n"] = {
--               -- your custom normal mode mappings
--               ["N"] = fb_actions.create,
--               ["h"] = fb_actions.goto_parent_dir,
--               ["/"] = function()
--                 vim.cmd("startinsert")
--               end,
--               ["<C-u>"] = function(prompt_bufnr)
--                 for i = 1, 10 do
--                   actions.move_selection_previous(prompt_bufnr)
--                 end
--               end,
--               ["<C-d>"] = function(prompt_bufnr)
--                 for i = 1, 10 do
--                   actions.move_selection_next(prompt_bufnr)
--                 end
--               end,
--               ["<PageUp>"] = actions.preview_scrolling_up,
--               ["<PageDown>"] = actions.preview_scrolling_down,
--             },
--           },
--         },
--       }
--       telescope.setup(opts)
--       require("telescope").load_extension("fzf")
--       require("telescope").load_extension("file_browser")
--     end,
--   },
-- }
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "telescope-dap.nvim",
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope-frecency.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local trouble = require("trouble.providers.telescope")
      local icons = require("config.icons")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopeResults",
        callback = function(ctx)
          vim.api.nvim_buf_call(ctx.buf, function()
            vim.fn.matchadd("TelescopeParent", "\t\t.*$")
            vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
          end)
        end,
      })

      local function formattedName(_, path)
        local tail = vim.fs.basename(path)
        local parent = vim.fs.dirname(path)
        if parent == "." then
          return tail
        end
        return string.format("%s\t\t%s", tail, parent)
      end

      telescope.setup({
        file_ignore_patterns = { "%.git/." },
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-t>"] = trouble.open_with_trouble,
            },

            n = { ["<C-t>"] = trouble.open_with_trouble },
          },
          previewer = false,
          prompt_prefix = " " .. icons.ui.Telescope .. " ",
          selection_caret = icons.ui.BoldArrowRight .. " ",
          file_ignore_patterns = { "node_modules", "package-lock.json" },
          initial_mode = "insert",
          select_strategy = "reset",
          sorting_strategy = "ascending",
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
          layout_config = {
            prompt_position = "top",
            preview_cutoff = 120,
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            previewer = false,
            path_display = formattedName,
            layout_config = {
              height = 0.4,
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          git_files = {
            previewer = false,
            path_display = formattedName,
            layout_config = {
              height = 0.4,
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          buffers = {
            path_display = formattedName,
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer,
              },
              n = {
                ["<c-d>"] = actions.delete_buffer,
              },
            },
            previewer = false,
            initial_mode = "normal",
            -- theme = "dropdown",
            layout_config = {
              height = 0.4,
              width = 0.6,
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          current_buffer_fuzzy_find = {
            previewer = true,
            layout_config = {
              prompt_position = "top",
              preview_cutoff = 120,
            },
          },
          live_grep = {
            only_sort_text = true,
            previewer = true,
          },
          grep_string = {
            only_sort_text = true,
            previewer = true,
          },
          lsp_references = {
            show_line = false,
            previewer = true,
          },
          treesitter = {
            show_line = false,
            previewer = true,
          },
          colorscheme = {
            enable_preview = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              previewer = false,
              initial_mode = "normal",
              sorting_strategy = "ascending",
              layout_strategy = "horizontal",
              layout_config = {
                horizontal = {
                  width = 0.5,
                  height = 0.4,
                  preview_width = 0.6,
                },
              },
            }),
          },
          frecency = {
            default_workspace = "CWD",
            show_scores = true,
            show_unindexed = true,
            disable_devicons = false,
            ignore_patterns = {
              "*.git/*",
              "*/tmp/*",
              "*/lua-language-server/*",
            },
          },
        },
      })
      -- telescope.load_extension("fzf")
      -- telescope.load_extension("ui-select")
      -- telescope.load_extension("refactoring")
      -- telescope.load_extension("dap")
      -- telescope.load_extension("frecency")
    end,
  },
}
