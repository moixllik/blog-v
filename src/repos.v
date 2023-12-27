module main

import os
import time
import json
import vweb
import net.http

struct Repo {
	name        string
	html_url    string
	description string
	archived    bool
	fork        bool
}

@['/repos/']
pub fn (mut app App) repos() vweb.Result {
	repos := app.api_get_repos()
	repos_opened := repos.filter(it.fork == false && it.archived == false)
	repos_forked := repos.filter(it.fork == true && it.archived == false)
	repos_archived := repos.filter(it.fork == false && it.archived == true)
	return $vweb.html()
}

fn (mut app App) api_get_repos() []Repo {
	tempfile := os.join_path(os.temp_dir(), time.now().day_of_week().str())
	mut content := ''
	if os.exists(tempfile) {
		content = os.read_file(tempfile) or { return [] }
	} else {
		token := os.getenv('GITHUB')
		mut header := http.Header{}
		header.add_custom('User-Agent', 'Mozilla/5.0') or { return [] }
		header.add_custom('Authorization', 'Bearer ${token}') or { return [] }
		res := http.fetch(
			url: 'https://api.github.com/users/moixllik/repos'
			header: header
		) or { return [] }
		if res.status_code == 200 {
			content = res.body
			os.write_file(tempfile, content) or {}
		}
	}
	return json.decode([]Repo, content) or { [] }
}
