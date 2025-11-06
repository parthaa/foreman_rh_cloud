import Immutable from 'seamless-immutable';
import {
  INVENTORY_POLLING_START,
  INVENTORY_POLLING,
  INVENTORY_TAB_CHANGED,
  INVENTORY_POLLING_ERROR,
} from '../DashboardConstants';
import reducer from '../DashboardReducer';
import {
  pollingProcessID,
  logs,
  activeTab,
  error,
  accountID,
  scheduled,
} from '../Dashboard.fixtures';

describe('Dashboard reducer', () => {
  const initialState = Immutable({});

  it('should return the initial state', () => {
    const result = reducer(undefined, {});
    expect(result).toEqual({});
  });

  it('should handle INVENTORY_POLLING_START', () => {
    const action = {
      type: INVENTORY_POLLING_START,
      payload: {
        pollingProcessID,
        accountID,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      'some-account-ID': {
        activeTab: 'generating',
        pollingProcessID: 1,
      },
    });
  });

  it('should handle INVENTORY_POLLING', () => {
    const action = {
      type: INVENTORY_POLLING,
      payload: {
        logs,
        accountID,
        activeTab,
        scheduled,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      'some-account-ID': {
        uploads: {
          error: null,
          logs: ['some-logs...'],
          scheduled: '2019-08-21T16:14:16.520+03:00',
        },
      },
    });
  });

  it('should handle INVENTORY_TAB_CHANGED', () => {
    const action = {
      type: INVENTORY_TAB_CHANGED,
      payload: {
        activeTab,
        accountID,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      'some-account-ID': {
        activeTab: 'uploads',
      },
    });
  });

  it('should handle INVENTORY_POLLING_ERROR', () => {
    const action = {
      type: INVENTORY_POLLING_ERROR,
      payload: {
        error,
        accountID,
        activeTab,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      'some-account-ID': {
        uploads: {
          error: 'some-error',
        },
      },
    });
  });
});
