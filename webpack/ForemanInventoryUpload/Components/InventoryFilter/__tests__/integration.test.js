import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { Provider } from 'react-redux';
import { createStore, combineReducers } from 'redux';
import InventoryFilter from '../index';
import reducers from '../../../../ForemanRhCloudReducers';

jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanOrganization: () => ({ title: 'test-org' }),
}));

describe('InventoryFilter integration test', () => {
  it('should update filter on input change', async () => {
    const store = createStore(combineReducers({ ForemanRhCloud: reducers }));
    const user = userEvent.setup();

    render(
      <Provider store={store}>
        <InventoryFilter />
      </Provider>
    );

    const input = screen.getByPlaceholderText('Filter..');
    await user.clear(input);
    await user.type(input, 'some_new_filter');

    const state = store.getState();
    expect(state.ForemanRhCloud.inventoryFilter.filterTerm).toBe('some_new_filter');
  });
});
