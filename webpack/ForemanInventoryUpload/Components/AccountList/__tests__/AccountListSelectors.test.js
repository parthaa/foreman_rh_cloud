import {
  selectAccountsList,
  selectAccounts,
  selectPollingProcessID,
} from '../AccountListSelectors';
import { pollingProcessID, accounts } from '../AccountList.fixtures';
import { rhCloudStateWrapper } from '../../../../ForemanRhCloudTestHelpers';

const state = rhCloudStateWrapper({
  accountsList: {
    accounts,
    pollingProcessID,
  },
});

describe('AccountList selectors', () => {
  it('should return AccountsList', () => {
    expect(selectAccountsList(state)).toEqual({
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
      pollingProcessID: 0,
    });
  });

  it('should return AccountList accounts', () => {
    expect(selectAccounts(state)).toEqual({
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
    });
  });

  it('should return AccountList pollingProcessID', () => {
    expect(selectPollingProcessID(state)).toBe(0);
  });
});
