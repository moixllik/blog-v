module main

import vweb

@['/resources/']
pub fn (mut app App) resources_index() vweb.Result {
	return $vweb.html()
}
