module main

import os
import vweb
import mongo
import dotenv

struct App {
	vweb.Context
	vweb.Controller
	db_handle vweb.DatabasePool[mongo.Database] = unsafe { nil }
pub:
	domain string @[vweb_global]
pub mut:
	db mongo.Database
}

fn init() {
	dotenv.load()
}

fn main() {
	pool := vweb.database_pool(handler: db_connect)
	mut app := &App{
		db_handle: pool
		domain: os.getenv('DOMAIN')
		controllers: []
	}
	app.handle_static('public', true)
	vweb.run_at(app, host: '::1') or { panic(err) }
}

pub fn (mut app App) not_found() vweb.Result {
	app.set_status(404, 'Not Found')
	return app.html($tmpl('templates/404.html'))
}

@['/sitemap.txt']
pub fn (mut app App) sitemap() vweb.Result {
	mut links := []string{}
	links << app.domain
	for uri in app.db_get_uris() {
		links << app.domain + '/p/' + uri.uri + '/'
	}
	return app.text(links.join('\n'))
}

@['/']
pub fn (mut app App) index() vweb.Result {
	posts := app.db_get_updates()
	return $vweb.html()
}

@['/search']
pub fn (mut app App) search() vweb.Result {
	query := app.query['q']
	posts := app.search_posts(query)
	return $vweb.html()
}

@['/p/:uri/']
pub fn (mut app App) reader(uri string) vweb.Result {
	post := app.db_get_post(uri) or { return app.not_found() }
	return app.html($tmpl('templates/reader.html'))
}
