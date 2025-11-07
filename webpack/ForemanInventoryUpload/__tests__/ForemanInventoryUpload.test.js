import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import ForemanInventoryUpload from '../../ForemanInventoryUpload';

describe('ForemanInventoryUpload', () => {
  it('should render without props', () => {
    const { container } = render(<ForemanInventoryUpload />);
    expect(container.querySelector('.foreman-inventory-upload')).toBeInTheDocument();
  });
});
