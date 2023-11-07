module main

import vweb
import encoding.base64

struct File {
	uri      string
	public   bool
	mime     string
	base64   bool
	content  string
	modified i64
}

['/file/:uri']
fn (mut app App) files(uri string) vweb.Result {
	collection := app.db.collection('files')
	filter := '{"public":true,"uri":"${uri}"}'
	_, file := collection.find_one[File](filter) or { return app.not_found() }
	app.set_content_type(file.mime)
	if file.base64 {
		return app.ok(base64.decode_str(file.content))
	}
	return app.ok(file.content)
}
