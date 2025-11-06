import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import { createStore, combineReducers } from 'redux';
import InventoryFilter from '../index';
import reducers from '../../../../ForemanRhCloudReducers';

jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanOrganization: () => ({ title: 'test-org' }),
}));

describe('InventoryFilter integration test', () => {
  it('should update filter on input change', () => {
    const store = createStore(combineReducers(reducers));

    render(
      <Provider store={store}>
        <InventoryFilter />
      </Provider>
    );

    const input = screen.getByPlaceholderText('Filter..');
    fireEvent.change(input, { target: { value: 'some_new_filter' } });

    const state = store.getState();
    expect(state.ForemanRhCloud.inventoryUpload.inventoryFilter.filterTerm).toBe('some_new_filter');
  });
});
