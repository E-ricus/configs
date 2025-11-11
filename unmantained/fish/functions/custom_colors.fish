function custom_colors
    switch $argv
        case ayu
            ayu_colors
        case nord
            nord_colors
        case darcula
            darcula_colors
        case '*'
            echo Undefined color
    end
end

function ayu_colors
    set -U fish_color_normal CBCCC6
    set -U fish_color_command 5CCFE6
    set -U fish_color_quote BAE67E
    set -U fish_color_redirection D4BFFF
    set -U fish_color_end F29E74
    set -U fish_color_error FF3333
    set -U fish_color_param CBCCC6
    set -U fish_color_comment 5C6773
    set -U fish_color_selection --background=FFCC66
    set -U fish_color_history_current --bold
    set -U fish_color_search_match --background=FFCC66
    set -U fish_color_match F28779
    set -U fish_color_operator FFCC66
    set -U fish_color_escape 95E6CB
    set -U fish_color_cwd 73D0FF
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion 707A8C
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel -r
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
end

function nord_colors
    set -U fish_color_normal normal
    set -U fish_color_command 81a1c1
    set -U fish_color_quote a3be8c
    set -U fish_color_redirection b48ead
    set -U fish_color_end 88c0d0
    set -U fish_color_error ebcb8b
    set -U fish_color_param eceff4
    set -U fish_color_comment 434c5e
    set -U fish_color_match --background=brblue
    set -U fish_color_selection white --bold --background=brblack
    set -U fish_color_search_match bryellow --background=brblack
    set -U fish_color_history_current --bold
    set -U fish_color_operator 00a6b2
    set -U fish_color_escape 00a6b2
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion 4c566a
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel -r
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
end

function darcula_colors
    set -L
    set -U fish_color_normal normal
    set -U fish_color_command F8F8F2
    set -U fish_color_quote F1FA8C
    set -U fish_color_redirection 8BE9FD
    set -U fish_color_end 50FA7B
    set -U fish_color_error FFB86C
    set -U fish_color_param FF79C6
    set -U fish_color_comment 6272A4
    set -U fish_color_match --background=brblue
    set -U fish_color_selection white --bold --background=brblack
    set -U fish_color_search_match bryellow --background=brblack
    set -U fish_color_history_current --bold
    set -U fish_color_operator 00a6b2
    set -U fish_color_escape 00a6b2
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion BD93F9
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel -r
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
end
