fx_version 'cerulean'
game 'gta5'

description 'TS Scripts - Radio in React Typescript with Mantine V7'
author 'TS Scripts - Thomas'
version '1.0.0'

ui_page 'web/build/index.html'

shared_scripts {
  'shared/**/*',
  '@ox_lib/init.lua',
  '@qbx_core/modules/lib.lua'
}
client_scripts {
  '@qbx_core/modules/playerdata.lua',
  'client/**/*'
}

server_script 'server/**/'

files {
  'web/build/index.html',
  'web/build/**/*',
}

dependency 'pma-voice'

lua54 'yes'
use_experimental_fxv2_oal 'yes'