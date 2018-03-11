shared_examples_for 'a sorting feature' do
  describe '#sort?' do
    it 'matches the sort option' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort :price
      expect(finder).not_to be_sort :name
    end

    it 'matches string also' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort 'price'
      expect(finder).not_to be_sort 'name'
    end

    it 'matches exact strings' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort 'price desc'
      expect(finder).not_to be_sort 'price asc'
    end
  end

  describe '#sort_attribute' do
    it 'returns sort option attribute' do
      finder = finder_with_sort 'price desc'
      expect(finder.sort_attribute).to eq 'price'
    end

    it 'defaults to the first sort by option' do
      finder = finder_with_sort
      expect(finder.sort_attribute).to eq 'name'
    end

    it 'rejects invalid sort options, uses defaults' do
      finder = finder_with_sort 'invalid'
      expect(finder.sort_attribute).to eq 'name'
    end
  end

  describe '#sort_direction' do
    it 'returns asc or desc' do
      expect(finder_with_sort('price desc').sort_direction).to eq 'desc'
      expect(finder_with_sort('price asc').sort_direction).to eq 'asc'
    end

    it 'defaults to desc' do
      expect(finder_with_sort.sort_direction).to eq 'desc'
      expect(finder_with_sort('price').sort_direction).to eq 'desc'
    end

    it 'rejects invalid sort options, uses desc' do
      expect(finder_with_sort('price foo').sort_direction).to eq 'desc'
    end
  end

  describe '#sort_direction_for' do
    it 'returns desc if current sort attribute is not the given attribute' do
      expect(finder_with_sort('price desc').sort_direction_for('name')).to eq 'desc'
    end

    it 'returns asc if current sort attribute is the given attribute' do
      expect(finder_with_sort('name desc').sort_direction_for('name')).to eq 'asc'
    end

    it 'returns desc if current sort attribute is the given attribute, but asc with direction' do
      expect(finder_with_sort('name asc').sort_direction_for('name')).to eq 'desc'
    end
  end

  describe '#sort_params_for' do
    it 'adds sort direction' do
      finder = finder_with_sort 'name', name: 'test'
      expect(finder.sort_params_for(:price)).to eq 'sort' => 'price desc', 'name' => 'test'
    end

    it 'reverses sort direction if this is the current sort attribute' do
      finder = finder_with_sort 'name desc', name: 'test'
      expect(finder.sort_params_for(:name)).to eq 'sort' => 'name asc', 'name' => 'test'
    end

    it 'accepts additional options' do
      finder = finder_with_sort
      expect(finder.sort_params_for(:price, name: 'value')).to eq 'sort' => 'price desc', 'name' => 'value'
    end
  end

  describe '#reverted_sort_direction' do
    it 'reverts sorting direction' do
      expect(finder_with_sort('price desc').reverted_sort_direction).to eq 'asc'
      expect(finder_with_sort('price asc').reverted_sort_direction).to eq 'desc'
    end
  end
end
