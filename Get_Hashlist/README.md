**How to use**


Use assets unpack tool to extract resource file, then use cmd below to get file name list:


```bash
@echo off

SET root_dir=%cd%
SET output=%root_dir%\assetlist.txt

for /R %root_dir% %%i in (*.*) do (
  cd %%~dpi
  echo %%~dpi%%~ni>>%output%
  cd %root_dir%
)
```


Use text editor to remove absolute path prefix, and replace `\` to `/`, then we get assetlist.txt.


Run game, run this mod with keybind to generate hashlist.

