import os

fn sh(commands string) {
	println('> ${commands}')
	cmd := os.execute(commands)
	if cmd.exit_code == 1 {
		panic(cmd.output)
	} else {
		println(cmd.output)
	}
}

mut cc := 'clang'
$if windows {
	cc = 'msvc'
	path := os.getenv('PATH')
	libs := os.join_path(os.vmodules_dir(), 'mongo\\thirdparty\\win64\\bin')
	os.setenv('PATH', '${libs};${path}', true)
}

match os.args[1] or { '' } {
	'release' {
		sh('v install')
		sh('v -cc ${cc} -prod -skip-unused -o app src')
	}
	'debug' {
		sh('v -cc ${cc} -o app src')
	}
	else {
		sh('v -cc ${cc} run src')
	}
}
