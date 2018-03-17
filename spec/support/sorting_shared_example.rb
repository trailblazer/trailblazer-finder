shared_examples_for 'a sorting feature' do
  describe '#sort?' do
    it 'says if the requested item is sorted on, for single sort' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort :price
      expect(finder).not_to be_sort :name
    end

    it 'says if the requested item is sorted on for multiple sorts' do
      finder = finder_with_sort 'price desc, name asc, id desc'

      expect(finder).to be_sort :price
      expect(finder).to be_sort :name
      expect(finder).to be_sort :id
      expect(finder).not_to be_sort :created_at
    end

    it 'matches string also, for single sort' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort 'price'
      expect(finder).not_to be_sort 'name'
    end

    it 'matches string also, for multiple sorts' do
      finder = finder_with_sort 'price desc, name asc, id desc'

      expect(finder).to be_sort 'price'
      expect(finder).to be_sort 'name'
      expect(finder).to be_sort 'id'
      expect(finder).not_to be_sort 'created_at'
    end

    it 'matches exact strings, for single sort' do
      finder = finder_with_sort 'price desc'

      expect(finder).to be_sort 'price desc'
      expect(finder).not_to be_sort 'price asc'
    end

    it 'matches exact strings, for multiple sort' do
      finder = finder_with_sort 'price desc, name asc'

      expect(finder).to be_sort 'price desc'
      expect(finder).to be_sort 'name asc'
      expect(finder).not_to be_sort 'name desc'
    end
  end

  describe '#sort_direction_for' do
    it 'returns desc if current sort attribute is not the given attribute' do
      expect(finder_with_sort('price desc').sort_direction_for('name')).to eq 'desc'
    end

    it 'returns asc if current sort attribute is the given attribute' do
      expect(finder_with_sort('name desc').sort_direction_for('name')).to eq 'desc'
    end

    it 'returns desc if current sort attribute is the given attribute, but asc with direction' do
      expect(finder_with_sort('name asc').sort_direction_for('name')).to eq 'asc'
    end
  end

  describe '#reverse_sort_direction_for' do
    it 'returns desc if current sort attribute is not the given attribute' do
      expect(finder_with_sort('price desc').reverse_sort_direction_for('name')).to eq 'asc'
    end

    it 'returns asc if current sort attribute is the given attribute' do
      expect(finder_with_sort('name desc').reverse_sort_direction_for('name')).to eq 'asc'
    end

    it 'returns desc if current sort attribute is the given attribute, but asc with direction' do
      expect(finder_with_sort('name asc').reverse_sort_direction_for('name')).to eq 'desc'
    end
  end

  describe '#new_sort_params_for' do
    it 'adds new sort parmas when none are present' do
      finder = finder_with_sort
      expect(finder.new_sort_params_for(:price)).to eq 'sort' => 'price desc'
    end

    it 'adds new sort params when multiple ones exists (replaces them all)' do
      finder = finder_with_sort 'name desc, price desc, id asc', name: 'test'
      expect(finder.new_sort_params_for(:name)).to eq 'sort' => 'name desc', 'name' => 'test'
    end
  end

  describe '#sort_params_for' do
    it 'adds sort direction' do
      finder = finder_with_sort 'name', name: 'test'
      expect(finder.sort_params_for(:price)).to eq 'sort' => 'price desc', 'name' => 'test'
    end

    it 'finds params for multiple sorts' do
      finder = finder_with_sort 'name desc, price desc, id asc', name: 'test'
      expect(finder.sort_params_for(:name)).to eq 'sort' => 'name desc, price desc, id asc', 'name' => 'test'
      expect(finder.sort_params_for(:price)).to eq 'sort' => 'name desc, price desc, id asc', 'name' => 'test'
    end

    it 'accepts additional options' do
      finder = finder_with_sort
      expect(finder.sort_params_for(:price, name: 'value')).to eq 'sort' => 'price desc', 'name' => 'value'
    end
  end

  describe '#add_sort_params_for' do
    it 'adds sort params when none exists' do
      finder = finder_with_sort
      expect(finder.add_sort_params_for(:price)).to eq 'sort' => 'price desc'
    end

    it 'adds sort params when one already exists' do
      finder = finder_with_sort 'name', name: 'test'
      expect(finder.add_sort_params_for(:price)).to eq 'sort' => 'name, price desc', 'name' => 'test'
    end

    it 'adds sort params when current attribute already exists, but change it' do
      finder = finder_with_sort 'name asc, price asc', name: 'test'
      expect(finder.add_sort_params_for(:price)).to eq 'sort' => 'name asc, price desc', 'name' => 'test'
    end
  end
end
