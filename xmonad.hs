import Control.Monad(liftM2)
import Graphics.X11.ExtraTypes.XF86
import System.IO

import XMonad
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.StackSet(greedyView,shift)
import XMonad.Actions.WindowBringer
import XMonad.Hooks.SetWMName

import XMonad.Util.Dzen
import Data.Map    (fromList)
import Data.Monoid (mappend)

alert = dzenConfig centered . show . round
centered =
        onCurr (center 150 66)
    >=> font "-*-helvetica-*-r-*-*-64-*-*-*-*-*-*-*"
    >=> addArgs ["-fg", "#80c0ff"]
    >=> addArgs ["-bg", "#000040"]


myWorkspaces = ["1:web+mail", "2:dev", "3:dev2", "4:rdp", "5:aud"] ++ map show [6..9]

myManageHook = composeAll
     [ className =? "Opera" --> viewShift "1:web+mail"
     , className =? "Spotify" --> viewShift "5:aud"
     , manageDocks
     ]
     where viewShift = doF . liftM2 (.) greedyView shift 

steamManageHook = composeAll $
    [ resource =? name --> doIgnore | name <- ignore ]
  ++[ title =? name --> doIgnore | name <- ignore ]
  ++[ className =? name --> doIgnore | name <- ignore ]
  ++[ resource =? name --> doFloat | name <- floaters ]
  ++[ title =? name --> doFloat | name <- floaters ]
  ++[ className =? name --> doFloat | name <- floaters ]
--  ++[ isFullscreen --> doFullFloat] --full float fullscreen flash
  ++[ isDialog --> doCenterFloat] --full float fullscreen flash
  ++[    className =? "Steam"        -->doFloat
      ,  className =? "steam"        -->doFullFloat --bigpicture-mode
  ]
  where
    floaters = ["glut"]
    ignore = ["stalonetray"]

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobarrc"
    xmonad $ defaultConfig
         { manageHook = myManageHook <+> steamManageHook <+> manageHook defaultConfig
         , layoutHook = smartBorders $ avoidStruts   $  layoutHook defaultConfig
         , modMask    = mod4Mask
         , startupHook = setWMName "LG3D"
         , logHook    = dynamicLogWithPP xmobarPP
                            { ppOutput = hPutStrLn xmproc
                            , ppTitle  = xmobarColor "green" "" . shorten 80
                            }
         , terminal   = "urxvt"
         , workspaces = myWorkspaces
         }
         `additionalKeys`
         [
          ((0, xF86XK_AudioMute),         spawn "pactl set-sink-mute 2 toggle"),
          ((0, xF86XK_Calculator),        spawn "urxvt"),
          ((0, xF86XK_AudioLowerVolume),  spawn "pactl set-sink-volume -- 2 -5%"),
          ((0, xF86XK_AudioRaiseVolume),  spawn "pactl  set-sink-volume -- 2 +5%"),
          ((0, xK_Print),  spawn "xfce4-screenshooter"),
          ((mod4Mask, xK_b     ), sendMessage ToggleStruts),
          ((mod4Mask .|. shiftMask, xK_a     ), gotoMenu),
          ((mod4Mask .|. shiftMask, xK_z     ), bringMenu)
         ]

