module main

import os
import vweb
import dotenv
import mongo

struct App {
	vweb.Context
	vweb.Controller
	db_handle vweb.DatabasePool[mongo.Database] = unsafe { nil }
pub:
	domain string [vweb_global]
pub mut:
	db mongo.Database
}

fn main() {
	dotenv.load()
	domain := os.getenv_opt('DOMAIN') or { 'http://localhost:8080' }
	pool := vweb.database_pool(handler: db_connect)
	mut app := App{
		db_handle: pool
		domain: domain
		controllers: []
	}
	app.handle_static('public', true)
	vweb.run_at(app, host: '::1') or { panic(err) }
}

pub fn (mut app App) not_found() vweb.Result {
	app.set_status(404, 'Not Found')
	return app.html($tmpl('templates/404.html'))
}

fn (mut app App) index() vweb.Result {
	docs := app.docs_search('{"public":true}', 3)
	repos := app.repos()
	return $vweb.html()
}

['/sitemap.txt']
fn (mut app App) sitemap() vweb.Result {
	mut links := []string{}
	links << app.domain
	uris := app.docs_lists()
	for uri in uris {
		links << '${app.domain}/d/${uri}'
	}
	return app.text(links.join('\n'))
}

['/search']
fn (mut app App) search() vweb.Result {
	q := app.query['q']
	typ := app.query['typ']
	if typ == 'muchik' {
		return app.redirect('https://muchik.moix.pe/?q=${q}')
	}
	return app.redirect('/d/?q=${q}')
}
