import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ReportUpload from '../ReportUpload';
import { props } from '../ReportUpload.fixtures';

jest.mock('../../ScheduledRun', () => ({
  __esModule: true,
  default: () => <div data-testid="scheduled-run">ScheduledRun</div>,
}));

describe('ReportUpload', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      render(<ReportUpload />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });

    it('should render with props', () => {
      render(<ReportUpload {...props} />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });
  });
});
