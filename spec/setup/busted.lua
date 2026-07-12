-- Load the stdlib-owned Factorio mock harness restored by the CI workflow.
require('faketorio/require')
require('faketorio/globals')

return require('busted.runner')
