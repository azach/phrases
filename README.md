# Phrases

An app that allows you to get random phrases from large files.

# Assumptions

Speed is the most critical aspect of the service, so the phrases are loaded at start time into a trie structure, which makes search and lookup very fast.

Phrases are assumed to be unique in a file, so phrases that exist in the file are not added again.

# Running

(Requirements: Ruby 2.0.0-p247)

To run the app, copy the conf.yml.example file to conf.yml, and replace the `phrases_file_path` option with the path to your phrase file.

Start the app by running:

`bundle exec rackup config.ru`

# Running specs

Run the specs from the root directory of the project using:

`bundle exec rspec`
