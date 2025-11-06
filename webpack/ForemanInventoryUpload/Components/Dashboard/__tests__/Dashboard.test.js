import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Dashboard from '../Dashboard';
import { props } from '../Dashboard.fixtures';

jest.mock('../../NavContainer', () => ({
  __esModule: true,
  default: ({ items, showFullScreen }) => (
    <div data-testid="nav-container">
      <div data-testid="show-fullscreen">{String(showFullScreen)}</div>
      <div data-testid="items-count">{items.length}</div>
      {items.map((item, idx) => (
        <div key={idx} data-testid={`item-${idx}`}>
          <span data-testid={`item-${idx}-icon`}>{item.icon}</span>
          <span data-testid={`item-${idx}-name`}>{item.name}</span>
        </div>
      ))}
    </div>
  ),
}));

describe('Dashboard', () => {
  it('should render with props', () => {
    render(<Dashboard {...props} />);

    expect(screen.getByTestId('nav-container')).toBeInTheDocument();
    expect(screen.getByTestId('show-fullscreen')).toHaveTextContent('false');
    expect(screen.getByTestId('items-count')).toHaveTextContent('2');

    // Check first item (Generating)
    expect(screen.getByTestId('item-0-icon')).toHaveTextContent('database');
    expect(screen.getByTestId('item-0-name')).toHaveTextContent('Generating');

    // Check second item (Uploading)
    expect(screen.getByTestId('item-1-icon')).toHaveTextContent('cloud-upload');
    expect(screen.getByTestId('item-1-name')).toHaveTextContent('Uploading');
  });

  it('should call stopPolling on unmount', () => {
    const stopPolling = jest.fn();
    const modifiedProps = {
      ...props,
      stopPolling,
    };
    const { unmount } = render(<Dashboard {...modifiedProps} />);
    unmount();
    expect(stopPolling).toHaveBeenCalled();
  });
});
