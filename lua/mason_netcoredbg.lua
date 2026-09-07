-- Temporary override until mason-org's recipe includes Samsung's ARM macOS release.
-- https://github.com/Samsung/netcoredbg/releases/tag/3.2.0-1092
return {
  name = 'netcoredbg',
  description = 'Managed .NET debugger with native Apple Silicon support',
  homepage = 'https://github.com/Samsung/netcoredbg',
  licenses = { 'MIT' },
  languages = { 'C#', 'F#' },
  categories = { 'DAP' },
  source = {
    id = 'pkg:github/Samsung/netcoredbg@' .. require('tooling').netcoredbg_version,
    asset = {
      { target = 'darwin_arm64', file = 'netcoredbg-osx-arm64.zip:libexec/', bin = 'exec:libexec/netcoredbg/netcoredbg' },
      { target = 'darwin_x64', file = 'netcoredbg-osx-amd64.tar.gz:libexec/', bin = 'exec:libexec/netcoredbg/netcoredbg' },
      { target = 'linux_arm64_gnu', file = 'netcoredbg-linux-arm64.tar.gz:libexec/', bin = 'exec:libexec/netcoredbg/netcoredbg' },
      { target = 'linux_x64_gnu', file = 'netcoredbg-linux-amd64.tar.gz:libexec/', bin = 'exec:libexec/netcoredbg/netcoredbg' },
      { target = 'win_x64', file = 'netcoredbg-win64.zip', bin = 'netcoredbg/netcoredbg.exe' },
    },
  },
  bin = { netcoredbg = '{{source.asset.bin}}' },
}
