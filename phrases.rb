require 'rambling-trie'

class Phrases
  SEPARATOR = '|'

  def self.initialize_phrases(file_path)
    @@instance = new(file_path)
  end

  def self.instance
    @@instance
  end

  def self.get(search = nil)
    return self.sample if search.nil? || search.empty?
    exists?(search) ? search : nil
  end

  def self.exists?(phrase)
    instance.exists?(phrase)
  end

  def self.add(phrase)
    instance.add(phrase)
  end

  def self.sample
    instance.sample
  end

  def self.populate_trie(trie: trie, file_path: file_path)
    raise 'Invalid file' unless File.exists?(file_path)

    File.open(file_path, 'r') do |f|
      phrase = []
      f.each_char do |char|
        if char == SEPARATOR || f.eof?
          trie.add(phrase.join)
          phrase.clear
        else
          phrase << char
        end
      end
    end
  end

  def initialize(file_path)
    @file_path = file_path
    @trie = Rambling::Trie.create
    Phrases.populate_trie(trie: @trie, file_path: file_path)
  end

  def exists?(phrase)
    trie.word?(phrase)
  end

  def add(phrase)
    return if exists?(phrase)
    trie.add(phrase)
    append_to_file(phrase)
  end

  def sample
    node = @trie.children.sample
    return nil unless node
    node = node.children.sample while !node.terminal?
    node.as_word
  end

  private

  def append_to_file(phrase)
    File.open(file_path, 'a') { |f| f << [SEPARATOR, phrase].join }
  end

  attr_reader :file_path, :trie
end
