-- Load the stdlib-owned Factorio mock harness restored by the CI workflow.
require('faketorio/require')
require('faketorio/globals')
require('spec/setup/factorio21')

return require('busted.runner')
