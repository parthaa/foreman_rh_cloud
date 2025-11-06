import {
  selectDashboard,
  selectPollingProcessID,
  selectActiveTab,
  selectUploading,
  selectGenerating,
} from '../DashboardSelectors';
import {
  logs,
  completed,
  pollingProcessID,
  activeTab,
  accountID,
} from '../Dashboard.fixtures';
import { rhCloudStateWrapper } from '../../../../ForemanRhCloudTestHelpers';

const state = rhCloudStateWrapper({
  dashboard: {
    [accountID]: {
      generating: {
        logs,
        completed,
      },
      uploading: {
        logs,
        completed,
      },
      activeTab,
      pollingProcessID,
    },
  },
});

describe('Dashboard selectors', () => {
  it('should return Dashboard', () => {
    expect(selectDashboard(state, accountID)).toEqual({
      activeTab: 'uploads',
      generating: {
        completed: 25,
        logs: ['some-logs...'],
      },
      pollingProcessID: 1,
      uploading: {
        completed: 25,
        logs: ['some-logs...'],
      },
    });
  });

  it('should return Dashboard uploading', () => {
    expect(selectUploading(state, accountID)).toEqual({
      completed: 25,
      logs: ['some-logs...'],
    });
  });

  it('should return Dashboard generating', () => {
    expect(selectGenerating(state, accountID)).toEqual({
      completed: 25,
      logs: ['some-logs...'],
    });
  });

  it('should return Dashboard pollingProcessID', () => {
    expect(selectPollingProcessID(state, accountID)).toBe(1);
  });

  it('should return Dashboard activeTab', () => {
    expect(selectActiveTab(state, accountID)).toBe('uploads');
  });
});
