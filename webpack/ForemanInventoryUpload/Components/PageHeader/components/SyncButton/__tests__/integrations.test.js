import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import * as API from 'foremanReact/redux/API';
import { noop } from 'foremanReact/common/helpers';
import SyncButton from '../index';
import { successResponse } from './SyncButtonFixtures';
import {
  INVENTORY_SYNC,
  INVENTORY_SYNC_TASK_UPDATE,
} from '../SyncButtonConstants';

jest.spyOn(API, 'post');
jest.spyOn(API, 'get');

describe('SyncButton integration test', () => {
  it('Successful task was triggered on the server resulting in an info toast and polling on the task', async () => {
    API.post.mockImplementation(({ handleSuccess = noop, key, ...action }) => {
      if (key === INVENTORY_SYNC) {
        handleSuccess(successResponse);
      }
      return { type: 'API_POST', key, ...action };
    });
    API.get.mockImplementation(({ handleSuccess = noop, key, ...action }) => {
      if (key === INVENTORY_SYNC_TASK_UPDATE) {
        handleSuccess(
          {
            data: {
              endedAt: '2021-03-22T15:59:02.468+02:00',
              output: {
                host_statuses: {
                  sync: 0,
                  disconnect: 2,
                },
              },
              result: 'success',
            },
          },
          jest.fn
        );
      }
      return { type: 'API_GET', key, ...action };
    });

    const reducer = (state = {}, action) => {
      // Simple reducer for testing
      return state;
    };

    const store = createStore(reducer, applyMiddleware(thunk));

    render(
      <Provider store={store}>
        <SyncButton />
      </Provider>
    );

    const button = screen.getByText('Sync all inventory status');
    fireEvent.click(button);

    await waitFor(() => {
      expect(API.post).toHaveBeenCalledWith(
        expect.objectContaining({
          key: INVENTORY_SYNC,
        })
      );
    });
  });
});
