import { API } from 'foremanReact/redux/API';
import {
  startPolling,
  stopPolling,
  fetchLogs,
  setActiveTab,
  downloadReports,
  toggleFullScreen,
} from '../DashboardActions';
import {
  pollingProcessID,
  serverMock,
  activeTab,
  accountID,
} from '../Dashboard.fixtures';
import { rhCloudStateWrapper } from '../../../../ForemanRhCloudTestHelpers';

jest.mock('foremanReact/redux/API');
API.get.mockImplementation(() => serverMock);

const runWithGetState = (state, action, params) => dispatch => {
  const getState = () => rhCloudStateWrapper({ dashboard: state });
  action(params)(dispatch, getState);
};

describe('Dashboard actions', () => {
  const { open } = window;

  beforeAll(() => {
    delete window.open;
    window.open = jest.fn();
  });

  afterAll(() => {
    window.open = open;
  });

  it('should startPolling', () => {
    const action = startPolling(accountID, pollingProcessID);
    expect(action).toEqual({
      type: 'INVENTORY_POLLING_START',
      payload: {
        accountID: 'some-account-ID',
        pollingProcessID: 1,
      },
    });
  });

  it('should fetchLogs', async () => {
    const dispatch = jest.fn();
    const action = runWithGetState({}, fetchLogs, accountID);
    await action(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_POLLING',
      payload: {
        accountID: 'some-account-ID',
        activeTab: 'generating',
        logs: ['some-logs', 'some-logs'],
        scheduled: '2019-08-21T16:14:16.520+03:00',
      },
    });
  });

  it('should stopPolling', () => {
    const dispatch = jest.fn();
    const action = stopPolling(accountID, pollingProcessID);
    action(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_POLLING_STOP',
      payload: {
        accountID: 'some-account-ID',
      },
    });
  });

  it('should setActiveTab', () => {
    const action = setActiveTab(accountID, activeTab);
    expect(action).toEqual({
      type: 'INVENTORY_TAB_CHANGED',
      payload: {
        accountID: 'some-account-ID',
        activeTab: 'uploads',
      },
    });
  });

  it('should downloadReports', () => {
    const action = downloadReports(accountID);
    expect(action).toEqual({
      type: 'INVENTORY_REPORTS_DOWNLOAD',
      payload: {
        accountID: 'some-account-ID',
      },
    });
  });

  it('should toggleFullScreen', () => {
    const dispatch = jest.fn();
    const action = runWithGetState({}, toggleFullScreen, accountID);
    action(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: 'INVENTORY_TOGGLE_TERMINAL_FULL_SCREEN',
      payload: {
        accountID: 'some-account-ID',
        activeTab: 'generating',
      },
    });
  });
});
