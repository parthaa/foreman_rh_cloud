import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import TabFooter from '../TabFooter';

describe('TabFooter', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<TabFooter />);
      expect(container.querySelector('.tab-footer')).toBeInTheDocument();
    });
  });
});
