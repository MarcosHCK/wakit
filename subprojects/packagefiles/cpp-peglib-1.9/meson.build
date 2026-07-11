project('peglib', 'cpp', version: '1.9')

cpp = meson.get_compiler ('cpp')

compile_args = []
compile_args += [ cpp.get_supported_arguments ([ '-Wno-shadow' ]) ]
compile_args += [ cpp.get_supported_arguments ([ '-Wno-deprecated-literal-operator' ]) ]

peglib_dep = declare_dependency (

		compile_args: compile_args,
		include_directories: include_directories ('.'),
		sources: [ 'peglib.h' ])

meson.override_dependency ('cpp-peglib', peglib_dep)