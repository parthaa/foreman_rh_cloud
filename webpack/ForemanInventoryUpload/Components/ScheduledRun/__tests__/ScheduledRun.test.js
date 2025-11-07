import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import ScheduledRun from '../ScheduledRun';
import { props } from '../ScheduledRun.fixtures';

describe('ScheduledRun', () => {
  describe('rendering', () => {
    it('should render with props', () => {
      render(<ScheduledRun {...props} />);
      expect(screen.getByText(/scheduled task is configured/i)).toBeInTheDocument();
    });
  });
});
