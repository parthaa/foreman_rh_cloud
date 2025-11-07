import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import TabBody from '../TabBody';

jest.mock('../../ScheduledRun', () => ({
  __esModule: true,
  default: () => <div data-testid="scheduled-run">ScheduledRun</div>,
}));

describe('TabBody', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<TabBody />);
      expect(container.querySelector('.tab_body')).toBeInTheDocument();
    });
  });
});
