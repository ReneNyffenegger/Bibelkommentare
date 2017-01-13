call TQ84_log_indent(expand("<sfile>"))

nnoremap <buffer> ,vs :call tq84#bibelkommentare#searchVerse(Bibel#EingabeBuchKapitelVers())<CR>

call TQ84_log_dedent()
