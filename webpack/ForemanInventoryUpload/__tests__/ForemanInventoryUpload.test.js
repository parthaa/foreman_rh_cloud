import React from 'react';
import { render } from '@testing-library/react';
import '@testing-library/jest-dom';

import ForemanInventoryUpload from '../../ForemanInventoryUpload';

jest.mock('../../Components/AccountList', () => ({
  __esModule: true,
  default: () => <div data-testid="account-list">AccountList</div>,
}));

jest.mock('../../Components/PageHeader', () => ({
  __esModule: true,
  default: () => <div data-testid="page-header">PageHeader</div>,
}));

describe('ForemanInventoryUpload', () => {
  it('should render without props', () => {
    const { container } = render(<ForemanInventoryUpload />);
    expect(container.querySelector('.rh-cloud-inventory-page')).toBeInTheDocument();
  });
});
