shared_examples_for 'a paging feature' do
  describe '#page' do
    it 'treats nil page as 0' do
      finder = finder_with_page nil
      expect(finder.page).to eq 0
    end

    it 'treats negative page numbers as positive' do
      finder = finder_with_page(-1)
      expect(finder.page).to eq 0
    end
  end

  describe '#per_page' do
    it 'returns the class defined per page' do
      finder = finder_class.new
      expect(finder.per_page).to eq 2
    end

    it 'can be overwritten as option' do
      finder = finder_class.new per_page: 3
      expect(finder.per_page).to eq 3
    end

    it 'respects min per page' do
      finder = finder_class.new per_page: 1
      expect(finder.per_page).to eq 2
    end

    it 'respects max per page' do
      finder = finder_class.new per_page: 100
      expect(finder.per_page).to eq 10
    end
  end

  describe '.per_page' do
    it 'does not accept 0' do
      expect { define_finder_class { per_page(0) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end

    it 'does not accept negative number' do
      expect { define_finder_class { per_page(-1) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end
  end

  describe '.min_per_page' do
    it 'does not accept 0' do
      expect { define_finder_class { min_per_page(0) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end

    it 'does not accept negative number' do
      expect { define_finder_class { min_per_page(-1) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end
  end

  describe '.max_per_page' do
    it 'does not accept 0' do
      expect { define_finder_class { max_per_page(0) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end

    it 'does not accept negative number' do
      expect { define_finder_class { max_per_page(-1) } }.to raise_error Trailblazer::Finder::Error::InvalidNumber
    end
  end
end
