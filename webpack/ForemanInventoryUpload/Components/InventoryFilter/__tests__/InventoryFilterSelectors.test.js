import { filterTerm } from '../InventoryFilter.fixtures';
import { rhCloudStateWrapper } from '../../../../ForemanRhCloudTestHelpers';
import {
  selectInventoryFilter,
  selectFilterTerm,
} from '../InventoryFilterSelectors';

const state = rhCloudStateWrapper({
  inventoryFilter: {
    filterTerm,
  },
});

describe('InventoryFilter selectors', () => {
  it('should return InventoryFilter', () => {
    expect(selectInventoryFilter(state)).toEqual({
      filterTerm: 'test_filter_term',
    });
  });

  it('should return filterTerm', () => {
    expect(selectFilterTerm(state)).toBe('test_filter_term');
  });
});
