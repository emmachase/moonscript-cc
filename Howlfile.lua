Options:Default "trace"

Tasks:clean()

Tasks:minify "minify-moonc" {
	input = "build/moonc.lua",
	output = "build/moonc.min.lua",
}

Tasks:minify "minify-moon" {
	input = "build/moon.lua",
	output = "build/moon.min.lua",
}

Tasks:Task "minify" { "minify-moon", "minify-moonc" }

Tasks:require "moonc" {
	include = { "bin/moonc", "moonscript/*.lua", "cc/*.lua" },
	startup = "bin/moonc",
	output = "build/moonc.lua",
}

Tasks:require "moon" {
	include = { "bin/moon", "moon/*.lua", "moonscript/*.lua", "cc/*.lua" },
	startup = "bin/moon",
	output = "build/moon.lua",
}

Tasks:Task "build" { "clean", "minify" } :Description "Main build task"

Tasks:Default "build"
