import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import StatusChart from '../StatusChart';

describe('StatusChart', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<StatusChart />);
      expect(container.querySelector('.donut-chart-container')).toBeInTheDocument();
    });
  });
});
