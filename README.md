# askai.nvim

A lightweight Neovim plugin to ask AI questions directly about **visual selections** and show the response in a popup window.

Supports **Gemini**, **OpenAI**, **Anthropic**, and **OpenAI-compatible APIs** (e.g. DeepSeek).


## 📦 Installation

Using **lazy.nvim**:


```lua
{
  "aufam/askai.nvim",
  config = function()
    require("askai").setup({
      provider = "gemini", -- "gemini"|"openai"|"anthropic"
    })

    vim.keymap.set("v", "<leader>ai", ":AskAI ", { desc = "askai: Ask AI about visual selections" })
  end,
}

````


## 🚀 Usage

1. Select text in **Visual mode**
2. Press your mapped key (example: `<leader>ai`)
3. Type your question and hit `<Enter>`
4. The AI answer appears in a popup

---


## ⚙️ Configuration

### Default Configuration


```lua
require("askai").setup({
  prompt = "Answer shortly",
  provider = "gemini",
  gemini = {
    model = "gemini-2.5-flash-lite",
    version = "v1",
  },
  openai = {
    url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4o-mini",
    api_key_env_name = "OPENAI_API_KEY",
    system_role = "You are a helpful assistant.",
  },
  anthropic = {
	anthropic_version = "2023-06-01",
	model = "claude-sonnet-4-5",
	max_tokens = 128,
  }
})

```

---


## 🔮 Provider Examples

### Gemini

```lua
require("askai").setup({
  gemini = {
    model = "gemini-2.5-flash-lite",
  },
})
```


### OpenAI

```lua
require("askai").setup({
  openai = {
    model = "gpt-4o-mini",
  },
})

```


### DeepSeek

```lua
require("askai").setup({
  openai = {
    url = "https://api.deepseek.com/chat/completions",
    model = "deepseek-chat",
    api_key_env_name = "DEEPSEEK_API_KEY",
  },
})

```


### Anthropic

```lua
require("askai").setup({
  anthropic = {
	model = "claude-sonnet-4-5",
  },
})

```

---


## 🛠️ Notes

* Designed for **short answers** by default
* Corresponding env variable must be defined
* Works best with concise prompts

---


## 📄 License

MIT

