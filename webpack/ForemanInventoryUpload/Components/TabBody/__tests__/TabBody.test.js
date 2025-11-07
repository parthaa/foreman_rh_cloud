import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import TabBody from '../TabBody';

describe('TabBody', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<TabBody />);
      expect(container.querySelector('.tab-body')).toBeInTheDocument();
    });
  });
});
