import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import PageTitle from '../PageTitle';

jest.mock('../components/CloudPingModal', () => ({
  __esModule: true,
  default: () => <div data-testid="cloud-ping-modal">CloudPingModal</div>,
}));

describe('PageTitle', () => {
  it('should render without props', () => {
    render(<PageTitle />);

    expect(screen.getByText('Red Hat Inventory')).toBeInTheDocument();
    expect(screen.getByTestId('cloud-ping-modal')).toBeInTheDocument();
  });
});
