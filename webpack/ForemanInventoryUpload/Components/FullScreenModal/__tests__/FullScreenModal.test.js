import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import FullScreenModal from '../FullScreenModal';

jest.mock('../../Terminal', () => ({
  __esModule: true,
  default: () => <div data-testid="terminal">Terminal</div>,
}));

describe('FullScreenModal', () => {
  it('should render without props', () => {
    render(<FullScreenModal />);

    // Modal is hidden by default (showFullScreen: false)
    expect(screen.queryByText('Full Screen')).not.toBeInTheDocument();
  });

  it('should render when showFullScreen is true', () => {
    render(<FullScreenModal showFullScreen={true} />);

    expect(screen.getByText('Full Screen')).toBeInTheDocument();
    expect(screen.getByTestId('terminal')).toBeInTheDocument();
  });
});
