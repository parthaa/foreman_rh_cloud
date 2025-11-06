import { API } from 'foremanReact/redux/API';
import {
  fetchAccountsStatus,
  startAccountStatusPolling,
  stopAccountStatusPolling,
  restartProcess,
} from '../AccountListActions';
import {
  pollingProcessID,
  fetchAccountsStatusResponse,
} from '../AccountList.fixtures';
import { accountID, activeTab } from '../../Dashboard/Dashboard.fixtures';

jest.mock('foremanReact/redux/API');
API.get.mockImplementation(async () => fetchAccountsStatusResponse);

describe('AccountList actions', () => {
  it('should fetchAccountsStatus', async () => {
    const dispatch = jest.fn();
    await fetchAccountsStatus()(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_ACCOUNT_STATUS_POLLING',
      payload: {
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
        CloudConnectorStatus: {
          id: 7,
          task: {
            id: 11,
          },
        },
      },
    });
  });

  it('should startAccountStatusPolling', () => {
    const action = startAccountStatusPolling(pollingProcessID);
    expect(action).toEqual({
      type: 'INVENTORY_ACCOUNT_STATUS_POLLING_START',
      payload: {
        pollingProcessID: 0,
      },
    });
  });

  it('should stopAccountStatusPolling', () => {
    const dispatch = jest.fn();
    stopAccountStatusPolling(pollingProcessID)(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_ACCOUNT_STATUS_POLLING_STOP',
    });
  });

  it('should restartProcess', async () => {
    const dispatch = jest.fn();
    await restartProcess(accountID, activeTab)(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_PROCESS_RESTART',
      payload: {
        accountID: 'some-account-ID',
        processStatusName: 'generate_report_status',
      },
    });
  });

  it('should invoke toast notification upon failure', async () => {
    API.post.mockImplementationOnce(() =>
      Promise.reject(new Error('test error'))
    );

    const dispatch = jest.fn();
    await restartProcess(accountID, activeTab)(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'TOASTS_ADD',
      payload: {
        message: {
          message: 'test error',
          type: 'error',
          sticky: true,
        },
      },
    });
  });
});
