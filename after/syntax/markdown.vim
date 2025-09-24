augroup ZKHighlight
  autocmd!
  autocmd BufEnter ~/zettelkasten/*.md syntax match zkLink "\[\[[^]]\+\]\]"
augroup END

highlight default link zkLink LineNr
