import {
  handleFilterChange,
  handleFilterClear,
} from '../InventoryFilterActions';
import { filterTerm } from '../InventoryFilter.fixtures';

describe('InventoryFilter actions', () => {
  it('should handleFilterChange', () => {
    const action = handleFilterChange(filterTerm);
    expect(action).toEqual({
      type: 'INVENTORY_FILTER_UPDATE',
      payload: {
        filterTerm: 'test_filter_term',
      },
    });
  });

  it('should handleFilterClear', () => {
    const action = handleFilterClear();
    expect(action).toEqual({
      type: 'INVENTORY_FILTER_CLEAR',
      payload: {},
    });
  });
});
