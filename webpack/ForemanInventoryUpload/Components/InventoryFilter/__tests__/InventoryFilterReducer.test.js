import Immutable from 'seamless-immutable';
import reducer from '../InventoryFilterReducer';
import { filterTerm } from '../InventoryFilter.fixtures';
import {
  INVENTORY_FILTER_UPDATE,
  INVENTORY_FILTER_CLEAR,
} from '../InventoryFilterConstants';

describe('InventoryFilter reducer', () => {
  const initialState = Immutable({
    filterTerm: '',
  });

  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      filterTerm: '',
    });
  });

  it('should handle INVENTORY_FILTER_UPDATE', () => {
    const action = {
      type: INVENTORY_FILTER_UPDATE,
      payload: {
        filterTerm,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      filterTerm: 'test_filter_term',
    });
  });

  it('should handle INVENTORY_FILTER_CLEAR', () => {
    const action = {
      type: INVENTORY_FILTER_CLEAR,
      payload: {},
    };
    expect(reducer(initialState, action)).toEqual({
      filterTerm: '',
    });
  });
});
