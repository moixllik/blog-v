module main

import vweb

struct App {
	vweb.Context
}

fn main() {
	mut app := &App{}
	vweb.run_at(app, host: '::1') or { panic(err) }
}

pub fn (mut app App) index() vweb.Result {
	return $vweb.html()
}
