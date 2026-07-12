local DataFixture = {}

function DataFixture.reload()
    for module_name in pairs(package.loaded) do
        if module_name == 'faketorio/dataloader' or module_name:match('^faketorio/raw/') then
            package.loaded[module_name] = nil
        end
    end
    _G.data = nil
    return require('faketorio/dataloader')
end

return DataFixture
