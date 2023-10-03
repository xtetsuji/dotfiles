# $Id: .xsession,v 1.1 2009/07/08 15:22:40 ogata Exp $
# $Source: /var/cvs/dot/konko/.xsession,v $
# ogata 2009/07/09

# for ThinkPad X series and Linux X.org

# 右側 Alt が違う認識をしていたので明示的に設定
xmodmap -e 'keycode 108 = Alt_R'

# 矢印キーの横にある進む戻るボタンを F19/F20 として割り当てる
# daichi (X60 だと 233, 234 だった)
xmodmap -e 'keycode 166 = F19'
xmodmap -e 'keycode 167 = F20'
