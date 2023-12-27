module main

import vweb

@['/user/']
pub fn (mut app App) user_index() vweb.Result {
	return $vweb.html()
}
