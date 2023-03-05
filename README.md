# vim-rq

This is a simple request-making pluging for neovim. 
In order to install it, you can use [Packer](https://github.com/wbthomason/packer.nvim). 
For now, this pluging only supports making GET requests, in any vim buffer you can 
write: 

```bash
GET <api url>
```

after that, just select the text you just wrote and press _<leader>k_, it will make the get request
to the endpoint you specified and write the result into another vim buffer that you can play with. 
Another important thing is that, it will automatically pretty format your json responses, so you get
the best experience ever!
