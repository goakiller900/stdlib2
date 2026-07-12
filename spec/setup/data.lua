local DataFixture = {}

function DataFixture.reload()
    for module_name in pairs(package.loaded) do
        if module_name:find('faketorio/dataloader', 1, true)
            or module_name:find('faketorio/raw/', 1, true) then
            package.loaded[module_name] = nil
        end
    end
    _G.data = nil
    return require('faketorio/dataloader')
end

return DataFixture
