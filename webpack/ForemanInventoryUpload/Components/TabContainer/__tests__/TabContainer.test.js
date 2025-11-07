import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import TabContainer from '../TabContainer';

describe('TabContainer', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<TabContainer />);
      expect(container.querySelector('.tab-container')).toBeInTheDocument();
    });
  });
});
