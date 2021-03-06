call TQ84_log_indent(expand("<sfile>"))

nnoremap <buffer> ,vs :call tq84#bibelkommentare#searchVerse(Bibel#EingabeBuchKapitelVers())<CR>
nnoremap <buffer> ,it :call tq84#bibelkommentare#insertText()<CR>
nnoremap <buffer> ,sa :call tq84#bibelkommentare#substitute_a_href()<CR>
vnoremap <buffer> ,sa :call tq84#bibelkommentare#substitute_a_href()<CR>
nnoremap <buffer> ,s' :s!\v'([^']+)'!\='<i>' . submatch(1) . '</i>'!<CR>
nnoremap <buffer> ,mp :call tq84#buf#openFile($github_root . 'Bibelkommentare/mappings.vim')<CR>

setl foldmarker={,}
setl foldmethod=marker

so $github_root/notes/common.vim

call TQ84_log_dedent()
