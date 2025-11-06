import Immutable from 'seamless-immutable';
import {
  INVENTORY_ACCOUNT_STATUS_POLLING,
  INVENTORY_ACCOUNT_STATUS_POLLING_START,
  INVENTORY_ACCOUNT_STATUS_POLLING_STOP,
  INVENTORY_ACCOUNT_STATUS_POLLING_ERROR,
  INVENTORY_PROCESS_RESTART,
} from '../AccountListConstants';
import reducer from '../AccountListReducer';
import {
  error,
  pollingProcessID,
  accountID,
  processStatusName,
  pollingResponse,
} from '../AccountList.fixtures';

describe('AccountList reducer', () => {
  const initialState = Immutable({
    accounts: {},
    pollingProcessID: 0,
    error: null,
  });

  it('should return the initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      accounts: {},
      error: null,
      pollingProcessID: 0,
    });
  });

  it('should handle INVENTORY_ACCOUNT_STATUS_POLLING', () => {
    const action = {
      type: INVENTORY_ACCOUNT_STATUS_POLLING,
      payload: pollingResponse,
    };
    expect(reducer(initialState, action)).toEqual({
      CloudConnectorStatus: {
        id: 7,
        task: {
          id: 11,
        },
      },
      accounts: {
        Account1: {
          generate_report_status: 'running',
          id: 1,
          upload_report_status: 'running',
        },
        Account2: {
          generate_report_status: 'failure',
          id: 2,
          upload_report_status: 'unknown',
        },
        Account3: {
          generate_report_status: 'running',
          id: 3,
          upload_report_status: 'success',
        },
      },
      error: null,
      pollingProcessID: 0,
    });
  });

  it('should handle INVENTORY_ACCOUNT_STATUS_POLLING_ERROR', () => {
    const action = {
      type: INVENTORY_ACCOUNT_STATUS_POLLING_ERROR,
      payload: { error },
    };
    expect(reducer(initialState, action)).toEqual({
      accounts: {},
      error: 'some-error',
      pollingProcessID: 0,
    });
  });

  it('should handle INVENTORY_ACCOUNT_STATUS_POLLING_START', () => {
    const action = {
      type: INVENTORY_ACCOUNT_STATUS_POLLING_START,
      payload: {
        pollingProcessID,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      accounts: {},
      error: null,
      pollingProcessID: 0,
    });
  });

  it('should handle INVENTORY_ACCOUNT_STATUS_POLLING_STOP', () => {
    const action = {
      type: INVENTORY_ACCOUNT_STATUS_POLLING_STOP,
    };
    expect(reducer(initialState, action)).toEqual({
      accounts: {},
      error: null,
      pollingProcessID: 0,
    });
  });

  it('should handle INVENTORY_PROCESS_RESTART', () => {
    const action = {
      type: INVENTORY_PROCESS_RESTART,
      payload: {
        accountID,
        processStatusName,
      },
    };
    expect(reducer(initialState, action)).toEqual({
      accounts: {
        'user@redhat.com': {
          upload_report_status: 'Restarting...',
        },
      },
      error: null,
      pollingProcessID: 0,
    });
  });
});
