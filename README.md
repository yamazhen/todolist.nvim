> [!WARNING]
> This is a WIP plugin

# ZhenList (zhenlist.nvim)

**zhenlist.nvim** is a Neovim plugin designed to streamline task management right within your editor. It provides a dedicated checklist window that you can easily toggle on or off, allowing you to:
* **Quickly access your task:** Instantly open or hide the checklist window with a simple command or you can bind it to a key
* **Manage checklist item:** Add, remove, and mark task as complete directly in Neovim

This plugin is particularly useful for developers who want to handle coding to-dos, project tasks, or personal reminders without leaving their Neovim workspace.

## Features
* Toggle checklist window that you can write notes and add todo items to it.
* Function to create a new todo item on a new line
* Check and uncheck a todo item in the checklist
* The checklist is saved as markdown file in the plugin directory

## Installation
To install `zhenlist.nvim`, you can use any Neovim plugin manager.

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'yamazhen/zhenlist.nvim'
```
### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)
``` lua
return {
    "yamazhen/zhenlist.nvim",
    opts = {}
}
```

## Default Configuration
You can configure the default configuration with the `setup` function.

```lua
require("zhenlist").setup({
    window = {
        border = "rounded",
        title = "zhenlist",
        title_pos = "left",
    },
    insert_on_item_add = true,
    insert_with_a = false,
    keymap = {
        add_item = "o",
    },
    disable_omni_completion = true,
})
```

## Usage
Once installed, there are two commands you can call which are:
* **ZhenListToggle:** toggles the checklist
* **ZhenListAddItem:** adds a todo check in the checklist

Inside the checklist window, you can press "o" in normal mode to create a new todo. You can also press enter on a todo item to mark it as completed and vice versa.

## Note
I made this for myself to use, but if you would like to contribute or suggest some useful features feel free to do so.
