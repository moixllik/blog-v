module main

import os
import time
import json
import net.http

struct Repo {
	name        string
	html_url    string
	description string
	archived    bool
	fork        bool
}

fn (mut app App) repos() []Repo {
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
	repos := json.decode([]Repo, content) or { [] }
	return repos.filter(it.fork == false && it.archived == false)
}
