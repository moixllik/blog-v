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

match os.args[1] or { '' } {
	'release' {
		sh('v install')
		sh('v -prod -skip-unused -o app src')
	}
	'debug' {
		sh('v -o app src')
	}
	else {}
}
