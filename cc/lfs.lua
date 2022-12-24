-- Simple implementation of LuaFileSystem for ComputerCraft
-- Only supports the functions needed for Moonscript

local lfs = {}

function lfs.attributes(path, requestName)
    if not fs.exists(path) then
        printError(debug.traceback())
        error("File '" .. path .. "' does not exist", 2)
    end
    local results = fs.attributes(path)
    local adapted = {
        mode = results.isDir and "directory" or "file",
        size = results.size,
        modification = results.modified,
    }

    if requestName then
        return adapted[requestName]
    else
        return adapted
    end
end

function lfs.currentdir()
    return shell.dir()
end

function lfs.dir(path)
    if not fs.isDir(path) then
        error("Directory does not exist", 2)
    end
    local dir = fs.list(path)
    local i = 0
    return function()
        i = i + 1
        return dir[i]
    end
end

function lfs.mkdir(path)
    fs.makeDir(path)
end

function lfs.rmdir(path)
    fs.delete(path)
end

return lfs
