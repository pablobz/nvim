return {
   'vimwiki/vimwiki',
   init = function () --replace 'config' with 'init'
      vim.g.vimwiki_list = {{path = '~/Documents/roger/wiki', syntax = 'markdown', ext = '.md'}}
   end
}
