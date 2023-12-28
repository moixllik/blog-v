module main

import os
import mongo

struct Post {
	uri      string
	title    ?string
	desc     ?string
	content  ?string
	modified ?string
	public   ?bool
}

fn db_connect() mongo.Database {
	url := os.getenv_opt('DATABASE_URL') or { panic(err) }
	uri := mongo.uri(url) or { panic(err) }
	client := uri.client() or { panic(err) }
	return client.database('moixllik')
}

pub fn (mut app App) db_get_uris() []Post {
	coll := app.db.collection('posts')
	cursor := coll.find('{
		"public": true
	}', '{
		"projection": {
			"uri": 1
		}
	}') or {
		return []
	}
	mut uris := []Post{}
	for doc in cursor {
		_, uri := doc.decode[Post]() or { continue }
		uris << uri
	}
	return uris
}

pub fn (mut app App) db_get_post(uri string) !Post {
	coll := app.db.collection('posts')
	_, post := coll.find_one[Post]('{
		"public": true,
		"uri": "${uri}"
	}') or {
		return error('Not found query')
	}
	return post
}

pub fn (mut app App) db_get_updates() []Post {
	coll := app.db.collection('posts')
	cursor := coll.find('{
		"public": true
	}', '{
		"limit": 7,
		"sort": {
			"modified": 1
		},
		"projection": {
			"uri": 1,
			"title": 1,
			"desc": 1
		}
	}') or {
		return []
	}
	mut updates := []Post{}
	for doc in cursor {
		_, update := doc.decode[Post]() or { continue }
		updates << update
	}
	return updates
}

pub fn (mut app App) search_posts(query string) []Post {
	if query.len == 0 {
		return []
	}
	q_string := '{
		"\$regex": "${query}",
		"\$options": "i"
	}'
	filter := '{
		"public": true,
		"\$or":[
			{"uri": ${q_string}},
			{"title": ${q_string}},
			{"desc": ${q_string}}
		]
	}'
	opts := '{
		"limit": 10,
		"sort": {
			"modified": -1
		},
		"projection": {
			"uri":1,
			"title":1,
			"desc":1
		}
	}'
	coll := app.db.collection('posts')
	cursor := coll.find(filter, opts) or { return [] }
	mut result := []Post{}
	for doc in cursor {
		_, post := doc.decode[Post]() or { continue }
		result << post
	}
	return result
}
