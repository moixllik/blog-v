module main

import vweb
import json

struct Doc {
	uri      string
	desc     string
	title    string
	cover    string
	content  string
	extra    string
	authors  string
	tags     string
	modified string
}

struct DocUri {
	uri string
}

struct DocSearch {
	uri   string
	desc  string
	title string
}

fn (mut app App) docs_lists() []string {
	collection := app.db.collection('docs')
	opts := '{"projection":{"uri":1}}'
	cursor := collection.find('{"public":true}', opts) or { return [] }
	mut list := []string{}
	for document in cursor {
		_, doc := document.decode[DocUri]() or { continue }
		list << doc.uri
	}
	return list
}

fn (mut app App) docs_search(filter string, limit int) []DocSearch {
	collection := app.db.collection('docs')
	opts := '{
		"limit":${limit},
		"sort":{"modified":-1},
		"projection":{"uri":1, "title":1, "desc":1}
	}'
	cursor := collection.find(filter, opts) or { return [] }
	mut docs := []DocSearch{}
	for document in cursor {
		_, doc := document.decode[DocSearch]() or { continue }
		docs << doc
	}
	return docs
}

['/d/']
fn (mut app App) docs_index() vweb.Result {
	q := app.query['q']
	mut filter := '{}'
	if q.len > 0 {
		q_string := '{"\$regex":"${q}","\$options":"i"}'
		filter = match q[0] {
			35 {
				'{"public":true,
					"tags":{"\$in":["${q[1..]}"]}
				}'
			}
			64 {
				'{"public":true,
					"authors": {"\$in":["${q[1..]}"]}
				}'
			}
			else {
				'{"public":true,
					"\$or":[
						{"uri":${q_string}},{"title":${q_string}},{"desc":${q_string}}
					]
				}'
			}
		}
	}
	docs := app.docs_search(filter, 7)
	return $vweb.html()
}

['/d/:uri']
fn (mut app App) docs_reader(uri string) vweb.Result {
	q := ''
	collection := app.db.collection('docs')
	filter := '{"public":true,"uri":"${uri}"}'
	_, doc := collection.find_one[Doc](filter) or { return app.not_found() }
	modified := doc.modified[..10]
	tags := json.decode([]string, doc.tags) or { [] }
	authors := json.decode([]string, doc.authors) or { [] }
	return $vweb.html()
}
