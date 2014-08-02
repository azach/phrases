require_relative '../phrases.rb'

describe Phrases do
  let(:file_path) { File.join(File.expand_path(File.dirname(__FILE__)), 'support/dummy_phrases') }
  let(:phrases) { Phrases.new(file_path) }

  describe '.get' do
    before { Phrases.initialize_phrases(file_path) }

    subject { Phrases.get(search) }

    context 'if a search term is not specified' do
      let(:search) { nil }

      it 'returns a random phrase' do
        expect(subject).to match(/phrase \d+/)
      end
    end

    context 'if a search term that exists is specified' do
      let(:search) { 'phrase 1' }

      it 'returns the search term' do
        expect(subject).to eql(search)
      end
    end

    context 'if a search term that does not exist is specified' do
      let(:search) { 'non-existent phrase' }

      it { should be_nil }
    end
  end

  describe '.populate_trie' do
    let(:trie) { Rambling::Trie.create }

    it 'raises an error if the file does not exist' do
      expect { Phrases.populate_trie(trie: trie, file_path: '/fake') }.to raise_error
    end

    it 'adds all the words from the file to the trie' do
      Phrases.populate_trie(trie: trie, file_path: file_path)
      expect(trie.to_a).to eql(['phrase 1', 'phrase 2', 'phrase 3', 'phrase 4'])
    end
  end

  describe '#exists?' do
    subject { phrases.exists?(word) }

    context 'for a word in the file' do
      let(:word) { 'phrase 1' }
      it { should be_true }
    end

    context 'for a word not in the file' do
      let(:word) { 'non-existent' }
      it { should be_false }
    end
  end

  describe '#add' do
    subject { phrases.add(word) }
    let(:word) { 'another phrase' }

    before { phrases.stub(append_to_file: true) }

    it 'adds the word to the trie' do
      expect { subject }.to change { phrases.exists?(word) }.from(false).to(true)
    end

    it 'adds the word to the file' do
      phrases.should_receive(:append_to_file).with(word)
      subject
    end
  end

  describe '#sample' do
    it 'returns nil if there are no phrases' do
      phrases = Phrases.new('/dev/null')
      expect(phrases.sample).to be_nil
    end

    it 'returns a phrase from the file if there are phrases' do
      expect(phrases.sample).to match(/phrase \d+/)
    end
  end
end
