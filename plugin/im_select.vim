if exists('g:im_select_loaded') || &compatible
  finish
endif

if !exists('*jobstart') || !exists('*job_start')
  finish
endif

" OS and IM detection
if !exists('g:im_select_get_func') || !exists('g:im_select_set_func')
  let os = im_select#get_os()
  if os == 'Linux'
    if $GTK_IM_MODULE == 'fcitx' || $QT_IM_MODULE == 'fcitx'
      let g:im_select_get_func = function('im_select#fcitx_get_im')
      let g:im_select_set_func = function('im_select#fcitx_set_im')
      if !exists('g:im_select_default')
        let g:im_select_default = '1'
      endif
    elseif match($XDG_CURRENT_DESKTOP, '\cgnome')
      if $GTK_IM_MODULE == 'ibus'
        let g:im_select_get_func = function('im_select#gnome_shell_get_im')
        let g:im_select_set_func = function('im_select#gnome_shell_set_im')
        if !exists('g:im_select_default')
          let g:im_select_default = '0'
        endif
      endif
    else
      if $GTK_IM_MODULE == 'ibus' || $QT_IM_MODULE == 'ibus'
        let g:im_select_get_func = function('im_select#ibus_get_im')
        let g:im_select_set_func = function('im_select#ibus_set_im')
        if !exists('g:im_select_default')
          let g:im_select_default = 'xkb:us::eng'
        endif
      elseif $GTK_IM_MODULE == 'fcitx' || $QT_IM_MODULE == 'fcitx'
        let g:im_select_get_func = function('im_select#fcitx_get_im')
        let g:im_select_set_func = function('im_select#fcitx_set_im')
        if !exists('g:im_select_default')
          let g:im_select_default = '1'
        endif
      endif
    endif
  elseif os == 'macOS' || os == 'Windows'
    if !exists('g:im_select_command')
      if os == 'macOS'
        let command = im_select#rstrip(system('which im-select'), "\r\n")
      else
        let command = im_select#rstrip(system('where.exe im-select.exe'), "\r\n")
      endif

      if command == ''
        echohl ErrorMsg | echomsg 'im-select is not found on your system. Please refer to https://github.com/daipeihust/im-select' | echohl None
        finish
      endif
    endif

    if !exists('g:im_select_default')
      if os == 'Windows'
        echohl ErrorMsg | echomsg "Please set the default IM manually on Windows." | echohl None
        finish
      endif
      let g:im_select_default = 'com.apple.keylayout.US'
    endif

    let g:im_select_get_func = function('im_select#im_select_get_im')
    let g:im_select_set_func = function('im_select#im_select_set_im')
  endif
endif

if !exists('g:im_select_get_func') || !exists('g:im_select_set_func')
  finish
endif

let g:im_select_loaded = 1

augroup im_select
  autocmd InsertEnter * call im_select#on_insert_enter()
  autocmd InsertLeave * call im_select#on_insert_leave()
  autocmd FocusGained * call im_select#on_focus_gained()
  autocmd FocusLost * call im_select#on_focus_lost()
  autocmd VimLeavePre * call im_select#on_vim_leave_pre()
augroup end