module main

import os
import mongo

fn db_connect() mongo.Database {
	url := os.getenv_opt('DATABASE_URL') or { panic(err) }
	uri := mongo.uri(url) or { panic(err) }
	client := uri.client() or { panic(err) }
	return client.database('moixllik')
}
