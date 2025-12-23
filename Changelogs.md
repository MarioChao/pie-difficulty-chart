# Changelogs

## [v0.0.2] Award badge fix | 2025/12/23

Badge awarding is now done in a `task.defer()` thread.

Added touched throttle for each stage and each player.

## [v0.0.1] Interactive events + Touched unlock config | 2025/12/01

Added new server bindable events `StageSelected_Bindable` and `StageUnlockQuery_Bindable` to allow other scripts to interact with the stage system.

Added `Unlock_ByTouch` configuration to the `Stage_Config` module so that stages can be configured to not unlock on touch.
